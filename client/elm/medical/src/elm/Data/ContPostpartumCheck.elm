module Data.ContPostpartumCheck
    exposing
        ( ContPostpartumCheckId(..)
        , ContPostpartumCheckRecord
        , ContPostpartumCheckRecordNew
        , contPostpartumCheckRecord
        , contPostpartumCheckRecordNewToContPostpartumCheckRecord
        , contPostpartumCheckRecordNewToValue
        , contPostpartumCheckRecordToValue
        , isContPostpartumCheckRecordComplete
        )

import Data.Table exposing (Table(..), tableToString)
import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import Util as U


type ContPostpartumCheckId
    = ContPostpartumCheckId Int


type alias ContPostpartumCheckRecord =
    { id : Int
    , checkDatetime : Date
    , motherSystolic : Maybe Int
    , motherDiastolic : Maybe Int
    , motherCR : Maybe Int
    , motherTemp : Maybe Float
    , motherFundus : Maybe String
    , motherEBL : Maybe Int
    , babyBFed : Maybe String
    , babyTemp : Maybe Float
    , babyRR : Maybe Int
    , babyCR : Maybe Int
    , comments : Maybe String
    , labor_id : Int
    }


type alias ContPostpartumCheckRecordNew =
    { checkDatetime : Date
    , motherSystolic : Maybe Int
    , motherDiastolic : Maybe Int
    , motherCR : Maybe Int
    , motherTemp : Maybe Float
    , motherFundus : Maybe String
    , motherEBL : Maybe Int
    , babyBFed : Maybe String
    , babyTemp : Maybe Float
    , babyRR : Maybe Int
    , babyCR : Maybe Int
    , comments : Maybe String
    , labor_id : Int
    }


contPostpartumCheckRecord : JD.Decoder ContPostpartumCheckRecord
contPostpartumCheckRecord =
    JDP.decode ContPostpartumCheckRecord
        |> JDP.required "id" JD.int
        |> JDP.required "checkDatetime" JDE.date
        |> JDP.required "motherSystolic" (JD.maybe JD.int)
        |> JDP.required "motherDiastolic" (JD.maybe JD.int)
        |> JDP.required "motherCR" (JD.maybe JD.int)
        |> JDP.required "motherTemp" (JD.maybe JD.float)
        |> JDP.required "motherFundus" (JD.maybe JD.string)
        |> JDP.required "motherEBL" (JD.maybe JD.int)
        |> JDP.required "babyBFed" (JD.maybe JD.string)
        |> JDP.required "babyTemp" (JD.maybe JD.float)
        |> JDP.required "babyRR" (JD.maybe JD.int)
        |> JDP.required "babyCR" (JD.maybe JD.int)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "labor_id" JD.int


contPostpartumCheckRecordToValue : ContPostpartumCheckRecord -> JE.Value
contPostpartumCheckRecordToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString ContPostpartumCheck) )
        , ( "data"
          , JE.object
                [ ( "id", JE.int rec.id )
                , ( "checkDatetime", U.dateToStringValue rec.checkDatetime )
                , ( "motherSystolic", JEE.maybe JE.int rec.motherSystolic )
                , ( "motherDiastolic", JEE.maybe JE.int rec.motherDiastolic )
                , ( "motherCR", JEE.maybe JE.int rec.motherCR )
                , ( "motherTemp", JEE.maybe JE.float rec.motherTemp )
                , ( "motherFundus", JEE.maybe JE.string rec.motherFundus )
                , ( "motherEBL", JEE.maybe JE.int rec.motherEBL )
                , ( "babyBFed", JEE.maybe JE.string rec.babyBFed )
                , ( "babyTemp", JEE.maybe JE.float rec.babyTemp )
                , ( "babyRR", JEE.maybe JE.int rec.babyRR )
                , ( "babyCR", JEE.maybe JE.int rec.babyCR )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "labor_id", JE.int rec.labor_id )
                ]
          )
        ]


contPostpartumCheckRecordNewToValue : ContPostpartumCheckRecordNew -> JE.Value
contPostpartumCheckRecordNewToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString ContPostpartumCheck) )
        , ( "data"
          , JE.object
                [ ( "checkDatetime", U.dateToStringValue rec.checkDatetime )
                , ( "motherSystolic", JEE.maybe JE.int rec.motherSystolic )
                , ( "motherDiastolic", JEE.maybe JE.int rec.motherDiastolic )
                , ( "motherCR", JEE.maybe JE.int rec.motherCR )
                , ( "motherTemp", JEE.maybe JE.float rec.motherTemp )
                , ( "motherFundus", JEE.maybe JE.string rec.motherFundus )
                , ( "motherEBL", JEE.maybe JE.int rec.motherEBL )
                , ( "babyBFed", JEE.maybe JE.string rec.babyBFed )
                , ( "babyTemp", JEE.maybe JE.float rec.babyTemp )
                , ( "babyRR", JEE.maybe JE.int rec.babyRR )
                , ( "babyCR", JEE.maybe JE.int rec.babyCR )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "labor_id", JE.int rec.labor_id )
                ]
          )
        ]


contPostpartumCheckRecordNewToContPostpartumCheckRecord :
    ContPostpartumCheckId
    -> ContPostpartumCheckRecordNew
    -> ContPostpartumCheckRecord
contPostpartumCheckRecordNewToContPostpartumCheckRecord (ContPostpartumCheckId id) newRec =
    ContPostpartumCheckRecord id
        newRec.checkDatetime
        newRec.motherSystolic
        newRec.motherDiastolic
        newRec.motherCR
        newRec.motherTemp
        newRec.motherFundus
        newRec.motherEBL
        newRec.babyBFed
        newRec.babyTemp
        newRec.babyRR
        newRec.babyCR
        newRec.comments
        newRec.labor_id


{-| A record is not complete if at least one user data field is not filled.
-}
isContPostpartumCheckRecordComplete : ContPostpartumCheckRecord -> Bool
isContPostpartumCheckRecordComplete rec =
    not <|
        (U.validateReasonableDate (Just rec.checkDatetime)
            || ((rec.motherSystolic == Nothing)
                    && (rec.motherDiastolic == Nothing)
                    && (rec.motherCR == Nothing)
                    && (rec.motherTemp == Nothing)
                    && (rec.motherFundus == Nothing)
                    && (rec.motherEBL == Nothing)
                    && (rec.babyBFed == Nothing)
                    && (rec.babyTemp == Nothing)
                    && (rec.babyRR == Nothing)
                    && (rec.babyCR == Nothing)
                    && (rec.comments == Nothing)
               )
        )
