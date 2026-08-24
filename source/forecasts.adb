with Ada.Directories;
with Ada.Directories.Hierarchical_File_Names;
with Ada.Text_IO;
with Forecasts.Lexer;

package body Forecasts is

  procedure Search_For_Files_Recursively(Folder_Name: in String; Pattern: in String; List_Of_File_Names: in out Strings.List) is

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

    Start_Search(File_Search, Folder_Name, Pattern, File_Filter);

    --Print_Info("Searching for files in " & Folder_Name & " folder...");

    while More_Entries(File_Search) loop
      Get_Next_Entry(File_Search, Found_File);
      Strings.Append(List_Of_File_Names, To_Unbounded_String(Full_Name(Found_File)));
      --Print_More("File found: " & Full_Name(Found_File));
    end loop;


    Start_Search(Directory_Search, Folder_Name, "", Directory_Filter);

    while More_Entries(Directory_Search) loop
      Get_Next_Entry(Directory_Search, Found_Directory);

      if Is_Parent_Directory_Name(Simple_Name(Found_Directory)) or Is_Current_Directory_Name(Simple_Name(Found_Directory)) then
        null;
      else
        --Print_Info("Notable directory found: " & Full_Name(Found_Directory));
        Search_For_Files_Recursively(Full_Name(Found_Directory), Pattern, List_Of_File_Names);
      end if;

    end loop;

  end Search_For_Files_Recursively;


  procedure Gather_Input_Files(Source_Folder_Name: in String;
                               Prediction_File_Names: out Strings.List;
                               Outcome_File_Names: out Strings.List) is

  begin

    Prediction_File_Names := Strings.Empty_List;
    Outcome_File_Names := Strings.Empty_List;
    Search_For_Files_Recursively(Source_Folder_Name, "*.Predictions", Prediction_File_Names);
    Search_For_Files_Recursively(Source_Folder_Name, "*.Outcomes", Outcome_File_Names);

  end Gather_Input_Files;


  procedure Evaluate_Forecasts(Input_Folder_Name: in String; Status: out Program_Status) is
    use Ada.Directories;

    Prediction_File_Names: Strings.List;
    Outcome_File_Names: Strings.List;

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

    Gather_Input_Files(Input_Folder_Name, Prediction_File_Names, Outcome_File_Names);

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
