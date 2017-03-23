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
        [ Ports.adhocResponse Decoders.decodeAdhocResponse
            |> Sub.map AdhocResponseMessages
        , Ports.createResponse Decoders.decodeCreateResponse
            |> Sub.map CreateResponseMsg
        , Ports.deleteResponse Decoders.decodeDeleteResponse
            |> Sub.map DeleteResponseMsg
        , Ports.selectQueryResponse Decoders.decodeSelectQueryResponse
            |> Sub.map SelectQueryResponseMsg
        , Ports.systemMessages Decoders.decodeSystemMessage
            |> Sub.map NewSystemMessage
        , Ports.updateResponse Decoders.decodeUpdateResponse
            |> Sub.map UpdateResponseMsg
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = View.view
        , subscriptions = subscriptions
        }
