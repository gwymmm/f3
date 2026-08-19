with Ada.Text_IO;


package body Message_Handling is

  use Ada.Text_IO;

  procedure Print_Error(Error_Message: in String) is
  begin
    Put_Line("Error: " & Error_Message);
  end Print_Error;

  procedure Print_Info(Info_Message: in String) is
  begin
    Put_Line(Info_Message);
  end Print_Info;

end Message_Handling;
