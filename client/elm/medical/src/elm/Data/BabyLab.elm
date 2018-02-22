module Data.BabyLab
    exposing
        ( BabyLabId(..)
        , BabyLabRecord
        , BabyLabRecordNew
        , babyLabRecord
        , babyLabRecordNewToValue
        , babyLabRecordToValue
        , babyLabRecordNewToBabyLabRecord
        )

import Data.Table exposing (Table(..), tableToString)
import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import Util as U


type BabyLabId
    = BabyLabId Int


type alias BabyLabRecord =
    { id : Int
    , babyLabType : Int
    , dateTime : Date
    , fld1Value : Maybe String
    , fld2Value : Maybe String
    , fld3Value : Maybe String
    , fld4Value : Maybe String
    , initials : Maybe String
    , baby_id : Int
    }

type alias BabyLabRecordNew =
    { babyLabType : Int
    , dateTime : Date
    , fld1Value : Maybe String
    , fld2Value : Maybe String
    , fld3Value : Maybe String
    , fld4Value : Maybe String
    , initials : Maybe String
    , baby_id : Int
    }


babyLabRecord : JD.Decoder BabyLabRecord
babyLabRecord =
    JDP.decode BabyLabRecord
        |> JDP.required "id" JD.int
        |> JDP.required "babyLabType" JD.int
        |> JDP.required "dateTime" JDE.date
        |> JDP.required "fld1Value" (JD.maybe JD.string)
        |> JDP.required "fld2Value" (JD.maybe JD.string)
        |> JDP.required "fld3Value" (JD.maybe JD.string)
        |> JDP.required "fld4Value" (JD.maybe JD.string)
        |> JDP.required "initials" (JD.maybe JD.string)
        |> JDP.required "baby_id" JD.int


babyLabRecordToValue : BabyLabRecord -> JE.Value
babyLabRecordToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString BabyLab) )
        , ( "data"
          , JE.object
                [ ( "id", JE.int rec.id )
                , ( "babyLabType", JE.int rec.babyLabType )
                , ( "dateTime", U.dateToStringValue rec.dateTime )
                , ( "fld1Value", JEE.maybe JE.string rec.fld1Value )
                , ( "fld2Value", JEE.maybe JE.string rec.fld2Value )
                , ( "fld3Value", JEE.maybe JE.string rec.fld3Value )
                , ( "fld4Value", JEE.maybe JE.string rec.fld4Value )
                , ( "initials", JEE.maybe JE.string rec.initials )
                , ( "baby_id", JE.int rec.baby_id )
                ]
          )
        ]


babyLabRecordNewToValue : BabyLabRecordNew -> JE.Value
babyLabRecordNewToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString BabyLab) )
        , ( "data"
          , JE.object
                [ ( "babyLabType", JE.int rec.babyLabType )
                , ( "dateTime", U.dateToStringValue rec.dateTime )
                , ( "fld1Value", JEE.maybe JE.string rec.fld1Value )
                , ( "fld2Value", JEE.maybe JE.string rec.fld2Value )
                , ( "fld3Value", JEE.maybe JE.string rec.fld3Value )
                , ( "fld4Value", JEE.maybe JE.string rec.fld4Value )
                , ( "initials", JEE.maybe JE.string rec.initials )
                , ( "baby_id", JE.int rec.baby_id )
                ]
          )
        ]


babyLabRecordNewToBabyLabRecord : BabyLabId -> BabyLabRecordNew -> BabyLabRecord
babyLabRecordNewToBabyLabRecord (BabyLabId id) babyLabNew =
    BabyLabRecord id
        babyLabNew.babyLabType
        babyLabNew.dateTime
        babyLabNew.fld1Value
        babyLabNew.fld2Value
        babyLabNew.fld3Value
        babyLabNew.fld4Value
        babyLabNew.initials
        babyLabNew.baby_id

