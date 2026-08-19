with Ada.Directories;
with Message_Handling;

package body Forecasts is

  use Message_Handling;

  procedure Evaluate_Forecasts(Input_Folder_Name: in String) is
    use Ada.Directories;
  begin

    if not Exists(Input_Folder_Name) then
      Print_Error("Directory does not exist: " & Input_Folder_Name);
      return;
    end if;

    if Kind(Input_Folder_Name) /= Directory then
      Print_Error(Input_Folder_Name & " is not a directory.");
      return;
    end if;

    Print_Info("Folder ready to be processed: " & Input_Folder_Name);

  end Evaluate_Forecasts;

end Forecasts;
