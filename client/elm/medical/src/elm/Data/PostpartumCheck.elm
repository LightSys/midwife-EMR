module Data.PostpartumCheck
    exposing
        ( PostpartumCheckId(..)
        , PostpartumCheckRecord
        , PostpartumCheckRecordNew
        , postpartumCheckRecord
        , postpartumCheckRecordNewToPostpartumCheckRecord
        , postpartumCheckRecordNewToValue
        , postpartumCheckRecordToValue
        )

import Data.Table exposing (Table(..), tableToString)
import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import Util as U


type PostpartumCheckId
    = PostpartumCheckId Int


getPostpartumId : PostpartumCheckId -> Int
getPostpartumId (PostpartumCheckId id) =
    id


{-| Note: hgbTestDate and nextScheduledCheck fields
do not have a time element that we care about.
-}
type alias PostpartumCheckRecord =
    { id : Int
    , checkDatetime : Date
    , babyWeight : Maybe Int
    , babyTemp : Maybe Float
    , babyCR : Maybe Int
    , babyRR : Maybe Int
    , babyLungs : Maybe String
    , babyColor : Maybe String
    , babySkin : Maybe String
    , babyCord : Maybe String
    , babyUrine : Maybe String
    , babyStool : Maybe String
    , babySSInfection : Maybe String
    , babyFeeding : Maybe String
    , babyFeedingDaily : Maybe String
    , motherTemp : Maybe Float
    , motherSystolic : Maybe Int
    , motherDiastolic : Maybe Int
    , motherCR : Maybe Int
    , motherBreasts : Maybe String
    , motherFundus : Maybe String
    , motherPerineum : Maybe String
    , motherLochia : Maybe String
    , motherUrine : Maybe String
    , motherStool : Maybe String
    , motherSSInfection : Maybe String
    , motherFamilyPlanning : Maybe String
    , birthCertReq : Maybe Bool
    , hgbRequested : Maybe Bool
    , hgbTestDate : Maybe Date
    , hgbTestResult : Maybe String
    , ironGiven : Maybe Int
    , comments : Maybe String
    , nextScheduledCheck : Maybe Date
    , labor_id : Int
    }


type alias PostpartumCheckRecordNew =
    { checkDatetime : Date
    , babyWeight : Maybe Int
    , babyTemp : Maybe Float
    , babyCR : Maybe Int
    , babyRR : Maybe Int
    , babyLungs : Maybe String
    , babyColor : Maybe String
    , babySkin : Maybe String
    , babyCord : Maybe String
    , babyUrine : Maybe String
    , babyStool : Maybe String
    , babySSInfection : Maybe String
    , babyFeeding : Maybe String
    , babyFeedingDaily : Maybe String
    , motherTemp : Maybe Float
    , motherSystolic : Maybe Int
    , motherDiastolic : Maybe Int
    , motherCR : Maybe Int
    , motherBreasts : Maybe String
    , motherFundus : Maybe String
    , motherPerineum : Maybe String
    , motherLochia : Maybe String
    , motherUrine : Maybe String
    , motherStool : Maybe String
    , motherSSInfection : Maybe String
    , motherFamilyPlanning : Maybe String
    , birthCertReq : Maybe Bool
    , hgbRequested : Maybe Bool
    , hgbTestDate : Maybe Date
    , hgbTestResult : Maybe String
    , ironGiven : Maybe Int
    , comments : Maybe String
    , nextScheduledCheck : Maybe Date
    , labor_id : Int
    }


postpartumCheckRecord : JD.Decoder PostpartumCheckRecord
postpartumCheckRecord =
    JDP.decode PostpartumCheckRecord
        |> JDP.required "id" JD.int
        |> JDP.required "checkDatetime" JDE.date
        |> JDP.required "babyWeight" (JD.maybe JD.int)
        |> JDP.required "babyTemp" (JD.maybe JD.float)
        |> JDP.required "babyCR" (JD.maybe JD.int)
        |> JDP.required "babyRR" (JD.maybe JD.int)
        |> JDP.required "babyLungs" (JD.maybe JD.string)
        |> JDP.required "babyColor" (JD.maybe JD.string)
        |> JDP.required "babySkin" (JD.maybe JD.string)
        |> JDP.required "babyCord" (JD.maybe JD.string)
        |> JDP.required "babyUrine" (JD.maybe JD.string)
        |> JDP.required "babyStool" (JD.maybe JD.string)
        |> JDP.required "babySSInfection" (JD.maybe JD.string)
        |> JDP.required "babyFeeding" (JD.maybe JD.string)
        |> JDP.required "babyFeedingDaily" (JD.maybe JD.string)
        |> JDP.required "motherTemp" (JD.maybe JD.float)
        |> JDP.required "motherSystolic" (JD.maybe JD.int)
        |> JDP.required "motherDiastolic" (JD.maybe JD.int)
        |> JDP.required "motherCR" (JD.maybe JD.int)
        |> JDP.required "motherBreasts" (JD.maybe JD.string)
        |> JDP.required "motherFundus" (JD.maybe JD.string)
        |> JDP.required "motherPerineum" (JD.maybe JD.string)
        |> JDP.required "motherLochia" (JD.maybe JD.string)
        |> JDP.required "motherUrine" (JD.maybe JD.string)
        |> JDP.required "motherStool" (JD.maybe JD.string)
        |> JDP.required "motherSSInfection" (JD.maybe JD.string)
        |> JDP.required "motherFamilyPlanning" (JD.maybe JD.string)
        |> JDP.required "birthCertReq" U.maybeIntToMaybeBool
        |> JDP.required "hgbRequested" U.maybeIntToMaybeBool
        |> JDP.required "hgbTestDate" (JD.maybe JDE.date)
        |> JDP.required "hgbTestResult" (JD.maybe JD.string)
        |> JDP.required "ironGiven" (JD.maybe JD.int)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "nextScheduledCheck" (JD.maybe JDE.date)
        |> JDP.required "labor_id" JD.int


postpartumCheckRecordToValue : PostpartumCheckRecord -> JE.Value
postpartumCheckRecordToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString PostpartumCheck) )
        , ( "data"
          , JE.object
                [ ( "id", JE.int rec.id )
                , ( "checkDatetime", U.dateToStringValue rec.checkDatetime )
                , ( "babyWeight", JEE.maybe JE.int rec.babyWeight )
                , ( "babyTemp", JEE.maybe JE.float rec.babyTemp )
                , ( "babyCR", JEE.maybe JE.int rec.babyCR )
                , ( "babyRR", JEE.maybe JE.int rec.babyRR )
                , ( "babyLungs", JEE.maybe JE.string rec.babyLungs )
                , ( "babyColor", JEE.maybe JE.string rec.babyColor )
                , ( "babySkin", JEE.maybe JE.string rec.babySkin )
                , ( "babyCord", JEE.maybe JE.string rec.babyCord )
                , ( "babyUrine", JEE.maybe JE.string rec.babyUrine )
                , ( "babyStool", JEE.maybe JE.string rec.babyStool )
                , ( "babySSInfection", JEE.maybe JE.string rec.babySSInfection )
                , ( "babyFeeding", JEE.maybe JE.string rec.babyFeeding )
                , ( "babyFeedingDaily", JEE.maybe JE.string rec.babyFeedingDaily )
                , ( "motherTemp", JEE.maybe JE.float rec.motherTemp )
                , ( "motherSystolic", JEE.maybe JE.int rec.motherSystolic )
                , ( "motherDiastolic", JEE.maybe JE.int rec.motherDiastolic )
                , ( "motherCR", JEE.maybe JE.int rec.motherCR )
                , ( "motherBreasts", JEE.maybe JE.string rec.motherBreasts )
                , ( "motherFundus", JEE.maybe JE.string rec.motherFundus )
                , ( "motherPerineum", JEE.maybe JE.string rec.motherPerineum )
                , ( "motherLochia", JEE.maybe JE.string rec.motherLochia )
                , ( "motherUrine", JEE.maybe JE.string rec.motherUrine )
                , ( "motherStool", JEE.maybe JE.string rec.motherStool )
                , ( "motherSSInfection", JEE.maybe JE.string rec.motherSSInfection )
                , ( "motherFamilyPlanning", JEE.maybe JE.string rec.motherFamilyPlanning )
                , ( "birthCertReq", JEE.maybe JE.bool rec.birthCertReq )
                , ( "hgbRequested", JEE.maybe JE.bool rec.hgbRequested )
                , ( "hgbTestDate", JEE.maybe U.dateToStringValue rec.hgbTestDate )
                , ( "hgbTestResult", JEE.maybe JE.string rec.hgbTestResult )
                , ( "ironGiven", JEE.maybe JE.int rec.ironGiven )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "nextScheduledCheck", JEE.maybe U.dateToStringValue rec.nextScheduledCheck )
                , ( "labor_id", JE.int rec.labor_id )
                ]
          )
        ]


postpartumCheckRecordNewToValue : PostpartumCheckRecordNew -> JE.Value
postpartumCheckRecordNewToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString PostpartumCheck) )
        , ( "data"
          , JE.object
                [ ( "checkDatetime", U.dateToStringValue rec.checkDatetime )
                , ( "babyWeight", JEE.maybe JE.int rec.babyWeight )
                , ( "babyTemp", JEE.maybe JE.float rec.babyTemp )
                , ( "babyCR", JEE.maybe JE.int rec.babyCR )
                , ( "babyRR", JEE.maybe JE.int rec.babyRR )
                , ( "babyLungs", JEE.maybe JE.string rec.babyLungs )
                , ( "babyColor", JEE.maybe JE.string rec.babyColor )
                , ( "babySkin", JEE.maybe JE.string rec.babySkin )
                , ( "babyCord", JEE.maybe JE.string rec.babyCord )
                , ( "babyUrine", JEE.maybe JE.string rec.babyUrine )
                , ( "babyStool", JEE.maybe JE.string rec.babyStool )
                , ( "babySSInfection", JEE.maybe JE.string rec.babySSInfection )
                , ( "babyFeeding", JEE.maybe JE.string rec.babyFeeding )
                , ( "babyFeedingDaily", JEE.maybe JE.string rec.babyFeedingDaily )
                , ( "motherTemp", JEE.maybe JE.float rec.motherTemp )
                , ( "motherSystolic", JEE.maybe JE.int rec.motherSystolic )
                , ( "motherDiastolic", JEE.maybe JE.int rec.motherDiastolic )
                , ( "motherCR", JEE.maybe JE.int rec.motherCR )
                , ( "motherBreasts", JEE.maybe JE.string rec.motherBreasts )
                , ( "motherFundus", JEE.maybe JE.string rec.motherFundus )
                , ( "motherPerineum", JEE.maybe JE.string rec.motherPerineum )
                , ( "motherLochia", JEE.maybe JE.string rec.motherLochia )
                , ( "motherUrine", JEE.maybe JE.string rec.motherUrine )
                , ( "motherStool", JEE.maybe JE.string rec.motherStool )
                , ( "motherSSInfection", JEE.maybe JE.string rec.motherSSInfection )
                , ( "motherFamilyPlanning", JEE.maybe JE.string rec.motherFamilyPlanning )
                , ( "birthCertReq", JEE.maybe JE.bool rec.birthCertReq )
                , ( "hgbRequested", JEE.maybe JE.bool rec.hgbRequested )
                , ( "hgbTestDate", JEE.maybe U.dateToStringValue rec.hgbTestDate )
                , ( "hgbTestResult", JEE.maybe JE.string rec.hgbTestResult )
                , ( "ironGiven", JEE.maybe JE.int rec.ironGiven )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "nextScheduledCheck", JEE.maybe U.dateToStringValue rec.nextScheduledCheck )
                , ( "labor_id", JE.int rec.labor_id )
                ]
          )
        ]


postpartumCheckRecordNewToPostpartumCheckRecord : PostpartumCheckId -> PostpartumCheckRecordNew -> PostpartumCheckRecord
postpartumCheckRecordNewToPostpartumCheckRecord (PostpartumCheckId id) newRec =
    PostpartumCheckRecord id
        newRec.checkDatetime
        newRec.babyWeight
        newRec.babyTemp
        newRec.babyCR
        newRec.babyRR
        newRec.babyLungs
        newRec.babyColor
        newRec.babySkin
        newRec.babyCord
        newRec.babyUrine
        newRec.babyStool
        newRec.babySSInfection
        newRec.babyFeeding
        newRec.babyFeedingDaily
        newRec.motherTemp
        newRec.motherSystolic
        newRec.motherDiastolic
        newRec.motherCR
        newRec.motherBreasts
        newRec.motherFundus
        newRec.motherPerineum
        newRec.motherLochia
        newRec.motherUrine
        newRec.motherStool
        newRec.motherSSInfection
        newRec.motherFamilyPlanning
        newRec.birthCertReq
        newRec.hgbRequested
        newRec.hgbTestDate
        newRec.hgbTestResult
        newRec.ironGiven
        newRec.comments
        newRec.nextScheduledCheck
        newRec.labor_id


