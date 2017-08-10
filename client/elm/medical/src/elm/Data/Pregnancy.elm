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
        |> JDP.required "sureLMP" (JD.maybe JD.bool)
        |> JDP.required "warning" (JD.maybe JD.bool)
        |> JDP.required "riskNote" (JD.maybe JD.string)
        |> JDP.required "alternateEdd" (JD.maybe JDE.date)
        |> JDP.required "useAlternateEdd" (JD.maybe JD.bool)
        |> JDP.required "doctorConsultDate" (JD.maybe JDE.date)
        |> JDP.required "dentistConsultDate" (JD.maybe JDE.date)
        |> JDP.required "mbBook" (JD.maybe JD.bool)
        |> JDP.required "whereDeliver" (JD.maybe JD.string)
        |> JDP.required "fetuses" (JD.maybe JD.int)
        |> JDP.required "monozygotic" (JD.maybe JD.bool)
        |> JDP.required "pregnancyEndDate" (JD.maybe JDE.date)
        |> JDP.required "pregnancyEndResult" (JD.maybe JD.string)
        |> JDP.required "iugr" (JD.maybe JD.bool)
        |> JDP.required "note" (JD.maybe JD.string)
        |> JDP.required "numberRequiredTetanus" (JD.maybe JD.int)
        |> JDP.required "invertedNipples" (JD.maybe JD.bool)
        |> JDP.required "hasUS" (JD.maybe JD.bool)
        |> JDP.required "wantsUS" (JD.maybe JD.bool)
        |> JDP.required "gravida" (JD.maybe JD.int)
        |> JDP.required "stillBirths" (JD.maybe JD.int)
        |> JDP.required "abortions" (JD.maybe JD.int)
        |> JDP.required "living" (JD.maybe JD.int)
        |> JDP.required "para" (JD.maybe JD.int)
        |> JDP.required "term" (JD.maybe JD.int)
        |> JDP.required "preterm" (JD.maybe JD.int)
        |> JDP.required "philHealthMCP" (JD.maybe JD.bool)
        |> JDP.required "philHealthNCP" (JD.maybe JD.bool)
        |> JDP.required "philHealthID" (JD.maybe JD.string)
        |> JDP.required "philHealthApproved" (JD.maybe JD.bool)
        |> JDP.required "transferOfCare" (JD.maybe JDE.date)
        |> JDP.required "transferOfCareNote" (JD.maybe JD.string)
        |> JDP.required "currentlyVomiting" (JD.maybe JD.bool)
        |> JDP.required "currentlyDizzy" (JD.maybe JD.bool)
        |> JDP.required "currentlyFainting" (JD.maybe JD.bool)
        |> JDP.required "currentlyBleeding" (JD.maybe JD.bool)
        |> JDP.required "currentlyUrinationPain" (JD.maybe JD.bool)
        |> JDP.required "currentlyBlurryVision" (JD.maybe JD.bool)
        |> JDP.required "currentlySwelling" (JD.maybe JD.bool)
        |> JDP.required "currentlyVaginalPain" (JD.maybe JD.bool)
        |> JDP.required "currentlyVaginalItching" (JD.maybe JD.bool)
        |> JDP.required "currentlyNone" (JD.maybe JD.bool)
        |> JDP.required "useIodizedSalt" (JD.maybe JD.string)
        |> JDP.required "takingMedication" (JD.maybe JD.string)
        |> JDP.required "planToBreastFeed" (JD.maybe JD.string)
        |> JDP.required "birthCompanion" (JD.maybe JD.string)
        |> JDP.required "practiceFamilyPlanning" (JD.maybe JD.bool)
        |> JDP.required "practiceFamilyPlanningDetails" (JD.maybe JD.string)
        |> JDP.required "familyHistoryTwins" (JD.maybe JD.bool)
        |> JDP.required "familyHistoryHighBloodPressure" (JD.maybe JD.bool)
        |> JDP.required "familyHistoryDiabetes" (JD.maybe JD.bool)
        |> JDP.required "familyHistoryHeartProblems" (JD.maybe JD.bool)
        |> JDP.required "familyHistoryTB" (JD.maybe JD.bool)
        |> JDP.required "familyHistorySmoking" (JD.maybe JD.bool)
        |> JDP.required "familyHistoryNone" (JD.maybe JD.bool)
        |> JDP.required "historyFoodAllergy" (JD.maybe JD.bool)
        |> JDP.required "historyMedicineAllergy" (JD.maybe JD.bool)
        |> JDP.required "historyAsthma" (JD.maybe JD.bool)
        |> JDP.required "historyHeartProblems" (JD.maybe JD.bool)
        |> JDP.required "historyKidneyProblems" (JD.maybe JD.bool)
        |> JDP.required "historyHepatitis" (JD.maybe JD.bool)
        |> JDP.required "historyGoiter" (JD.maybe JD.bool)
        |> JDP.required "historyHighBloodPressure" (JD.maybe JD.bool)
        |> JDP.required "historyHospitalOperation" (JD.maybe JD.bool)
        |> JDP.required "historyBloodTransfusion" (JD.maybe JD.bool)
        |> JDP.required "historySmoking" (JD.maybe JD.bool)
        |> JDP.required "historyDrinking" (JD.maybe JD.bool)
        |> JDP.required "historyNone" (JD.maybe JD.bool)
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
