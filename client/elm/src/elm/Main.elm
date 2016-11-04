module Main exposing (..)

import Html.App as App
import Json.Decode as JD
import Material


-- LOCAL IMPORTS

import Decoders exposing (..)
import Model exposing (..)
import Msg exposing (..)
import Ports
import View as View


-- UPDATE


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



-- MAIN


init : ( Model, Cmd Msg )
init =
    Model.initialModel ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.systemMessages Decoders.decodeSystemMessage
            |> Sub.map NewSystemMessage
        ]


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , view = View.view
        , subscriptions = subscriptions
        }
