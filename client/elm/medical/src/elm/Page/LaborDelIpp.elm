module Page.LaborDelIpp exposing (Model, Msg, init, update, view)


import Html as H exposing (Html)
import Task exposing (Task)
import Window


-- LOCAL IMPORTS --

import Data.Pregnancy exposing (getPregId, PregnancyId(..))
import Data.Session as Session exposing (Session)
import Page.Errored as Errored exposing (PageLoadError)


-- MODEL --

type alias Model =
    { pregnancy_id : PregnancyId
    }


init : PregnancyId -> Session -> Task PageLoadError Model
init pregId session =
    Task.succeed { pregnancy_id = pregId }


view : (Maybe Window.Size) -> Session -> Model -> Html Msg
view size session model =
    H.div []
        [ H.text <| "Pregnancy id: " ++ (toString <| getPregId model.pregnancy_id)
        , H.br [][]
        , H.text <| "Window size: " ++ (toString size)
        ]



-- UPDATE --


type Msg
    = PageNoop


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        PageNoop ->
            ( model, Cmd.none )
