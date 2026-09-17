with Ada.Strings.Unbounded;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers.Vectors;
with Ada.Containers.Ordered_Maps;

package Forecasts is

  type Program_Status is (Success, Failure);

  procedure Evaluate_Forecasts(Input_Folder_Name: in String; Status: out Program_Status);

private

  package Strings is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Ada.Strings.Unbounded.Unbounded_String,
    "=" => Ada.Strings.Unbounded."=");

  procedure Print_Error(Error_Message: in String);
  procedure Print_Info(Info_Message: in String);
  procedure Print_More(Additional_Info: in String);

  type Float_Type is digits 5;

  package Floats is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Float_Type, "=" => "=");

  type Forecasting_Question is
    record
      ID: Ada.Strings.Unbounded.Unbounded_String;
      Outcome_Probabilities: Floats.List;
    end record;

  package Forecasting_Questions is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Forecasting_Question, "=" => "=");

  type Forecasting_Challenge_Type is
    record
      Questions_Answered: Boolean;
      Challenge_Questions: Forecasting_Questions.List;
    end record;

  package Challenges is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Forecasting_Challenge_Type, "=" => "=");

  package Challenge_Table_Columns is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Challenges.Vector, "=" => Challenges."=");

  package Name_To_Table_Index_Maps is new Ada.Containers.Ordered_Maps(Key_Type => Ada.Strings.Unbounded.Unbounded_String,
    Element_Type => Positive, "<" => Ada.Strings.Unbounded."<", "=" => "=");

  package Table_Index_To_Name_Vectors is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Ada.Strings.Unbounded.Unbounded_String, "=" => Ada.Strings.Unbounded."=");

  type Forecasting_Challenge_Table_Type is
    record

      Forecaster_Predictions: Challenge_Table_Columns.Vector;
      Outcomes: Challenges.Vector;

      Forecaster_Name_To_Idx_Map: Name_To_Table_Index_Maps.Map;
      Challenge_Name_To_Idx_Map: Name_To_Table_Index_Maps.Map;

      Forecaster_Names: Table_Index_To_Name_Vectors.Vector; -- columns names of the forecasting challenge table
      Challenge_Names: Table_Index_To_Name_Vectors.Vector;  -- row names of the forecasting challenge table

    end record;

end Forecasts;
