module Main exposing (..)

import Html.App as App
import Json.Decode as JD
import Material
import RemoteData as RD exposing (RemoteData(..), WebData)


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Msg exposing (..)
import Ports
import Types exposing (..)
import View as View


-- UPDATE


{-| Returns the number of records in the selected table
or zero if anything goes wrong.
-}
numRecsSelectedTable : Model -> Int
numRecsSelectedTable model =
    case model.selectedTable of
        Just t ->
            case t of
                MedicationType ->
                    case model.medicationType of
                        Success val ->
                            (List.length val)

                        _ ->
                            0

                VaccinationType ->
                    case model.vaccinationType of
                        Success val ->
                            (List.length val)

                        _ ->
                            0

                -- TODO: add more tables.
                _ ->
                    0

        Nothing ->
            0


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl matMsg ->
            Material.update matMsg model

        SelectTab tab ->
            { model | selectedTab = tab } ! []

        NewSystemMessage sysMsg ->
            -- We only keep the most recent 1000 messages.
            let
                newSysMessages =
                    if sysMsg.id /= "ERROR" then
                        sysMsg
                            :: model.systemMessages
                            |> List.take 1000
                    else
                        model.systemMessages
            in
                { model | systemMessages = newSysMessages } ! []

        NoOp ->
            let
                _ =
                    Debug.log "NoOp" "was called"
            in
                model ! []

        SelectQuerySelectTable query ->
            -- Perform a SelectQuery and set the selectTable field.
            { model | selectedTable = Just query.table, selectedTableRecord = 0 }
                ! [ Ports.selectQuery (E.selectQueryToValue query) ]

        SelectTableRecord rec ->
            { model | selectedTableRecord = rec } ! []

        FirstRecord ->
            { model | selectedTableRecord = 0 } ! []

        PreviousRecord ->
            { model | selectedTableRecord = max 0 (model.selectedTableRecord - 1) } ! []

        NextRecord ->
            let
                maxRecNumber =
                    (numRecsSelectedTable model) - 1
            in
                { model | selectedTableRecord = min maxRecNumber (model.selectedTableRecord + 1) } ! []

        LastRecord ->
            let
                recNumber =
                    (numRecsSelectedTable model) - 1
            in
                { model | selectedTableRecord = recNumber } ! []

        EventTypeResponse eventTypeTbl ->
            { model | eventType = eventTypeTbl } ! []

        LabSuiteResponse labSuiteTbl ->
            { model | labSuite = labSuiteTbl } ! []

        LabTestResponse labTestTbl ->
            { model | labTest = labTestTbl } ! []

        LabTestValueResponse labTestValueTbl ->
            { model | labTestValue = labTestValueTbl } ! []

        MedicationTypeResponse medicationTypeTbl ->
            { model | medicationType = medicationTypeTbl } ! []

        PregnoteTypeResponse pregnoteTypeTbl ->
            { model | pregnoteType = pregnoteTypeTbl } ! []

        RiskCodeResponse riskCodeTbl ->
            { model | riskCode = riskCodeTbl } ! []

        VaccinationTypeResponse vaccinationTypeTbl ->
            { model | vaccinationType = vaccinationTypeTbl } ! []



-- MAIN


init : ( Model, Cmd Msg )
init =
    Model.initialModel ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.systemMessages Decoders.decodeSystemMessage
            |> Sub.map NewSystemMessage
        , Ports.eventType Decoders.decodeEventTypeTable
            |> Sub.map EventTypeResponse
        , Ports.labSuite Decoders.decodeLabSuiteTable
            |> Sub.map LabSuiteResponse
        , Ports.labTest Decoders.decodeLabTestTable
            |> Sub.map LabTestResponse
        , Ports.labTestValue Decoders.decodeLabTestValueTable
            |> Sub.map LabTestValueResponse
        , Ports.medicationType Decoders.decodeMedicationTypeTable
            |> Sub.map MedicationTypeResponse
        , Ports.pregnoteType Decoders.decodePregnoteTypeTable
            |> Sub.map PregnoteTypeResponse
        , Ports.riskCode Decoders.decodeRiskCodeTable
            |> Sub.map RiskCodeResponse
        , Ports.vaccinationType Decoders.decodeVaccinationTypeTable
            |> Sub.map VaccinationTypeResponse
        ]


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , view = View.view
        , subscriptions = subscriptions
        }
