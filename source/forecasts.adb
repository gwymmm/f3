with Ada.Directories;
with Ada.Text_IO;


package body Forecasts is

  procedure Evaluate_Forecasts(Input_Folder_Name: in String) is
    use Ada.Directories;
  begin

    if not Ada.Directories.Exists(Input_Folder_Name) then
      Ada.Text_IO.Put_Line("Error: Directory does not exist: " & Input_Folder_Name);
      return;
    end if;

    if Ada.Directories.Kind(Input_Folder_Name) /= Ada.Directories.Directory then
      Ada.Text_IO.Put_Line("Error: " & Input_Folder_Name & " is not a directory.");
      return;
    end if;

  Ada.Text_IO.Put_Line("Folder ready to be processed: " & Input_Folder_Name);

  end Evaluate_Forecasts;

end Forecasts;