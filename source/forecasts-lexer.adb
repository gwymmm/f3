
package body Forecasts.Lexer is

  procedure Init_Lexer(Lexer_Instance: out Lexer_Type; Input_File_Name: in String) is
  begin
    Ada.Text_IO.Open(Lexer_Instance.Input_File, Ada.Text_IO.In_File, Input_File_Name);
    Lexer_Instance.End_Of_File_Reached := False;
    Lexer_Instance.In_Error_State := False;
  end Init_Lexer;

end Forecasts.Lexer;
