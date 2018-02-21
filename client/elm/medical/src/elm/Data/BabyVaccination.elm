module Data.BabyVaccination
    exposing
        ( BabyVaccinationId(..)
        , BabyVaccinationRecord
        , BabyVaccinationRecordNew
        , babyVaccinationRecordNewToBabyVaccinationRecord
        , babyVaccinationRecord
        , babyVaccinationRecordToValue
        , babyVaccinationRecordNewToValue
        )

import Data.Table exposing (Table(..), tableToString)
import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import Util as U


type BabyVaccinationId
    = BabyVaccinationId Int


type alias BabyVaccinationRecord =
    { id : Int
    , babyVaccinationType : Int
    , vaccinationDate : Date
    , location : Maybe String
    , initials : Maybe String
    , comments : Maybe String
    , baby_id : Int
    }


type alias BabyVaccinationRecordNew =
    { babyVaccinationType : Int
    , vaccinationDate : Date
    , location : Maybe String
    , initials : Maybe String
    , comments : Maybe String
    , baby_id : Int
    }

babyVaccinationRecord : JD.Decoder BabyVaccinationRecord
babyVaccinationRecord =
    JDP.decode BabyVaccinationRecord
        |> JDP.required "id" JD.int
        |> JDP.required "babyVaccinationType" JD.int
        |> JDP.required "vaccinationDate" JDE.date
        |> JDP.required "location" (JD.maybe JD.string)
        |> JDP.required "initials" (JD.maybe JD.string)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "baby_id" JD.int


babyVaccinationRecordToValue : BabyVaccinationRecord -> JE.Value
babyVaccinationRecordToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString BabyVaccination) )
        , ( "data"
          , JE.object
                [ ( "id", JE.int rec.id )
                , ( "babyVaccinationType", JE.int rec.babyVaccinationType )
                , ( "vaccinationDate", U.dateToStringValue rec.vaccinationDate )
                , ( "location", JEE.maybe JE.string rec.location )
                , ( "initials", JEE.maybe JE.string rec.initials )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "baby_id", JE.int rec.baby_id )
                ]
          )
        ]

babyVaccinationRecordNewToValue : BabyVaccinationRecordNew -> JE.Value
babyVaccinationRecordNewToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString BabyVaccination) )
        , ( "data"
          , JE.object
                [ ( "babyVaccinationType", JE.int rec.babyVaccinationType )
                , ( "vaccinationDate", U.dateToStringValue rec.vaccinationDate )
                , ( "location", JEE.maybe JE.string rec.location )
                , ( "initials", JEE.maybe JE.string rec.initials )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "baby_id", JE.int rec.baby_id )
                ]
          )
        ]

babyVaccinationRecordNewToBabyVaccinationRecord : BabyVaccinationId -> BabyVaccinationRecordNew -> BabyVaccinationRecord
babyVaccinationRecordNewToBabyVaccinationRecord (BabyVaccinationId id) babyVaccinationNew =
    BabyVaccinationRecord id
        babyVaccinationNew.babyVaccinationType
        babyVaccinationNew.vaccinationDate
        babyVaccinationNew.location
        babyVaccinationNew.initials
        babyVaccinationNew.comments
        babyVaccinationNew.baby_id

