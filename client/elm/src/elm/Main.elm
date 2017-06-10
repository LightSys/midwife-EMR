module Main exposing (..)

import Html
import Navigation exposing (Location)
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Model exposing (..)
import Msg exposing (..)
import Ports
import Types exposing (Page(..), adminPages, allPages)
import Update exposing (update)
import Utils exposing (locationToPage)
import View as View


-- MAIN


{-| Set the selectedPage to the page specified in location
as much as possible and load the profile as soon as
possible as well.

TODO: after adding a different role, make sure that this
does not allow inappropriate pages per the role.
-}
init : Location -> ( Model, Cmd Msg )
init location =
    let
        page =
            locationToPage location allPages
                |> (\p ->
                        if p == PageDefNotFoundPage then
                            ProfileNotLoadedPage
                        else
                            p
                   )

        model =
            { initialModel | selectedPage = page }
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
