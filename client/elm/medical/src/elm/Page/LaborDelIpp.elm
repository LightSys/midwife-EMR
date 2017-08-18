module Page.LaborDelIpp
    exposing
        ( Model
        , buildModel
        , init
        , update
        , view
        )

import Html as H exposing (Html)
import Task exposing (Task)
import Window


-- LOCAL IMPORTS --

import Data.LaborDelIpp exposing (InternalMsg(..))
import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (getPregId, PregnancyId(..), PregnancyRecord)
import Data.Processing exposing (ProcessId(..))
import Data.SelectQuery exposing (SelectQuery, selectQueryToValue)
import Data.Session as Session exposing (Session)
import Data.Table exposing (Table(..))
import Msg exposing (Msg(..), ProcessType(..))
import Page.Errored as Errored exposing (PageLoadError)
import Ports
import Processing exposing (ProcessStore)
import Time exposing (Time)
import Util exposing ((=>))
import Views.PregnancyHeader exposing (viewPrenatal)


-- MODEL --


type alias Model =
    { currTime : Time
    , pregnancy_id : PregnancyId
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    }


buildModel : Time -> PregnancyId -> Maybe PatientRecord -> Maybe PregnancyRecord -> Model
buildModel currTime pregId patrec pregRec =
    Model currTime pregId patrec pregRec


init : PregnancyId -> Session -> ProcessStore -> ( ProcessStore, Cmd Msg )
init pregId session store =
    let
        selectQuery =
            SelectQuery Pregnancy (Just (getPregId pregId)) [ Patient ]

        ( processId, processStore ) =
            Processing.add (SelectQueryType (LaborDelIppLoaded pregId) selectQuery) Nothing store

        msg =
            wrapPayload processId SelectMsgType (selectQueryToValue selectQuery)
    in
        processStore
            => Ports.outgoing msg


view : Maybe Window.Size -> Session -> Model -> Html Msg
view size session model =
    let
        pregHeader =
            case (model.patientRecord, model.pregnancyRecord) of
                (Just patRec, Just pregRec) ->
                    viewPrenatal patRec pregRec model.currTime size

                (_, _) ->
                    H.text ""
    in
        H.div []
            [ pregHeader
            ]



-- UPDATE --


update : Session -> InternalMsg -> Model -> ( Model, Cmd InternalMsg )
update session msg model =
    case msg of
        PageNoop ->
            ( model, Cmd.none )
