module Data.NewbornExam
    exposing
        ( NewbornExamId(..)
        , NewbornExamRecord
        , NewbornExamRecordNew
        , isNewbornExamRecordComplete
        , newbornExamRecord
        , newbornExamRecordNewToNewbornExamRecord
        , newbornExamRecordNewToValue
        , newbornExamRecordToValue
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


type NewbornExamId
    = NewbornExamId Int


type alias NewbornExamRecord =
    { id : Int
    , examDatetime : Date
    , examiners : String
    , rr : Maybe Int
    , hr : Maybe Int
    , temperature : Maybe Float
    , length : Maybe Int
    , headCir : Maybe Int
    , chestCir : Maybe Int
    , appearance : Maybe String
    , color : Maybe String
    , skin : Maybe String
    , head : Maybe String
    , eyes : Maybe String
    , ears : Maybe String
    , nose : Maybe String
    , mouth : Maybe String
    , neck : Maybe String
    , chest : Maybe String
    , lungs : Maybe String
    , heart : Maybe String
    , abdomen : Maybe String
    , hips : Maybe String
    , cord : Maybe String
    , femoralPulses : Maybe String
    , genitalia : Maybe String
    , anus : Maybe String
    , back : Maybe String
    , extremities : Maybe String
    , estGA : Maybe String
    , moroReflex : Maybe Bool
    , moroReflexComment : Maybe String
    , palmarReflex : Maybe Bool
    , palmarReflexComment : Maybe String
    , steppingReflex : Maybe Bool
    , steppingReflexComment : Maybe String
    , plantarReflex : Maybe Bool
    , plantarReflexComment : Maybe String
    , babinskiReflex : Maybe Bool
    , babinskiReflexComment : Maybe String
    , comments : Maybe String
    , baby_id : Int
    }


type alias NewbornExamRecordNew =
    { examDatetime : Date
    , examiners : String
    , rr : Maybe Int
    , hr : Maybe Int
    , temperature : Maybe Float
    , length : Maybe Int
    , headCir : Maybe Int
    , chestCir : Maybe Int
    , appearance : Maybe String
    , color : Maybe String
    , skin : Maybe String
    , head : Maybe String
    , eyes : Maybe String
    , ears : Maybe String
    , nose : Maybe String
    , mouth : Maybe String
    , neck : Maybe String
    , chest : Maybe String
    , lungs : Maybe String
    , heart : Maybe String
    , abdomen : Maybe String
    , hips : Maybe String
    , cord : Maybe String
    , femoralPulses : Maybe String
    , genitalia : Maybe String
    , anus : Maybe String
    , back : Maybe String
    , extremities : Maybe String
    , estGA : Maybe String
    , moroReflex : Maybe Bool
    , moroReflexComment : Maybe String
    , palmarReflex : Maybe Bool
    , palmarReflexComment : Maybe String
    , steppingReflex : Maybe Bool
    , steppingReflexComment : Maybe String
    , plantarReflex : Maybe Bool
    , plantarReflexComment : Maybe String
    , babinskiReflex : Maybe Bool
    , babinskiReflexComment : Maybe String
    , comments : Maybe String
    , baby_id : Int
    }


newbornExamRecord : JD.Decoder NewbornExamRecord
newbornExamRecord =
    JDP.decode NewbornExamRecord
        |> JDP.required "id" JD.int
        |> JDP.required "examDatetime" JDE.date
        |> JDP.required "examiners" JD.string
        |> JDP.required "rr" (JD.maybe JD.int)
        |> JDP.required "hr" (JD.maybe JD.int)
        |> JDP.required "temperature" (JD.maybe JD.float)
        |> JDP.required "length" (JD.maybe JD.int)
        |> JDP.required "headCir" (JD.maybe JD.int)
        |> JDP.required "chestCir" (JD.maybe JD.int)
        |> JDP.required "appearance" (JD.maybe JD.string)
        |> JDP.required "color" (JD.maybe JD.string)
        |> JDP.required "skin" (JD.maybe JD.string)
        |> JDP.required "head" (JD.maybe JD.string)
        |> JDP.required "eyes" (JD.maybe JD.string)
        |> JDP.required "ears" (JD.maybe JD.string)
        |> JDP.required "nose" (JD.maybe JD.string)
        |> JDP.required "mouth" (JD.maybe JD.string)
        |> JDP.required "neck" (JD.maybe JD.string)
        |> JDP.required "chest" (JD.maybe JD.string)
        |> JDP.required "lungs" (JD.maybe JD.string)
        |> JDP.required "heart" (JD.maybe JD.string)
        |> JDP.required "abdomen" (JD.maybe JD.string)
        |> JDP.required "hips" (JD.maybe JD.string)
        |> JDP.required "cord" (JD.maybe JD.string)
        |> JDP.required "femoralPulses" (JD.maybe JD.string)
        |> JDP.required "genitalia" (JD.maybe JD.string)
        |> JDP.required "anus" (JD.maybe JD.string)
        |> JDP.required "back" (JD.maybe JD.string)
        |> JDP.required "extremities" (JD.maybe JD.string)
        |> JDP.required "estGA" (JD.maybe JD.string)
        |> JDP.required "moroReflex" U.maybeIntToMaybeBool
        |> JDP.required "moroReflexComment" (JD.maybe JD.string)
        |> JDP.required "palmarReflex" U.maybeIntToMaybeBool
        |> JDP.required "palmarReflexComment" (JD.maybe JD.string)
        |> JDP.required "steppingReflex" U.maybeIntToMaybeBool
        |> JDP.required "steppingReflexComment" (JD.maybe JD.string)
        |> JDP.required "plantarReflex" U.maybeIntToMaybeBool
        |> JDP.required "plantarReflexComment" (JD.maybe JD.string)
        |> JDP.required "babinskiReflex" U.maybeIntToMaybeBool
        |> JDP.required "babinskiReflexComment" (JD.maybe JD.string)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "baby_id" JD.int


newbornExamRecordToValue : NewbornExamRecord -> JE.Value
newbornExamRecordToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString NewbornExam) )
        , ( "data"
          , JE.object
                [ ( "id", JE.int rec.id )
                , ( "examDatetime", U.dateToStringValue rec.examDatetime )
                , ( "examiners", JE.string rec.examiners )
                , ( "rr", JEE.maybe JE.int rec.rr )
                , ( "hr", JEE.maybe JE.int rec.hr )
                , ( "temperature", JEE.maybe JE.float rec.temperature )
                , ( "length", JEE.maybe JE.int rec.length )
                , ( "headCir", JEE.maybe JE.int rec.headCir )
                , ( "chestCir", JEE.maybe JE.int rec.chestCir )
                , ( "appearance", JEE.maybe JE.string rec.appearance )
                , ( "color", JEE.maybe JE.string rec.color )
                , ( "skin", JEE.maybe JE.string rec.skin )
                , ( "head", JEE.maybe JE.string rec.head )
                , ( "eyes", JEE.maybe JE.string rec.eyes )
                , ( "ears", JEE.maybe JE.string rec.ears )
                , ( "nose", JEE.maybe JE.string rec.nose )
                , ( "mouth", JEE.maybe JE.string rec.mouth )
                , ( "neck", JEE.maybe JE.string rec.neck )
                , ( "chest", JEE.maybe JE.string rec.chest )
                , ( "lungs", JEE.maybe JE.string rec.lungs )
                , ( "heart", JEE.maybe JE.string rec.heart )
                , ( "abdomen", JEE.maybe JE.string rec.abdomen )
                , ( "hips", JEE.maybe JE.string rec.hips )
                , ( "cord", JEE.maybe JE.string rec.cord )
                , ( "femoralPulses", JEE.maybe JE.string rec.femoralPulses )
                , ( "genitalia", JEE.maybe JE.string rec.genitalia )
                , ( "anus", JEE.maybe JE.string rec.anus )
                , ( "back", JEE.maybe JE.string rec.back )
                , ( "extremities", JEE.maybe JE.string rec.extremities )
                , ( "estGA", JEE.maybe JE.string rec.estGA )
                , ( "moroReflex", U.maybeBoolToMaybeInt rec.moroReflex )
                , ( "moroReflexComment", JEE.maybe JE.string rec.moroReflexComment )
                , ( "palmarReflex", U.maybeBoolToMaybeInt rec.palmarReflex )
                , ( "palmarReflexComment", JEE.maybe JE.string rec.palmarReflexComment )
                , ( "steppingReflex", U.maybeBoolToMaybeInt rec.steppingReflex )
                , ( "steppingReflexComment", JEE.maybe JE.string rec.steppingReflexComment )
                , ( "plantarReflex", U.maybeBoolToMaybeInt rec.plantarReflex )
                , ( "plantarReflexComment", JEE.maybe JE.string rec.plantarReflexComment )
                , ( "babinskiReflex", U.maybeBoolToMaybeInt rec.babinskiReflex )
                , ( "babinskiReflexComment", JEE.maybe JE.string rec.babinskiReflexComment )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "baby_id", JE.int rec.baby_id )
                ]
          )
        ]


newbornExamRecordNewToValue : NewbornExamRecordNew -> JE.Value
newbornExamRecordNewToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString NewbornExam) )
        , ( "data"
          , JE.object
                [ ( "examDatetime", U.dateToStringValue rec.examDatetime )
                , ( "examiners", JE.string rec.examiners )
                , ( "rr", JEE.maybe JE.int rec.rr )
                , ( "hr", JEE.maybe JE.int rec.hr )
                , ( "temperature", JEE.maybe JE.float rec.temperature )
                , ( "length", JEE.maybe JE.int rec.length )
                , ( "headCir", JEE.maybe JE.int rec.headCir )
                , ( "chestCir", JEE.maybe JE.int rec.chestCir )
                , ( "appearance", JEE.maybe JE.string rec.appearance )
                , ( "color", JEE.maybe JE.string rec.color )
                , ( "skin", JEE.maybe JE.string rec.skin )
                , ( "head", JEE.maybe JE.string rec.head )
                , ( "eyes", JEE.maybe JE.string rec.eyes )
                , ( "ears", JEE.maybe JE.string rec.ears )
                , ( "nose", JEE.maybe JE.string rec.nose )
                , ( "mouth", JEE.maybe JE.string rec.mouth )
                , ( "neck", JEE.maybe JE.string rec.neck )
                , ( "chest", JEE.maybe JE.string rec.chest )
                , ( "lungs", JEE.maybe JE.string rec.lungs )
                , ( "heart", JEE.maybe JE.string rec.heart )
                , ( "abdomen", JEE.maybe JE.string rec.abdomen )
                , ( "hips", JEE.maybe JE.string rec.hips )
                , ( "cord", JEE.maybe JE.string rec.cord )
                , ( "femoralPulses", JEE.maybe JE.string rec.femoralPulses )
                , ( "genitalia", JEE.maybe JE.string rec.genitalia )
                , ( "anus", JEE.maybe JE.string rec.anus )
                , ( "back", JEE.maybe JE.string rec.back )
                , ( "extremities", JEE.maybe JE.string rec.extremities )
                , ( "estGA", JEE.maybe JE.string rec.estGA )
                , ( "moroReflex", U.maybeBoolToMaybeInt rec.moroReflex )
                , ( "moroReflexComment", JEE.maybe JE.string rec.moroReflexComment )
                , ( "palmarReflex", U.maybeBoolToMaybeInt rec.palmarReflex )
                , ( "palmarReflexComment", JEE.maybe JE.string rec.palmarReflexComment )
                , ( "steppingReflex", U.maybeBoolToMaybeInt rec.steppingReflex )
                , ( "steppingReflexComment", JEE.maybe JE.string rec.steppingReflexComment )
                , ( "plantarReflex", U.maybeBoolToMaybeInt rec.plantarReflex )
                , ( "plantarReflexComment", JEE.maybe JE.string rec.plantarReflexComment )
                , ( "babinskiReflex", U.maybeBoolToMaybeInt rec.babinskiReflex )
                , ( "babinskiReflexComment", JEE.maybe JE.string rec.babinskiReflexComment )
                , ( "comments", JEE.maybe JE.string rec.comments )
                , ( "baby_id", JE.int rec.baby_id )
                ]
          )
        ]


newbornExamRecordNewToNewbornExamRecord : NewbornExamId -> NewbornExamRecordNew -> NewbornExamRecord
newbornExamRecordNewToNewbornExamRecord (NewbornExamId id) newRec =
    NewbornExamRecord id
        newRec.examDatetime
        newRec.examiners
        newRec.rr
        newRec.hr
        newRec.temperature
        newRec.length
        newRec.headCir
        newRec.chestCir
        newRec.appearance
        newRec.color
        newRec.skin
        newRec.head
        newRec.eyes
        newRec.ears
        newRec.nose
        newRec.mouth
        newRec.neck
        newRec.chest
        newRec.lungs
        newRec.heart
        newRec.abdomen
        newRec.hips
        newRec.cord
        newRec.femoralPulses
        newRec.genitalia
        newRec.anus
        newRec.back
        newRec.extremities
        newRec.estGA
        newRec.moroReflex
        newRec.moroReflexComment
        newRec.palmarReflex
        newRec.palmarReflexComment
        newRec.steppingReflex
        newRec.steppingReflexComment
        newRec.plantarReflex
        newRec.plantarReflexComment
        newRec.babinskiReflex
        newRec.babinskiReflexComment
        newRec.comments
        newRec.baby_id


isNewbornExamRecordComplete : NewbornExamRecord -> Bool
isNewbornExamRecordComplete rec =
    not <|
        (U.validateDate (Just rec.examDatetime)
            || U.validatePopulatedString (Just rec.examiners)
            || (rec.rr == Nothing)
            || (rec.hr == Nothing)
            || (rec.temperature == Nothing)
            || (rec.length == Nothing)
            || (rec.headCir == Nothing)
            || (rec.chestCir == Nothing)
            || U.validatePopulatedString rec.appearance
            || U.validatePopulatedString rec.color
            || U.validatePopulatedString rec.skin
            || U.validatePopulatedString rec.head
            || U.validatePopulatedString rec.eyes
            || U.validatePopulatedString rec.ears
            || U.validatePopulatedString rec.nose
            || U.validatePopulatedString rec.mouth
            || U.validatePopulatedString rec.neck
            || U.validatePopulatedString rec.chest
            || U.validatePopulatedString rec.lungs
            || U.validatePopulatedString rec.heart
            || U.validatePopulatedString rec.abdomen
            || U.validatePopulatedString rec.hips
            || U.validatePopulatedString rec.cord
            || U.validatePopulatedString rec.femoralPulses
            || U.validatePopulatedString rec.genitalia
            || U.validatePopulatedString rec.anus
            || U.validatePopulatedString rec.back
            || U.validatePopulatedString rec.extremities
            || U.validateBool rec.moroReflex
            || U.validateBool rec.palmarReflex
            || U.validateBool rec.steppingReflex
            || U.validateBool rec.plantarReflex
            || U.validateBool rec.babinskiReflex
        )
