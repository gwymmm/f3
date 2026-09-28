with Ada.Directories;
with Ada.Directories.Hierarchical_File_Names;
with Ada.Text_IO;
with Forecasts.Lexer;

package body Forecasts is

  procedure Search_For_Files_Recursively(Folder_Name: in String; Relevant_Extension: in String; List_Of_File_Names: in out Strings.List) is

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

    Print_Info("Searching for files in " & Folder_Name & " folder...");

    while More_Entries(File_Search) loop
      Get_Next_Entry(File_Search, Found_File);
      if Extension(Full_Name(Found_File)) = Relevant_Extension then
        Strings.Append(List_Of_File_Names, To_Unbounded_String(Full_Name(Found_File)));
        Print_More("File found: " & Full_Name(Found_File));
      end if;
    end loop;


    Start_Search(Directory_Search, Folder_Name, "", Directory_Filter);

    while More_Entries(Directory_Search) loop
      Get_Next_Entry(Directory_Search, Found_Directory);

      if Is_Parent_Directory_Name(Simple_Name(Found_Directory)) or Is_Current_Directory_Name(Simple_Name(Found_Directory)) then
        null;
      else
        Print_Info("Notable directory found: " & Full_Name(Found_Directory));
        Search_For_Files_Recursively(Full_Name(Found_Directory), Relevant_Extension, List_Of_File_Names);
      end if;

    end loop;

  end Search_For_Files_Recursively;


  procedure Evaluate_Forecasts(Input_Folder_Name: in String; Status: out Program_Status) is
    use Ada.Directories;

    Prediction_File_Names: Strings.List;
    Outcome_File_Names: Strings.List;

    Forecasting_Challenge_Table: Forecasting_Challenge_Table_Type;

    type Prediction_File_Metadata_Type is
      record
        Input_File_Name: Ada.Strings.Unbounded.Unbounded_String;
        Challenge_Name: Ada.Strings.Unbounded.Unbounded_String;
        Forecaster_Name: Ada.Strings.Unbounded.Unbounded_String;
      end record;

    package Prediction_Files_Data is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Prediction_File_Metadata_Type, "=" => "=");

    type Outcome_File_Metadata_Type is
      record
        Input_File_Name: Ada.Strings.Unbounded.Unbounded_String;
        Challenge_Name: Ada.Strings.Unbounded.Unbounded_String;
      end record;

    package Outcome_Files_Data is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Outcome_File_Metadata_Type, "=" => "=");

    Outcome_File_Metadata: Outcome_Files_Data.List;
    Prediction_File_Metadata: Prediction_Files_Data.List;

    DUMMY_INDEX: Positive := Positive'Last;

  begin

    if not Exists(Input_Folder_Name) then
      Print_Error("Directory does not exist: " & Input_Folder_Name);
      Status := Failure;
      return;
    end if;

    if Kind(Input_Folder_Name) /= Directory then
      Print_Error(Input_Folder_Name & " is not a directory.");
      Status := Failure;
      return;
    end if;

    Print_Info("Folder ready to be processed: " & Input_Folder_Name);

    -- gather input files
    Search_For_Files_Recursively(Input_Folder_Name, "Predictions", Prediction_File_Names);
    Search_For_Files_Recursively(Input_Folder_Name, "Outcomes", Outcome_File_Names);

    for C in Outcome_File_Names.Iterate loop
      --Print_Info("Outcome File listed: " & Ada.Strings.Unbounded.To_String(Outcome_File_Names(C)) );
      declare
        Temp_Data: Outcome_File_Metadata_Type;
        Temp_Base_Name: String := Ada.Directories.Base_Name( Ada.Strings.Unbounded.To_String(Outcome_File_Names(C)) );
      begin
        Temp_Data.Input_File_Name := Outcome_File_Names(C);
        Temp_Data.Challenge_Name := Ada.Strings.Unbounded.To_Unbounded_String(Temp_Base_Name);
        Outcome_Files_Data.Append(Outcome_File_Metadata, Temp_Data);

        if Name_To_Table_Index_Maps.Contains(Forecasting_Challenge_Table.Challenge_Name_To_Idx_Map, Key => Temp_Data.Challenge_Name) then
          Print_Error("Challenge with name '" & Temp_Base_Name & "' already defined");
          Print_More("Duplicate found in input file: " & Ada.Strings.Unbounded.To_String(Temp_Data.Input_File_Name));
          Status := Failure;
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

    -- populate forecast table

    Status := Success;
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

end Forecasts;
