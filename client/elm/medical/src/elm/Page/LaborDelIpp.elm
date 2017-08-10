module Page.LaborDelIpp exposing (Model, init, update, view)


import Html as H exposing (Html)
import Task exposing (Task)
import Window


-- LOCAL IMPORTS --

import Data.LaborDelIpp exposing (InternalMsg(..))
import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Pregnancy exposing (getPregId, PregnancyId(..))
import Data.Processing exposing (ProcessId(..))
import Data.SelectQuery exposing (SelectQuery, selectQueryToValue)
import Data.Session as Session exposing (Session)
import Data.Table exposing (Table(..))
import Msg exposing (Msg(..), ProcessType(..))
import Page.Errored as Errored exposing (PageLoadError)
import Ports
import Processing exposing (ProcessStore)
import Util exposing ((=>))


-- MODEL --

type alias Model =
    { pregnancy_id : PregnancyId
    }


init : PregnancyId -> Session -> ProcessStore -> ( ProcessStore, Cmd Msg )
init pregId session store =
    let
        selectQuery =
            SelectQuery Pregnancy (Just (getPregId pregId)) [ Patient ]

        (processId, processStore ) =
            Processing.add (SelectQueryType LaborDelIppLoaded selectQuery) Nothing store

        msg =
            wrapPayload processId SelectMsgType (selectQueryToValue selectQuery)
    in
    processStore
        => Ports.outgoing msg


view : (Maybe Window.Size) -> Session -> Model -> Html Msg
view size session model =
    H.div []
        [ H.text <| "Pregnancy id: " ++ (toString <| getPregId model.pregnancy_id)
        , H.br [][]
        , H.text <| "Window size: " ++ (toString size)
        ]



-- UPDATE --


update : Session -> InternalMsg -> Model -> ( Model, Cmd InternalMsg )
update session msg model =
    case msg of
        PageNoop ->
            ( model, Cmd.none )
