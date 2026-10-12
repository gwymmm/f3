with Ada.Text_IO;

package body Forecasts.Test is

  procedure Print_Strings_List(S_List: Strings.List) is
    use Ada.Text_IO;
    use Ada.Strings.Unbounded;
  begin
    for E of S_List loop
      Put( To_String(E) & ", ");
    end loop;
  end Print_Strings_List;


  procedure Test_String_Split is
    use Ada.Text_IO;
    use Ada.Strings.Unbounded;
    Test_String: Unbounded_String;
    Pattern: Unbounded_String;
  begin

    Put_Line("Test String Split");
    New_Line;

    Test_String := To_Unbounded_String("car-house-tree");
    Pattern := To_Unbounded_String("-");
    Put_Line("Splitting string " & "'" & To_String(Test_String) & "' on pattern " & "'" & To_String(Pattern) & "'");
    Put("Result: ");
    Print_Strings_List( Split(Test_String, "-") );
    New_Line(2);

    Test_String := To_Unbounded_String("Challenge_Name-Forecaster_Name");
    Pattern := To_Unbounded_String("-");
    Put_Line("Splitting string " & "'" & To_String(Test_String) & "' on pattern " & "'" & To_String(Pattern) & "'");
    Put("Result: ");
    Print_Strings_List( Split(Test_String, "-") );
    New_Line(2);

    Test_String := To_Unbounded_String("-Forecaster_Name");
    Pattern := To_Unbounded_String("-");
    Put_Line("Splitting string " & "'" & To_String(Test_String) & "' on pattern " & "'" & To_String(Pattern) & "'");
    Put("Result: ");
    Print_Strings_List( Split(Test_String, "-") );
    New_Line(2);

    Test_String := To_Unbounded_String("Challenge_Name-");
    Pattern := To_Unbounded_String("-");
    Put_Line("Splitting string " & "'" & To_String(Test_String) & "' on pattern " & "'" & To_String(Pattern) & "'");
    Put("Result: ");
    Print_Strings_List( Split(Test_String, "-") );
    New_Line(2);

    Test_String := To_Unbounded_String("patpatpat");
    Pattern := To_Unbounded_String("pat");
    Put_Line("Splitting string " & "'" & To_String(Test_String) & "' on pattern " & "'" & To_String(Pattern) & "'");
    Put("Result: ");
    Print_Strings_List( Split(Test_String, "pat") ); -- expect 4 empty strings
    New_Line(2);

    Test_String := To_Unbounded_String("1 ; 22 ; 3 ; 44");
    Pattern := To_Unbounded_String(" ; ");
    Put_Line("Splitting string " & "'" & To_String(Test_String) & "' on pattern " & "'" & To_String(Pattern) & "'");
    Put("Result: ");
    Print_Strings_List( Split(Test_String, " ; ") );
    New_Line(2);

    Test_String := To_Unbounded_String("the house is green and large.");
    Pattern := To_Unbounded_String(" ");
    Put_Line("Splitting string " & "'" & To_String(Test_String) & "' on pattern " & "'" & To_String(Pattern) & "'");
    Put("Result: ");
    Print_Strings_List( Split(Test_String, " ") );
    New_Line(2);

    Test_String := To_Unbounded_String("the house is green and large.");
    Pattern := To_Unbounded_String(";");
    Put_Line("Splitting string " & "'" & To_String(Test_String) & "' on pattern " & "'" & To_String(Pattern) & "'");
    Put("Result: ");
    Print_Strings_List( Split(Test_String, ";") );
    New_Line(2);

  end Test_String_Split;

end Forecasts.Test;