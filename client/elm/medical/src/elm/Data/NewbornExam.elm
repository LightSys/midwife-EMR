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
    , length : Maybe Float
    , headCir : Maybe Float
    , chestCir : Maybe Float
    , appearance : Maybe String
    , appearanceComment : Maybe String
    , color : Maybe String
    , colorComment : Maybe String
    , skin : Maybe String
    , skinComment : Maybe String
    , head : Maybe String
    , headComment : Maybe String
    , eyes : Maybe String
    , eyesComment : Maybe String
    , ears : Maybe String
    , earsComment : Maybe String
    , nose : Maybe String
    , noseComment : Maybe String
    , mouth : Maybe String
    , mouthComment : Maybe String
    , neck : Maybe String
    , neckComment : Maybe String
    , chest : Maybe String
    , chestComment : Maybe String
    , lungs : Maybe String
    , lungsComment : Maybe String
    , heart : Maybe String
    , heartComment : Maybe String
    , abdomen : Maybe String
    , abdomenComment : Maybe String
    , hips : Maybe String
    , hipsComment : Maybe String
    , cord : Maybe String
    , cordComment : Maybe String
    , femoralPulses : Maybe String
    , femoralPulsesComment : Maybe String
    , genitalia : Maybe String
    , genitaliaComment : Maybe String
    , anus : Maybe String
    , anusComment : Maybe String
    , back : Maybe String
    , backComment : Maybe String
    , extremities : Maybe String
    , extremitiesComment : Maybe String
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
    , length : Maybe Float
    , headCir : Maybe Float
    , chestCir : Maybe Float
    , appearance : Maybe String
    , appearanceComment : Maybe String
    , color : Maybe String
    , colorComment : Maybe String
    , skin : Maybe String
    , skinComment : Maybe String
    , head : Maybe String
    , headComment : Maybe String
    , eyes : Maybe String
    , eyesComment : Maybe String
    , ears : Maybe String
    , earsComment : Maybe String
    , nose : Maybe String
    , noseComment : Maybe String
    , mouth : Maybe String
    , mouthComment : Maybe String
    , neck : Maybe String
    , neckComment : Maybe String
    , chest : Maybe String
    , chestComment : Maybe String
    , lungs : Maybe String
    , lungsComment : Maybe String
    , heart : Maybe String
    , heartComment : Maybe String
    , abdomen : Maybe String
    , abdomenComment : Maybe String
    , hips : Maybe String
    , hipsComment : Maybe String
    , cord : Maybe String
    , cordComment : Maybe String
    , femoralPulses : Maybe String
    , femoralPulsesComment : Maybe String
    , genitalia : Maybe String
    , genitaliaComment : Maybe String
    , anus : Maybe String
    , anusComment : Maybe String
    , back : Maybe String
    , backComment : Maybe String
    , extremities : Maybe String
    , extremitiesComment : Maybe String
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
        |> JDP.required "length" (JD.maybe JD.float)
        |> JDP.required "headCir" (JD.maybe JD.float)
        |> JDP.required "chestCir" (JD.maybe JD.float)
        |> JDP.required "appearance" (JD.maybe JD.string)
        |> JDP.required "appearanceComment" (JD.maybe JD.string)
        |> JDP.required "color" (JD.maybe JD.string)
        |> JDP.required "colorComment" (JD.maybe JD.string)
        |> JDP.required "skin" (JD.maybe JD.string)
        |> JDP.required "skinComment" (JD.maybe JD.string)
        |> JDP.required "head" (JD.maybe JD.string)
        |> JDP.required "headComment" (JD.maybe JD.string)
        |> JDP.required "eyes" (JD.maybe JD.string)
        |> JDP.required "eyesComment" (JD.maybe JD.string)
        |> JDP.required "ears" (JD.maybe JD.string)
        |> JDP.required "earsComment" (JD.maybe JD.string)
        |> JDP.required "nose" (JD.maybe JD.string)
        |> JDP.required "noseComment" (JD.maybe JD.string)
        |> JDP.required "mouth" (JD.maybe JD.string)
        |> JDP.required "mouthComment" (JD.maybe JD.string)
        |> JDP.required "neck" (JD.maybe JD.string)
        |> JDP.required "neckComment" (JD.maybe JD.string)
        |> JDP.required "chest" (JD.maybe JD.string)
        |> JDP.required "chestComment" (JD.maybe JD.string)
        |> JDP.required "lungs" (JD.maybe JD.string)
        |> JDP.required "lungsComment" (JD.maybe JD.string)
        |> JDP.required "heart" (JD.maybe JD.string)
        |> JDP.required "heartComment" (JD.maybe JD.string)
        |> JDP.required "abdomen" (JD.maybe JD.string)
        |> JDP.required "abdomenComment" (JD.maybe JD.string)
        |> JDP.required "hips" (JD.maybe JD.string)
        |> JDP.required "hipsComment" (JD.maybe JD.string)
        |> JDP.required "cord" (JD.maybe JD.string)
        |> JDP.required "cordComment" (JD.maybe JD.string)
        |> JDP.required "femoralPulses" (JD.maybe JD.string)
        |> JDP.required "femoralPulsesComment" (JD.maybe JD.string)
        |> JDP.required "genitalia" (JD.maybe JD.string)
        |> JDP.required "genitaliaComment" (JD.maybe JD.string)
        |> JDP.required "anus" (JD.maybe JD.string)
        |> JDP.required "anusComment" (JD.maybe JD.string)
        |> JDP.required "back" (JD.maybe JD.string)
        |> JDP.required "backComment" (JD.maybe JD.string)
        |> JDP.required "extremities" (JD.maybe JD.string)
        |> JDP.required "extremitiesComment" (JD.maybe JD.string)
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
                , ( "length", JEE.maybe JE.float rec.length )
                , ( "headCir", JEE.maybe JE.float rec.headCir )
                , ( "chestCir", JEE.maybe JE.float rec.chestCir )
                , ( "appearance", JEE.maybe JE.string rec.appearance )
                , ( "appearanceComment", JEE.maybe JE.string rec.appearanceComment )
                , ( "color", JEE.maybe JE.string rec.color )
                , ( "colorComment", JEE.maybe JE.string rec.colorComment )
                , ( "skin", JEE.maybe JE.string rec.skin )
                , ( "skinComment", JEE.maybe JE.string rec.skinComment )
                , ( "head", JEE.maybe JE.string rec.head )
                , ( "headComment", JEE.maybe JE.string rec.headComment )
                , ( "eyes", JEE.maybe JE.string rec.eyes )
                , ( "eyesComment", JEE.maybe JE.string rec.eyesComment )
                , ( "ears", JEE.maybe JE.string rec.ears )
                , ( "earsComment", JEE.maybe JE.string rec.earsComment )
                , ( "nose", JEE.maybe JE.string rec.nose )
                , ( "noseComment", JEE.maybe JE.string rec.noseComment )
                , ( "mouth", JEE.maybe JE.string rec.mouth )
                , ( "mouthComment", JEE.maybe JE.string rec.mouthComment )
                , ( "neck", JEE.maybe JE.string rec.neck )
                , ( "neckComment", JEE.maybe JE.string rec.neckComment )
                , ( "chest", JEE.maybe JE.string rec.chest )
                , ( "chestComment", JEE.maybe JE.string rec.chestComment )
                , ( "lungs", JEE.maybe JE.string rec.lungs )
                , ( "lungsComment", JEE.maybe JE.string rec.lungsComment )
                , ( "heart", JEE.maybe JE.string rec.heart )
                , ( "heartComment", JEE.maybe JE.string rec.heartComment )
                , ( "abdomen", JEE.maybe JE.string rec.abdomen )
                , ( "abdomenComment", JEE.maybe JE.string rec.abdomenComment )
                , ( "hips", JEE.maybe JE.string rec.hips )
                , ( "hipsComment", JEE.maybe JE.string rec.hipsComment )
                , ( "cord", JEE.maybe JE.string rec.cord )
                , ( "cordComment", JEE.maybe JE.string rec.cordComment )
                , ( "femoralPulses", JEE.maybe JE.string rec.femoralPulses )
                , ( "femoralPulsesComment", JEE.maybe JE.string rec.femoralPulsesComment )
                , ( "genitalia", JEE.maybe JE.string rec.genitalia )
                , ( "genitaliaComment", JEE.maybe JE.string rec.genitaliaComment )
                , ( "anus", JEE.maybe JE.string rec.anus )
                , ( "anusComment", JEE.maybe JE.string rec.anusComment )
                , ( "back", JEE.maybe JE.string rec.back )
                , ( "backComment", JEE.maybe JE.string rec.backComment )
                , ( "extremities", JEE.maybe JE.string rec.extremities )
                , ( "extremitiesComment", JEE.maybe JE.string rec.extremitiesComment )
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
                , ( "length", JEE.maybe JE.float rec.length )
                , ( "headCir", JEE.maybe JE.float rec.headCir )
                , ( "chestCir", JEE.maybe JE.float rec.chestCir )
                , ( "appearance", JEE.maybe JE.string rec.appearance )
                , ( "appearanceComment", JEE.maybe JE.string rec.appearanceComment )
                , ( "color", JEE.maybe JE.string rec.color )
                , ( "colorComment", JEE.maybe JE.string rec.colorComment )
                , ( "skin", JEE.maybe JE.string rec.skin )
                , ( "skinComment", JEE.maybe JE.string rec.skinComment )
                , ( "head", JEE.maybe JE.string rec.head )
                , ( "headComment", JEE.maybe JE.string rec.headComment )
                , ( "eyes", JEE.maybe JE.string rec.eyes )
                , ( "eyesComment", JEE.maybe JE.string rec.eyesComment )
                , ( "ears", JEE.maybe JE.string rec.ears )
                , ( "earsComment", JEE.maybe JE.string rec.earsComment )
                , ( "nose", JEE.maybe JE.string rec.nose )
                , ( "noseComment", JEE.maybe JE.string rec.noseComment )
                , ( "mouth", JEE.maybe JE.string rec.mouth )
                , ( "mouthComment", JEE.maybe JE.string rec.mouthComment )
                , ( "neck", JEE.maybe JE.string rec.neck )
                , ( "neckComment", JEE.maybe JE.string rec.neckComment )
                , ( "chest", JEE.maybe JE.string rec.chest )
                , ( "chestComment", JEE.maybe JE.string rec.chestComment )
                , ( "lungs", JEE.maybe JE.string rec.lungs )
                , ( "lungsComment", JEE.maybe JE.string rec.lungsComment )
                , ( "heart", JEE.maybe JE.string rec.heart )
                , ( "heartComment", JEE.maybe JE.string rec.heartComment )
                , ( "abdomen", JEE.maybe JE.string rec.abdomen )
                , ( "abdomenComment", JEE.maybe JE.string rec.abdomenComment )
                , ( "hips", JEE.maybe JE.string rec.hips )
                , ( "hipsComment", JEE.maybe JE.string rec.hipsComment )
                , ( "cord", JEE.maybe JE.string rec.cord )
                , ( "cordComment", JEE.maybe JE.string rec.cordComment )
                , ( "femoralPulses", JEE.maybe JE.string rec.femoralPulses )
                , ( "femoralPulsesComment", JEE.maybe JE.string rec.femoralPulsesComment )
                , ( "genitalia", JEE.maybe JE.string rec.genitalia )
                , ( "genitaliaComment", JEE.maybe JE.string rec.genitaliaComment )
                , ( "anus", JEE.maybe JE.string rec.anus )
                , ( "anusComment", JEE.maybe JE.string rec.anusComment )
                , ( "back", JEE.maybe JE.string rec.back )
                , ( "backComment", JEE.maybe JE.string rec.backComment )
                , ( "extremities", JEE.maybe JE.string rec.extremities )
                , ( "extremitiesComment", JEE.maybe JE.string rec.extremitiesComment )
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
        newRec.appearanceComment
        newRec.color
        newRec.colorComment
        newRec.skin
        newRec.skinComment
        newRec.head
        newRec.headComment
        newRec.eyes
        newRec.eyesComment
        newRec.ears
        newRec.earsComment
        newRec.nose
        newRec.noseComment
        newRec.mouth
        newRec.mouthComment
        newRec.neck
        newRec.neckComment
        newRec.chest
        newRec.chestComment
        newRec.lungs
        newRec.lungsComment
        newRec.heart
        newRec.heartComment
        newRec.abdomen
        newRec.abdomenComment
        newRec.hips
        newRec.hipsComment
        newRec.cord
        newRec.cordComment
        newRec.femoralPulses
        newRec.femoralPulsesComment
        newRec.genitalia
        newRec.genitaliaComment
        newRec.anus
        newRec.anusComment
        newRec.back
        newRec.backComment
        newRec.extremities
        newRec.extremitiesComment
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
        (U.validateReasonableDate (Just rec.examDatetime)
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
            || (if rec.genitalia == Just "M" || rec.genitalia == Just "F" then
                    U.validatePopulatedString rec.genitalia
                else
                    False
               )
            || U.validatePopulatedString rec.anus
            || U.validatePopulatedString rec.back
            || U.validatePopulatedString rec.extremities
            || U.validateBool rec.moroReflex
            || U.validateBool rec.palmarReflex
            || U.validateBool rec.steppingReflex
            || U.validateBool rec.plantarReflex
            || U.validateBool rec.babinskiReflex
        )
