module Data.MotherMedication
    exposing
        ( MotherMedicationId(..)
        , MotherMedicationRecord
        , MotherMedicationRecordNew
        , motherMedicationRecordNewToMotherMedicationRecord
        , motherMedicationRecord
        , motherMedicationRecordToValue
        , motherMedicationRecordNewToValue
        )

import Data.Table exposing (Table(..), tableToString)
import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import Util as U


type MotherMedicationId
    = MotherMedicationId Int


type alias MotherMedicationRecord =
    { id : Int
    , motherMedicationType : Int
    , medicationDate : Date
    , initials : Maybe String
    , comments : Maybe String
    , labor_id : Int
    }


type alias MotherMedicationRecordNew =
    { motherMedicationType : Int
    , medicationDate : Date
    , initials : Maybe String
    , comments : Maybe String
    , labor_id : Int
    }

motherMedicationRecord : JD.Decoder MotherMedicationRecord
motherMedicationRecord =
    JDP.decode MotherMedicationRecord
        |> JDP.required "id" JD.int
        |> JDP.required "motherMedicationType" JD.int
        |> JDP.required "medicationDate" JDE.date
        |> JDP.required "initials" (JD.maybe JD.string)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "labor_id" JD.int


motherMedicationRecordToValue : MotherMedicationRecord -> JE.Value
motherMedicationRecordToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString MotherMedication) )
        , ( "data"
          , JE.object
                [ ( "id", JE.int rec.id )
                , ( "motherMedicationType", JE.int rec.motherMedicationType )
                , ( "medicationDate", U.dateToStringValue rec.medicationDate )
                , ( "initials", JEE.maybe JE.string rec.initials )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "labor_id", JE.int rec.labor_id )
                ]
          )
        ]

motherMedicationRecordNewToValue : MotherMedicationRecordNew -> JE.Value
motherMedicationRecordNewToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString MotherMedication) )
        , ( "data"
          , JE.object
                [ ( "motherMedicationType", JE.int rec.motherMedicationType )
                , ( "medicationDate", U.dateToStringValue rec.medicationDate )
                , ( "initials", JEE.maybe JE.string rec.initials )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "labor_id", JE.int rec.labor_id )
                ]
          )
        ]

motherMedicationRecordNewToMotherMedicationRecord : MotherMedicationId -> MotherMedicationRecordNew -> MotherMedicationRecord
motherMedicationRecordNewToMotherMedicationRecord (MotherMedicationId id) motherMedicationNew =
    MotherMedicationRecord id
        motherMedicationNew.motherMedicationType
        motherMedicationNew.medicationDate
        motherMedicationNew.initials
        motherMedicationNew.comments
        motherMedicationNew.labor_id

