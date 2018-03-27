module Page.Postpartum
    exposing
        ( buildModel
        , closeAllDialogs
        , getTablesByCacheOrServer
        , init
        , Model
        , update
        , view
        )

-- TODO: remove unnecessary imports.

import Const exposing (Dialog(..), FldChgValue(..))
import Data.Baby
    exposing
        ( BabyRecord
        )
import Data.BabyLab
    exposing
        ( BabyLabRecord
        )
import Data.BabyLabType
    exposing
        ( BabyLabTypeRecord
        )
import Data.BabyVaccination
    exposing
        ( BabyVaccinationRecord
        )
import Data.BabyVaccinationType
    exposing
        ( BabyVaccinationTypeRecord
        )
import Data.ContPostpartumCheck exposing (ContPostpartumCheckRecord)
import Data.DataCache as DataCache exposing (DataCache(..))
import Data.DatePicker exposing (DateField(..), DateFieldMessage(..), dateFieldToString)
import Data.Labor
    exposing
        ( LaborId(..)
        , LaborRecord
          --, LaborRecordNew
          --, laborRecordNewToValue
          --, laborRecordNewToLaborRecord
          --, laborRecordToValue
        , getLaborId
          --, getMostRecentLaborRecord
        )
import Data.LaborStage1 exposing (LaborStage1Record)
import Data.LaborStage2 exposing (LaborStage2Record)
import Data.LaborStage3 exposing (LaborStage3Record)
import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Patient exposing (PatientRecord)
import Data.Postpartum
    exposing
        ( Field(..)
        , SubMsg(..)
        )
import Data.PostpartumCheck
    exposing
        ( PostpartumCheckId(..)
        , PostpartumCheckRecord
        , PostpartumCheckRecordNew
        , postpartumCheckRecordNewToValue
        , postpartumCheckRecordToValue
        )
import Data.Pregnancy
    exposing
        ( PregnancyId(..)
        , PregnancyRecord
        , getPregId
        )
import Data.PregnancyHeader as PregHeaderData exposing (PregHeaderContent(..))
import Data.SelectData
    exposing
        ( SelectDataRecord
        , filterByName
        , filterSetByString
        , getSelectDataAsMaybeString
        , getSelectDataBySelectKey
        , setSelectedBySelectKey
        )
import Data.SelectQuery exposing (SelectQuery, selectQueryToValue)
import Data.Session as Session exposing (Session)
import Data.Table exposing (Table(..), tableToString)
import Data.Toast exposing (ToastType(..))
import Date exposing (Date)
import Dict exposing (Dict)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import List.Extra as LE
import Msg
    exposing
        ( Msg(..)
        , ProcessType(..)
        , logConsole
        , toastError
        , toastInfo
        , toastWarn
        )
import Ports
import Processing exposing (ProcessStore)
import Route
import Task exposing (Task)
import Time exposing (Time)
import Util as U exposing ((=>))
import Validate exposing (ifBlank, ifInvalid, ifNotInt)
import Views.Form as Form
import Views.PregnancyHeader as PregHeaderView
import Window


-- MODEL --


type ViewEditState
    = NoViewEditState
    | PostpartumCheckViewState
    | PostpartumCheckEditState


{-| TODO: remove unnecessary parts of this model.
-}
type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , pregnancy_id : PregnancyId
    , currLaborId : Maybe LaborId
    , currPostpartumCheckId : Maybe PostpartumCheckId
    , currPregHeaderContent : PregHeaderData.PregHeaderContent
    , dataCache : Dict String DataCache
    , pendingSelectQuery : Dict String Table
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    , laborRecord : LaborRecord
    , laborStage1Record : Maybe LaborStage1Record
    , laborStage2Record : Maybe LaborStage2Record
    , laborStage3Record : Maybe LaborStage3Record
    , contPostpartumCheckRecords : List ContPostpartumCheckRecord
    , babyRecord : Maybe BabyRecord
    , selectDataRecords : List SelectDataRecord
    , babyLabRecords : List BabyLabRecord
    , babyLabTypeRecords : List BabyLabTypeRecord
    , babyVaccinationRecords : List BabyVaccinationRecord
    , babyVaccinationTypeRecords : List BabyVaccinationTypeRecord
    , postpartumCheckRecords : List PostpartumCheckRecord
    , postpartumCheckViewEditState : ViewEditState
    , pcCheckDate : Maybe Date
    , pcCheckTime : Maybe String
    , pcBabyWeight : Maybe String
    , pcBabyTemp : Maybe String
    , pcBabyCR : Maybe String
    , pcBabyRR : Maybe String
    , pcBabyLungs : List SelectDataRecord
    , pcBabyColor : List SelectDataRecord
    , pcBabySkin : List SelectDataRecord
    , pcBabyCord : List SelectDataRecord
    , pcBabyUrine : Maybe String
    , pcBabyStool : Maybe String
    , pcBabySSInfection : List SelectDataRecord
    , pcBabyFeeding : List SelectDataRecord
    , pcBabyFeedingDaily : Maybe String
    , pcMotherTemp : Maybe String
    , pcMotherSystolic : Maybe String
    , pcMotherDiastolic : Maybe String
    , pcMotherCR : Maybe String
    , pcMotherBreasts : List SelectDataRecord
    , pcMotherFundus : List SelectDataRecord
    , pcMotherPerineum : List SelectDataRecord
    , pcMotherLochia : List SelectDataRecord
    , pcMotherUrine : List SelectDataRecord
    , pcMotherStool : List SelectDataRecord
    , pcMotherSSInfection : List SelectDataRecord
    , pcMotherFamilyPlanning : List SelectDataRecord
    , pcBirthCertReq : Maybe Bool
    , pcHgbRequested : Maybe Bool
    , pcHgbTestDate : Maybe Date
    , pcHgbTestResult : Maybe String
    , pcIronGiven : Maybe String
    , pcComments : Maybe String
    , pcNextScheduledCheck : Maybe Date
    }


{-| Updates the model to close all dialogs. Called by Medical.update in
the SetRoute message. This allows the back button to close a dialog.
-}
closeAllDialogs : Model -> Model
closeAllDialogs model =
    { model
        | postpartumCheckViewEditState = NoViewEditState
    }

{-| Clear the continued postpartum check fields in the model.
-}
clearPostpartumCheckModelFields : Model -> Model
clearPostpartumCheckModelFields model =
    { model
        | pcCheckDate = Nothing
        , pcCheckTime = Nothing
        , pcBabyWeight = Nothing
        , pcBabyTemp = Nothing
        , pcBabyCR = Nothing
        , pcBabyRR = Nothing
        , pcBabyLungs = []
        , pcBabyColor = []
        , pcBabySkin = []
        , pcBabyCord = []
        , pcBabyUrine = Nothing
        , pcBabyStool = Nothing
        , pcBabySSInfection = []
        , pcBabyFeeding = []
        , pcBabyFeedingDaily = Nothing
        , pcMotherTemp = Nothing
        , pcMotherSystolic = Nothing
        , pcMotherDiastolic = Nothing
        , pcMotherCR = Nothing
        , pcMotherBreasts = []
        , pcMotherFundus = []
        , pcMotherPerineum = []
        , pcMotherLochia = []
        , pcMotherUrine = []
        , pcMotherStool = []
        , pcMotherSSInfection = []
        , pcMotherFamilyPlanning = []
        , pcBirthCertReq = Nothing
        , pcHgbRequested = Nothing
        , pcHgbTestDate = Nothing
        , pcHgbTestResult = Nothing
        , pcIronGiven = Nothing
        , pcComments = Nothing
        , pcNextScheduledCheck = Nothing
    }


{-| Get records from the server that we don't already have like baby and
postpartum checks.

Note that ContPostpartumCheck records are retrieved in order to calculate
total EBL.

-}
init : PregnancyId -> LaborRecord -> Session -> ProcessStore -> ( ProcessStore, Cmd Msg )
init pregId laborRec session store =
    let
        selectQuery =
            SelectQuery Labor
                (Just laborRec.id)
                [ LaborStage1
                , LaborStage2
                , LaborStage3
                , ContPostpartumCheck
                , Baby
                , PostpartumCheck
                ]

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
    -> List ContPostpartumCheckRecord
    -> Maybe BabyRecord
    -> List PostpartumCheckRecord
    -> Bool
    -> Time
    -> ProcessStore
    -> PregnancyId
    -> Maybe PatientRecord
    -> Maybe PregnancyRecord
    -> ( Model, ProcessStore, Cmd Msg )
buildModel laborRec stage1Rec stage2Rec stage3Rec contPPCheckRecs babyRecord postpartumCheckRecords browserSupportsDate currTime store pregId patRec pregRec =
    let
        -- Get the lookup tables that this page will need.
        getSelectDataCmd =
            getTables SelectData Nothing []

        getBabyLabTypeCmd =
            getTables BabyLabType Nothing []

        getBabyVaccinationTypeCmd =
            getTables BabyVaccinationType Nothing []

        -- Populate the pendingSelectQuery field with dependent tables that
        -- we will need if/when they are available.
        -- Note: we get motherMedication in init since it is a sub-table of labor.
        pendingSelectQuery =
            Dict.singleton (tableToString BabyLab) BabyLab
                |> Dict.insert (tableToString BabyVaccination) BabyVaccination
    in
    ( { browserSupportsDate = browserSupportsDate
      , currTime = currTime
      , pregnancy_id = pregId
      , currLaborId = Just (LaborId laborRec.id)
      , currPostpartumCheckId = Nothing
      , currPregHeaderContent = PregHeaderData.IPPContent
      , dataCache = Dict.empty
      , pendingSelectQuery = pendingSelectQuery
      , patientRecord = patRec
      , pregnancyRecord = pregRec
      , laborRecord = laborRec
      , laborStage1Record = stage1Rec
      , laborStage2Record = stage2Rec
      , laborStage3Record = stage3Rec
      , contPostpartumCheckRecords = contPPCheckRecs
      , babyRecord = babyRecord
      , selectDataRecords = []
      , babyLabRecords = []
      , babyLabTypeRecords = []
      , babyVaccinationRecords = []
      , babyVaccinationTypeRecords = []
      , postpartumCheckRecords = postpartumCheckRecords
      , postpartumCheckViewEditState = NoViewEditState
      , pcCheckDate = Nothing
      , pcCheckTime = Nothing
      , pcBabyWeight = Nothing
      , pcBabyTemp = Nothing
      , pcBabyCR = Nothing
      , pcBabyRR = Nothing
      , pcBabyLungs = []
      , pcBabyColor = []
      , pcBabySkin = []
      , pcBabyCord = []
      , pcBabyUrine = Nothing
      , pcBabyStool = Nothing
      , pcBabySSInfection = []
      , pcBabyFeeding = []
      , pcBabyFeedingDaily = Nothing
      , pcMotherTemp = Nothing
      , pcMotherSystolic = Nothing
      , pcMotherDiastolic = Nothing
      , pcMotherCR = Nothing
      , pcMotherBreasts = []
      , pcMotherFundus = []
      , pcMotherPerineum = []
      , pcMotherLochia = []
      , pcMotherUrine = []
      , pcMotherStool = []
      , pcMotherSSInfection = []
      , pcMotherFamilyPlanning = []
      , pcBirthCertReq = Nothing
      , pcHgbRequested = Nothing
      , pcHgbTestDate = Nothing
      , pcHgbTestResult = Nothing
      , pcIronGiven = Nothing
      , pcComments = Nothing
      , pcNextScheduledCheck = Nothing
      }
    , store
    , Cmd.batch
        [ getSelectDataCmd
        , getBabyLabTypeCmd
        , getBabyVaccinationTypeCmd
        ]
    )

{-| Generate an top-level module command to retrieve additional data which checks
first in the data cache, and secondarily from the server.
-}
getTables : Table -> Maybe Int -> List Table -> Cmd Msg
getTables table key relatedTables =
    Task.perform
        (always (PostpartumSelectQuery table key relatedTables))
        (Task.succeed True)


{-| Retrieve additional data from the server as may be necessary after the page is
fully loaded, but get the data from the data cache instead of the server, if available.

This is called by the top-level module which passes it's data cache for our use.
-}
getTablesByCacheOrServer : ProcessStore -> Table -> Maybe Int -> List Table -> Dict String DataCache -> ( ProcessStore, Cmd Msg )
getTablesByCacheOrServer store table key relatedTbls dataCache =
    let
        -- Determine if the cache has all of the data that we need.
        isCached =
            List.all
                (\t -> U.isJust <| DataCache.get t dataCache)
                (table :: relatedTbls)

        -- We add the primary table to the list of tables affected so
        -- that refreshModelFromCache will update our model for the
        -- primary table as well as the related tables.
        dataCacheTables =
            relatedTbls ++ [ table ]

        ( newStore, newCmd ) =
            if isCached then
                let
                    cachedMsg =
                        Data.Postpartum.DataCache Nothing (Just dataCacheTables)
                            |> PostpartumMsg
                in
                store => Task.perform (always cachedMsg) (Task.succeed True)
            else
                let
                    selectQuery =
                        SelectQuery table key relatedTbls

                    ( processId, processStore ) =
                        Processing.add
                            (SelectQueryType
                                (PostpartumMsg
                                    (DataCache Nothing (Just dataCacheTables))
                                )
                                selectQuery
                            )
                            Nothing
                            store

                    jeVal =
                        wrapPayload processId SelectMsgType (selectQueryToValue selectQuery)
                in
                processStore => Ports.outgoing jeVal
    in
    newStore => newCmd


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
                        Baby ->
                            case DataCache.get t dc of
                                Just (BabyDataCache rec) ->
                                    { m | babyRecord = Just rec }

                                _ ->
                                    m

                        BabyLab ->
                            case DataCache.get t dc of
                                Just (BabyLabDataCache recs) ->
                                    { m | babyLabRecords = recs }

                                _ ->
                                    m

                        BabyLabType ->
                            case DataCache.get t dc of
                                Just (BabyLabTypeDataCache recs) ->
                                    { m | babyLabTypeRecords = recs }

                                _ ->
                                    m

                        BabyVaccination ->
                            case DataCache.get t dc of
                                Just (BabyVaccinationDataCache recs) ->
                                    { m | babyVaccinationRecords = recs }

                                _ ->
                                    m

                        BabyVaccinationType ->
                            case DataCache.get t dc of
                                Just (BabyVaccinationTypeDataCache recs) ->
                                    { m | babyVaccinationTypeRecords = recs }

                                _ ->
                                    m

                        ContPostpartumCheck ->
                            case DataCache.get t dc of
                                Just (ContPostpartumCheckDataCache recs) ->
                                    { m | contPostpartumCheckRecords = recs }

                                _ ->
                                    m

                        Labor ->
                            case DataCache.get t dc of
                                Just (LaborDataCache rec) ->
                                    { m | laborRecord = rec }

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

                        PostpartumCheck ->
                            case DataCache.get t dc of
                                Just (PostpartumCheckDataCache recs) ->
                                    { m | postpartumCheckRecords = recs }

                                _ ->
                                    m

                        SelectData ->
                            case DataCache.get t dc of
                                Just (SelectDataDataCache recs) ->
                                    { m | selectDataRecords = recs }

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

        CloseAllDialogs ->
            -- Close all of the open dialogs that we have. This may be called
            -- when the user uses the back button to back out of a dialog.
            ( closeAllDialogs model, Cmd.none, Cmd.none )

        DataCache dc tbls ->
            -- If the dataCache and tables are something, this is the top-level
            -- intentionally sending it's dataCache to us as a read-only update
            -- on the latest data that it has. The specific records that need
            -- to be updated are in the tables list.
            let
                newModel =
                    case ( dc, tbls ) of
                        ( Just dataCache, Just tables ) ->
                            let
                                newModel =
                                    refreshModelFromCache dataCache tables model
                            in
                            { newModel | dataCache = dataCache }

                        ( _, _ ) ->
                            model

                -- Get all sub tables of baby that are pending retrieval from the server.
                ( newCmd, newPendingSQ ) =
                    case newModel.babyRecord of
                        Just baby ->
                            if
                                Dict.member (tableToString BabyLab) newModel.pendingSelectQuery
                                    || Dict.member (tableToString BabyVaccination) newModel.pendingSelectQuery
                            then
                                ( Task.perform
                                    (always
                                        (PostpartumSelectQuery Baby
                                            (Just baby.id)
                                            [ BabyLab, BabyVaccination ]
                                        )
                                    )
                                    (Task.succeed True)
                                , Dict.remove (tableToString BabyLab) newModel.pendingSelectQuery
                                    |> Dict.remove (tableToString BabyVaccination)
                                )
                            else
                                ( Cmd.none, newModel.pendingSelectQuery )

                        Nothing ->
                            ( Cmd.none, newModel.pendingSelectQuery )
            in
            ( { newModel | pendingSelectQuery = newPendingSQ }
            , Cmd.none
            , newCmd
            )

        DateFieldSubMsg dateFldMsg ->
            -- For browsers that do not support a native date field.
            case dateFldMsg of
                DateFieldMessage { dateField, date } ->
                    case dateField of
                        PostpartumCheckDateField ->
                            ( { model | pcCheckDate = Just date }, Cmd.none, Cmd.none )

                        PostpartumCheckHgbField ->
                            ( { model | pcHgbTestDate = Just date }, Cmd.none, Cmd.none )

                        PostpartumCheckScheduledField ->
                            ( { model | pcNextScheduledCheck = Just date }, Cmd.none, Cmd.none )

                        UnknownDateField str ->
                            ( model, Cmd.none, logConsole str )

                        _ ->
                            let
                                _ =
                                    Debug.log "Postpartum DateFieldSubMsg" <| toString dateFldMsg
                            in
                            -- This page is not the only one with date fields, we only
                            -- handle what we know about.
                            ( model, Cmd.none, Cmd.none )

                UnknownDateFieldMessage str ->
                    ( model, Cmd.none, Cmd.none )

        FldChgSubMsg fld val ->
            case val of
                FldChgString value ->
                    ( case fld of
                        PCCheckDateFld ->
                            { model | pcCheckDate = Date.fromString value |> Result.toMaybe }

                        PCCheckTimeFld ->
                            { model | pcCheckTime = Just <| U.filterStringLikeTime value }

                        PCBabyWeightFld ->
                            { model | pcBabyWeight = Just <| U.filterStringLikeInt value }

                        PCBabyTempFld ->
                            { model | pcBabyTemp = Just <| U.filterStringLikeFloat value }

                        PCBabyCRFld ->
                            { model | pcBabyCR = Just <| U.filterStringLikeInt value }

                        PCBabyRRFld ->
                            { model | pcBabyRR = Just <| U.filterStringLikeInt value }

                        PCBabyUrineFld ->
                            { model | pcBabyUrine = Just value }

                        PCBabyStoolFld ->
                            { model | pcBabyStool = Just value }

                        PCBabyFeedingDailyFld ->
                            { model | pcBabyFeedingDaily = Just value }

                        PCMotherTempFld ->
                            { model | pcMotherTemp = Just <| U.filterStringLikeFloat value }

                        PCMotherSystolicFld ->
                            { model | pcMotherSystolic = Just <| U.filterStringLikeInt value }

                        PCMotherDiastolicFld ->
                            { model | pcMotherDiastolic = Just <| U.filterStringLikeInt value }

                        PCMotherCRFld ->
                            { model | pcMotherCR = Just <| U.filterStringLikeInt value }

                        PCHgbTestResultFld ->
                            { model | pcHgbTestResult = Just value }

                        PCIronGivenFld ->
                            { model | pcIronGiven = Just <| U.filterStringLikeInt value }

                        PCCommentsFld ->
                            { model | pcComments = Just value }

                        PCHgbTestDateFld ->
                            { model | pcHgbTestDate = Date.fromString value |> Result.toMaybe }

                        PCNextScheduledCheckFld ->
                            { model | pcNextScheduledCheck = Date.fromString value |> Result.toMaybe }

                        _ ->
                            model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgStringList selectKey isChecked ->
                    ( case fld of
                        PCBabyLungsFld ->
                            { model | pcBabyLungs = setSelectedBySelectKey selectKey isChecked model.pcBabyLungs }

                        PCBabyColorFld ->
                            { model | pcBabyColor = setSelectedBySelectKey selectKey isChecked model.pcBabyColor }

                        PCBabySkinFld ->
                            { model | pcBabySkin = setSelectedBySelectKey selectKey isChecked model.pcBabySkin }

                        PCBabyCordFld ->
                            { model | pcBabyCord = setSelectedBySelectKey selectKey isChecked model.pcBabyCord }

                        PCBabySSInfectionFld ->
                            { model | pcBabySSInfection = setSelectedBySelectKey selectKey isChecked model.pcBabySSInfection }

                        PCBabyFeedingFld ->
                            { model | pcBabyFeeding = setSelectedBySelectKey selectKey isChecked model.pcBabyFeeding }

                        PCMotherBreastsFld ->
                            { model | pcMotherBreasts = setSelectedBySelectKey selectKey isChecked model.pcMotherBreasts }

                        PCMotherFundusFld ->
                            { model | pcMotherFundus = setSelectedBySelectKey selectKey isChecked model.pcMotherFundus }

                        PCMotherPerineumFld ->
                            { model | pcMotherPerineum = setSelectedBySelectKey selectKey isChecked model.pcMotherPerineum }

                        PCMotherLochiaFld ->
                            { model | pcMotherLochia = setSelectedBySelectKey selectKey isChecked model.pcMotherLochia }

                        PCMotherUrineFld ->
                            { model | pcMotherUrine = setSelectedBySelectKey selectKey isChecked model.pcMotherUrine }

                        PCMotherStoolFld ->
                            { model | pcMotherStool = setSelectedBySelectKey selectKey isChecked model.pcMotherStool }

                        PCMotherSSInfectionFld ->
                            { model | pcMotherSSInfection = setSelectedBySelectKey selectKey isChecked model.pcMotherSSInfection }

                        PCMotherFamilyPlanningFld ->
                            { model | pcMotherFamilyPlanning = setSelectedBySelectKey selectKey isChecked model.pcMotherFamilyPlanning }

                        _ ->
                            model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgBool value ->
                    ( case fld of
                        PCBirthCertReqFld ->
                            { model | pcBirthCertReq = Just value }

                        PCHgbRequestedFld ->
                            { model | pcHgbRequested = Just value }

                        _ ->
                            model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgIntString intVal strVal ->
                    ( model, Cmd.none, Cmd.none )

        HandlePostpartumCheckModal dialogState pcId ->
            case dialogState of
                OpenDialog ->
                    -- This is used only for new records. EditDialog if used to edit
                    -- existing records using the id passed.
                    let
                        -- Default to the current time and date.
                        currDate =
                            Date.fromTime model.currTime

                        newModel =
                            clearPostpartumCheckModelFields model
                                |> (\mdl ->
                                        { mdl
                                            | pcCheckDate = Just currDate
                                            , pcCheckTime = Just <| U.dateToTimeString currDate
                                            , pcBabyLungs = filterByName Const.postpartumCheckBabyLungs model.selectDataRecords
                                            , pcBabyColor = filterByName Const.postpartumCheckBabyColor model.selectDataRecords
                                            , pcBabySkin = filterByName Const.postpartumCheckBabySkin model.selectDataRecords
                                            , pcBabyCord = filterByName Const.postpartumCheckBabyCord model.selectDataRecords
                                            , pcBabySSInfection = filterByName Const.postpartumCheckBabySSInfection model.selectDataRecords
                                            , pcBabyFeeding = filterByName Const.postpartumCheckBabyFeeding model.selectDataRecords
                                            , pcMotherBreasts = filterByName Const.postpartumCheckMotherBreasts model.selectDataRecords
                                            , pcMotherFundus = filterByName Const.postpartumCheckMotherFundus model.selectDataRecords
                                            , pcMotherPerineum = filterByName Const.postpartumCheckMotherPerineum model.selectDataRecords
                                            , pcMotherLochia = filterByName Const.postpartumCheckMotherLochia model.selectDataRecords
                                            , pcMotherUrine = filterByName Const.postpartumCheckMotherUrine model.selectDataRecords
                                            , pcMotherStool = filterByName Const.postpartumCheckMotherStool model.selectDataRecords
                                            , pcMotherSSInfection = filterByName Const.postpartumCheckMotherSSInfection model.selectDataRecords
                                            , pcMotherFamilyPlanning = filterByName Const.postpartumCheckMotherFamilyPlanning model.selectDataRecords
                                        }
                                   )
                    in
                    ( { newModel | postpartumCheckViewEditState = PostpartumCheckEditState }
                    , Cmd.none
                    , Cmd.batch
                        [ if model.postpartumCheckViewEditState == NoViewEditState then
                            Route.addDialogUrl Route.PostpartumRoute
                          else
                            Route.back
                        , Task.perform SetDialogActive <| Task.succeed True
                        ]
                    )

                CloseNoSaveDialog ->
                    ( { model
                        | postpartumCheckViewEditState = NoViewEditState
                        , currPostpartumCheckId = Nothing
                      }
                    , Cmd.none
                    , Route.back
                    )

                EditDialog ->
                    let
                        newModel =
                            case ( pcId, DataCache.get PostpartumCheck model.dataCache ) of
                                ( Just (PostpartumCheckId theId), Just (PostpartumCheckDataCache recs) ) ->
                                    case LE.find (\r -> r.id == theId) recs of
                                        Just rec ->
                                            { model
                                                | pcCheckDate = Just rec.checkDatetime
                                                , pcCheckTime = Just <| U.dateToTimeString rec.checkDatetime
                                                , pcBabyWeight = Maybe.map toString rec.babyWeight
                                                , pcBabyTemp = Maybe.map toString rec.babyTemp
                                                , pcBabyCR = Maybe.map toString rec.babyCR
                                                , pcBabyRR = Maybe.map toString rec.babyRR
                                                , pcBabyLungs =
                                                    filterSetByString Const.postpartumCheckBabyLungs
                                                        rec.babyLungs
                                                        model.selectDataRecords
                                                , pcBabyColor =
                                                    filterSetByString Const.postpartumCheckBabyColor
                                                        rec.babyColor
                                                        model.selectDataRecords
                                                , pcBabySkin =
                                                    filterSetByString Const.postpartumCheckBabySkin
                                                        rec.babySkin
                                                        model.selectDataRecords
                                                , pcBabyCord =
                                                    filterSetByString Const.postpartumCheckBabyCord
                                                        rec.babyCord
                                                        model.selectDataRecords
                                                , pcBabyUrine = rec.babyUrine
                                                , pcBabyStool = rec.babyStool
                                                , pcBabySSInfection =
                                                    filterSetByString Const.postpartumCheckBabySSInfection
                                                        rec.babySSInfection
                                                        model.selectDataRecords
                                                , pcBabyFeeding =
                                                    filterSetByString Const.postpartumCheckBabyFeeding
                                                        rec.babyFeeding
                                                        model.selectDataRecords
                                                , pcBabyFeedingDaily = rec.babyFeedingDaily
                                                , pcMotherTemp = Maybe.map toString rec.motherTemp
                                                , pcMotherSystolic = Maybe.map toString rec.motherSystolic
                                                , pcMotherDiastolic = Maybe.map toString rec.motherDiastolic
                                                , pcMotherCR = Maybe.map toString rec.motherCR
                                                , pcMotherBreasts =
                                                    filterSetByString Const.postpartumCheckMotherBreasts
                                                        rec.motherBreasts
                                                        model.selectDataRecords
                                                , pcMotherFundus =
                                                    filterSetByString Const.postpartumCheckMotherFundus
                                                        rec.motherFundus
                                                        model.selectDataRecords
                                                , pcMotherPerineum =
                                                    filterSetByString Const.postpartumCheckMotherPerineum
                                                        rec.motherPerineum
                                                        model.selectDataRecords
                                                , pcMotherLochia =
                                                    filterSetByString Const.postpartumCheckMotherLochia
                                                        rec.motherLochia
                                                        model.selectDataRecords
                                                , pcMotherUrine =
                                                    filterSetByString Const.postpartumCheckMotherUrine
                                                        rec.motherUrine
                                                        model.selectDataRecords
                                                , pcMotherStool =
                                                    filterSetByString Const.postpartumCheckMotherStool
                                                        rec.motherStool
                                                        model.selectDataRecords
                                                , pcMotherSSInfection =
                                                    filterSetByString Const.postpartumCheckMotherSSInfection
                                                        rec.motherSSInfection
                                                        model.selectDataRecords
                                                , pcMotherFamilyPlanning =
                                                    filterSetByString Const.postpartumCheckMotherFamilyPlanning
                                                        rec.motherFamilyPlanning
                                                        model.selectDataRecords
                                                , pcBirthCertReq = rec.birthCertReq
                                                , pcHgbRequested = rec.hgbRequested
                                                , pcHgbTestDate = rec.hgbTestDate
                                                , pcHgbTestResult = rec.hgbTestResult
                                                , pcIronGiven = Maybe.map toString rec.ironGiven
                                                , pcComments = rec.comments
                                                , pcNextScheduledCheck = rec.nextScheduledCheck
                                            }

                                        Nothing ->
                                            model

                                ( _, _ ) ->
                                    model
                    in
                    ( { newModel
                        | postpartumCheckViewEditState = PostpartumCheckEditState
                        , currPostpartumCheckId = pcId
                      }
                    , Cmd.none
                    , if newModel.postpartumCheckViewEditState == NoViewEditState then
                        Cmd.batch
                            [ Route.addDialogUrl Route.PostpartumRoute
                            , Task.perform SetDialogActive <| Task.succeed True
                            ]
                      else
                        Cmd.none
                    )

                CloseSaveDialog ->
                    case validatePostpartumCheck model of
                        [] ->
                            let
                                -- Check that the date and corresponding time fields together
                                -- produce valid dates.
                                checkDatetime =
                                    U.maybeDateMaybeTimeToMaybeDateTime model.pcCheckDate
                                        model.pcCheckTime
                                        "Please correct the date and time for the postpartum check fields."

                                errors =
                                    U.maybeDateTimeErrors [ checkDatetime ]

                                outerMsg =
                                    case ( List.length errors > 0, model.currLaborId, pcId ) of
                                        ( True, _, _ ) ->
                                            -- Errors found in the date and time field, so notifiy user
                                            -- instead of saving.
                                            Toast (errors ++ [ "Record was not saved." ]) 10 ErrorToast

                                        ( _, Nothing, _ ) ->
                                            LogConsole "Error: Current labor id is not known."

                                        ( False, Just (LaborId lid), Nothing ) ->
                                            -- New check being created.
                                            case derivePostpartumCheckRecordNew model of
                                                Just check ->
                                                    ProcessTypeMsg
                                                        (AddPostpartumCheckType
                                                            (PostpartumMsg
                                                                -- Request top-level to provide data in
                                                                -- the dataCache once received from server.
                                                                (DataCache Nothing (Just [ PostpartumCheck ]))
                                                            )
                                                            check
                                                        )
                                                        AddMsgType
                                                        (postpartumCheckRecordNewToValue check)

                                                Nothing ->
                                                    LogConsole "derivePostpartumCheckRecordNew returned a Nothing"

                                        ( False, Just (LaborId lid), Just (PostpartumCheckId checkId) ) ->
                                            -- Existing check being updated.
                                            case DataCache.get PostpartumCheck model.dataCache of
                                                Just (PostpartumCheckDataCache checks) ->
                                                    case LE.find (\c -> c.id == checkId) checks of
                                                        Just check ->
                                                            let
                                                                newCheck =
                                                                    { check
                                                                        | checkDatetime =
                                                                            Maybe.withDefault check.checkDatetime
                                                                                (U.maybeDateTimeValue checkDatetime)
                                                                        , babyWeight = U.maybeStringToMaybeInt model.pcBabyWeight
                                                                        , babyTemp = U.maybeStringToMaybeFloat model.pcBabyTemp
                                                                        , babyCR = U.maybeStringToMaybeInt model.pcBabyCR
                                                                        , babyRR = U.maybeStringToMaybeInt model.pcBabyRR
                                                                        , babyLungs =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcBabyLungs)
                                                                                check.babyLungs
                                                                        , babyColor =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcBabyColor)
                                                                                check.babyColor
                                                                        , babySkin =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcBabySkin)
                                                                                check.babySkin
                                                                        , babyCord =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcBabyCord)
                                                                                check.babyCord
                                                                        , babyUrine = model.pcBabyUrine
                                                                        , babyStool = model.pcBabyStool
                                                                        , babySSInfection =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcBabySSInfection)
                                                                                check.babySSInfection
                                                                        , babyFeeding =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcBabyFeeding)
                                                                                check.babyFeeding
                                                                        , babyFeedingDaily = model.pcBabyFeedingDaily
                                                                        , motherTemp = U.maybeStringToMaybeFloat model.pcMotherTemp
                                                                        , motherSystolic = U.maybeStringToMaybeInt model.pcMotherSystolic
                                                                        , motherDiastolic = U.maybeStringToMaybeInt model.pcMotherDiastolic
                                                                        , motherCR = U.maybeStringToMaybeInt model.pcMotherCR
                                                                        , motherBreasts =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcMotherBreasts)
                                                                                check.motherBreasts
                                                                        , motherFundus =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcMotherFundus)
                                                                                check.motherFundus
                                                                        , motherPerineum =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcMotherPerineum)
                                                                                check.motherPerineum
                                                                        , motherLochia =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcMotherLochia)
                                                                                check.motherLochia
                                                                        , motherUrine =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcMotherUrine)
                                                                                check.motherUrine
                                                                        , motherStool =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcMotherStool)
                                                                                check.motherStool
                                                                        , motherSSInfection =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcMotherSSInfection)
                                                                                check.motherSSInfection
                                                                        , motherFamilyPlanning =
                                                                            U.maybeOr (getSelectDataAsMaybeString model.pcMotherFamilyPlanning)
                                                                                check.motherFamilyPlanning
                                                                        , birthCertReq = model.pcBirthCertReq
                                                                        , hgbRequested = model.pcHgbRequested
                                                                        , hgbTestDate = model.pcHgbTestDate
                                                                        , hgbTestResult = model.pcHgbTestResult
                                                                        , ironGiven = U.maybeStringToMaybeInt model.pcIronGiven
                                                                        , comments = model.pcComments
                                                                        , nextScheduledCheck = model.pcNextScheduledCheck
                                                                    }
                                                            in
                                                            ProcessTypeMsg
                                                                (UpdatePostpartumCheckType
                                                                    (PostpartumMsg
                                                                        (DataCache Nothing (Just [ PostpartumCheck ]))
                                                                    )
                                                                    newCheck
                                                                )
                                                                ChgMsgType
                                                                (postpartumCheckRecordToValue newCheck)

                                                        Nothing ->
                                                            LogConsole "HandlePostpartumCheckModal: did not find PPCheck in data cache."

                                                _ ->
                                                    Noop
                            in
                            ( { model
                                | postpartumCheckViewEditState = NoViewEditState
                                , currPostpartumCheckId = Nothing
                              }
                            , Cmd.none
                            , Cmd.batch
                                [ Task.perform (always outerMsg) (Task.succeed True)
                                , Route.back
                                ]
                            )

                        errors ->
                            let
                                msgs =
                                    List.map Tuple.second errors
                                        |> flip (++) [ "Record was not saved." ]
                            in
                            ( { model | postpartumCheckViewEditState = NoViewEditState }
                            , Cmd.none
                            , toastError msgs 10
                            )

        OpenDatePickerSubMsg id ->
            ( model, Cmd.none, Task.perform OpenDatePicker (Task.succeed id) )

        PostpartumTick time ->
            -- Keep the current time in the Model.
            ( { model | currTime = time }, Cmd.none, Cmd.none )

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


derivePostpartumCheckRecordNew : Model -> Maybe PostpartumCheckRecordNew
derivePostpartumCheckRecordNew model =
    case model.currLaborId of
        Just (LaborId lid) ->
            let
                checkDatetime =
                    U.maybeDateMaybeTimeToMaybeDateTime model.pcCheckDate model.pcCheckTime ""
                        |> U.maybeDateTimeValue
            in
            case checkDatetime of
                Just d ->
                    Just <|
                        PostpartumCheckRecordNew d
                            (U.maybeStringToMaybeInt model.pcBabyWeight)
                            (U.maybeStringToMaybeFloat model.pcBabyTemp)
                            (U.maybeStringToMaybeInt model.pcBabyCR)
                            (U.maybeStringToMaybeInt model.pcBabyRR)
                            (getSelectDataAsMaybeString model.pcBabyLungs)
                            (getSelectDataAsMaybeString model.pcBabyColor)
                            (getSelectDataAsMaybeString model.pcBabySkin)
                            (getSelectDataAsMaybeString model.pcBabyCord)
                            model.pcBabyUrine
                            model.pcBabyStool
                            (getSelectDataAsMaybeString model.pcBabySSInfection)
                            (getSelectDataAsMaybeString model.pcBabyFeeding)
                            model.pcBabyFeedingDaily
                            (U.maybeStringToMaybeFloat model.pcMotherTemp)
                            (U.maybeStringToMaybeInt model.pcMotherSystolic)
                            (U.maybeStringToMaybeInt model.pcMotherDiastolic)
                            (U.maybeStringToMaybeInt model.pcMotherCR)
                            (getSelectDataAsMaybeString model.pcMotherBreasts)
                            (getSelectDataAsMaybeString model.pcMotherFundus)
                            (getSelectDataAsMaybeString model.pcMotherPerineum)
                            (getSelectDataAsMaybeString model.pcMotherLochia)
                            (getSelectDataAsMaybeString model.pcMotherUrine)
                            (getSelectDataAsMaybeString model.pcMotherStool)
                            (getSelectDataAsMaybeString model.pcMotherSSInfection)
                            (getSelectDataAsMaybeString model.pcMotherFamilyPlanning)
                            model.pcBirthCertReq
                            model.pcHgbRequested
                            model.pcHgbTestDate
                            model.pcHgbTestResult
                            (U.maybeStringToMaybeInt model.pcIronGiven)
                            model.pcComments
                            model.pcNextScheduledCheck
                            lid

                Nothing ->
                    Nothing

        Nothing ->
            Nothing



-- VIEW --


view : Maybe Window.Size -> Session -> Model -> Html SubMsg
view size session model =
    let
        pregHeader =
            case ( model.patientRecord, model.pregnancyRecord ) of
                ( Just patRec, Just pregRec ) ->
                    let
                        laborInfo =
                            PregHeaderData.LaborInfo (Just model.laborRecord)
                                model.laborStage1Record
                                model.laborStage2Record
                                model.laborStage3Record
                                model.contPostpartumCheckRecords
                    in
                    PregHeaderView.view patRec
                        pregRec
                        laborInfo
                        model.currPregHeaderContent
                        model.currTime
                        size

                ( _, _ ) ->
                    H.text ""

        postpartumCheckViewEditStageConfig =
            ViewEditStageConfig
                (model.postpartumCheckViewEditState
                    == PostpartumCheckViewState
                    || model.postpartumCheckViewEditState
                    == NoViewEditState
                )
                (model.postpartumCheckViewEditState == PostpartumCheckEditState)
                "Postpartum Checks"
                model
                (HandlePostpartumCheckModal CloseNoSaveDialog Nothing)
                -- These two are not used because of PostpartumCheckId being passed.
                PageNoop
                PageNoop
    in
    H.div []
        [ pregHeader |> H.map (\a -> RotatePregHeaderContent a)
        , H.div [ HA.class "content-wrapper" ]
            [ viewPostpartumChecks postpartumCheckViewEditStageConfig
            ]
        ]


getErr : Field -> List FieldError -> String
getErr fld errors =
    case LE.find (\fe -> Tuple.first fe == fld) errors of
        Just fe ->
            Tuple.second fe

        Nothing ->
            ""


{-| Configuration for a dialog.
-}
type alias ViewEditStageConfig =
    { isShown : Bool
    , isEditing : Bool
    , title : String
    , model : Model
    , closeMsg : SubMsg
    , saveMsg : SubMsg
    , editMsg : SubMsg
    }


{-| TODO: This is hard-coded for now to the NBS lab; need to handle better.
-}
nbsReportString : List BabyLabTypeRecord -> List BabyLabRecord -> String
nbsReportString babyLabTypeRecs babyLabRecs =
    case Data.BabyLabType.getByName "NBS" babyLabTypeRecs of
        Just babyLabType ->
            case LE.find (\r -> r.babyLabType == babyLabType.id) babyLabRecs of
                Just babyLab ->
                    U.dateToDateMonString babyLab.dateTime "-"
                        ++ " "
                        ++ babyLabType.fld1Name
                        ++ ": "
                        ++ Maybe.withDefault "" babyLab.fld1Value
                        ++ (if U.maybeStringLength babyLab.fld2Value > 0 then
                                ", " ++ Maybe.withDefault "" babyLab.fld2Value
                            else
                                ""
                           )
                        ++ (if U.maybeStringLength babyLab.initials > 0 then
                                ", " ++ Maybe.withDefault "" babyLab.initials
                            else
                                ""
                           )

                Nothing ->
                    ""

        Nothing ->
            ""


bcgReportString : List BabyVaccinationTypeRecord -> List BabyVaccinationRecord -> String
bcgReportString babyVacTypeRecs babyVacRecs =
    case Data.BabyVaccinationType.getByName "BCG" babyVacTypeRecs of
        Just babyVaccinationType ->
            case
                LE.find
                    (\r -> r.babyVaccinationType == babyVaccinationType.id)
                    babyVacRecs
            of
                Just babyVaccination ->
                    U.dateToDateMonString babyVaccination.vaccinationDate "-"
                        ++ (if U.maybeStringLength babyVaccination.comments > 0 then
                                ", " ++ Maybe.withDefault " " babyVaccination.comments
                            else
                                ""
                           )
                        ++ (if U.maybeStringLength babyVaccination.initials > 0 then
                                ", " ++ Maybe.withDefault " " babyVaccination.initials
                            else
                                ""
                           )

                Nothing ->
                    ""

        Nothing ->
            ""


viewPostpartumChecks : ViewEditStageConfig -> Html SubMsg
viewPostpartumChecks cfg =
    let
        dateSort a b =
            U.sortDate U.AscendingSort a.checkDatetime b.checkDatetime

        checks =
            List.sortWith dateSort cfg.model.postpartumCheckRecords
                |> List.map (viewPostpartumCheck cfg)
    in
    H.div []
        [ H.h1 [ HA.class "c-heading u-large" ]
            [ H.text cfg.title ]
        , H.div
            [ HA.style [ ( "margin-bottom", "1em" ) ]
            , HA.classList [ ( "isHidden", not cfg.isShown ) ]
            ]
            checks
        , H.button
            [ HA.type_ "button"
            , HA.class "c-button c-button u-small"
            , HA.classList [ ( "isHidden", not cfg.isShown ) ]
            , HE.onClick <| HandlePostpartumCheckModal OpenDialog Nothing
            ]
            [ H.text "Add Postpartum Check" ]
        , viewPostpartumCheckEdit cfg
        ]


viewPostpartumCheck : ViewEditStageConfig -> PostpartumCheckRecord -> Html SubMsg
viewPostpartumCheck cfg rec =
    let
        checkDate =
            U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep rec.checkDatetime

        field lbl val =
            H.table [ HA.class "u-small" ]
                [ H.tr []
                    [ H.td
                        [ HA.class "c-text--quiet"
                        , HA.style [ ( "min-width", "8.0em" ) ]
                        ]
                        [ H.text <| lbl ++ ": " ]
                    , H.td
                        [ HA.class "c-text--loud"
                        ]
                        [ H.text val ]
                    ]
                ]

        yesNoBool bool =
            case bool of
                Just True ->
                    "Yes"

                _ ->
                    "No"

        dateAsString d =
            U.dateFormatter U.MDYDateFmt U.DashDateSep d

        pipeToComma str =
            Maybe.map U.pipeToComma str
                |> stringDefault

        toStringDefault val =
            stringDefault (Maybe.map toString val)

        stringDefault val =
            Maybe.withDefault "" val

        bp =
            case ( rec.motherSystolic, rec.motherDiastolic ) of
                ( Just sys, Just dia ) ->
                    toString sys ++ " / " ++ toString dia

                ( _, _ ) ->
                    ""

        nbs =
            nbsReportString cfg.model.babyLabTypeRecords
                cfg.model.babyLabRecords

        bcg =
            bcgReportString cfg.model.babyVaccinationTypeRecords
                cfg.model.babyVaccinationRecords
    in
    H.div [ HA.class "c-card" ]
        [ H.div
            [ HA.class "c-card__item u-color-white primary-dark-bg"

            -- In order to float the edit button below to the right.
            , HA.style [ ( "overflow", "hidden" ) ]
            ]
            [ H.span []
                [ H.text checkDate ]
            , H.button
                [ HA.type_ "button"
                , HA.class "c-button c-button--ghost u-color-white u-xsmall"
                , HA.style [ ( "float", "right" ) ]
                , HE.onClick <|
                    HandlePostpartumCheckModal EditDialog
                        (Just (PostpartumCheckId rec.id))
                ]
                [ H.text "Edit" ]
            ]
        , H.div [ HA.class "c-card__item" ]
            [ H.div [ HA.class "contPP-wrapper" ]
                [ H.div [ HA.class "c-card contPP-content" ]
                    [ H.div [ HA.class "c-card__item u-small u-color-white accent-bg" ]
                        [ H.text "Baby" ]
                    , field "Weight" <| toStringDefault rec.babyWeight
                    , field "Temp" <| toStringDefault rec.babyTemp
                    , field "HR" <| toStringDefault rec.babyCR
                    , field "RR" <| toStringDefault rec.babyRR
                    , field "Lungs" <| pipeToComma rec.babyLungs
                    , field "Color" <| pipeToComma rec.babyColor
                    , field "Skin" <| pipeToComma rec.babySkin
                    , field "Cord" <| pipeToComma rec.babyCord
                    , field "Urine" <| stringDefault rec.babyUrine
                    , field "Stool" <| stringDefault rec.babyStool
                    , field "S/S Infection" <| pipeToComma rec.babySSInfection
                    , field "Feeding" <| pipeToComma rec.babyFeeding
                    , field "Feedings/day" <| stringDefault rec.babyFeedingDaily
                    , field "NBS" nbs
                    , field "Bcg" bcg
                    ]
                , H.div [ HA.class "c-card contPP-content" ]
                    [ H.div [ HA.class "c-card__item u-small u-color-white accent-bg" ]
                        [ H.text "Mother" ]
                    , field "Temp" <| toStringDefault rec.motherTemp
                    , field "BP" bp
                    , field "Pulse" <| toStringDefault rec.motherCR
                    , field "Breasts" <| pipeToComma rec.motherBreasts
                    , field "Fundus" <| pipeToComma rec.motherFundus
                    , field "Perineum" <| pipeToComma rec.motherPerineum
                    , field "Lochia" <| pipeToComma rec.motherLochia
                    , field "Urine" <| pipeToComma rec.motherUrine
                    , field "Stool" <| pipeToComma rec.motherStool
                    , field "SSInfection" <| pipeToComma rec.motherSSInfection
                    , field "Family Planning" <| pipeToComma rec.motherFamilyPlanning
                    , field "Birth Cert Reg" <| yesNoBool rec.birthCertReq
                    , field "Hgb Requested" <| yesNoBool rec.hgbRequested
                    , field "Hgb Test Date" <| stringDefault <| Maybe.map dateAsString rec.hgbTestDate
                    , field "Hgb Result" <| stringDefault rec.hgbTestResult
                    , field "Iron given" <| toStringDefault rec.ironGiven
                    , field "Next check" <| stringDefault <| Maybe.map dateAsString rec.nextScheduledCheck
                    ]
                ]
            ]
        , H.div [ HA.class "c-card__item" ]
            [ H.text <| stringDefault rec.comments ]
        ]


viewPostpartumCheckEdit : ViewEditStageConfig -> Html SubMsg
viewPostpartumCheckEdit cfg =
    let
        errors =
            validatePostpartumCheck cfg.model

        getMsgSD fld modelFld =
            List.map (\sd -> ( FldChgStringList sd.selectKey >> FldChgSubMsg fld, sd )) modelFld

        nbs =
            nbsReportString cfg.model.babyLabTypeRecords
                cfg.model.babyLabRecords

        bcg =
            bcgReportString cfg.model.babyVaccinationTypeRecords
                cfg.model.babyVaccinationRecords
    in
    H.div
        [ HA.classList [ ( "isHidden", not cfg.isEditing ) ]
        , HA.class "u-high"
        , HA.style
            [ ( "padding", "0.8em" )
            , ( "margin-top", "0.8em" )
            ]
        ]
        [ H.h3 [ HA.class "c-text--brand mw-header-3" ]
            [ H.text "Edit Postpartum Check" ]
        , H.div [ HA.class "form-wrapper u-small" ]
            [ H.h1
                [ HA.class "c-heading u-large accent-bg"
                , HA.style [ ( "padding", "0.2em 2em" ) ]
                ]
                [ H.text "Baby" ]
            , H.div [ HA.class "o-fieldset form-wrapper" ]
                [ if cfg.model.browserSupportsDate then
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Check date and time" ]
                            ]
                        , H.div [ HA.class "c-card__body dateTimeModalBody" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDate (FldChgString >> FldChgSubMsg PCCheckDateFld)
                                    "Date"
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.pcCheckDate
                                    (getErr PCCheckDateFld errors)
                                , Form.formField (FldChgString >> FldChgSubMsg PCCheckTimeFld)
                                    "Time"
                                    "24 hr format, 14:44"
                                    False
                                    cfg.model.pcCheckTime
                                    (getErr PCCheckTimeFld errors)
                                ]
                            ]
                        ]
                  else
                    -- Browser does not support date.
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Check date and time" ]
                            ]
                        , H.div [ HA.class "c-card__body" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDatePicker OpenDatePickerSubMsg
                                    PostpartumCheckDateField
                                    "Date"
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.pcCheckDate
                                    (getErr PCCheckDateFld errors)
                                , Form.formField (FldChgString >> FldChgSubMsg PCCheckTimeFld)
                                    "Time"
                                    "24 hr format, 14:44"
                                    False
                                    cfg.model.pcCheckTime
                                    (getErr PCCheckTimeFld errors)
                                ]
                            ]
                        ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCBabyWeightFld)
                        "Baby weight"
                        ""
                        True
                        cfg.model.pcBabyWeight
                        (getErr PCBabyWeightFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCBabyTempFld)
                        "Baby temp"
                        ""
                        True
                        cfg.model.pcBabyTemp
                        (getErr PCBabyTempFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCBabyCRFld)
                        "Baby HR"
                        ""
                        True
                        cfg.model.pcBabyCR
                        (getErr PCBabyCRFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCBabyRRFld)
                        "Baby RR"
                        ""
                        True
                        cfg.model.pcBabyRR
                        (getErr PCBabyRRFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCBabyLungsFld cfg.model.pcBabyLungs)
                        "Baby lungs"
                        (getErr PCBabyLungsFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCBabyColorFld cfg.model.pcBabyColor)
                        "Baby color"
                        (getErr PCBabyColorFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCBabySkinFld cfg.model.pcBabySkin)
                        "Baby skin"
                        (getErr PCBabySkinFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCBabyCordFld cfg.model.pcBabyCord)
                        "Baby cord"
                        (getErr PCBabyCordFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCBabyUrineFld)
                        "Baby urine"
                        "nbr of times last 24 hours"
                        True
                        cfg.model.pcBabyUrine
                        (getErr PCBabyUrineFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCBabyStoolFld)
                        "Baby stool"
                        "nbr of times last 24 hours"
                        True
                        cfg.model.pcBabyStool
                        (getErr PCBabyStoolFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCBabySSInfectionFld cfg.model.pcBabySSInfection)
                        "Baby S/S infection"
                        (getErr PCBabySSInfectionFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCBabyFeedingFld cfg.model.pcBabyFeeding)
                        "Baby feeding"
                        (getErr PCBabyFeedingFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCBabyFeedingDailyFld)
                        "Feedings/day"
                        "# in 24 hours"
                        True
                        cfg.model.pcBabyFeedingDaily
                        (getErr PCBabyFeedingDailyFld errors)
                    ]
                , H.div [ HA.class "u-medium" ]
                    [ H.span
                        [ HA.class "c-text--loud"
                        , HA.style [ ( "display", "inline-block" ), ( "min-width", "3.0em" ) ]
                        ]
                        [ H.text "NBS: " ]
                    , H.span [ HA.class "c-text" ]
                        [ H.text nbs ]
                    ]
                , H.div [ HA.class "u-medium" ]
                    [ H.span
                        [ HA.class "c-text--loud"
                        , HA.style [ ( "display", "inline-block" ), ( "min-width", "3.0em" ) ]
                        ]
                        [ H.text "BCG: " ]
                    , H.span [ HA.class "c-text" ]
                        [ H.text bcg ]
                    ]
                ]
            , H.h1
                [ HA.class "c-heading u-large accent-bg"
                , HA.style
                    [ ( "padding", "0.2em 2em" )
                    , ( "margin-top", "0.5em" )
                    ]
                ]
                [ H.text "Mother" ]
            , H.div [ HA.class "o-fieldset form-wrapper" ]
                [ H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCMotherTempFld)
                        "Mother temp"
                        ""
                        True
                        cfg.model.pcMotherTemp
                        (getErr PCMotherTempFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCMotherSystolicFld)
                        "Mother systolic"
                        ""
                        True
                        cfg.model.pcMotherSystolic
                        (getErr PCMotherSystolicFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCMotherDiastolicFld)
                        "Mother diastolic"
                        ""
                        True
                        cfg.model.pcMotherDiastolic
                        (getErr PCMotherDiastolicFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCMotherCRFld)
                        "Mother pulse"
                        ""
                        True
                        cfg.model.pcMotherCR
                        (getErr PCMotherCRFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCMotherBreastsFld cfg.model.pcMotherBreasts)
                        "Mother breasts"
                        (getErr PCMotherBreastsFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCMotherFundusFld cfg.model.pcMotherFundus)
                        "Mother fundus"
                        (getErr PCMotherFundusFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCMotherPerineumFld cfg.model.pcMotherPerineum)
                        "Mother perineum"
                        (getErr PCMotherPerineumFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCMotherLochiaFld cfg.model.pcMotherLochia)
                        "Mother lochia"
                        (getErr PCMotherLochiaFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCMotherUrineFld cfg.model.pcMotherUrine)
                        "Mother urine"
                        (getErr PCMotherUrineFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCMotherStoolFld cfg.model.pcMotherStool)
                        "Mother stool"
                        (getErr PCMotherStoolFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCMotherSSInfectionFld cfg.model.pcMotherSSInfection)
                        "Mother S/S infection"
                        (getErr PCMotherSSInfectionFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD PCMotherFamilyPlanningFld cfg.model.pcMotherFamilyPlanning)
                        "Mother family planning"
                        (getErr PCMotherFamilyPlanningFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field-2x" ]
                    [ Form.checkboxPlainWide "Birth cert registered"
                        (FldChgBool >> FldChgSubMsg PCBirthCertReqFld)
                        cfg.model.pcBirthCertReq
                    , H.text (getErr PCBirthCertReqFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field-2x" ]
                    [ Form.checkboxPlainWide "Hgb requested"
                        (FldChgBool >> FldChgSubMsg PCHgbRequestedFld)
                        cfg.model.pcHgbRequested
                    , H.text (getErr PCHgbRequestedFld errors)
                    ]
                , if cfg.model.browserSupportsDate then
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Date of Hgb test" ]
                            ]
                        , H.div [ HA.class "c-card__body dateTimeModalBody" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDate (FldChgString >> FldChgSubMsg PCHgbTestDateFld)
                                    "Date"
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.pcHgbTestDate
                                    (getErr PCHgbTestDateFld errors)
                                ]
                            ]
                        ]
                  else
                    -- Browser does not support date.
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Hgb test date" ]
                            ]
                        , H.div [ HA.class "c-card__body" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDatePicker OpenDatePickerSubMsg
                                    PostpartumCheckHgbField
                                    "Date"
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.pcHgbTestDate
                                    (getErr PCHgbTestDateFld errors)
                                ]
                            ]
                        ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCHgbTestResultFld)
                        "Hgb result"
                        ""
                        True
                        cfg.model.pcHgbTestResult
                        (getErr PCHgbTestResultFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg PCIronGivenFld)
                        "# iron given"
                        ""
                        True
                        cfg.model.pcIronGiven
                        (getErr PCIronGivenFld errors)
                    ]
                , if cfg.model.browserSupportsDate then
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Next scheduled visit" ]
                            ]
                        , H.div [ HA.class "c-card__body dateTimeModalBody" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDate (FldChgString >> FldChgSubMsg PCNextScheduledCheckFld)
                                    "Date"
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.pcNextScheduledCheck
                                    (getErr PCNextScheduledCheckFld errors)
                                ]
                            ]
                        ]
                  else
                    -- Browser does not support date.
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Next scheduled check" ]
                            ]
                        , H.div [ HA.class "c-card__body" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDatePicker OpenDatePickerSubMsg
                                    PostpartumCheckScheduledField
                                    "Date"
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.pcNextScheduledCheck
                                    (getErr PCNextScheduledCheckFld errors)
                                ]
                            ]
                        ]
                , Form.formTextareaField (FldChgString >> FldChgSubMsg PCCommentsFld)
                    "Comments"
                    ""
                    True
                    cfg.model.pcComments
                    3
                ]
            ]
        , H.div
            [ HA.class "spacedButtons"
            , HA.style [ ( "width", "100%" ) ]
            ]
            [ H.button
                [ HA.type_ "button"
                , HA.class "c-button c-button u-small"
                , HE.onClick cfg.closeMsg
                ]
                [ H.text "Cancel" ]
            , H.button
                [ HA.type_ "button"
                , HA.class "c-button c-button--brand u-small"
                , HE.onClick <|
                    HandlePostpartumCheckModal CloseSaveDialog
                        cfg.model.currPostpartumCheckId
                ]
                [ H.text "Save" ]
            ]
        ]



-- VALIDATION --


type alias FieldError =
    ( Field, String )


validatePostpartumCheck : Model -> List FieldError
validatePostpartumCheck =
    Validate.all
        [ .pcCheckDate >> ifInvalid U.validateDate (PCCheckDateFld => "Date of check must be provided.")
        , .pcCheckTime >> ifInvalid U.validateTime (PCCheckTimeFld => "Time of check must be provided.")
        ]
