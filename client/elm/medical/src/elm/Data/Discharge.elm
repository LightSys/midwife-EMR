module Data.Discharge
    exposing
        ( DischargeId(..)
        , DischargeRecord
        , DischargeRecordNew
        , dischargeRecord
        , dischargeRecordNewToDischargeRecord
        , dischargeRecordNewToValue
        , dischargeRecordToValue
        , isDischargeRecordComplete
        , maybeNBSToMaybeString
        , maybeStringToNBS
        , nbsToString
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


type DischargeId
    = DischargeId Int


type NBS
    = DoneNBS
    | WaivedNBS


maybeNBSToMaybeString : Maybe NBS -> Maybe String
maybeNBSToMaybeString nbs =
    Maybe.map nbsToString nbs


nbsToString : NBS -> String
nbsToString nbs =
    case nbs of
        WaivedNBS ->
            "Waived"

        DoneNBS ->
            "Done"


stringToNBS : String -> Maybe NBS
stringToNBS str =
    case str of
        "Waived" ->
            Just WaivedNBS

        "Done" ->
            Just DoneNBS

        _ ->
            Nothing


maybeStringToNBS : Maybe String -> Maybe NBS
maybeStringToNBS str =
    case str of
        Just val ->
            stringToNBS val

        Nothing ->
            Nothing


type alias DischargeRecord =
    { id : Int
    , dateTime : Maybe Date
    , motherSystolic : Maybe Int
    , motherDiastolic : Maybe Int
    , motherTemp : Maybe Float
    , motherCR : Maybe Int
    , babyRR : Maybe Int
    , babyTemp : Maybe Float
    , babyCR : Maybe Int
    , ppInstructionsSchedule : Maybe Bool
    , birthCertWorksheet : Maybe Bool
    , birthRecorded : Maybe Bool
    , chartsComplete : Maybe Bool
    , logsComplete : Maybe Bool
    , billPaid : Maybe Bool
    , nbs : Maybe NBS
    , immunizationReferral : Maybe Bool
    , breastFeedingEstablished : Maybe Bool
    , newbornBath : Maybe Bool
    , fundusFirmBleedingCtld : Maybe Bool
    , motherAteDrank : Maybe Bool
    , motherUrinated : Maybe Bool
    , placentaGone : Maybe Bool
    , prayer : Maybe Bool
    , bible : Maybe Bool
    , transferBaby : Maybe Bool
    , transferMother : Maybe Bool
    , transferComment : Maybe String
    , initials : Maybe String
    , labor_id : Int
    }


type alias DischargeRecordNew =
    { dateTime : Maybe Date
    , motherSystolic : Maybe Int
    , motherDiastolic : Maybe Int
    , motherTemp : Maybe Float
    , motherCR : Maybe Int
    , babyRR : Maybe Int
    , babyTemp : Maybe Float
    , babyCR : Maybe Int
    , ppInstructionsSchedule : Maybe Bool
    , birthCertWorksheet : Maybe Bool
    , birthRecorded : Maybe Bool
    , chartsComplete : Maybe Bool
    , logsComplete : Maybe Bool
    , billPaid : Maybe Bool
    , nbs : Maybe NBS
    , immunizationReferral : Maybe Bool
    , breastFeedingEstablished : Maybe Bool
    , newbornBath : Maybe Bool
    , fundusFirmBleedingCtld : Maybe Bool
    , motherAteDrank : Maybe Bool
    , motherUrinated : Maybe Bool
    , placentaGone : Maybe Bool
    , prayer : Maybe Bool
    , bible : Maybe Bool
    , transferBaby : Maybe Bool
    , transferMother : Maybe Bool
    , transferComment : Maybe String
    , initials : Maybe String
    , labor_id : Int
    }


dischargeRecord : JD.Decoder DischargeRecord
dischargeRecord =
    JDP.decode DischargeRecord
        |> JDP.required "id" JD.int
        |> JDP.required "dateTime" (JD.maybe JDE.date)
        |> JDP.required "motherSystolic" (JD.maybe JD.int)
        |> JDP.required "motherDiastolic" (JD.maybe JD.int)
        |> JDP.required "motherTemp" (JD.maybe JD.float)
        |> JDP.required "motherCR" (JD.maybe JD.int)
        |> JDP.required "babyRR" (JD.maybe JD.int)
        |> JDP.required "babyTemp" (JD.maybe JD.float)
        |> JDP.required "babyCR" (JD.maybe JD.int)
        |> JDP.required "ppInstructionsSchedule" U.maybeIntToMaybeBool
        |> JDP.required "birthCertWorksheet" U.maybeIntToMaybeBool
        |> JDP.required "birthRecorded" U.maybeIntToMaybeBool
        |> JDP.required "chartsComplete" U.maybeIntToMaybeBool
        |> JDP.required "logsComplete" U.maybeIntToMaybeBool
        |> JDP.required "billPaid" U.maybeIntToMaybeBool
        |> JDP.required "nbs" (JD.maybe JD.string |> JD.map maybeStringToNBS)
        |> JDP.required "immunizationReferral" U.maybeIntToMaybeBool
        |> JDP.required "breastFeedingEstablished" U.maybeIntToMaybeBool
        |> JDP.required "newbornBath" U.maybeIntToMaybeBool
        |> JDP.required "fundusFirmBleedingCtld" U.maybeIntToMaybeBool
        |> JDP.required "motherAteDrank" U.maybeIntToMaybeBool
        |> JDP.required "motherUrinated" U.maybeIntToMaybeBool
        |> JDP.required "placentaGone" U.maybeIntToMaybeBool
        |> JDP.required "prayer" U.maybeIntToMaybeBool
        |> JDP.required "bible" U.maybeIntToMaybeBool
        |> JDP.required "transferBaby" U.maybeIntToMaybeBool
        |> JDP.required "transferBaby" U.maybeIntToMaybeBool
        |> JDP.required "transferComment" (JD.maybe JD.string)
        |> JDP.required "initials" (JD.maybe JD.string)
        |> JDP.required "labor_id" JD.int


dischargeRecordToValue : DischargeRecord -> JE.Value
dischargeRecordToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString Discharge) )
        , ( "data"
          , JE.object
                [ ( "id", JE.int rec.id )
                , ( "dateTime", JEE.maybe U.dateToStringValue rec.dateTime )
                , ( "motherSystolic", JEE.maybe JE.int rec.motherSystolic )
                , ( "motherDiastolic", JEE.maybe JE.int rec.motherDiastolic )
                , ( "motherTemp", JEE.maybe JE.float rec.motherTemp )
                , ( "motherCR", JEE.maybe JE.int rec.motherCR )
                , ( "babyRR", JEE.maybe JE.int rec.babyRR )
                , ( "babyTemp", JEE.maybe JE.float rec.babyTemp )
                , ( "babyCR", JEE.maybe JE.int rec.babyCR )
                , ( "ppInstructionsSchedule", U.maybeBoolToMaybeInt rec.ppInstructionsSchedule )
                , ( "birthCertWorksheet", U.maybeBoolToMaybeInt rec.birthCertWorksheet )
                , ( "birthRecorded", U.maybeBoolToMaybeInt rec.birthRecorded )
                , ( "chartsComplete", U.maybeBoolToMaybeInt rec.chartsComplete )
                , ( "logsComplete", U.maybeBoolToMaybeInt rec.logsComplete )
                , ( "billPaid", U.maybeBoolToMaybeInt rec.billPaid )
                , ( "nbs", JEE.maybe (\n -> JE.string (nbsToString n)) rec.nbs )
                , ( "immunizationReferral", U.maybeBoolToMaybeInt rec.immunizationReferral )
                , ( "breastFeedingEstablished", U.maybeBoolToMaybeInt rec.breastFeedingEstablished )
                , ( "newbornBath", U.maybeBoolToMaybeInt rec.newbornBath )
                , ( "fundusFirmBleedingCtld", U.maybeBoolToMaybeInt rec.fundusFirmBleedingCtld )
                , ( "motherAteDrank", U.maybeBoolToMaybeInt rec.motherAteDrank )
                , ( "motherUrinated", U.maybeBoolToMaybeInt rec.motherUrinated )
                , ( "placentaGone", U.maybeBoolToMaybeInt rec.placentaGone )
                , ( "prayer", U.maybeBoolToMaybeInt rec.prayer )
                , ( "bible", U.maybeBoolToMaybeInt rec.bible )
                , ( "transferBaby", U.maybeBoolToMaybeInt rec.transferBaby )
                , ( "transferMother", U.maybeBoolToMaybeInt rec.transferMother )
                , ( "transferComment", JEE.maybe JE.string rec.transferComment )
                , ( "initials", JEE.maybe JE.string rec.initials )
                , ( "labor_id", JE.int rec.labor_id )
                ]
          )
        ]


dischargeRecordNewToValue : DischargeRecordNew -> JE.Value
dischargeRecordNewToValue rec =
    JE.object
        [ ( "table", JE.string (tableToString Discharge) )
        , ( "data"
          , JE.object
                [ ( "dateTime", JEE.maybe U.dateToStringValue rec.dateTime )
                , ( "motherSystolic", JEE.maybe JE.int rec.motherSystolic )
                , ( "motherDiastolic", JEE.maybe JE.int rec.motherDiastolic )
                , ( "motherTemp", JEE.maybe JE.float rec.motherTemp )
                , ( "motherCR", JEE.maybe JE.int rec.motherCR )
                , ( "babyRR", JEE.maybe JE.int rec.babyRR )
                , ( "babyTemp", JEE.maybe JE.float rec.babyTemp )
                , ( "babyCR", JEE.maybe JE.int rec.babyCR )
                , ( "ppInstructionsSchedule", U.maybeBoolToMaybeInt rec.ppInstructionsSchedule )
                , ( "birthCertWorksheet", U.maybeBoolToMaybeInt rec.birthCertWorksheet )
                , ( "birthRecorded", U.maybeBoolToMaybeInt rec.birthRecorded )
                , ( "chartsComplete", U.maybeBoolToMaybeInt rec.chartsComplete )
                , ( "logsComplete", U.maybeBoolToMaybeInt rec.logsComplete )
                , ( "billPaid", U.maybeBoolToMaybeInt rec.billPaid )
                , ( "nbs", JEE.maybe (\n -> JE.string (nbsToString n)) rec.nbs )
                , ( "immunizationReferral", U.maybeBoolToMaybeInt rec.immunizationReferral )
                , ( "breastFeedingEstablished", U.maybeBoolToMaybeInt rec.breastFeedingEstablished )
                , ( "newbornBath", U.maybeBoolToMaybeInt rec.newbornBath )
                , ( "fundusFirmBleedingCtld", U.maybeBoolToMaybeInt rec.fundusFirmBleedingCtld )
                , ( "motherAteDrank", U.maybeBoolToMaybeInt rec.motherAteDrank )
                , ( "motherUrinated", U.maybeBoolToMaybeInt rec.motherUrinated )
                , ( "placentaGone", U.maybeBoolToMaybeInt rec.placentaGone )
                , ( "prayer", U.maybeBoolToMaybeInt rec.prayer )
                , ( "bible", U.maybeBoolToMaybeInt rec.bible )
                , ( "transferBaby", U.maybeBoolToMaybeInt rec.transferBaby )
                , ( "transferMother", U.maybeBoolToMaybeInt rec.transferMother )
                , ( "transferComment", JEE.maybe JE.string rec.transferComment )
                , ( "initials", JEE.maybe JE.string rec.initials )
                , ( "labor_id", JE.int rec.labor_id )
                ]
          )
        ]


dischargeRecordNewToDischargeRecord : DischargeId -> DischargeRecordNew -> DischargeRecord
dischargeRecordNewToDischargeRecord (DischargeId id) newRec =
    DischargeRecord id
        newRec.dateTime
        newRec.motherSystolic
        newRec.motherDiastolic
        newRec.motherTemp
        newRec.motherCR
        newRec.babyRR
        newRec.babyTemp
        newRec.babyCR
        newRec.ppInstructionsSchedule
        newRec.birthCertWorksheet
        newRec.birthRecorded
        newRec.chartsComplete
        newRec.logsComplete
        newRec.billPaid
        newRec.nbs
        newRec.immunizationReferral
        newRec.breastFeedingEstablished
        newRec.newbornBath
        newRec.fundusFirmBleedingCtld
        newRec.motherAteDrank
        newRec.motherUrinated
        newRec.placentaGone
        newRec.prayer
        newRec.bible
        newRec.transferBaby
        newRec.transferMother
        newRec.transferComment
        newRec.initials
        newRec.labor_id


{-| Took a guess that Bible and prayer can be refused
by the patient and the discharge should still be
considered complete. Also allows that bfed never gets
established for some reason but discharge is still allowed.
-}
isDischargeRecordComplete : DischargeRecord -> Bool
isDischargeRecordComplete rec =
    let
        validateBool fld =
            fld == Nothing || fld == Just False
    in
    not <|
        ( ((U.validateReasonableDate True) rec.dateTime)
            || (rec.motherSystolic == Nothing)
            || (rec.motherDiastolic == Nothing)
            || (rec.motherTemp == Nothing)
            || (rec.motherCR == Nothing)
            || (rec.babyRR == Nothing)
            || (rec.babyTemp == Nothing)
            || (rec.babyCR == Nothing)
            || (validateBool rec.ppInstructionsSchedule)
            || (validateBool rec.birthCertWorksheet)
            || (validateBool rec.birthRecorded)
            || (validateBool rec.chartsComplete)
            || (validateBool rec.logsComplete)
            || (validateBool rec.billPaid)
            || (rec.nbs == Nothing)
            || (validateBool rec.immunizationReferral)
            || (validateBool rec.breastFeedingEstablished)
            || (validateBool rec.newbornBath)
            || (validateBool rec.fundusFirmBleedingCtld)
            || (validateBool rec.motherAteDrank)
            || (validateBool rec.motherUrinated)
            || (validateBool rec.placentaGone)
        )
