module AdminMain exposing (..)

import Html.App as App
import Material


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (..)
import View as View


-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl matMsg ->
            Material.update matMsg model

        SelectTab tab ->
            { model | selectedTab = tab } ! []

        NoOp ->
            let
                _ =
                    Debug.log "NoOp" "was called"
            in
                model ! []



-- MAIN


init : ( Model, Cmd Msg )
init =
    { mdl = Material.model
    , user = 1
    , selectedTab = HomeTab
    , selectedPage = HomePage
    }
        ! []


subscriptions : a -> Sub msg
subscriptions =
    always Sub.none


main : Program Never
main =
    App.program
        { init = init
        , update = update
        , view = View.view
        , subscriptions = subscriptions
        }
