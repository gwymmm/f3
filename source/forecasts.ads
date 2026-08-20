with Ada.Strings.Unbounded;
with Ada.Containers.Doubly_Linked_Lists;

package Forecasts is

  type Program_Status is (Success, Failure);

  procedure Evaluate_Forecasts(Input_Folder_Name: in String; Status: out Program_Status);

private

  package Strings is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Ada.Strings.Unbounded.Unbounded_String,
    "=" => Ada.Strings.Unbounded."=");

  procedure Print_Error(Error_Message: in String);
  procedure Print_Info(Info_Message: in String);
  procedure Print_More(Additional_Info: in String);

end Forecasts;
