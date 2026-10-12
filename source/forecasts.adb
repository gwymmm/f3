with Ada.Directories;
with Ada.Directories.Hierarchical_File_Names;
with Ada.Text_IO;
with Forecasts.Lexer;
with Forecasts.Test;

package body Forecasts is

  procedure Search_For_Files_Recursively(Folder_Name: in String; Relevant_Extension: in String; List_Of_File_Names: in out Strings.List;
    Debug: in Boolean) is

    use Ada.Directories;
    use Ada.Directories.Hierarchical_File_Names;
    use Strings;
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

      --exit when Current_Left_Border > U_String_Length;

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


  procedure Evaluate_Forecasts(Input_Folder_Name: in String; Program_Parameter: in out Program_Parameter_Type) is
    use Ada.Directories;

    Prediction_File_Names: Strings.List;
    Outcome_File_Names: Strings.List;

    Forecasting_Challenge_Table: Forecasting_Challenge_Table_Type;

    Outcome_File_Metadata: Outcome_Files_Data.List;
    Prediction_File_Metadata: Prediction_Files_Data.List;

    DUMMY_INDEX: Positive := Positive'Last;

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

      end;

    end loop;

    for C in Prediction_File_Names.Iterate loop
      Print_Info("Prediction File listed: " & Ada.Strings.Unbounded.To_String(Prediction_File_Names(C)) );
    end loop;

    if Program_Parameter.Debug then
      Print_Delimiter;
    end if;

    Test.Test_String_Split;

    -- populate forecast table

    Program_Parameter.Current_Program_Status := Success;
    return;

  end Evaluate_Forecasts;


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
