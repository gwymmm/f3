
private package Forecasts.Lexer is

  type Lexer_Type is limited private;

  type Parser_Token_Type is private;

  -- Empty_Box  : ( )
  -- Ticked_Box : (x)
  -- Number_Box : (0.8)
  -- Text       : "abc"
  -- ID         : [q_1]

  type Parser_Token_Category is (ID, End_Of_File, Text, Empty_Box, Ticked_Box, Number_Box, Error);

  procedure Init_Lexer(Lexer_Instance: out Lexer_Type; Input_File_Name: in String);

private

  -- Number_Sign          : '#'
  -- Left_Square_Bracket  : '['
  -- Right_Square_Bracket : ']'
  -- Left_Parenthesis     : '('
  -- Right_Parenthesis    : ')'
  -- Low_Line             : '_'
  -- Quotation            : '"'
  -- Full_Stop            : '.'
  -- Cross                : 'x'

  type Token_Category is
    (Number_Sign, Left_Square_Bracket, Right_Square_Bracket, Whitespace, Left_Parenthesis, Right_Parenthesis, Digit, Letter,
     Low_Line, Quotation, Full_Stop, Cross, Other, End_Of_File);

  type Lexer_Type is
    record
      Input_File: Ada.Text_IO.File_Type;
      End_Of_File_Reached: Boolean;
      In_Error_State: Boolean;
   end record;

  type File_Location is
    record
      Line_Number: Ada.Text_IO.Positive_Count;
      Column_Number: Ada.Text_IO.Positive_Count;
  end record;

  type Lexer_Token_Type is
    record
      Category: Token_Category;
      Value: Character;
  end record;

  type Parser_Token_Type is
    record
      Category: Parser_Token_Category;
      Current_Location: File_Location;
      Value: Ada.Strings.Unbounded.Unbounded_String;
  end record;

end Forecasts.Lexer;
