module Utils
    exposing
        ( addMessage
        , addWarning
        , getIdxRemoteDataById
        , maybeStringToInt
        , stringToTable
        , tableToString
        )

import Json.Encode as JE
import List.Extra as LE
import Material.Snackbar as Snackbar
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (..)
import Types exposing (..)


tableToString : Table -> String
tableToString table =
    case table of
        Unknown ->
            ""

        CustomField ->
            "customField"

        CustomFieldType ->
            "customFieldType"

        Event ->
            "event"

        EventType ->
            "eventType"

        HealthTeaching ->
            "healthTeaching"

        LabSuite ->
            "labSuite"

        LabTest ->
            "labTest"

        LabTestResult ->
            "labTestResult"

        LabTestValue ->
            "labTestValue"

        Medication ->
            "medication"

        MedicationType ->
            "medicationType"

        Patient ->
            "patient"

        Pregnancy ->
            "pregnancy"

        PregnancyHistory ->
            "pregnancyHistory"

        Pregnote ->
            "pregnote"

        PregnoteType ->
            "pregnoteType"

        PrenatalExam ->
            "prenatalExam"

        Priority ->
            "priority"

        Risk ->
            "risk"

        RiskCode ->
            "riskCode"

        Referral ->
            "referral"

        RoFieldsByRole ->
            "roFieldsByRole"

        Role ->
            "role"

        Schedule ->
            "schedule"

        SelectData ->
            "selectData"

        User ->
            "user"

        Vaccination ->
            "vaccination"

        VaccinationType ->
            "vaccinationType"


stringToTable : String -> Table
stringToTable name =
    case name of
        "customField" ->
            CustomField

        "customFieldType" ->
            CustomFieldType

        "event" ->
            Event

        "eventType" ->
            EventType

        "healthTeaching" ->
            HealthTeaching

        "labSuite" ->
            LabSuite

        "labTest" ->
            LabTest

        "labTestResult" ->
            LabTestResult

        "labTestValue" ->
            LabTestValue

        "medication" ->
            Medication

        "medicationType" ->
            MedicationType

        "patient" ->
            Patient

        "pregnancy" ->
            Pregnancy

        "pregnancyHistory" ->
            PregnancyHistory

        "pregnote" ->
            Pregnote

        "pregnoteType" ->
            PregnoteType

        "prenatalExam" ->
            PrenatalExam

        "priority" ->
            Priority

        "risk" ->
            Risk

        "riskCode" ->
            RiskCode

        "referral" ->
            Referral

        "roFieldsByRole" ->
            RoFieldsByRole

        "role" ->
            Role

        "schedule" ->
            Schedule

        "selectData" ->
            SelectData

        "user" ->
            User

        "vaccination" ->
            Vaccination

        "vaccinationType" ->
            VaccinationType

        _ ->
            Unknown


{-| Converts a String to an Int using a default
value passed upon failure.
-}
maybeStringToInt : Int -> Maybe String -> Int
maybeStringToInt default str =
    Maybe.withDefault "" str
        |> String.toInt
        |> Result.withDefault default


addMessage : String -> Model -> ( Model, Cmd Msg )
addMessage msg model =
    let
        sbContent =
            Snackbar.toast "" msg

        ( sbModel, sbCmd ) =
            Snackbar.add sbContent model.snackbar
    in
        ( { model | snackbar = sbModel }, Cmd.map Snackbar sbCmd )


addWarning : String -> Model -> ( Model, Cmd Msg )
addWarning msg model =
    let
        sbContent =
            Snackbar.Contents msg (Just "Warning") "" 5000 250

        ( sbModel, sbCmd ) =
            Snackbar.add sbContent model.snackbar
    in
        ( { model | snackbar = sbModel }, Cmd.map Snackbar sbCmd )


getIdxRemoteDataById : Int -> RemoteData e (List { a | id : Int }) -> Maybe Int
getIdxRemoteDataById id rdata =
    case rdata of
        Success recs ->
            case LE.findIndex (\r -> r.id == id) recs of
                Just idx ->
                    Just idx

                Nothing ->
                    Nothing

        _ ->
            Nothing


