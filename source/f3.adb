with Ada.Command_Line;
with Forecasts;
with Message_Handling;

procedure F3 is

use Message_Handling;

begin

  if Ada.Command_Line.Argument_Count = 1 then
    Print_Info("This is the first argument:" & Ada.Command_Line.Argument(1));
  else
    Print_Error("Only one argument expected (name of the directory that contains the files defining predictions and outcomes).");
    return;
  end if;

  Forecasts.Evaluate_Forecasts(Ada.Command_Line.Argument(1));

end F3;
