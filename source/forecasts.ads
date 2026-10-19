with Ada.Strings.Unbounded;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Containers.Vectors;
with Ada.Containers.Ordered_Maps;

package Forecasts is

  type Program_Status is (Success, Failure);

  type Program_Parameter_Type is
    record
      Current_Program_Status: Program_Status := Success;
      Debug: Boolean;
    end record;

  procedure Evaluate_Forecasts(Input_Folder_Name: in String; Program_Parameter: in out Program_Parameter_Type);

private

  package Strings is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Ada.Strings.Unbounded.Unbounded_String,
    "=" => Ada.Strings.Unbounded."=");

  function Split(U_String: in Ada.Strings.Unbounded.Unbounded_String; Pattern: in String) return Strings.List;

  procedure Print_Error(Error_Message: in String);
  procedure Print_Info(Info_Message: in String);
  procedure Print_More(Additional_Info: in String);
  procedure Print_Delimiter;

  type Prediction_File_Metadata_Type is
    record
      Input_File_Name: Ada.Strings.Unbounded.Unbounded_String;
      Challenge_Name: Ada.Strings.Unbounded.Unbounded_String;
      Forecaster_Name: Ada.Strings.Unbounded.Unbounded_String;
    end record;

  package Prediction_Files_Data is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Prediction_File_Metadata_Type, "=" => "=");

  type Outcome_File_Metadata_Type is
    record
      Input_File_Name: Ada.Strings.Unbounded.Unbounded_String;
      Challenge_Name: Ada.Strings.Unbounded.Unbounded_String;
    end record;

  package Outcome_Files_Data is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Outcome_File_Metadata_Type, "=" => "=");

  type Float_Type is digits 5;

  package Floats is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Float_Type, "=" => "=");

  type Forecasting_Score_Record is
    record
      Brier_Score: Float_Type;

      -- three component decomposition
      Variability_Index: Float_Type;
      Calibration_Index: Float_Type;
      Discrimination_Index: Float_Type;
    end record;

  type Forecasting_Question is
    record
      ID: Ada.Strings.Unbounded.Unbounded_String;
      Outcome_Probabilities: Floats.List;
    end record;

  package Forecasting_Questions is new Ada.Containers.Doubly_Linked_Lists(Element_Type => Forecasting_Question, "=" => "=");

  type Forecasting_Challenge_Type is
    record
      Questions_Answered: Boolean;
      Prediction_File_Name: Ada.Strings.Unbounded.Unbounded_String;
      Challenge_Questions: Forecasting_Questions.List;
      Score_Results: Forecasting_Score_Record;
    end record;

  package Challenges is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Forecasting_Challenge_Type, "=" => "=");

  package Challenge_Table_Columns is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Challenges.Vector, "=" => Challenges."=");

  package Name_To_Table_Index_Maps is new Ada.Containers.Ordered_Maps(Key_Type => Ada.Strings.Unbounded.Unbounded_String,
    Element_Type => Positive, "<" => Ada.Strings.Unbounded."<", "=" => "=");

  package Table_Index_To_Name_Vectors is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Ada.Strings.Unbounded.Unbounded_String, "=" => Ada.Strings.Unbounded."=");

  package Forecasting_Score_Records is new Ada.Containers.Vectors(Index_Type => Positive,
    Element_Type => Forecasting_Score_Record, "=" => "=");

  type Forecasting_Challenge_Table_Type is
    record

      Forecaster_Predictions: Challenge_Table_Columns.Vector;
      Outcomes: Challenges.Vector;

      Overall_Score_Results: Forecasting_Score_Records.Vector;

      Forecaster_Name_To_Idx_Map: Name_To_Table_Index_Maps.Map;
      Challenge_Name_To_Idx_Map: Name_To_Table_Index_Maps.Map;

      Forecaster_Names: Table_Index_To_Name_Vectors.Vector; -- columns names of the forecasting challenge table
      Challenge_Names: Table_Index_To_Name_Vectors.Vector;  -- row names of the forecasting challenge table

    end record;

end Forecasts;
