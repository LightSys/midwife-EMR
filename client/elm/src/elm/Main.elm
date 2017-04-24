module Main exposing (..)

import Html
import Navigation exposing (Location)
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Model exposing (..)
import Msg exposing (..)
import Ports
import Types exposing (Page(..), adminPages)
import Update exposing (update)
import Utils exposing (locationToPage)
import View as View


-- MAIN


{-| Set the selectedPage to the ProfileNotLoadedPage, which is
not a page at all, and start the process of retrieving the
user's profile information.
-}
init : Location -> ( Model, Cmd Msg )
init location =
    let
        model =
            { initialModel | selectedPage = ProfileNotLoadedPage }
    in
        model ! [ Task.perform (always RequestUserProfile) (Task.succeed True) ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.addChgDelNotification Decoders.decodeAddChgDelNotification
            |> Sub.map AddChgDelNotificationMessages
        , Ports.adhocResponse Decoders.decodeAdhocResponse
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
