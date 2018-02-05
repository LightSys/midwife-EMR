module Data.Pregnancy
    exposing
        ( getPregId
        , PregnancyId(..)
        , PregnancyRecord
        , pregnancyRecord
        )

import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP

-- LOCAL IMPORTS

import Util as U

type PregnancyId
    = PregnancyId Int


type alias PregnancyRecord =
    { id : Int
    , firstname : String
    , lastname : String
    , maidenname : Maybe String
    , nickname : Maybe String
    , religion : Maybe String
    , maritalStatus : Maybe String
    , telephone : Maybe String
    , work : Maybe String
    , education : Maybe String
    , clientIncome : Maybe Int
    , clientIncomePeriod : Maybe String
    , address1 : Maybe String
    , address2 : Maybe String
    , address3 : Maybe String
    , address4 : Maybe String
    , city : Maybe String
    , state : Maybe String
    , postalCode : Maybe String
    , country : Maybe String
    , gravidaNumber : Maybe Int
    , lmp : Maybe Date
    , sureLMP : Maybe Bool
    , warning : Maybe Bool
    , riskNote : Maybe String
    , alternateEdd : Maybe Date
    , useAlternateEdd : Maybe Bool
    , doctorConsultDate : Maybe Date
    , dentistConsultDate : Maybe Date
    , mbBook : Maybe Bool
    , whereDeliver : Maybe String
    , fetuses : Maybe Int
    , monozygotic : Maybe Bool
    , pregnancyEndDate : Maybe Date
    , pregnancyEndResult : Maybe String
    , iugr : Maybe Bool
    , note : Maybe String
    , numberRequiredTetanus : Maybe Int
    , invertedNipples : Maybe Bool
    , hasUS : Maybe Bool
    , wantsUS : Maybe Bool
    , gravida : Maybe Int
    , stillBirths : Maybe Int
    , abortions : Maybe Int
    , living : Maybe Int
    , para : Maybe Int
    , term : Maybe Int
    , preterm : Maybe Int
    , philHealthMCP : Maybe Bool
    , philHealthNCP : Maybe Bool
    , philHealthID : Maybe String
    , philHealthApproved : Maybe Bool
    , transferOfCare : Maybe Date
    , transferOfCareNote : Maybe String
    , currentlyVomiting : Maybe Bool
    , currentlyDizzy : Maybe Bool
    , currentlyFainting : Maybe Bool
    , currentlyBleeding : Maybe Bool
    , currentlyUrinationPain : Maybe Bool
    , currentlyBlurryVision : Maybe Bool
    , currentlySwelling : Maybe Bool
    , currentlyVaginalPain : Maybe Bool
    , currentlyVaginalItching : Maybe Bool
    , currentlyNone : Maybe Bool
    , useIodizedSalt : Maybe String
    , takingMedication : Maybe String
    , planToBreastFeed : Maybe String
    , birthCompanion : Maybe String
    , practiceFamilyPlanning : Maybe Bool
    , practiceFamilyPlanningDetails : Maybe String
    , familyHistoryTwins : Maybe Bool
    , familyHistoryHighBloodPressure : Maybe Bool
    , familyHistoryDiabetes : Maybe Bool
    , familyHistoryHeartProblems : Maybe Bool
    , familyHistoryTB : Maybe Bool
    , familyHistorySmoking : Maybe Bool
    , familyHistoryNone : Maybe Bool
    , historyFoodAllergy : Maybe Bool
    , historyMedicineAllergy : Maybe Bool
    , historyAsthma : Maybe Bool
    , historyHeartProblems : Maybe Bool
    , historyKidneyProblems : Maybe Bool
    , historyHepatitis : Maybe Bool
    , historyGoiter : Maybe Bool
    , historyHighBloodPressure : Maybe Bool
    , historyHospitalOperation : Maybe Bool
    , historyBloodTransfusion : Maybe Bool
    , historySmoking : Maybe Bool
    , historyDrinking : Maybe Bool
    , historyNone : Maybe Bool
    , questionnaireNote : Maybe String
    , partnerFirstname : Maybe String
    , partnerLastname : Maybe String
    , partnerAge : Maybe Int
    , partnerWork : Maybe String
    , partnerEducation : Maybe String
    , partnerIncome : Maybe Int
    , partnerIncomePeriod : Maybe String
    , patient_id : Int
    }


{-| Decode the pregnancy record from JSON.
-}
pregnancyRecord : JD.Decoder PregnancyRecord
pregnancyRecord =
    JDP.decode PregnancyRecord
        |> JDP.required "id" JD.int
        |> JDP.required "firstname" JD.string
        |> JDP.required "lastname" JD.string
        |> JDP.required "maidenname" (JD.maybe JD.string)
        |> JDP.required "nickname" (JD.maybe JD.string)
        |> JDP.required "religion" (JD.maybe JD.string)
        |> JDP.required "maritalStatus" (JD.maybe JD.string)
        |> JDP.required "telephone" (JD.maybe JD.string)
        |> JDP.required "work" (JD.maybe JD.string)
        |> JDP.required "education" (JD.maybe JD.string)
        |> JDP.required "clientIncome" (JD.maybe JD.int)
        |> JDP.required "clientIncomePeriod" (JD.maybe JD.string)
        |> JDP.required "address1" (JD.maybe JD.string)
        |> JDP.required "address2" (JD.maybe JD.string)
        |> JDP.required "address3" (JD.maybe JD.string)
        |> JDP.required "address4" (JD.maybe JD.string)
        |> JDP.required "city" (JD.maybe JD.string)
        |> JDP.required "state" (JD.maybe JD.string)
        |> JDP.required "postalCode" (JD.maybe JD.string)
        |> JDP.required "country" (JD.maybe JD.string)
        |> JDP.required "gravidaNumber" (JD.maybe JD.int)
        |> JDP.required "lmp" (JD.maybe JDE.date)
        |> JDP.required "sureLMP" U.maybeIntToMaybeBool
        |> JDP.required "warning" U.maybeIntToMaybeBool
        |> JDP.required "riskNote" (JD.maybe JD.string)
        |> JDP.required "alternateEdd" (JD.maybe JDE.date)
        |> JDP.required "useAlternateEdd" U.maybeIntToMaybeBool
        |> JDP.required "doctorConsultDate" (JD.maybe JDE.date)
        |> JDP.required "dentistConsultDate" (JD.maybe JDE.date)
        |> JDP.required "mbBook" U.maybeIntToMaybeBool
        |> JDP.required "whereDeliver" (JD.maybe JD.string)
        |> JDP.required "fetuses" (JD.maybe JD.int)
        |> JDP.required "monozygotic" U.maybeIntToMaybeBool
        |> JDP.required "pregnancyEndDate" (JD.maybe JDE.date)
        |> JDP.required "pregnancyEndResult" (JD.maybe JD.string)
        |> JDP.required "iugr" U.maybeIntToMaybeBool
        |> JDP.required "note" (JD.maybe JD.string)
        |> JDP.required "numberRequiredTetanus" (JD.maybe JD.int)
        |> JDP.required "invertedNipples" U.maybeIntToMaybeBool
        |> JDP.required "hasUS" U.maybeIntToMaybeBool
        |> JDP.required "wantsUS" U.maybeIntToMaybeBool
        |> JDP.required "gravida" (JD.maybe JD.int)
        |> JDP.required "stillBirths" (JD.maybe JD.int)
        |> JDP.required "abortions" (JD.maybe JD.int)
        |> JDP.required "living" (JD.maybe JD.int)
        |> JDP.required "para" (JD.maybe JD.int)
        |> JDP.required "term" (JD.maybe JD.int)
        |> JDP.required "preterm" (JD.maybe JD.int)
        |> JDP.required "philHealthMCP" U.maybeIntToMaybeBool
        |> JDP.required "philHealthNCP" U.maybeIntToMaybeBool
        |> JDP.required "philHealthID" (JD.maybe JD.string)
        |> JDP.required "philHealthApproved" U.maybeIntToMaybeBool
        |> JDP.required "transferOfCare" (JD.maybe JDE.date)
        |> JDP.required "transferOfCareNote" (JD.maybe JD.string)
        |> JDP.required "currentlyVomiting" U.maybeIntToMaybeBool
        |> JDP.required "currentlyDizzy" U.maybeIntToMaybeBool
        |> JDP.required "currentlyFainting" U.maybeIntToMaybeBool
        |> JDP.required "currentlyBleeding" U.maybeIntToMaybeBool
        |> JDP.required "currentlyUrinationPain" U.maybeIntToMaybeBool
        |> JDP.required "currentlyBlurryVision" U.maybeIntToMaybeBool
        |> JDP.required "currentlySwelling" U.maybeIntToMaybeBool
        |> JDP.required "currentlyVaginalPain" U.maybeIntToMaybeBool
        |> JDP.required "currentlyVaginalItching" U.maybeIntToMaybeBool
        |> JDP.required "currentlyNone" U.maybeIntToMaybeBool
        |> JDP.required "useIodizedSalt" (JD.maybe JD.string)
        |> JDP.required "takingMedication" (JD.maybe JD.string)
        |> JDP.required "planToBreastFeed" (JD.maybe JD.string)
        |> JDP.required "birthCompanion" (JD.maybe JD.string)
        |> JDP.required "practiceFamilyPlanning" U.maybeIntToMaybeBool
        |> JDP.required "practiceFamilyPlanningDetails" (JD.maybe JD.string)
        |> JDP.required "familyHistoryTwins" U.maybeIntToMaybeBool
        |> JDP.required "familyHistoryHighBloodPressure" U.maybeIntToMaybeBool
        |> JDP.required "familyHistoryDiabetes" U.maybeIntToMaybeBool
        |> JDP.required "familyHistoryHeartProblems" U.maybeIntToMaybeBool
        |> JDP.required "familyHistoryTB" U.maybeIntToMaybeBool
        |> JDP.required "familyHistorySmoking" U.maybeIntToMaybeBool
        |> JDP.required "familyHistoryNone" U.maybeIntToMaybeBool
        |> JDP.required "historyFoodAllergy" U.maybeIntToMaybeBool
        |> JDP.required "historyMedicineAllergy" U.maybeIntToMaybeBool
        |> JDP.required "historyAsthma" U.maybeIntToMaybeBool
        |> JDP.required "historyHeartProblems" U.maybeIntToMaybeBool
        |> JDP.required "historyKidneyProblems" U.maybeIntToMaybeBool
        |> JDP.required "historyHepatitis" U.maybeIntToMaybeBool
        |> JDP.required "historyGoiter" U.maybeIntToMaybeBool
        |> JDP.required "historyHighBloodPressure" U.maybeIntToMaybeBool
        |> JDP.required "historyHospitalOperation" U.maybeIntToMaybeBool
        |> JDP.required "historyBloodTransfusion" U.maybeIntToMaybeBool
        |> JDP.required "historySmoking" U.maybeIntToMaybeBool
        |> JDP.required "historyDrinking" U.maybeIntToMaybeBool
        |> JDP.required "historyNone" U.maybeIntToMaybeBool
        |> JDP.required "questionnaireNote" (JD.maybe JD.string)
        |> JDP.required "partnerFirstname" (JD.maybe JD.string)
        |> JDP.required "partnerLastname" (JD.maybe JD.string)
        |> JDP.required "partnerAge" (JD.maybe JD.int)
        |> JDP.required "partnerWork" (JD.maybe JD.string)
        |> JDP.required "partnerEducation" (JD.maybe JD.string)
        |> JDP.required "partnerIncome" (JD.maybe JD.int)
        |> JDP.required "partnerIncomePeriod" (JD.maybe JD.string)
        |> JDP.required "patient_id" JD.int


getPregId : PregnancyId -> Int
getPregId (PregnancyId id) =
    id
