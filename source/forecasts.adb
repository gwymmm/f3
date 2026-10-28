with Ada.Directories;
with Ada.Directories.Hierarchical_File_Names;
with Forecasts.Lexer;
with Forecasts.Test;
with Ada.Strings.Fixed;

package body Forecasts is

  procedure Search_For_Files_Recursively(Folder_Name: in String; Relevant_Extension: in String; List_Of_File_Names: in out Strings.List;
    Debug: in Boolean) is

    use Ada.Directories;
    use Ada.Directories.Hierarchical_File_Names;
    use Ada.Strings.Unbounded;

    File_Search: Search_Type;
    File_Filter: constant Filter_Type := (Ordinary_File => True, others => False);
    Found_File: Directory_Entry_Type;

    Directory_Search: Search_Type;
    Directory_Filter: constant Filter_Type := (Directory => True, others => False);
    Found_Directory: Directory_Entry_Type;

  begin

    Start_Search(File_Search, Folder_Name, "", File_Filter);

    if Debug then
      Print_Info("Searching for files in " & Folder_Name & " folder...");
    end if;

    while More_Entries(File_Search) loop
      Get_Next_Entry(File_Search, Found_File);
      if Extension(Full_Name(Found_File)) = Relevant_Extension then
        Strings.Append(List_Of_File_Names, To_Unbounded_String(Full_Name(Found_File)));
        if Debug then
            Print_Info("Relevant file found: " & Full_Name(Found_File));
        end if;
      end if;
    end loop;


    Start_Search(Directory_Search, Folder_Name, "", Directory_Filter);

    while More_Entries(Directory_Search) loop
      Get_Next_Entry(Directory_Search, Found_Directory);

      if Is_Parent_Directory_Name(Simple_Name(Found_Directory)) or Is_Current_Directory_Name(Simple_Name(Found_Directory)) then
        null;
      else
        if Debug then
          Print_Info("Continue search in directory: " & Full_Name(Found_Directory));
        end if;
        Search_For_Files_Recursively(Full_Name(Found_Directory), Relevant_Extension, List_Of_File_Names, Debug);
      end if;

    end loop;

  end Search_For_Files_Recursively;


  function Split(U_String: in Ada.Strings.Unbounded.Unbounded_String; Pattern: in String) return Strings.List is

    Result: Strings.List;
    Current_Index: Natural;
    Current_Left_Border: Positive := 1;
    Current_Right_Border: Natural;
    Pattern_Length: constant Natural := Pattern'Length;

    use Ada.Strings.Unbounded;
    Temp_String: Unbounded_String := Null_Unbounded_String;
    U_String_Length: constant Natural := Length(U_String);

  begin

    if Length(U_String) = 0 then
      return Result;
    end if;

    Current_Index := Index(U_String, Pattern);

    if Current_Index = 0 then
      return Result;
    end if;

-- length >= 1 and index >= 1

    loop

      pragma Assert (Current_Index >= Current_Left_Border);
      Current_Right_Border := Current_Index - 1;

      if Current_Right_Border < Current_Left_Border then
        null;
      elsif Current_Right_Border = Current_Left_Border then
        Append(Temp_String, Element(U_String, Current_Left_Border) );
      else -- Current_Right_Border > Current_Left_Border
        Unbounded_Slice(Source => U_String, Target => Temp_String, Low => Current_Left_Border, High => Current_Right_Border);
      end if;

      Strings.Append(Result, Temp_String);
      Temp_String := Null_Unbounded_String;
      Current_Left_Border := Current_Index + Pattern_Length;

      if Current_Left_Border > U_String_Length then
        Strings.Append(Result, Temp_String);
        exit;
      end if;

      Current_Index := Index(U_String, Pattern, From => Current_Left_Border);

      if Current_Index = 0 then
        Unbounded_Slice(Source => U_String, Target => Temp_String, Low => Current_Left_Border, High => U_String_Length);
        Strings.Append(Result, Temp_String);
        exit;
      end if;

    end loop;

    return Result;
  end Split;

--##########################################################################################################################
  procedure Evaluate_Forecasts(Input_Folder_Name: in String; Program_Parameter: in out Program_Parameter_Type) is
    Forecasting_Challenge_Table: Forecasting_Challenge_Table_Type;
  begin

    Init_Forecasting_Challenge_Table(Input_Folder_Name, Program_Parameter, Forecasting_Challenge_Table);

    if Program_Parameter.Current_Program_Status = Failure then
      return;
    end if;

    Print_Forecasting_Challenge_Table(Program_Parameter, Forecasting_Challenge_Table);

  end Evaluate_Forecasts;

--##########################################################################################################################
  procedure Init_Forecasting_Challenge_Table(Input_Folder_Name: in String;
                                             Program_Parameter: in out Program_Parameter_Type;
                                             Forecasting_Challenge_Table: out Forecasting_Challenge_Table_Type) is
    use Ada.Directories;

    Prediction_File_Names: Strings.List;
    Outcome_File_Names: Strings.List;

    Outcome_File_Metadata: Outcome_Files_Data.List;
    Prediction_File_Metadata: Prediction_Files_Data.List;

    DUMMY_INDEX: constant Positive := Positive'Last;

    Number_Of_Challenges: Ada.Containers.Count_Type;
    Number_Of_Forecasters: Ada.Containers.Count_Type;

    Initial_Score_Record: Forecasting_Score_Record;

    Initial_Forecasting_Challenge: constant Forecasting_Challenge_Type := (Questions_Answered => False,
      Prediction_File_Name => Ada.Strings.Unbounded.To_Unbounded_String("???"),
      Challenge_Questions => Forecasting_Questions.Empty_List,
      Score_Results => Initial_Score_Record);

    Initial_Challenge_Table_Column: Challenges.Vector;

    use type Ada.Containers.Count_Type;

  begin

    if Program_Parameter.Debug then
      Print_Info("Checking input folder...");
    end if;

    if not Exists(Input_Folder_Name) then
      Print_Error("Directory does not exist: " & Input_Folder_Name);
      Program_Parameter.Current_Program_Status := Failure;
      return;
    end if;

    if Kind(Input_Folder_Name) /= Directory then
      Print_Error(Input_Folder_Name & " is not a directory.");
      Program_Parameter.Current_Program_Status := Failure;
      return;
    end if;

    -- gather input files
    if Program_Parameter.Debug then
      Print_Delimiter;
      Print_Info("Gathering prediction files in folder: " & Input_Folder_Name);
    end if;

    Search_For_Files_Recursively(Input_Folder_Name, "Predictions", Prediction_File_Names, Program_Parameter.Debug);

    if Program_Parameter.Debug then
      Print_Delimiter;
      Print_Info("Gathering outcome files in folder: " & Input_Folder_Name);
    end if;

    Search_For_Files_Recursively(Input_Folder_Name, "Outcomes", Outcome_File_Names, Program_Parameter.Debug);

    if Program_Parameter.Debug then
      Print_Delimiter;
    end if;

    if Strings.Length(Outcome_File_Names) = 0 then
      Print_Error("No outcome files found in input directory");
      Program_Parameter.Current_Program_Status := Failure;
      return;
    end if;

    for C in Outcome_File_Names.Iterate loop
      --Print_Info("Outcome File listed: " & Ada.Strings.Unbounded.To_String(Outcome_File_Names(C)) );
      declare
        Temp_Data: Outcome_File_Metadata_Type;
        Temp_Base_Name: String := Ada.Directories.Base_Name( Ada.Strings.Unbounded.To_String(Outcome_File_Names(C)) );
      begin
        Temp_Data.Input_File_Name := Outcome_File_Names(C);
        Temp_Data.Challenge_Name := Ada.Strings.Unbounded.To_Unbounded_String(Temp_Base_Name);

        if Ada.Strings.Unbounded.Index(Temp_Data.Challenge_Name, "-") > 0 then
          Print_Error("Character '-' not allowed in name of '.Outcomes' file: " & Ada.Strings.Unbounded.To_String(Temp_Data.Input_File_Name) );
          Print_More("Character '-' is the delimiter between challenge and forecast name in '.Predictions' files");
          Program_Parameter.Current_Program_Status := Failure;
          return;
        end if;

        Outcome_Files_Data.Append(Outcome_File_Metadata, Temp_Data);

        if Name_To_Table_Index_Maps.Contains(Forecasting_Challenge_Table.Challenge_Name_To_Idx_Map, Key => Temp_Data.Challenge_Name) then
          Print_Error("Duplicate found in input file: " & Ada.Strings.Unbounded.To_String(Temp_Data.Input_File_Name));
          Print_More("Challenge with name '" & Temp_Base_Name & "' already defined");
          Program_Parameter.Current_Program_Status := Failure;
          return;
        else
          Name_To_Table_Index_Maps.Insert(Forecasting_Challenge_Table.Challenge_Name_To_Idx_Map,
            Key => Temp_Data.Challenge_Name,
            New_Item => DUMMY_INDEX);
        end if;

      end; -- end declare

    end loop;

    if Program_Parameter.Debug then
      Test.Print_Outcome_Files_List(Outcome_File_Metadata);
      Print_Delimiter;
    end if;

    if Strings.Length(Prediction_File_Names) = 0 then
      Print_Error("No prediction files found in input directory");
      Program_Parameter.Current_Program_Status := Failure;
      return;
    end if;

    for C in Prediction_File_Names.Iterate loop
      -- Print_Info("Prediction File listed: " & Ada.Strings.Unbounded.To_String(Prediction_File_Names(C)) );

      declare
        Temp_Data: Prediction_File_Metadata_Type;
        Temp_Base_Name: String := Ada.Directories.Base_Name( Ada.Strings.Unbounded.To_String(Prediction_File_Names(C)) );
        String_Split_Result: Strings.List;
        use type Ada.Strings.Unbounded.Unbounded_String;
      begin
        Temp_Data.Input_File_Name := Prediction_File_Names(C);
        String_Split_Result := Split( Ada.Strings.Unbounded.To_Unbounded_String(Temp_Base_Name), "-");

        if Strings.Length(String_Split_Result) /= 2 or else
          ( Strings.First_Element(String_Split_Result) = Ada.Strings.Unbounded.Null_Unbounded_String or
            Strings.Last_Element(String_Split_Result) = Ada.Strings.Unbounded.Null_Unbounded_String) then
          Print_Error("Wrong name of input file: " & Ada.Strings.Unbounded.To_String(Temp_Data.Input_File_Name));
          Print_More("Expected name format for prediction files is: Challenge_Name-Forecaster_Name.Predictions " &
            "(use character '-' as delimiter)");
          Program_Parameter.Current_Program_Status := Failure;
          return;
        end if;

        Temp_Data.Challenge_Name := Strings.First_Element(String_Split_Result);
        Temp_Data.Forecaster_Name := Strings.Last_Element(String_Split_Result);
        Prediction_Files_Data.Append(Prediction_File_Metadata, Temp_Data);

        if not Name_To_Table_Index_Maps.Contains(Forecasting_Challenge_Table.Challenge_Name_To_Idx_Map, Key => Temp_Data.Challenge_Name) then
          Print_Error("Unknown challenge name in input file: " & Ada.Strings.Unbounded.To_String(Temp_Data.Input_File_Name));
          Print_More("No outcomes file exists for challenge with name '" & Ada.Strings.Unbounded.To_String(Temp_Data.Challenge_Name) & "'");
          Program_Parameter.Current_Program_Status := Failure;
          return;
        end if;

        if not Name_To_Table_Index_Maps.Contains(Forecasting_Challenge_Table.Forecaster_Name_To_Idx_Map, Key => Temp_Data.Forecaster_Name) then
          Name_To_Table_Index_Maps.Insert(Forecasting_Challenge_Table.Forecaster_Name_To_Idx_Map,
            Key => Temp_Data.Forecaster_Name,
            New_Item => DUMMY_INDEX);
        end if;
      end; -- end declare

    end loop;

    if Program_Parameter.Debug then
      Test.Print_Prediction_Files_List(Prediction_File_Metadata);
      Print_Delimiter;
    end if;

    -- populate forecast table
    declare
      Current_Challenge_Index: Positive := 1;
      use Name_To_Table_Index_Maps;
    begin

      Number_Of_Challenges := Length(Forecasting_Challenge_Table.Challenge_Name_To_Idx_Map);
      Table_Index_To_Name_Vectors.Reserve_Capacity(Forecasting_Challenge_Table.Challenge_Names, Number_Of_Challenges);

      for C in Forecasting_Challenge_Table.Challenge_Name_To_Idx_Map.Iterate loop
        Replace_Element(Forecasting_Challenge_Table.Challenge_Name_To_Idx_Map, C, Current_Challenge_Index);
        -- Print_Info("Processing node: key -> " & Ada.Strings.Unbounded.To_String(Key(C)) & ", value -> " & Element(C)'Image);
        Current_Challenge_Index := Current_Challenge_Index + 1;
        Table_Index_To_Name_Vectors.Append(Forecasting_Challenge_Table.Challenge_Names, Key(C));
      end loop;

    end; -- end declare

    Initial_Challenge_Table_Column := Challenges.To_Vector(Initial_Forecasting_Challenge, Number_Of_Challenges);
    Forecasting_Challenge_Table.Outcomes := Initial_Challenge_Table_Column;

    declare
      Current_Forecaster_Index: Positive := 1;
      use Name_To_Table_Index_Maps;
    begin

      Number_Of_Forecasters := Length(Forecasting_Challenge_Table.Forecaster_Name_To_Idx_Map);
      Table_Index_To_Name_Vectors.Reserve_Capacity(Forecasting_Challenge_Table.Forecaster_Names, Number_Of_Forecasters);

      for C in Forecasting_Challenge_Table.Forecaster_Name_To_Idx_Map.Iterate loop
        Replace_Element(Forecasting_Challenge_Table.Forecaster_Name_To_Idx_Map, C, Current_Forecaster_Index);
        -- Print_Info("Processing node: key -> " & Ada.Strings.Unbounded.To_String(Key(C)) & ", value -> " & Element(C)'Image);
        Current_Forecaster_Index := Current_Forecaster_Index + 1;
        Table_Index_To_Name_Vectors.Append(Forecasting_Challenge_Table.Forecaster_Names, Key(C));
      end loop;

    end; -- end declare

    Forecasting_Challenge_Table.Overall_Score_Results := Forecasting_Score_Records.To_Vector(Initial_Score_Record, Number_Of_Forecasters);
    Forecasting_Challenge_Table.Forecaster_Predictions := Challenge_Table_Columns.To_Vector(Initial_Challenge_Table_Column, Number_Of_Forecasters);

    Forecasting_Challenge_Table.Number_Of_Forecasters := Positive(Number_Of_Forecasters);
    Forecasting_Challenge_Table.Number_Of_Challenges := Positive(Number_Of_Challenges);

    Program_Parameter.Current_Program_Status := Success;
    return;

  end Init_Forecasting_Challenge_Table;

--##########################################################################################################################

  procedure Print_Forecasting_Challenge_Table(Program_Parameter: in out Program_Parameter_Type;
                                              Forecasting_Challenge_Table: in Forecasting_Challenge_Table_Type) is

    use Ada.Strings.Fixed;
    use Ada.Text_IO;
    Overall_Score_Results_Row_Name: constant String := "ALL";
    Row_Names_Column_Width: Natural := Overall_Score_Results_Row_Name'Length;

    -- number format is ' 1.123' and consists of 6 characters

    Initial_Column_Width: constant Natural := 6;
    Empty_Entry_Symbol: constant String := " /    ";
    Column_Delimiter: constant String := "  ";

    type Column_Widths_Type is array (Positive range <>) of Positive;
    Column_Widths: Column_Widths_Type(1 .. Forecasting_Challenge_Table.Number_Of_Forecasters);

  begin

    Float_Type_IO.Default_Fore := 2;
    Float_Type_IO.Default_Aft := 3;
    Float_Type_IO.Default_Exp := 0;

    for N of Forecasting_Challenge_Table.Challenge_Names loop
      if Ada.Strings.Unbounded.Length(N) > Row_Names_Column_Width then
        Row_Names_Column_Width := Ada.Strings.Unbounded.Length(N);
      end if;
    end loop;

    -- print table header
    Put( ( Row_Names_Column_Width * " " ) & Column_Delimiter);

    for K in 1 .. Forecasting_Challenge_Table.Number_Of_Forecasters loop

      declare
        Column_Name: constant Ada.Strings.Unbounded.Unbounded_String
            := Table_Index_To_Name_Vectors.Element(Forecasting_Challenge_Table.Forecaster_Names, K);
        Name_Length: constant Natural := Ada.Strings.Unbounded.Length(Column_Name);
      begin

        Put( Ada.Strings.Unbounded.To_String(Column_Name) );

        if Name_Length > Initial_Column_Width then
          Column_Widths(K) := Name_Length;
        else
          Column_Widths(K) := Initial_Column_Width;
          Put( (Initial_Column_Width - Name_Length) * " " );
        end if;

        if K < Forecasting_Challenge_Table.Number_Of_Forecasters then
          Put(Column_Delimiter);
        end if;
      end; -- end declare

    end loop;

  end Print_Forecasting_Challenge_Table;

--##########################################################################################################################

  procedure Print_Error(Error_Message: in String) is
  begin
    Ada.Text_IO.Put_Line("Error: " & Error_Message);
  end Print_Error;


  procedure Print_Info(Info_Message: in String) is
  begin
    Ada.Text_IO.Put_Line(Info_Message);
  end Print_Info;


  procedure Print_More(Additional_Info: in String) is
  begin
    Ada.Text_IO.Put_Line("    " & Additional_Info);
  end Print_More;

  procedure Print_Delimiter is
  begin
    Ada.Text_IO.New_Line;
    Ada.Text_IO.Put_Line("    ####  COMPUTATION SECTION  ####");
    Ada.Text_IO.New_Line;
  end Print_Delimiter;

end Forecasts;
