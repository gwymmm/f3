with Ada.Command_Line;
with Forecasts;
with Ada.Text_IO;

procedure F3 is

use Ada.Text_IO;
use Forecasts;

Returned_Status: Forecasts.Program_Status;

begin

  if Ada.Command_Line.Argument_Count /= 1 then
    Put_Line("Error: Only one argument expected (name of the directory that contains the files defining predictions and outcomes).");
    Ada.Command_Line.Set_Exit_Status(Ada.Command_Line.Failure);
    return;
  end if;


  Evaluate_Forecasts(Ada.Command_Line.Argument(1), Returned_Status);


  if Returned_Status = Success then
    Ada.Command_Line.Set_Exit_Status(Ada.Command_Line.Success);
  else
    Ada.Command_Line.Set_Exit_Status(Ada.Command_Line.Failure);
  end if;

  return;

end F3;
