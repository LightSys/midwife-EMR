module Page.Postpartum
    exposing
        ( Model
        , buildModel
        , init
        , update
        , view
        )

import Date exposing (Date)
import Dict exposing (Dict)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import List.Extra as LE
import Task exposing (Task)
import Time exposing (Time)
import Validate exposing (ifBlank, ifInvalid, ifNotInt)
import Window


-- LOCAL IMPORTS --

import Data.Baby
    exposing
        ( BabyRecord
        )
import Data.DataCache as DataCache exposing (DataCache(..))
import Data.Labor
    exposing
        ( getLaborId
          --, getMostRecentLaborRecord
        , LaborId(..)
        , LaborRecord
          --, LaborRecordNew
          --, laborRecordNewToValue
          --, laborRecordNewToLaborRecord
          --, laborRecordToValue
        )
import Data.LaborStage1 exposing (LaborStage1Record)
import Data.LaborStage2 exposing (LaborStage2Record)
import Data.LaborStage3 exposing (LaborStage3Record)
import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Patient exposing (PatientRecord)
import Data.Postpartum
    exposing
        ( SubMsg(..)
        )
import Data.PostpartumCheck exposing (PostpartumCheck)
import Data.Pregnancy
    exposing
        ( getPregId
        , PregnancyId(..)
        , PregnancyRecord
        )
import Data.PregnancyHeader as PregHeaderData exposing (PregHeaderContent(..))
import Data.SelectQuery exposing (SelectQuery, selectQueryToValue)
import Data.Session as Session exposing (Session)
import Data.Table exposing (Table(..))
import Msg
    exposing
        ( logConsole
        , Msg(..)
        , ProcessType(..)
        , toastInfo
        , toastWarn
        , toastError
        )
import Ports
import Processing exposing (ProcessStore)
import Route
import Util as U exposing ((=>))
import Views.PregnancyHeader as PregHeaderView


-- MODEL --


type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , pregnancy_id : PregnancyId
    , currLaborId : Maybe LaborId
    , currPregHeaderContent : PregHeaderData.PregHeaderContent
    , dataCache : Dict String DataCache
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    , laborRecord : LaborRecord
    , laborStage1Record : Maybe LaborStage1Record
    , laborStage2Record : Maybe LaborStage2Record
    , laborStage3Record : Maybe LaborStage3Record
    , babyRecords : Maybe (Dict Int BabyRecord)
    }


{-| Get records from the server that we don't already have like baby and
postpartum checks.
-}
init : PregnancyId -> LaborRecord -> Session -> ProcessStore -> ( ProcessStore, Cmd Msg )
init pregId laborRec session store =
    let
        selectQuery =
            SelectQuery Labor (Just laborRec.id) [ LaborStage1, LaborStage2, LaborStage3, Baby ]

        ( processId, processStore ) =
            Processing.add (SelectQueryType (PostpartumLoaded pregId laborRec) selectQuery) Nothing store

        msg =
            wrapPayload processId SelectMsgType (selectQueryToValue selectQuery)
    in
        processStore
            => Ports.outgoing msg


{-| Builds the initial model for the page.
-}
buildModel :
    LaborRecord
    -> Maybe LaborStage1Record
    -> Maybe LaborStage2Record
    -> Maybe LaborStage3Record
    -> Maybe (Dict Int BabyRecord)
    -> Bool
    -> Time
    -> ProcessStore
    -> PregnancyId
    -> Maybe PatientRecord
    -> Maybe PregnancyRecord
    -> ( Model, ProcessStore, Cmd Msg )
buildModel laborRec stage1Rec stage2Rec stage3Rec babyRecords browserSupportsDate currTime store pregId patRec pregRec =
    ( Model browserSupportsDate
        currTime
        pregId
        (Just (LaborId laborRec.id))
        PregHeaderData.IPPContent
        Dict.empty
        patRec
        pregRec
        laborRec
        stage1Rec
        stage2Rec
        stage3Rec
        babyRecords
    , store
    , Cmd.none
    )



-- UPDATE --


{-| Extract data by key from the data cache passed and populate the
model with it. We do not update the model's fields except per the
list of keys (List Table) passed, which has to be initiated elsewhere
in this module. This is so that fields are not willy nilly overwritten
unexpectedly.
-}
refreshModelFromCache : Dict String DataCache -> List Table -> Model -> Model
refreshModelFromCache dc tables model =
    let
        newModel =
            List.foldl
                (\t m ->
                    case t of
                        Labor ->
                            case DataCache.get t dc of
                                Just (LaborDataCache recs) ->
                                    case Dict.values recs |> List.head of
                                        Just rec ->
                                            { m | laborRecord = rec }

                                        Nothing ->
                                            m

                                _ ->
                                    m

                        LaborStage1 ->
                            case DataCache.get t dc of
                                Just (LaborStage1DataCache rec) ->
                                    { m | laborStage1Record = Just rec }

                                _ ->
                                    m

                        LaborStage2 ->
                            case DataCache.get t dc of
                                Just (LaborStage2DataCache rec) ->
                                    { m | laborStage2Record = Just rec }

                                _ ->
                                    m

                        LaborStage3 ->
                            case DataCache.get t dc of
                                Just (LaborStage3DataCache rec) ->
                                    { m | laborStage3Record = Just rec }

                                _ ->
                                    m

                        _ ->
                            let
                                _ =
                                    Debug.log "Postpartum.refreshModelFromCache: Unhandled Table" <| toString t
                            in
                                m
                )
                model
                tables
    in
        newModel


update : Session -> SubMsg -> Model -> ( Model, Cmd SubMsg, Cmd Msg )
update session msg model =
    case msg of
        PageNoop ->
            let
                _ =
                    Debug.log "PageNoop" "was called."
            in
                ( model, Cmd.none, Cmd.none )

        DataCache dc tbls ->
            -- If the dataCache and tables are something, this is the top-level
            -- intentionally sending it's dataCache to us as a read-only update
            -- on the latest data that it has. The specific records that need
            -- to be updated are in the tables list.
            ( case ( dc, tbls ) of
                ( Just dataCache, Just tables ) ->
                    let
                        newModel =
                            refreshModelFromCache dataCache tables model
                    in
                        { newModel | dataCache = dataCache }

                ( _, _ ) ->
                    model
            , Cmd.none
            , Cmd.none
            )

        RotatePregHeaderContent pregHeaderMsg ->
            case pregHeaderMsg of
                PregHeaderData.RotatePregHeaderContentMsg ->
                    let
                        next =
                            case model.currPregHeaderContent of
                                PregHeaderData.PrenatalContent ->
                                    PregHeaderData.LaborContent

                                PregHeaderData.LaborContent ->
                                    PregHeaderData.IPPContent

                                PregHeaderData.IPPContent ->
                                    PregHeaderData.PrenatalContent
                    in
                        ( { model | currPregHeaderContent = next }, Cmd.none, Cmd.none )



-- VIEW --


view : Maybe Window.Size -> Session -> Model -> Html SubMsg
view size session model =
    let
        pregHeader =
            case ( model.patientRecord, model.pregnancyRecord ) of
                ( Just patRec, Just pregRec ) ->
                    let
                        laborInfo =
                            PregHeaderData.LaborInfo (Just (Dict.singleton model.laborRecord.id model.laborRecord))
                                model.laborStage1Record
                                model.laborStage2Record
                                model.laborStage3Record
                    in
                        PregHeaderView.view patRec
                            pregRec
                            laborInfo
                            model.currPregHeaderContent
                            model.currTime
                            size

                ( _, _ ) ->
                    H.text ""
    in
        H.div []
            [ pregHeader |> H.map (\a -> RotatePregHeaderContent a)
            , H.div [ HA.class "content-wrapper" ]
                [ viewBabyEdit model
                ]
            ]


viewBabyEdit : Model -> Html SubMsg
viewBabyEdit model =
    H.div []
        [ H.h3 [ HA.class "c-heading u-medium" ]
            [ H.text "What will be on this page" ]
        , H.ul []
            [ H.li [] [ H.text "Post-partum checks" ]
            ]
        ]
