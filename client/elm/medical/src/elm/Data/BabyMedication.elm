module Data.BabyMedication
    exposing
        ( BabyMedicationId(..)
        , BabyMedicationRecord
        , BabyMedicationRecordNew
        , babyMedicationRecordNewToBabyMedicationRecord
        , babyMedicationRecord
        , babyMedicationRecordToValue
        , babyMedicationRecordNewToValue
        )

import Data.Table exposing (Table(..), tableToString)
import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import Util as U


type BabyMedicationId
    = BabyMedicationId Int


type alias BabyMedicationRecord =
    { id : Int
    , babyMedicationType : Int
    , medicationDate : Date
    , location : Maybe String
    , initials : Maybe String
    , comments : Maybe String
    , baby_id : Int
    }


type alias BabyMedicationRecordNew =
    { babyMedicationType : Int
    , medicationDate : Date
    , location : Maybe String
    , initials : Maybe String
    , comments : Maybe String
    , baby_id : Int
    }

babyMedicationRecord : JD.Decoder BabyMedicationRecord
babyMedicationRecord =
    JDP.decode BabyMedicationRecord
        |> JDP.required "id" JD.int
        |> JDP.required "babyMedicationType" JD.int
        |> JDP.required "medicationDate" JDE.date
        |> JDP.required "location" (JD.maybe JD.string)
        |> JDP.required "initials" (JD.maybe JD.string)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "baby_id" JD.int


babyMedicationRecordToValue : BabyMedicationRecord -> JE.Value
babyMedicationRecordToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString BabyMedication) )
        , ( "data"
          , JE.object
                [ ( "id", JE.int rec.id )
                , ( "babyMedicationType", JE.int rec.babyMedicationType )
                , ( "medicationDate", U.dateToStringValue rec.medicationDate )
                , ( "location", JEE.maybe JE.string rec.location )
                , ( "initials", JEE.maybe JE.string rec.initials )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "baby_id", JE.int rec.baby_id )
                ]
          )
        ]

babyMedicationRecordNewToValue : BabyMedicationRecordNew -> JE.Value
babyMedicationRecordNewToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString BabyMedication) )
        , ( "data"
          , JE.object
                [ ( "babyMedicationType", JE.int rec.babyMedicationType )
                , ( "medicationDate", U.dateToStringValue rec.medicationDate )
                , ( "location", JEE.maybe JE.string rec.location )
                , ( "initials", JEE.maybe JE.string rec.initials )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "baby_id", JE.int rec.baby_id )
                ]
          )
        ]

babyMedicationRecordNewToBabyMedicationRecord : BabyMedicationId -> BabyMedicationRecordNew -> BabyMedicationRecord
babyMedicationRecordNewToBabyMedicationRecord (BabyMedicationId id) babyMedicationNew =
    BabyMedicationRecord id
        babyMedicationNew.babyMedicationType
        babyMedicationNew.medicationDate
        babyMedicationNew.location
        babyMedicationNew.initials
        babyMedicationNew.comments
        babyMedicationNew.baby_id

