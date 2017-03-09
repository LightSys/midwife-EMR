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
        [ Ports.addResponse Decoders.decodeAddResponse
            |> Sub.map AddResponseMsg
        , Ports.changeResponse Decoders.decodeChangeResponse
            |> Sub.map ChangeResponseMsg
        , Ports.delResponse Decoders.decodeDelResponse
            |> Sub.map DelResponseMsg
        , Ports.selectQueryResponse Decoders.decodeSelectQueryResponse
            |> Sub.map SelectQueryResponseMsg
        , Ports.systemMessages Decoders.decodeSystemMessage
            |> Sub.map NewSystemMessage
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = View.view
        , subscriptions = subscriptions
        }
