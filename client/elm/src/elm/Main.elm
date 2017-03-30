module Main exposing (..)

import Html
import Navigation exposing (Location)
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Model exposing (..)
import Msg exposing (..)
import Ports
import Types exposing (adminPages)
import Update exposing (update)
import Utils exposing (locationToPage)
import View as View


-- MAIN


init : Location -> ( Model, Cmd Msg )
init location =
    let
        model =
            { initialModel | selectedPage = locationToPage location adminPages }
    in
        model ! [ Task.perform (always RequestUserProfile) (Task.succeed True) ]


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
    Navigation.program
        UrlChange
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = View.view
        }
