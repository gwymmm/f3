with Ada.Text_IO;
with Ada.Command_Line;
with Forecasts;

procedure F3 is

begin

  if Ada.Command_Line.Argument_Count = 1 then
    Ada.Text_IO.Put_Line("This is the first argument:" & Ada.Command_Line.Argument(1));
  else
    Ada.Text_IO.Put_Line("Error: Only one argument expected (name of the directory that contains the files defining predictions and outcomes).");
    return;
  end if;

  Forecasts.Evaluate_Forecasts(Ada.Command_Line.Argument(1));

end F3;