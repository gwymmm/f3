with Ada.Directories;
with Ada.Text_IO;
with Forecasts.Lexer;

package body Forecasts is

  procedure Gather_Input_Files(Source_Folder_Name: in String;
    Prediction_File_Names: out Strings.List;
    Outcome_File_Names: out Strings.List) is

  begin
    null;
  end Gather_Input_Files;


  procedure Evaluate_Forecasts(Input_Folder_Name: in String; Status: out Program_Status) is
    use Ada.Directories;
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

    Lexer.Dummy;

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
