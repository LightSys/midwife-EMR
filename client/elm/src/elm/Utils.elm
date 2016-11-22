module Utils
    exposing
        ( tableToString
        , stringToTable
        )

import Json.Encode as JE


-- LOCAL IMPORTS

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
