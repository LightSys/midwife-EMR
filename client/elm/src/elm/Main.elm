module Main exposing (..)

import Html


-- LOCAL IMPORTS

import Decoders exposing (..)
import Model exposing (..)
import Msg exposing (..)
import Ports
import Update exposing (update)
import View as View


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
            |> Sub.map MedicationTypeMessages
        , Ports.pregnoteType Decoders.decodePregnoteTypeTable
            |> Sub.map PregnoteTypeResponse
        , Ports.riskCode Decoders.decodeRiskCodeTable
            |> Sub.map RiskCodeResponse
        , Ports.vaccinationType Decoders.decodeVaccinationTypeTable
            |> Sub.map VaccinationTypeResponse
        , Ports.changeResponse Decoders.decodeChangeResponse
            |> Sub.map ChangeResponseMsg
        , Ports.addResponse Decoders.decodeAddResponse
            |> Sub.map AddResponseMsg
        , Ports.delResponse Decoders.decodeDelResponse
            |> Sub.map DelResponseMsg
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = View.view
        , subscriptions = subscriptions
        }
