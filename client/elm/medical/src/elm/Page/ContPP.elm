module Page.ContPP
    exposing
        ( Model
        , buildModel
        , getTableData
        , init
        , update
        , view
        )

-- LOCAL IMPORTS --

import Const exposing (Dialog(..), FldChgValue(..))
import Data.Baby
    exposing
        ( BabyRecord
        )
import Data.BabyMedication
    exposing
        ( BabyMedicationRecord
        , BabyMedicationRecordNew
        , babyMedicationRecordNewToValue
        , babyMedicationRecordToValue
        )
import Data.BabyMedicationType
    exposing
        ( BabyMedicationTypeRecord
        )
import Data.BabyVaccination
    exposing
        ( BabyVaccinationRecord
        , BabyVaccinationRecordNew
        , babyVaccinationRecordNewToValue
        , babyVaccinationRecordToValue
        )
import Data.BabyVaccinationType
    exposing
        ( BabyVaccinationTypeRecord
        )
import Data.ContPP
    exposing
        ( Field(..)
        , MedVacLab(..)
        , SubMsg(..)
        )
import Data.ContPostpartumCheck
    exposing
        ( ContPostpartumCheckId(..)
        , ContPostpartumCheckRecord
        , ContPostpartumCheckRecordNew
        , contPostpartumCheckRecordNewToValue
        , contPostpartumCheckRecordToValue
        )
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
import Data.NewbornExam
    exposing
        ( NewbornExamId(..)
        , NewbornExamRecord
        , NewbornExamRecordNew
        , isNewbornExamRecordComplete
        , newbornExamRecordNewToNewbornExamRecord
        , newbornExamRecordNewToValue
        , newbornExamRecordToValue
        )
import Data.Patient exposing (PatientRecord)
import Data.PostpartumCheck exposing (PostpartumCheck)
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
    | NewbornExamViewState
    | NewbornExamEditState
    | ContPostpartumCheckViewState
    | ContPostpartumCheckEditState
    | BabyMedVacLabViewState
    | BabyMedVacLabEditState


{-| Handles user input for new or existing medication and
vaccination records.
-}
type alias MedVacFlds =
    { id : Maybe Int
    , date : Maybe Date
    , time : Maybe String
    , location : Maybe String
    , initials : Maybe String
    , comments : Maybe String
    , baby_id : Int
    , isEditing : Bool
    }


{-| Used with the DateField with the DynamicDateField
constructor as the first parameter.
-}
babyMedicalDynamicDateCategory : Int
babyMedicalDynamicDateCategory =
    1


{-| Used with the DateField with the DynamicDateField
constructor as the first parameter.
-}
babyVaccinationDynamicDateCategory : Int
babyVaccinationDynamicDateCategory =
    2


babyLabsDynamicDateCategory : Int
babyLabsDynamicDateCategory =
    3


type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , pregnancy_id : PregnancyId
    , currLaborId : Maybe LaborId
    , currContPostpartumCheckId : Maybe ContPostpartumCheckId
    , currPregHeaderContent : PregHeaderData.PregHeaderContent
    , dataCache : Dict String DataCache
    , pendingSelectQuery : Dict String Table
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    , laborRecord : LaborRecord
    , laborStage1Record : Maybe LaborStage1Record
    , laborStage2Record : Maybe LaborStage2Record
    , laborStage3Record : Maybe LaborStage3Record
    , babyRecord : Maybe BabyRecord
    , newbornExamRecord : Maybe NewbornExamRecord
    , contPostpartumCheckRecords : List ContPostpartumCheckRecord
    , babyMedicationRecords : List BabyMedicationRecord
    , babyVaccinationRecords : List BabyVaccinationRecord
    , selectDataRecords : List SelectDataRecord
    , babyMedicationTypeRecords : List BabyMedicationTypeRecord
    , babyVaccinationTypeRecords : List BabyVaccinationTypeRecord
    , newbornExamViewEditState : ViewEditState
    , nbsDate : Maybe Date
    , nbsTime : Maybe String
    , nbsExaminers : Maybe String
    , nbsRR : Maybe String
    , nbsHR : Maybe String
    , nbsTemperature : Maybe String
    , nbsLength : Maybe String
    , nbsHeadCir : Maybe String
    , nbsChestCir : Maybe String
    , nbsAppearance : List SelectDataRecord
    , nbsColor : List SelectDataRecord
    , nbsSkin : List SelectDataRecord
    , nbsHead : List SelectDataRecord
    , nbsEyes : List SelectDataRecord
    , nbsEars : List SelectDataRecord
    , nbsNose : List SelectDataRecord
    , nbsMouth : List SelectDataRecord
    , nbsNeck : List SelectDataRecord
    , nbsChest : List SelectDataRecord
    , nbsLungs : List SelectDataRecord
    , nbsHeart : List SelectDataRecord
    , nbsAbdomen : List SelectDataRecord
    , nbsHips : List SelectDataRecord
    , nbsCord : List SelectDataRecord
    , nbsFemoralPulses : List SelectDataRecord
    , nbsGenitalia : List SelectDataRecord
    , nbsAnus : List SelectDataRecord
    , nbsBack : List SelectDataRecord
    , nbsExtremities : List SelectDataRecord
    , nbsEstGA : Maybe String
    , nbsMoroReflex : Maybe Bool
    , nbsMoroReflexComment : Maybe String
    , nbsPalmarReflex : Maybe Bool
    , nbsPalmarReflexComment : Maybe String
    , nbsSteppingReflex : Maybe Bool
    , nbsSteppingReflexComment : Maybe String
    , nbsPlantarReflexComment : Maybe String
    , nbsPlantarReflex : Maybe Bool
    , nbsBabinskiReflexComment : Maybe String
    , nbsBabinskiReflex : Maybe Bool
    , nbsComments : Maybe String
    , contPostpartumCheckViewEditState : ViewEditState
    , cpcCheckDate : Maybe Date
    , cpcCheckTime : Maybe String
    , cpcMotherSystolic : Maybe String
    , cpcMotherDiastolic : Maybe String
    , cpcMotherCR : Maybe String
    , cpcMotherTemp : Maybe String
    , cpcMotherFundus : Maybe String
    , cpcMotherEBL : Maybe String
    , cpcBabyBFed : Maybe Bool
    , cpcBabyTemp : Maybe String
    , cpcBabyRR : Maybe String
    , cpcBabyCR : Maybe String
    , cpcComments : Maybe String
    , babyMedVacLabViewEditState : ViewEditState
    , babyMedFlds : Dict Int MedVacFlds
    , babyVacFlds : Dict Int MedVacFlds
    }


babyMedicationRecordToMedVacFlds : BabyMedicationRecord -> MedVacFlds
babyMedicationRecordToMedVacFlds rec =
    MedVacFlds (Just rec.id)
        (Just rec.medicationDate)
        (Just <| U.dateToTimeString rec.medicationDate)
        rec.location
        rec.initials
        rec.comments
        rec.baby_id
        False


babyVaccinationRecordToMedVacFlds : BabyVaccinationRecord -> MedVacFlds
babyVaccinationRecordToMedVacFlds rec =
    MedVacFlds (Just rec.id)
        (Just rec.vaccinationDate)
        (Just <| U.dateToTimeString rec.vaccinationDate)
        rec.location
        rec.initials
        rec.comments
        rec.baby_id
        False


defaultMedBabyMedVacFlds : Int -> MedVacFlds
defaultMedBabyMedVacFlds baby_id =
    MedVacFlds Nothing
        Nothing
        Nothing
        Nothing
        Nothing
        Nothing
        baby_id
        False


defaultVacBabyMedVacFlds : Int -> MedVacFlds
defaultVacBabyMedVacFlds baby_id =
    MedVacFlds Nothing
        Nothing
        Nothing
        Nothing
        Nothing
        Nothing
        baby_id
        False


setEditingBabyMedVacFlds : Int -> Bool -> Dict Int MedVacFlds -> Dict Int MedVacFlds
setEditingBabyMedVacFlds typeId isEditing fields =
    Dict.update typeId
        (\rec ->
            case rec of
                Just r ->
                    Just { r | isEditing = isEditing }

                Nothing ->
                    Nothing
        )
        fields


{-| Get records from the server that we don't already have like baby and
postpartum checks.
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
                , Baby
                , ContPostpartumCheck
                ]

        ( processId, processStore ) =
            Processing.add (SelectQueryType (ContPPLoaded pregId laborRec) selectQuery) Nothing store

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
    -> Maybe (Dict Int BabyRecord)
    -> Bool
    -> Time
    -> ProcessStore
    -> PregnancyId
    -> Maybe PatientRecord
    -> Maybe PregnancyRecord
    -> ( Model, ProcessStore, Cmd Msg )
buildModel laborRec stage1Rec stage2Rec stage3Rec contPPCheckRecs babyRecords browserSupportsDate currTime store pregId patRec pregRec =
    let
        -- Get the lookup tables that this page will need.
        ( newStore, getSelectDataCmd ) =
            getTableData store SelectData Nothing []

        ( newStore2, getBabyMedicationTypeCmd ) =
            getTableData newStore BabyMedicationType Nothing []

        ( newStore3, getBabyVaccinationTypeCmd ) =
            getTableData newStore2 BabyVaccinationType Nothing []

        -- Populate the pendingSelectQuery field with dependent tables that
        -- we will need if/when they are available.
        pendingSelectQuery =
            Dict.singleton (tableToString NewbornExam) NewbornExam
                |> Dict.insert (tableToString BabyMedication) BabyMedication
                |> Dict.insert (tableToString BabyVaccination) BabyVaccination

        -- We are not setup yet for multiple births, therefore we assume that there
        -- is only one baby.
        babyRecord =
            getBabyRecord babyRecords
    in
    ( { browserSupportsDate = browserSupportsDate
      , currTime = currTime
      , pregnancy_id = pregId
      , currLaborId = Just (LaborId laborRec.id)
      , currContPostpartumCheckId = Nothing
      , currPregHeaderContent = PregHeaderData.IPPContent
      , dataCache = Dict.empty
      , pendingSelectQuery = pendingSelectQuery
      , patientRecord = patRec
      , pregnancyRecord = pregRec
      , laborRecord = laborRec
      , laborStage1Record = stage1Rec
      , laborStage2Record = stage2Rec
      , laborStage3Record = stage3Rec
      , babyRecord = babyRecord
      , newbornExamRecord = Nothing
      , contPostpartumCheckRecords = contPPCheckRecs
      , babyMedicationRecords = []
      , babyVaccinationRecords = []
      , selectDataRecords = []
      , babyMedicationTypeRecords = []
      , babyVaccinationTypeRecords = []
      , newbornExamViewEditState = NoViewEditState
      , nbsDate = Nothing
      , nbsTime = Nothing
      , nbsExaminers = Nothing
      , nbsRR = Nothing
      , nbsHR = Nothing
      , nbsTemperature = Nothing
      , nbsLength = Nothing
      , nbsHeadCir = Nothing
      , nbsChestCir = Nothing
      , nbsAppearance = []
      , nbsColor = []
      , nbsSkin = []
      , nbsHead = []
      , nbsEyes = []
      , nbsEars = []
      , nbsNose = []
      , nbsMouth = []
      , nbsNeck = []
      , nbsChest = []
      , nbsLungs = []
      , nbsHeart = []
      , nbsAbdomen = []
      , nbsHips = []
      , nbsCord = []
      , nbsFemoralPulses = []
      , nbsGenitalia = []
      , nbsAnus = []
      , nbsBack = []
      , nbsExtremities = []
      , nbsEstGA = Nothing
      , nbsMoroReflex = Nothing
      , nbsMoroReflexComment = Nothing
      , nbsPalmarReflex = Nothing
      , nbsPalmarReflexComment = Nothing
      , nbsSteppingReflex = Nothing
      , nbsSteppingReflexComment = Nothing
      , nbsPlantarReflexComment = Nothing
      , nbsPlantarReflex = Nothing
      , nbsBabinskiReflexComment = Nothing
      , nbsBabinskiReflex = Nothing
      , nbsComments = Nothing
      , contPostpartumCheckViewEditState = NoViewEditState
      , cpcCheckDate = Nothing
      , cpcCheckTime = Nothing
      , cpcMotherSystolic = Nothing
      , cpcMotherDiastolic = Nothing
      , cpcMotherCR = Nothing
      , cpcMotherTemp = Nothing
      , cpcMotherFundus = Nothing
      , cpcMotherEBL = Nothing
      , cpcBabyBFed = Nothing
      , cpcBabyTemp = Nothing
      , cpcBabyRR = Nothing
      , cpcBabyCR = Nothing
      , cpcComments = Nothing
      , babyMedVacLabViewEditState = NoViewEditState
      , babyMedFlds = Dict.empty
      , babyVacFlds = Dict.empty
      }
    , newStore3
    , Cmd.batch [ getSelectDataCmd, getBabyMedicationTypeCmd, getBabyVaccinationTypeCmd ]
    )


{-| Retrieve additional data from the server as may be necessary after the page is
fully loaded.
-}
getTableData : ProcessStore -> Table -> Maybe Int -> List Table -> ( ProcessStore, Cmd Msg )
getTableData store table key relatedTbls =
    let
        selectQuery =
            SelectQuery table key relatedTbls

        -- We add the primary table to the list of tables affected so
        -- that refreshModelFromCache will update our model for the
        -- primary table as well as the related tables.
        dataCacheTables =
            relatedTbls ++ [ table ]

        ( processId, processStore ) =
            Processing.add
                (SelectQueryType
                    (ContPPMsg
                        (DataCache Nothing (Just dataCacheTables))
                    )
                    selectQuery
                )
                Nothing
                store

        msg =
            wrapPayload processId SelectMsgType (selectQueryToValue selectQuery)
    in
    processStore => Ports.outgoing msg


{-| Return the baby record we are using. We acknowledge that this client
does not handle multiple births and this function assumes that. We take the
first baby record we have and assume that is the one.
-}
getBabyRecord : Maybe (Dict Int BabyRecord) -> Maybe BabyRecord
getBabyRecord recs =
    case recs of
        Just r ->
            Dict.values r |> List.head

        Nothing ->
            Nothing



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

                        BabyMedication ->
                            case DataCache.get t dc of
                                Just (BabyMedicationDataCache recs) ->
                                    { m | babyMedicationRecords = recs }

                                _ ->
                                    m

                        BabyMedicationType ->
                            case DataCache.get t dc of
                                Just (BabyMedicationTypeDataCache recs) ->
                                    { m | babyMedicationTypeRecords = recs }

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

                        NewbornExam ->
                            case DataCache.get t dc of
                                Just (NewbornExamDataCache rec) ->
                                    { m | newbornExamRecord = Just rec }

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
                                    Debug.log "ContPP.refreshModelFromCache: Unhandled Table" <| toString t
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
            let
                newModel =
                    case ( dc, tbls ) of
                        ( Just dataCache, tables ) ->
                            let
                                newModel =
                                    refreshModelFromCache dataCache (Maybe.withDefault [] tables) model

                                -- If BabyMedication or BabyVaccination data has come in
                                -- and we have the dialog open, then update the form fields.
                                newModel2 =
                                    case tables of
                                        Just tbls ->
                                            List.foldl
                                                (\tbl mdl ->
                                                    if model.babyMedVacLabViewEditState /= NoViewEditState then
                                                        if tbl == BabyMedication then
                                                            populateBabyMedFields mdl
                                                        else if tbl == BabyVaccination then
                                                            populateBabyVacFields mdl
                                                        else
                                                            mdl
                                                    else
                                                        mdl
                                                )
                                                newModel
                                                tbls

                                        Nothing ->
                                            newModel
                            in
                            { newModel2 | dataCache = dataCache }

                        ( _, _ ) ->
                            model

                -- Get all sub tables of baby that are pending retrieval from the server.
                ( newCmd, newPendingSQ ) =
                    case newModel.babyRecord of
                        Just baby ->
                            if
                                Dict.member (tableToString NewbornExam) newModel.pendingSelectQuery
                                    || Dict.member (tableToString BabyMedication) newModel.pendingSelectQuery
                                    || Dict.member (tableToString BabyVaccination) newModel.pendingSelectQuery
                            then
                                ( Task.perform
                                    (always
                                        (ContPPSelectQuery Baby
                                            (Just baby.id)
                                            [ NewbornExam, BabyMedication, BabyVaccination ]
                                        )
                                    )
                                    (Task.succeed True)
                                , Dict.remove (tableToString NewbornExam) newModel.pendingSelectQuery
                                    |> Dict.remove (tableToString BabyMedication)
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
                        ContPostpartumCheckDateField ->
                            ( { model | cpcCheckDate = Just date }, Cmd.none, Cmd.none )

                        NewBornExamDateField ->
                            ( { model | nbsDate = Just date }, Cmd.none, Cmd.none )

                        DynamicDateField type_ typeId ->
                            -- The type_ identifies whether this is a babyMedication or
                            -- babyVaccination, etc. The typeId identifies the specifc
                            -- medication or vaccination and is the same as the
                            -- babyMedicationType or babyVaccinationType fields in
                            -- the respective records.
                            --
                            -- NOTE: this is used for browsers that do not support
                            -- the date field.
                            if type_ == babyMedicalDynamicDateCategory then
                                let
                                    _ =
                                        Debug.log "DynamicDateField" <| toString type_ ++ ", " ++ toString typeId

                                    newModel =
                                        case Dict.get typeId model.babyMedFlds of
                                            Just medFlds ->
                                                { model
                                                    | babyMedFlds =
                                                        Dict.insert typeId
                                                            { medFlds | date = Just date }
                                                            model.babyMedFlds
                                                }

                                            Nothing ->
                                                model
                                in
                                ( newModel, Cmd.none, Cmd.none )
                            else if type_ == babyVaccinationDynamicDateCategory then
                                let
                                    _ =
                                        Debug.log "DynamicDateField" <| toString type_ ++ ", " ++ toString typeId

                                    newModel =
                                        case Dict.get typeId model.babyVacFlds of
                                            Just vacFlds ->
                                                { model
                                                    | babyVacFlds =
                                                        Dict.insert typeId
                                                            { vacFlds | date = Just date }
                                                            model.babyVacFlds
                                                }

                                            Nothing ->
                                                model
                                in
                                ( newModel, Cmd.none, Cmd.none )
                            else
                                ( model, Cmd.none, logConsole <| "Unknown DynamicDateField category of: " ++ toString type_ )

                        UnknownDateField str ->
                            ( model, Cmd.none, logConsole str )

                        _ ->
                            let
                                _ =
                                    Debug.log "ContPP DateFieldSubMsg" <| toString dateFldMsg
                            in
                            -- This page is not the only one with date fields, we only
                            -- handle what we know about.
                            ( model, Cmd.none, Cmd.none )

                UnknownDateFieldMessage str ->
                    ( model, Cmd.none, Cmd.none )

        FldChgSubMsg fld val ->
            -- All fields are handled here except for the date fields for browsers that
            -- do not support the input date type (see DateFieldSubMsg for those) and
            -- the boolean fields handled by FldChgBoolSubMsg above.
            case val of
                FldChgString value ->
                    ( case fld of
                        NBSDateFld ->
                            { model | nbsDate = Date.fromString value |> Result.toMaybe }

                        NBSTimeFld ->
                            { model | nbsTime = Just <| U.filterStringLikeTime value }

                        NBSExaminersFld ->
                            { model | nbsExaminers = Just value }

                        NBSRRFld ->
                            { model | nbsRR = Just <| U.filterStringLikeInt value }

                        NBSHRFld ->
                            { model | nbsHR = Just <| U.filterStringLikeInt value }

                        NBSTemperatureFld ->
                            { model | nbsTemperature = Just <| U.filterStringLikeFloat value }

                        NBSLengthFld ->
                            { model | nbsLength = Just <| U.filterStringLikeInt value }

                        NBSHeadCirFld ->
                            { model | nbsHeadCir = Just <| U.filterStringLikeInt value }

                        NBSChestCirFld ->
                            { model | nbsChestCir = Just <| U.filterStringLikeInt value }

                        NBSEstGAFld ->
                            { model | nbsEstGA = Just value }

                        NBSMoroReflexCommentFld ->
                            { model | nbsMoroReflexComment = Just value }

                        NBSPalmarReflexCommentFld ->
                            { model | nbsPalmarReflexComment = Just value }

                        NBSSteppingReflexCommentFld ->
                            { model | nbsSteppingReflexComment = Just value }

                        NBSPlantarReflexCommentFld ->
                            { model | nbsPlantarReflexComment = Just value }

                        NBSBabinskiReflexCommentFld ->
                            { model | nbsBabinskiReflexComment = Just value }

                        NBSCommentsFld ->
                            { model | nbsComments = Just value }

                        CPCCheckDateFld ->
                            { model | cpcCheckDate = Date.fromString value |> Result.toMaybe }

                        CPCCheckTimeFld ->
                            { model | cpcCheckTime = Just <| U.filterStringLikeTime value }

                        CPCMotherSystolicFld ->
                            { model | cpcMotherSystolic = Just <| U.filterStringLikeInt value }

                        CPCMotherDiastolicFld ->
                            { model | cpcMotherDiastolic = Just <| U.filterStringLikeInt value }

                        CPCMotherCRFld ->
                            { model | cpcMotherCR = Just <| U.filterStringLikeInt value }

                        CPCMotherTempFld ->
                            { model | cpcMotherTemp = Just <| U.filterStringLikeFloat value }

                        CPCMotherFundusFld ->
                            { model | cpcMotherFundus = Just value }

                        CPCMotherEBLFld ->
                            { model | cpcMotherEBL = Just <| U.filterStringLikeInt value }

                        CPCBabyTempFld ->
                            { model | cpcBabyTemp = Just <| U.filterStringLikeFloat value }

                        CPCBabyRRFld ->
                            { model | cpcBabyRR = Just <| U.filterStringLikeInt value }

                        CPCBabyCRFld ->
                            { model | cpcBabyCR = Just <| U.filterStringLikeInt value }

                        CPCCommentsFld ->
                            { model | cpcComments = Just value }

                        _ ->
                            model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgStringList selectKey isChecked ->
                    ( case fld of
                        NBSAppearanceFld ->
                            { model | nbsAppearance = setSelectedBySelectKey selectKey isChecked model.nbsAppearance }

                        NBSColorFld ->
                            { model | nbsColor = setSelectedBySelectKey selectKey isChecked model.nbsColor }

                        NBSSkinFld ->
                            { model | nbsSkin = setSelectedBySelectKey selectKey isChecked model.nbsSkin }

                        NBSHeadFld ->
                            { model | nbsHead = setSelectedBySelectKey selectKey isChecked model.nbsHead }

                        NBSEyesFld ->
                            { model | nbsEyes = setSelectedBySelectKey selectKey isChecked model.nbsEyes }

                        NBSEarsFld ->
                            { model | nbsEars = setSelectedBySelectKey selectKey isChecked model.nbsEars }

                        NBSNoseFld ->
                            { model | nbsNose = setSelectedBySelectKey selectKey isChecked model.nbsNose }

                        NBSMouthFld ->
                            { model | nbsMouth = setSelectedBySelectKey selectKey isChecked model.nbsMouth }

                        NBSNeckFld ->
                            { model | nbsNeck = setSelectedBySelectKey selectKey isChecked model.nbsNeck }

                        NBSChestFld ->
                            { model | nbsChest = setSelectedBySelectKey selectKey isChecked model.nbsChest }

                        NBSLungsFld ->
                            { model | nbsLungs = setSelectedBySelectKey selectKey isChecked model.nbsLungs }

                        NBSHeartFld ->
                            { model | nbsHeart = setSelectedBySelectKey selectKey isChecked model.nbsHeart }

                        NBSAbdomenFld ->
                            { model | nbsAbdomen = setSelectedBySelectKey selectKey isChecked model.nbsAbdomen }

                        NBSHipsFld ->
                            { model | nbsHips = setSelectedBySelectKey selectKey isChecked model.nbsHips }

                        NBSCordFld ->
                            { model | nbsCord = setSelectedBySelectKey selectKey isChecked model.nbsCord }

                        NBSFemoralPulsesFld ->
                            { model | nbsFemoralPulses = setSelectedBySelectKey selectKey isChecked model.nbsFemoralPulses }

                        NBSGenitaliaFld ->
                            { model | nbsGenitalia = setSelectedBySelectKey selectKey isChecked model.nbsGenitalia }

                        NBSAnusFld ->
                            { model | nbsAnus = setSelectedBySelectKey selectKey isChecked model.nbsAnus }

                        NBSBackFld ->
                            { model | nbsBack = setSelectedBySelectKey selectKey isChecked model.nbsBack }

                        NBSExtremitiesFld ->
                            { model | nbsExtremities = setSelectedBySelectKey selectKey isChecked model.nbsExtremities }

                        _ ->
                            model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgBool value ->
                    ( case fld of
                        NBSMoroReflexFld ->
                            { model | nbsMoroReflex = Just value }

                        NBSPalmarReflexFld ->
                            { model | nbsPalmarReflex = Just value }

                        NBSSteppingReflexFld ->
                            { model | nbsSteppingReflex = Just value }

                        NBSPlantarReflexFld ->
                            { model | nbsPlantarReflex = Just value }

                        NBSBabinskiReflexFld ->
                            { model | nbsBabinskiReflex = Just value }

                        CPCBabyBFedFld ->
                            { model | cpcBabyBFed = Just value }

                        _ ->
                            model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgIntString intVal strVal ->
                    -- For the BabyMed and BabyVac fields, the intVal is the medicationType
                    -- or vaccinationType id, respectively.
                    ( case fld of
                        BabyMedDateFld ->
                            let
                                newModel =
                                    case Dict.get intVal model.babyMedFlds of
                                        Just medFlds ->
                                            { model
                                                | babyMedFlds =
                                                    Dict.insert intVal
                                                        { medFlds | date = Date.fromString strVal |> Result.toMaybe }
                                                        model.babyMedFlds
                                            }

                                        Nothing ->
                                            model
                            in
                            newModel

                        BabyMedTimeFld ->
                            let
                                newModel =
                                    case Dict.get intVal model.babyMedFlds of
                                        Just medFlds ->
                                            { model
                                                | babyMedFlds =
                                                    Dict.insert intVal
                                                        { medFlds | time = Just <| U.filterStringLikeTime strVal }
                                                        model.babyMedFlds
                                            }

                                        Nothing ->
                                            model
                            in
                            newModel

                        BabyMedLocationFld ->
                            let
                                newModel =
                                    case Dict.get intVal model.babyMedFlds of
                                        Just medFlds ->
                                            { model
                                                | babyMedFlds =
                                                    Dict.insert intVal
                                                        { medFlds | location = Just strVal }
                                                        model.babyMedFlds
                                            }

                                        Nothing ->
                                            model
                            in
                            newModel

                        BabyMedInitialsFld ->
                            let
                                newModel =
                                    case Dict.get intVal model.babyMedFlds of
                                        Just medFlds ->
                                            { model
                                                | babyMedFlds =
                                                    Dict.insert intVal
                                                        { medFlds | initials = Just strVal }
                                                        model.babyMedFlds
                                            }

                                        Nothing ->
                                            model
                            in
                            newModel

                        BabyMedCommentsFld ->
                            let
                                newModel =
                                    case Dict.get intVal model.babyMedFlds of
                                        Just medFlds ->
                                            { model
                                                | babyMedFlds =
                                                    Dict.insert intVal
                                                        { medFlds | comments = Just strVal }
                                                        model.babyMedFlds
                                            }

                                        Nothing ->
                                            model
                            in
                            newModel

                        BabyVacDateFld ->
                            let
                                newModel =
                                    case Dict.get intVal model.babyVacFlds of
                                        Just vacFlds ->
                                            { model
                                                | babyVacFlds =
                                                    Dict.insert intVal
                                                        { vacFlds | date = Date.fromString strVal |> Result.toMaybe }
                                                        model.babyVacFlds
                                            }

                                        Nothing ->
                                            model
                            in
                            newModel

                        BabyVacTimeFld ->
                            let
                                newModel =
                                    case Dict.get intVal model.babyVacFlds of
                                        Just vacFlds ->
                                            { model
                                                | babyVacFlds =
                                                    Dict.insert intVal
                                                        { vacFlds | time = Just <| U.filterStringLikeTime strVal }
                                                        model.babyVacFlds
                                            }

                                        Nothing ->
                                            model
                            in
                            newModel

                        BabyVacLocationFld ->
                            let
                                newModel =
                                    case Dict.get intVal model.babyVacFlds of
                                        Just vacFlds ->
                                            { model
                                                | babyVacFlds =
                                                    Dict.insert intVal
                                                        { vacFlds | location = Just strVal }
                                                        model.babyVacFlds
                                            }

                                        Nothing ->
                                            model
                            in
                            newModel

                        BabyVacInitialsFld ->
                            let
                                newModel =
                                    case Dict.get intVal model.babyVacFlds of
                                        Just vacFlds ->
                                            { model
                                                | babyVacFlds =
                                                    Dict.insert intVal
                                                        { vacFlds | initials = Just strVal }
                                                        model.babyVacFlds
                                            }

                                        Nothing ->
                                            model
                            in
                            newModel

                        BabyVacCommentsFld ->
                            let
                                newModel =
                                    case Dict.get intVal model.babyVacFlds of
                                        Just vacFlds ->
                                            { model
                                                | babyVacFlds =
                                                    Dict.insert intVal
                                                        { vacFlds | comments = Just strVal }
                                                        model.babyVacFlds
                                            }

                                        Nothing ->
                                            model
                            in
                            newModel

                        _ ->
                            let
                                _ =
                                    Debug.log "ContPP" "Unhandled FldChgIntString"
                            in
                            model
                    , Cmd.none
                    , Cmd.none
                    )

        HandleNewbornExamModal dialogState ->
            case dialogState of
                OpenDialog ->
                    let
                        sex =
                            case model.babyRecord of
                                Just b ->
                                    b.sex

                                Nothing ->
                                    let
                                        _ =
                                            Debug.log "Page/ContPP newbornExam" "Found no baby record; defaulting to Male."
                                    in
                                    Data.Baby.Male

                        newModel =
                            case model.newbornExamRecord of
                                Just rec ->
                                    -- There is already a newbornExam record.
                                    { model
                                        | nbsDate = Just rec.examDatetime
                                        , nbsTime = Just <| U.dateToTimeString rec.examDatetime
                                        , nbsExaminers = U.maybeOr (Just rec.examiners) model.nbsExaminers
                                        , nbsRR = U.maybeOr (Maybe.map toString rec.rr) model.nbsRR
                                        , nbsHR = U.maybeOr (Maybe.map toString rec.hr) model.nbsHR
                                        , nbsTemperature = U.maybeOr (Maybe.map toString rec.temperature) model.nbsTemperature
                                        , nbsLength = U.maybeOr (Maybe.map toString rec.length) model.nbsLength
                                        , nbsHeadCir = U.maybeOr (Maybe.map toString rec.headCir) model.nbsHeadCir
                                        , nbsChestCir = U.maybeOr (Maybe.map toString rec.chestCir) model.nbsChestCir
                                        , nbsAppearance =
                                            filterSetByString Const.newbornExamAppearance
                                                rec.appearance
                                                model.selectDataRecords
                                        , nbsColor =
                                            filterSetByString Const.newbornExamColor
                                                rec.color
                                                model.selectDataRecords
                                        , nbsSkin =
                                            filterSetByString Const.newbornExamSkin
                                                rec.skin
                                                model.selectDataRecords
                                        , nbsHead =
                                            filterSetByString Const.newbornExamHead
                                                rec.head
                                                model.selectDataRecords
                                        , nbsEyes =
                                            filterSetByString Const.newbornExamEyes
                                                rec.eyes
                                                model.selectDataRecords
                                        , nbsEars =
                                            filterSetByString Const.newbornExamEars
                                                rec.ears
                                                model.selectDataRecords
                                        , nbsNose =
                                            filterSetByString Const.newbornExamNose
                                                rec.nose
                                                model.selectDataRecords
                                        , nbsMouth =
                                            filterSetByString Const.newbornExamMouth
                                                rec.mouth
                                                model.selectDataRecords
                                        , nbsNeck =
                                            filterSetByString Const.newbornExamNeck
                                                rec.neck
                                                model.selectDataRecords
                                        , nbsChest =
                                            filterSetByString Const.newbornExamChest
                                                rec.chest
                                                model.selectDataRecords
                                        , nbsLungs =
                                            filterSetByString Const.newbornExamLungs
                                                rec.lungs
                                                model.selectDataRecords
                                        , nbsHeart =
                                            filterSetByString Const.newbornExamHeart
                                                rec.heart
                                                model.selectDataRecords
                                        , nbsAbdomen =
                                            filterSetByString Const.newbornExamAbdomen
                                                rec.abdomen
                                                model.selectDataRecords
                                        , nbsHips =
                                            filterSetByString Const.newbornExamHips
                                                rec.hips
                                                model.selectDataRecords
                                        , nbsCord =
                                            filterSetByString Const.newbornExamCord
                                                rec.cord
                                                model.selectDataRecords
                                        , nbsFemoralPulses =
                                            filterSetByString Const.newbornExamFemoralPulses
                                                rec.femoralPulses
                                                model.selectDataRecords
                                        , nbsGenitalia =
                                            filterSetByString
                                                (if sex == Data.Baby.Male then
                                                    Const.newbornExamGenitaliaMale
                                                 else
                                                    Const.newbornExamGenitaliaFemale
                                                )
                                                rec.genitalia
                                                model.selectDataRecords
                                        , nbsAnus =
                                            filterSetByString Const.newbornExamAnus
                                                rec.anus
                                                model.selectDataRecords
                                        , nbsBack =
                                            filterSetByString Const.newbornExamBack
                                                rec.back
                                                model.selectDataRecords
                                        , nbsExtremities =
                                            filterSetByString Const.newbornExamExtremities
                                                rec.extremities
                                                model.selectDataRecords
                                        , nbsEstGA = U.maybeOr rec.estGA model.nbsEstGA
                                        , nbsMoroReflex = U.maybeOr rec.moroReflex model.nbsMoroReflex
                                        , nbsMoroReflexComment = U.maybeOr rec.moroReflexComment model.nbsMoroReflexComment
                                        , nbsPalmarReflex = U.maybeOr rec.palmarReflex model.nbsPalmarReflex
                                        , nbsPalmarReflexComment = U.maybeOr rec.palmarReflexComment model.nbsPalmarReflexComment
                                        , nbsSteppingReflex = U.maybeOr rec.steppingReflex model.nbsSteppingReflex
                                        , nbsSteppingReflexComment = U.maybeOr rec.steppingReflexComment model.nbsSteppingReflexComment
                                        , nbsPlantarReflex = U.maybeOr rec.plantarReflex model.nbsPlantarReflex
                                        , nbsPlantarReflexComment = U.maybeOr rec.plantarReflexComment model.nbsPlantarReflexComment
                                        , nbsBabinskiReflex = U.maybeOr rec.babinskiReflex model.nbsBabinskiReflex
                                        , nbsBabinskiReflexComment = U.maybeOr rec.babinskiReflexComment model.nbsBabinskiReflexComment
                                        , nbsComments = U.maybeOr rec.comments model.nbsComments
                                    }

                                Nothing ->
                                    -- There is no newbornExam record.
                                    let
                                        currDate =
                                            Date.fromTime model.currTime
                                    in
                                    { model
                                        | nbsDate = Just currDate
                                        , nbsTime = Just <| U.dateToTimeString currDate
                                        , nbsAppearance = filterByName Const.newbornExamAppearance model.selectDataRecords
                                        , nbsColor = filterByName Const.newbornExamColor model.selectDataRecords
                                        , nbsSkin = filterByName Const.newbornExamSkin model.selectDataRecords
                                        , nbsHead = filterByName Const.newbornExamHead model.selectDataRecords
                                        , nbsEyes = filterByName Const.newbornExamEyes model.selectDataRecords
                                        , nbsEars = filterByName Const.newbornExamEars model.selectDataRecords
                                        , nbsNose = filterByName Const.newbornExamNose model.selectDataRecords
                                        , nbsMouth = filterByName Const.newbornExamMouth model.selectDataRecords
                                        , nbsNeck = filterByName Const.newbornExamNeck model.selectDataRecords
                                        , nbsChest = filterByName Const.newbornExamChest model.selectDataRecords
                                        , nbsLungs = filterByName Const.newbornExamLungs model.selectDataRecords
                                        , nbsHeart = filterByName Const.newbornExamHeart model.selectDataRecords
                                        , nbsAbdomen = filterByName Const.newbornExamAbdomen model.selectDataRecords
                                        , nbsHips = filterByName Const.newbornExamHips model.selectDataRecords
                                        , nbsCord = filterByName Const.newbornExamCord model.selectDataRecords
                                        , nbsFemoralPulses = filterByName Const.newbornExamFemoralPulses model.selectDataRecords
                                        , nbsGenitalia =
                                            filterByName
                                                (if sex == Data.Baby.Male then
                                                    Const.newbornExamGenitaliaMale
                                                 else
                                                    Const.newbornExamGenitaliaFemale
                                                )
                                                model.selectDataRecords
                                        , nbsAnus = filterByName Const.newbornExamAnus model.selectDataRecords
                                        , nbsBack = filterByName Const.newbornExamBack model.selectDataRecords
                                        , nbsExtremities = filterByName Const.newbornExamExtremities model.selectDataRecords
                                    }
                    in
                    ( { newModel
                        | newbornExamViewEditState =
                            if model.newbornExamViewEditState == NoViewEditState then
                                NewbornExamViewState
                            else
                                NoViewEditState
                      }
                    , Cmd.none
                    , Cmd.batch
                        [ if model.newbornExamViewEditState == NoViewEditState then
                            Route.addDialogUrl Route.ContPPRoute
                          else
                            Route.back
                        , Task.perform SetDialogActive <| Task.succeed True
                        ]
                    )

                CloseNoSaveDialog ->
                    ( { model | newbornExamViewEditState = NoViewEditState }
                    , Cmd.none
                    , Route.back
                    )

                EditDialog ->
                    ( { model | newbornExamViewEditState = NewbornExamEditState }
                    , Cmd.none
                    , if model.newbornExamViewEditState == NoViewEditState then
                        Cmd.batch
                            [ Route.addDialogUrl Route.ContPPRoute
                            , Task.perform SetDialogActive <| Task.succeed True
                            ]
                      else
                        Cmd.none
                    )

                CloseSaveDialog ->
                    case validateNewbornExam model of
                        [] ->
                            let
                                -- Check that the date and corresponding time fields together
                                -- produce valid dates.
                                examDatetime =
                                    U.maybeDateMaybeTimeToMaybeDateTime model.nbsDate
                                        model.nbsTime
                                        "Please correct the date and time for the newborn exam fields."

                                errors =
                                    U.maybeDateTimeErrors [ examDatetime ]

                                outerMsg =
                                    case ( List.length errors > 0, model.babyRecord, model.newbornExamRecord ) of
                                        ( _, Nothing, _ ) ->
                                            -- No baby record, so we cannot make a newborn exam record.
                                            LogConsole "Error: no baby record found."

                                        ( True, _, _ ) ->
                                            -- Errors found in the date and time field, so notifiy user
                                            -- instead of saving.
                                            Toast (errors ++ [ "Record was not saved." ]) 10 ErrorToast

                                        ( False, Just baby, Just exam ) ->
                                            -- Updating a newborn exam record.
                                            let
                                                newExam =
                                                    { exam
                                                        | examDatetime =
                                                            Maybe.withDefault exam.examDatetime
                                                                (U.maybeDateTimeValue examDatetime)
                                                        , examiners = Maybe.withDefault exam.examiners model.nbsExaminers
                                                        , rr = U.maybeOr (U.maybeStringToMaybeInt model.nbsRR) exam.rr
                                                        , hr = U.maybeOr (U.maybeStringToMaybeInt model.nbsHR) exam.hr
                                                        , temperature =
                                                            U.maybeOr
                                                                (U.maybeStringToMaybeFloat model.nbsTemperature)
                                                                exam.temperature
                                                        , length = U.maybeOr (U.maybeStringToMaybeInt model.nbsLength) exam.length
                                                        , headCir = U.maybeOr (U.maybeStringToMaybeInt model.nbsHeadCir) exam.headCir
                                                        , chestCir = U.maybeOr (U.maybeStringToMaybeInt model.nbsChestCir) exam.chestCir
                                                        , appearance =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsAppearance)
                                                                exam.appearance
                                                        , color =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsColor)
                                                                exam.color
                                                        , skin =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsSkin)
                                                                exam.skin
                                                        , head =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsHead)
                                                                exam.head
                                                        , eyes =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsEyes)
                                                                exam.eyes
                                                        , ears =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsEars)
                                                                exam.ears
                                                        , nose =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsNose)
                                                                exam.nose
                                                        , mouth =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsMouth)
                                                                exam.mouth
                                                        , neck =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsNeck)
                                                                exam.neck
                                                        , chest =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsChest)
                                                                exam.chest
                                                        , lungs =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsLungs)
                                                                exam.lungs
                                                        , heart =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsHeart)
                                                                exam.heart
                                                        , abdomen =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsAbdomen)
                                                                exam.abdomen
                                                        , hips =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsHips)
                                                                exam.hips
                                                        , cord =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsCord)
                                                                exam.cord
                                                        , femoralPulses =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsFemoralPulses)
                                                                exam.femoralPulses
                                                        , genitalia =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsGenitalia)
                                                                exam.genitalia
                                                        , anus =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsAnus)
                                                                exam.anus
                                                        , back =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsBack)
                                                                exam.back
                                                        , extremities =
                                                            U.maybeOr (getSelectDataAsMaybeString model.nbsExtremities)
                                                                exam.extremities
                                                        , estGA = U.maybeOr exam.estGA model.nbsEstGA
                                                        , moroReflex = U.maybeOr exam.moroReflex model.nbsMoroReflex
                                                        , moroReflexComment = U.maybeOr model.nbsMoroReflexComment exam.moroReflexComment
                                                        , palmarReflex = U.maybeOr exam.palmarReflex model.nbsPalmarReflex
                                                        , palmarReflexComment = U.maybeOr model.nbsPalmarReflexComment exam.palmarReflexComment
                                                        , steppingReflex = U.maybeOr exam.steppingReflex model.nbsSteppingReflex
                                                        , steppingReflexComment = U.maybeOr model.nbsSteppingReflexComment exam.steppingReflexComment
                                                        , plantarReflex = U.maybeOr exam.plantarReflex model.nbsPlantarReflex
                                                        , plantarReflexComment = U.maybeOr model.nbsPlantarReflexComment exam.plantarReflexComment
                                                        , babinskiReflex = U.maybeOr exam.babinskiReflex model.nbsBabinskiReflex
                                                        , babinskiReflexComment = U.maybeOr model.nbsBabinskiReflexComment exam.babinskiReflexComment
                                                        , comments = U.maybeOr model.nbsComments exam.comments
                                                    }
                                            in
                                            ProcessTypeMsg
                                                (UpdateNewbornExamType
                                                    (ContPPMsg
                                                        (DataCache Nothing (Just [ NewbornExam ]))
                                                    )
                                                    newExam
                                                )
                                                ChgMsgType
                                                (newbornExamRecordToValue newExam)

                                        ( False, Just baby, Nothing ) ->
                                            -- Creating a newborn exam record.
                                            case deriveNewbornExamRecordNew model of
                                                Just exam ->
                                                    ProcessTypeMsg
                                                        (AddNewbornExamType
                                                            (ContPPMsg
                                                                -- Request top-level to provide data in
                                                                -- the dataCache once received from server.
                                                                (DataCache Nothing (Just [ NewbornExam ]))
                                                            )
                                                            exam
                                                        )
                                                        AddMsgType
                                                        (newbornExamRecordNewToValue exam)

                                                Nothing ->
                                                    LogConsole "deriveNewbornExamRecordNew returned a Nothing"
                            in
                            ( { model | newbornExamViewEditState = NoViewEditState }
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
                            ( { model | newbornExamViewEditState = NoViewEditState }
                            , Cmd.none
                            , toastError msgs 10
                            )

        HandleContPostpartumCheckModal dialogState cpcId ->
            case dialogState of
                OpenDialog ->
                    -- This is used only for new records. EditDialog if used to edit
                    -- existing records using the id passed.
                    let
                        -- Default to the current time and date.
                        currDate =
                            Date.fromTime model.currTime

                        newModel =
                            clearContPostpartumCheckModelFields model
                                |> (\mdl ->
                                        { mdl
                                            | cpcCheckDate = Just currDate
                                            , cpcCheckTime = Just <| U.dateToTimeString currDate
                                        }
                                   )
                    in
                    ( { newModel | contPostpartumCheckViewEditState = ContPostpartumCheckEditState }
                    , Cmd.none
                    , Cmd.batch
                        [ if model.contPostpartumCheckViewEditState == NoViewEditState then
                            Route.addDialogUrl Route.ContPPRoute
                          else
                            Route.back
                        , Task.perform SetDialogActive <| Task.succeed True
                        ]
                    )

                CloseNoSaveDialog ->
                    ( { model | contPostpartumCheckViewEditState = NoViewEditState }
                    , Cmd.none
                    , Route.back
                    )

                EditDialog ->
                    let
                        newModel =
                            case ( cpcId, DataCache.get ContPostpartumCheck model.dataCache ) of
                                ( Just (ContPostpartumCheckId theId), Just (ContPostpartumCheckDataCache recs) ) ->
                                    case LE.find (\r -> r.id == theId) recs of
                                        Just rec ->
                                            { model
                                                | cpcCheckDate = Just rec.checkDatetime
                                                , cpcCheckTime = Just <| U.dateToTimeString rec.checkDatetime
                                                , cpcMotherSystolic = Maybe.map toString rec.motherSystolic
                                                , cpcMotherDiastolic = Maybe.map toString rec.motherDiastolic
                                                , cpcMotherCR = Maybe.map toString rec.motherCR
                                                , cpcMotherTemp = Maybe.map toString rec.motherTemp
                                                , cpcMotherFundus = rec.motherFundus
                                                , cpcMotherEBL = Maybe.map toString rec.motherEBL
                                                , cpcBabyBFed = rec.babyBFed
                                                , cpcBabyTemp = Maybe.map toString rec.babyTemp
                                                , cpcBabyRR = Maybe.map toString rec.babyRR
                                                , cpcBabyCR = Maybe.map toString rec.babyCR
                                                , cpcComments = rec.comments
                                            }

                                        Nothing ->
                                            model

                                ( _, _ ) ->
                                    model
                    in
                    ( { newModel
                        | contPostpartumCheckViewEditState = ContPostpartumCheckEditState
                        , currContPostpartumCheckId = cpcId
                      }
                    , Cmd.none
                    , if newModel.contPostpartumCheckViewEditState == NoViewEditState then
                        Cmd.batch
                            [ Route.addDialogUrl Route.ContPPRoute
                            , Task.perform SetDialogActive <| Task.succeed True
                            ]
                      else
                        Cmd.none
                    )

                CloseSaveDialog ->
                    case validateContPostpartumCheck model of
                        [] ->
                            let
                                -- Check that the date and corresponding time fields together
                                -- produce valid dates.
                                checkDatetime =
                                    U.maybeDateMaybeTimeToMaybeDateTime model.cpcCheckDate
                                        model.cpcCheckTime
                                        "Please correct the date and time for the postpartum check fields."

                                errors =
                                    U.maybeDateTimeErrors [ checkDatetime ]

                                outerMsg =
                                    case ( List.length errors > 0, model.currLaborId, cpcId ) of
                                        ( True, _, _ ) ->
                                            -- Errors found in the date and time field, so notifiy user
                                            -- instead of saving.
                                            Toast (errors ++ [ "Record was not saved." ]) 10 ErrorToast

                                        ( _, Nothing, _ ) ->
                                            LogConsole "Error: Current labor id is not known."

                                        ( False, Just (LaborId lid), Nothing ) ->
                                            -- New check being created.
                                            case deriveContPostpartumCheckRecordNew model of
                                                Just check ->
                                                    ProcessTypeMsg
                                                        (AddContPostpartumCheckType
                                                            (ContPPMsg
                                                                -- Request top-level to provide data in
                                                                -- the dataCache once received from server.
                                                                (DataCache Nothing (Just [ ContPostpartumCheck ]))
                                                            )
                                                            check
                                                        )
                                                        AddMsgType
                                                        (contPostpartumCheckRecordNewToValue check)

                                                Nothing ->
                                                    LogConsole "deriveContPostpartumCheckRecordNew returned a Nothing"

                                        ( False, Just (LaborId lid), Just (ContPostpartumCheckId checkId) ) ->
                                            -- Existing check being updated.
                                            case DataCache.get ContPostpartumCheck model.dataCache of
                                                Just (ContPostpartumCheckDataCache checks) ->
                                                    case LE.find (\c -> c.id == checkId) checks of
                                                        Just check ->
                                                            let
                                                                newCheck =
                                                                    { check
                                                                        | checkDatetime =
                                                                            Maybe.withDefault check.checkDatetime
                                                                                (U.maybeDateTimeValue checkDatetime)
                                                                        , motherSystolic = U.maybeStringToMaybeInt model.cpcMotherSystolic
                                                                        , motherDiastolic = U.maybeStringToMaybeInt model.cpcMotherDiastolic
                                                                        , motherCR = U.maybeStringToMaybeInt model.cpcMotherCR
                                                                        , motherTemp = U.maybeStringToMaybeFloat model.cpcMotherTemp
                                                                        , motherFundus = model.cpcMotherFundus
                                                                        , motherEBL = U.maybeStringToMaybeInt model.cpcMotherEBL
                                                                        , babyBFed = model.cpcBabyBFed
                                                                        , babyTemp = U.maybeStringToMaybeFloat model.cpcBabyTemp
                                                                        , babyRR = U.maybeStringToMaybeInt model.cpcBabyRR
                                                                        , babyCR = U.maybeStringToMaybeInt model.cpcBabyCR
                                                                        , comments = model.cpcComments
                                                                    }
                                                            in
                                                            ProcessTypeMsg
                                                                (UpdateContPostpartumCheckType
                                                                    (ContPPMsg
                                                                        (DataCache Nothing (Just [ ContPostpartumCheck ]))
                                                                    )
                                                                    newCheck
                                                                )
                                                                ChgMsgType
                                                                (contPostpartumCheckRecordToValue newCheck)

                                                        Nothing ->
                                                            LogConsole "HandleContPostpartumCheckModal: did not find PPCheck in data cache."

                                                _ ->
                                                    Noop
                            in
                            ( { model
                                | contPostpartumCheckViewEditState = NoViewEditState
                                , currContPostpartumCheckId = Nothing
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
                            ( { model | contPostpartumCheckViewEditState = NoViewEditState }
                            , Cmd.none
                            , toastError msgs 10
                            )

        HandleBabyMedVacLabModal dialogState medVacLab ->
            case dialogState of
                OpenDialog ->
                    -- Opens the main page displaying editing and view forms for each of the
                    -- medications, vaccinations, and labs.
                    --
                    -- TODO: populate the respective model fields based on the medicationType,
                    -- vaccinationType, and labType records for baby.
                    --
                    -- NOTE: a unique contraint in the database does not allow more than one
                    -- babyMedication record per babyMedicationType per baby_id.
                    let
                        newModel =
                            populateBabyMedFields model
                                |> populateBabyVacFields
                    in
                    ( { newModel
                        | babyMedVacLabViewEditState =
                            if newModel.babyMedVacLabViewEditState == NoViewEditState then
                                BabyMedVacLabViewState
                            else
                                NoViewEditState
                      }
                    , Cmd.none
                    , Cmd.batch
                        [ if newModel.babyMedVacLabViewEditState == NoViewEditState then
                            Route.addDialogUrl Route.ContPPRoute
                          else
                            Route.back
                        , Task.perform SetDialogActive <| Task.succeed True
                        ]
                    )

                CloseNoSaveDialog ->
                    -- Closes the main page dialog.
                    ( { model | babyMedVacLabViewEditState = NoViewEditState }
                    , Cmd.none
                    , Route.back
                    )

                EditDialog ->
                    -- Edits a specific medication, vaccination, or lab record as
                    -- specified in medVacLab.
                    let
                        newModel =
                            case medVacLab of
                                Just mvl ->
                                    case mvl of
                                        MedMVL id ->
                                            let
                                                newBabyMedFlds =
                                                    setEditingBabyMedVacFlds id
                                                        True
                                                        model.babyMedFlds
                                            in
                                            { model | babyMedFlds = newBabyMedFlds }

                                        VacMVL id ->
                                            let
                                                newBabyVacFlds =
                                                    setEditingBabyMedVacFlds id
                                                        True
                                                        model.babyVacFlds
                                            in
                                            { model | babyVacFlds = newBabyVacFlds }

                                        LabMVL id ->
                                            model

                                Nothing ->
                                    model
                    in
                    ( newModel
                    , Cmd.none
                    , if model.babyMedVacLabViewEditState == NoViewEditState then
                        Cmd.batch
                            [ Route.addDialogUrl Route.ContPPRoute
                            , Task.perform SetDialogActive <| Task.succeed True
                            ]
                      else
                        Cmd.none
                    )

                CloseSaveDialog ->
                    -- Saves a specific medication, vaccination, or lab record as
                    -- specified in medVacLab.
                    -- Note: this does not close the dialog but a successful save
                    -- should change the specific edit form to a view form.
                    let
                        msg =
                            case medVacLab of
                                Just mvl ->
                                    case mvl of
                                        MedMVL id ->
                                            "Medication " ++ toString id

                                        VacMVL id ->
                                            "Vaccination " ++ toString id

                                        LabMVL id ->
                                            "Lab " ++ toString id

                                Nothing ->
                                    "Error"

                        ( newModel, outerMsg ) =
                            case medVacLab of
                                Just mvl ->
                                    case mvl of
                                        MedMVL id ->
                                            let
                                                useLocation =
                                                    case Data.BabyMedicationType.getNameUseLocation id model.babyMedicationTypeRecords of
                                                        Just ( _, ul ) ->
                                                            ul

                                                        Nothing ->
                                                            False

                                                ( msg, success ) =
                                                    deriveBabyMedicationMsg id useLocation model.babyMedFlds

                                                newBabyMedFlds =
                                                    if success then
                                                        setEditingBabyMedVacFlds id
                                                            False
                                                            model.babyMedFlds
                                                    else
                                                        model.babyMedFlds
                                            in
                                            ( { model | babyMedFlds = newBabyMedFlds }
                                            , msg
                                            )

                                        VacMVL id ->
                                            let
                                                useLocation =
                                                    case Data.BabyVaccinationType.getNameUseLocation id model.babyVaccinationTypeRecords of
                                                        Just ( _, ul ) ->
                                                            ul

                                                        Nothing ->
                                                            False

                                                ( msg, success ) =
                                                    deriveBabyVaccinationMsg id useLocation model.babyVacFlds

                                                _ =
                                                    Debug.log "deriveBabyVaccinationMsg" <| toString msg

                                                newBabyVacFlds =
                                                    if success then
                                                        setEditingBabyMedVacFlds id
                                                            False
                                                            model.babyVacFlds
                                                    else
                                                        model.babyVacFlds
                                            in
                                            ( { model | babyVacFlds = newBabyVacFlds }
                                            , msg
                                            )

                                        LabMVL id ->
                                            ( model
                                            , LogConsole "CloseSaveDialog does not handle labs yet."
                                            )

                                Nothing ->
                                    ( model
                                    , LogConsole "Error: medVacLab is Nothing in CloseSaveDialog."
                                    )

                        _ =
                            Debug.log "HandleBabyMedVacLabModal CloseSaveDialog: " msg
                    in
                    ( newModel
                    , Cmd.none
                    , Cmd.batch
                        [ Task.perform (always outerMsg) (Task.succeed True)
                        ]
                    )

        OpenDatePickerSubMsg id ->
            ( model, Cmd.none, Task.perform OpenDatePicker (Task.succeed id) )

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


{-| Clear the continued postpartum check fields in the model.
-}
clearContPostpartumCheckModelFields : Model -> Model
clearContPostpartumCheckModelFields model =
    { model
        | cpcCheckDate = Nothing
        , cpcCheckTime = Nothing
        , cpcMotherSystolic = Nothing
        , cpcMotherDiastolic = Nothing
        , cpcMotherCR = Nothing
        , cpcMotherTemp = Nothing
        , cpcMotherFundus = Nothing
        , cpcMotherEBL = Nothing
        , cpcBabyBFed = Nothing
        , cpcBabyTemp = Nothing
        , cpcBabyRR = Nothing
        , cpcBabyCR = Nothing
        , cpcComments = Nothing
    }


{-| Populate the babyMedFlds in the Model according to
the babyMedicationTypeRecords and the existing babyMedicationRecords.
-}
populateBabyMedFields : Model -> Model
populateBabyMedFields model =
    case model.babyRecord of
        Just baby ->
            List.foldl
                (\medTypeRec mdl ->
                    let
                        newModel =
                            case
                                LE.find
                                    (\m -> m.babyMedicationType == medTypeRec.id)
                                    mdl.babyMedicationRecords
                            of
                                Just babyMedRec ->
                                    -- There is an existing BabyMedicationRecord
                                    -- so use it to populate form fields.
                                    { mdl
                                        | babyMedFlds =
                                            Dict.insert medTypeRec.id
                                                (babyMedicationRecordToMedVacFlds babyMedRec)
                                                mdl.babyMedFlds
                                    }

                                Nothing ->
                                    -- There is no BabyMedicationRecord so
                                    -- populate the form fields with defaults,
                                    -- but only if it is not already there cuz
                                    -- maybe the user has already partially
                                    -- completed the form but not pressed save.
                                    case Dict.member medTypeRec.id mdl.babyMedFlds of
                                        False ->
                                            { mdl
                                                | babyMedFlds =
                                                    Dict.insert medTypeRec.id
                                                        (defaultMedBabyMedVacFlds baby.id)
                                                        mdl.babyMedFlds
                                            }

                                        True ->
                                            mdl
                    in
                    newModel
                )
                model
                model.babyMedicationTypeRecords

        Nothing ->
            -- Don't have a baby record, really?
            model


{-| Populate the babyVacFlds in the Model according to
the babyMedicationTypeRecords and the existing babyMedicationRecords.
-}
populateBabyVacFields : Model -> Model
populateBabyVacFields model =
    case model.babyRecord of
        Just baby ->
            List.foldl
                (\vacTypeRec mdl ->
                    let
                        newModel =
                            case
                                LE.find
                                    (\m -> m.babyVaccinationType == vacTypeRec.id)
                                    mdl.babyVaccinationRecords
                            of
                                Just babyVacRec ->
                                    -- There is an existing BabyVaccinationRecord
                                    -- so use it to populate form fields.
                                    { mdl
                                        | babyVacFlds =
                                            Dict.insert vacTypeRec.id
                                                (babyVaccinationRecordToMedVacFlds babyVacRec)
                                                mdl.babyVacFlds
                                    }

                                Nothing ->
                                    -- There is no BabyVaccinationRecord so
                                    -- populate the form fields with defaults,
                                    -- but only if it is not already there cuz
                                    -- maybe the user has already partially
                                    -- completed the form but not pressed save.
                                    case Dict.member vacTypeRec.id mdl.babyVacFlds of
                                        False ->
                                            { mdl
                                                | babyVacFlds =
                                                    Dict.insert vacTypeRec.id
                                                        (defaultVacBabyMedVacFlds baby.id)
                                                        mdl.babyVacFlds
                                            }

                                        True ->
                                            mdl
                    in
                    newModel
                )
                model
                model.babyVaccinationTypeRecords

        Nothing ->
            -- Don't have a baby record, really?
            model


{-| Generate a Msg and a Bool flagging successfully sending a Msg to the server.
Upon error, the Msg will be either to the console or a Toast to the user.
-}
deriveBabyMedicationMsg : Int -> Bool -> Dict Int MedVacFlds -> ( Msg, Bool )
deriveBabyMedicationMsg medicationTypeId useLocation dict =
    case Dict.get medicationTypeId dict of
        Just rec ->
            let
                errors =
                    validateBabyMedication useLocation rec

                dateTime =
                    U.maybeDateMaybeTimeToMaybeDateTime rec.date
                        rec.time
                        ""
                        |> U.maybeDateTimeValue
            in
            case validateBabyMedication useLocation rec of
                [] ->
                    case dateTime of
                        Just date ->
                            case rec.id of
                                Nothing ->
                                    -- New record
                                    let
                                        newRec =
                                            BabyMedicationRecordNew medicationTypeId
                                                date
                                                rec.location
                                                rec.initials
                                                rec.comments
                                                rec.baby_id
                                    in
                                    ( ProcessTypeMsg
                                        (AddBabyMedicationType
                                            (ContPPMsg
                                                (DataCache Nothing (Just [ BabyMedication ]))
                                            )
                                            newRec
                                        )
                                        AddMsgType
                                        (babyMedicationRecordNewToValue newRec)
                                    , True
                                    )

                                Just id ->
                                    -- Update an existing record.
                                    let
                                        updatedRec =
                                            BabyMedicationRecord id
                                                medicationTypeId
                                                date
                                                rec.location
                                                rec.initials
                                                rec.comments
                                                rec.baby_id
                                    in
                                    ( ProcessTypeMsg
                                        (UpdateBabyMedicationType
                                            (ContPPMsg
                                                (DataCache Nothing (Just [ BabyMedication ]))
                                            )
                                            updatedRec
                                        )
                                        ChgMsgType
                                        (babyMedicationRecordToValue updatedRec)
                                    , True
                                    )

                        Nothing ->
                            ( LogConsole "deriveBabyMedicationMsg: date and time values are not right."
                            , False
                            )

                errors ->
                    let
                        msgs =
                            List.map Tuple.second errors
                                |> flip (++) [ "Record was not saved." ]
                    in
                    ( Toast msgs 10 ErrorToast
                    , False
                    )

        Nothing ->
            ( LogConsole "deriveBabyMedicationMsg: Error: unable to find record in babyMedFlds."
            , False
            )


{-| Generate a Msg and a Bool flagging successfully sending a Msg to the server.
Upon error, the Msg will be either to the console or a Toast to the user.
-}
deriveBabyVaccinationMsg : Int -> Bool -> Dict Int MedVacFlds -> ( Msg, Bool )
deriveBabyVaccinationMsg vaccinationTypeId useLocation dict =
    case Dict.get vaccinationTypeId dict of
        Just rec ->
            let
                errors =
                    validateBabyVaccination useLocation rec

                dateTime =
                    U.maybeDateMaybeTimeToMaybeDateTime rec.date
                        rec.time
                        ""
                        |> U.maybeDateTimeValue
            in
            case validateBabyVaccination useLocation rec of
                [] ->
                    case dateTime of
                        Just date ->
                            case rec.id of
                                Nothing ->
                                    -- New record
                                    let
                                        newRec =
                                            BabyVaccinationRecordNew vaccinationTypeId
                                                date
                                                rec.location
                                                rec.initials
                                                rec.comments
                                                rec.baby_id
                                    in
                                    ( ProcessTypeMsg
                                        (AddBabyVaccinationType
                                            (ContPPMsg
                                                (DataCache Nothing (Just [ BabyVaccination ]))
                                            )
                                            newRec
                                        )
                                        AddMsgType
                                        (babyVaccinationRecordNewToValue newRec)
                                    , True
                                    )

                                Just id ->
                                    -- Update an existing record.
                                    let
                                        updatedRec =
                                            BabyVaccinationRecord id
                                                vaccinationTypeId
                                                date
                                                rec.location
                                                rec.initials
                                                rec.comments
                                                rec.baby_id
                                    in
                                    ( ProcessTypeMsg
                                        (UpdateBabyVaccinationType
                                            (ContPPMsg
                                                (DataCache Nothing (Just [ BabyVaccination ]))
                                            )
                                            updatedRec
                                        )
                                        ChgMsgType
                                        (babyVaccinationRecordToValue updatedRec)
                                    , True
                                    )

                        Nothing ->
                            ( LogConsole "deriveBabyVaccinationMsg: date and time values are not right."
                            , False
                            )

                errors ->
                    let
                        msgs =
                            List.map Tuple.second errors
                                |> flip (++) [ "Record was not saved." ]
                    in
                    ( Toast msgs 10 ErrorToast
                    , False
                    )

        Nothing ->
            ( LogConsole "deriveBabyVaccinationMsg: Error: unable to find record in babyVacFlds."
            , False
            )


deriveContPostpartumCheckRecordNew : Model -> Maybe ContPostpartumCheckRecordNew
deriveContPostpartumCheckRecordNew model =
    case model.currLaborId of
        Just (LaborId lid) ->
            let
                checkDatetime =
                    U.maybeDateMaybeTimeToMaybeDateTime model.cpcCheckDate model.cpcCheckTime ""
                        |> U.maybeDateTimeValue
            in
            case checkDatetime of
                Just d ->
                    Just <|
                        ContPostpartumCheckRecordNew d
                            (U.maybeStringToMaybeInt model.cpcMotherSystolic)
                            (U.maybeStringToMaybeInt model.cpcMotherDiastolic)
                            (U.maybeStringToMaybeInt model.cpcMotherCR)
                            (U.maybeStringToMaybeFloat model.cpcMotherTemp)
                            model.cpcMotherFundus
                            (U.maybeStringToMaybeInt model.cpcMotherEBL)
                            model.cpcBabyBFed
                            (U.maybeStringToMaybeFloat model.cpcBabyTemp)
                            (U.maybeStringToMaybeInt model.cpcBabyRR)
                            (U.maybeStringToMaybeInt model.cpcBabyCR)
                            model.cpcComments
                            lid

                Nothing ->
                    Nothing

        Nothing ->
            Nothing


deriveNewbornExamRecordNew : Model -> Maybe NewbornExamRecordNew
deriveNewbornExamRecordNew model =
    case model.babyRecord of
        Just baby ->
            let
                examDatetime =
                    U.maybeDateMaybeTimeToMaybeDateTime model.nbsDate model.nbsTime ""
                        |> U.maybeDateTimeValue
            in
            case examDatetime of
                Just d ->
                    Just <|
                        NewbornExamRecordNew d
                            (Maybe.withDefault "" model.nbsExaminers)
                            (U.maybeStringToMaybeInt model.nbsRR)
                            (U.maybeStringToMaybeInt model.nbsHR)
                            (U.maybeStringToMaybeFloat model.nbsTemperature)
                            (U.maybeStringToMaybeInt model.nbsLength)
                            (U.maybeStringToMaybeInt model.nbsHeadCir)
                            (U.maybeStringToMaybeInt model.nbsChestCir)
                            (getSelectDataAsMaybeString model.nbsAppearance)
                            (getSelectDataAsMaybeString model.nbsColor)
                            (getSelectDataAsMaybeString model.nbsSkin)
                            (getSelectDataAsMaybeString model.nbsHead)
                            (getSelectDataAsMaybeString model.nbsEyes)
                            (getSelectDataAsMaybeString model.nbsEars)
                            (getSelectDataAsMaybeString model.nbsNose)
                            (getSelectDataAsMaybeString model.nbsMouth)
                            (getSelectDataAsMaybeString model.nbsNeck)
                            (getSelectDataAsMaybeString model.nbsChest)
                            (getSelectDataAsMaybeString model.nbsLungs)
                            (getSelectDataAsMaybeString model.nbsHeart)
                            (getSelectDataAsMaybeString model.nbsAbdomen)
                            (getSelectDataAsMaybeString model.nbsHips)
                            (getSelectDataAsMaybeString model.nbsCord)
                            (getSelectDataAsMaybeString model.nbsFemoralPulses)
                            (getSelectDataAsMaybeString model.nbsGenitalia)
                            (getSelectDataAsMaybeString model.nbsAnus)
                            (getSelectDataAsMaybeString model.nbsBack)
                            (getSelectDataAsMaybeString model.nbsExtremities)
                            model.nbsEstGA
                            model.nbsMoroReflex
                            model.nbsMoroReflexComment
                            model.nbsPalmarReflex
                            model.nbsPalmarReflexComment
                            model.nbsSteppingReflex
                            model.nbsSteppingReflexComment
                            model.nbsPlantarReflex
                            model.nbsPlantarReflexComment
                            model.nbsBabinskiReflex
                            model.nbsBabinskiReflexComment
                            model.nbsComments
                            baby.id

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

        isEditingNewbornExam =
            if model.newbornExamViewEditState == NewbornExamEditState then
                True
            else
                not (isNewbornExamDone model)

        newbornExamViewEditStageConfig =
            ViewEditStageConfig
                (model.newbornExamViewEditState
                    == NewbornExamViewState
                    || model.newbornExamViewEditState
                    == NewbornExamEditState
                )
                isEditingNewbornExam
                "Newborn Exam"
                model
                (HandleNewbornExamModal CloseNoSaveDialog)
                (HandleNewbornExamModal CloseSaveDialog)
                (HandleNewbornExamModal EditDialog)

        isEditingBabyMedVacLab =
            if model.babyMedVacLabViewEditState == NewbornExamEditState then
                True
            else
                not (isBabyMedVacLabDone model)

        babyMedVacLabViewEditStageConfig =
            ViewEditStageConfig
                (model.babyMedVacLabViewEditState
                    == BabyMedVacLabViewState
                    || model.babyMedVacLabViewEditState
                    == BabyMedVacLabEditState
                )
                isEditingBabyMedVacLab
                "Baby Meds, Vacs, and Labs"
                model
                (HandleBabyMedVacLabModal CloseNoSaveDialog Nothing)
                -- These two are customized in a subview.
                PageNoop
                PageNoop

        contPostpartumCheckViewEditStageConfig =
            ViewEditStageConfig
                (model.contPostpartumCheckViewEditState
                    == ContPostpartumCheckViewState
                    || model.contPostpartumCheckViewEditState
                    == NoViewEditState
                )
                (model.contPostpartumCheckViewEditState == ContPostpartumCheckEditState)
                "Continued Postpartum Checks"
                model
                (HandleContPostpartumCheckModal CloseNoSaveDialog Nothing)
                -- These two are not used because of ContPostpartumCheckId being passed.
                PageNoop
                PageNoop
    in
    H.div []
        [ pregHeader |> H.map (\a -> RotatePregHeaderContent a)
        , H.div [ HA.class "content-wrapper" ]
            [ viewButtons model
            , dialogNewbornExamSummary newbornExamViewEditStageConfig
            , dialogBabyMedVacLab babyMedVacLabViewEditStageConfig
            , viewContPostpartumChecks contPostpartumCheckViewEditStageConfig
            , viewWhatIsComing model
            ]
        ]


viewButtons : Model -> Html SubMsg
viewButtons model =
    H.div [ HA.class "stage-wrapper" ]
        [ H.div
            [ HA.class "stage-content"
            , HA.classList [ ( "isHidden", False ) ]
            ]
            [ H.div [ HA.class "c-text--brand c-text--loud" ]
                [ H.text "Newborn Exam" ]
            , H.div []
                [ H.button
                    [ HA.class "c-button c-button--ghost-brand u-small"
                    , HE.onClick <| HandleNewbornExamModal OpenDialog
                    ]
                    [ if isNewbornExamDone model then
                        H.i [ HA.class "fa fa-check" ]
                            [ H.text "" ]
                      else
                        H.span [] [ H.text "" ]
                    , H.text " Summary"
                    ]
                ]
            ]
        , H.div
            [ HA.class "stage-content"
            , HA.classList [ ( "isHidden", False ) ]
            ]
            [ H.div [ HA.class "c-text--brand c-text--loud" ]
                [ H.text "Baby Med/Vac" ]
            , H.div []
                [ H.button
                    [ HA.class "c-button c-button--ghost-brand u-small"
                    , HE.onClick <| HandleBabyMedVacLabModal OpenDialog Nothing
                    ]
                    [ if isBabyMedVacLabDone model then
                        H.i [ HA.class "fa fa-check" ]
                            [ H.text "" ]
                      else
                        H.span [] [ H.text "" ]
                    , H.text " Summary"
                    ]
                ]
            ]
        ]


isNewbornExamDone : Model -> Bool
isNewbornExamDone model =
    case model.newbornExamRecord of
        Just rec ->
            isNewbornExamRecordComplete rec

        Nothing ->
            False


{-| Should be a medication record for every
medicationType record. Same for vaccination and
labs.

TODO: do vaccinations.
TODO: do labs.

-}
isBabyMedVacLabDone : Model -> Bool
isBabyMedVacLabDone model =
    let
        medsDone =
            List.foldl
                (\mt bool ->
                    bool
                        && LE.count (\m -> m.babyMedicationType == mt.id)
                            model.babyMedicationRecords
                        > 0
                )
                True
                model.babyMedicationTypeRecords

        vacsDone =
            List.foldl
                (\mt bool ->
                    bool
                        && LE.count (\m -> m.babyVaccinationType == mt.id)
                            model.babyVaccinationRecords
                        > 0
                )
                True
                model.babyVaccinationTypeRecords
    in
    medsDone && vacsDone


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



-- View Baby Medication, Vaccination, and Labs --


{-| The view and edit forms are the same form which displays
each medication, vaccination, and lab according to whether it
has been completed or not.
-}
dialogBabyMedVacLab : ViewEditStageConfig -> Html SubMsg
dialogBabyMedVacLab cfg =
    let
        closeBtn =
            [ H.div
                [ HA.class "spacedButtons"
                , HA.style [ ( "width", "100%" ) ]
                ]
                [ H.button
                    [ HA.type_ "button"
                    , HA.class "c-button c-button u-small"
                    , HE.onClick cfg.closeMsg
                    ]
                    [ H.text "Close" ]
                ]
            ]

        medViews =
            List.map
                (\( id, medRec ) ->
                    case
                        Data.BabyMedicationType.getNameUseLocation id
                            cfg.model.babyMedicationTypeRecords
                    of
                        Just ( name, useLocation ) ->
                            babyMVLFormViewEdit (MedMVL id)
                                name
                                useLocation
                                medRec
                                cfg.isEditing
                                cfg.model.browserSupportsDate

                        Nothing ->
                            let
                                _ =
                                    Debug.log "dialogBabyMedVacLab" "Error: Data.BabyMedicationType.getNameUseLocation returned Nothing."
                            in
                            H.text ""
                )
                (Dict.toList cfg.model.babyMedFlds)

        vacViews =
            List.map
                (\( id, vacRec ) ->
                    case
                        Data.BabyVaccinationType.getNameUseLocation id
                            cfg.model.babyVaccinationTypeRecords
                    of
                        Just ( name, useLocation ) ->
                            babyMVLFormViewEdit (VacMVL id)
                                name
                                useLocation
                                vacRec
                                cfg.isEditing
                                cfg.model.browserSupportsDate

                        Nothing ->
                            let
                                _ =
                                    Debug.log "dialogBabyMedVacLab" "Error: Data.BabyVaccinationType.getNameUseLocation returned Nothing."
                            in
                            H.text ""
                )
                (Dict.toList cfg.model.babyVacFlds)
    in
    H.div
        [ HA.classList [ ( "isHidden", not cfg.isShown ) ]
        , HA.class "u-high"
        , HA.style
            [ ( "padding", "0.8em" )
            , ( "margin-top", "0.8em" )
            ]
        ]
        [ H.div [ HA.class "" ] medViews
        , H.div [ HA.class "" ] vacViews
        , H.div
            [ HA.class "spacedButtons"
            , HA.style
                [ ( "width", "100%" )
                , ( "margin-top", "0.5em" )
                ]
            ]
            [ H.button
                [ HA.type_ "button"
                , HA.class "c-button c-button u-small"
                , HE.onClick cfg.closeMsg
                ]
                [ H.text "Close" ]
            ]
        ]


babyMVLFormViewEdit : MedVacLab -> String -> Bool -> MedVacFlds -> Bool -> Bool -> Html SubMsg
babyMVLFormViewEdit mvl name useLocation mvlRec isEditing browserSupportsDate =
    case mvl of
        MedMVL refId ->
            case mvlRec.id of
                Just id ->
                    -- Existing record, so default to view only unless user chose otherwise.
                    if mvlRec.isEditing then
                        babyMedVacEdit mvl name useLocation mvlRec browserSupportsDate
                    else
                        babyMedVacView mvl name useLocation mvlRec

                Nothing ->
                    -- No record yet, so have to edit.
                    babyMedVacEdit mvl name useLocation mvlRec browserSupportsDate

        VacMVL refId ->
            case mvlRec.id of
                Just id ->
                    if mvlRec.isEditing then
                        babyMedVacEdit mvl name useLocation mvlRec browserSupportsDate
                    else
                        babyMedVacView mvl name useLocation mvlRec

                Nothing ->
                    babyMedVacEdit mvl name useLocation mvlRec browserSupportsDate

        LabMVL refId ->
            H.text <| "babyMVLFormViewEdit Lab" ++ toString refId


babyMedVacEdit : MedVacLab -> String -> Bool -> MedVacFlds -> Bool -> Html SubMsg
babyMedVacEdit mvl name useLocation mvlRec browserSupportsDate =
    let
        ( type_, typeId, errors ) =
            case mvl of
                MedMVL id ->
                    ( babyMedicalDynamicDateCategory, id, validateBabyMedication useLocation mvlRec )

                VacMVL id ->
                    ( babyVaccinationDynamicDateCategory, id, validateBabyVaccination useLocation mvlRec )

                LabMVL id ->
                    ( babyLabsDynamicDateCategory, id, [] )

        ( dateFld, timeFld, locationFld, initialsFld, commentsFld ) =
            case mvl of
                MedMVL _ ->
                    ( BabyMedDateFld, BabyMedTimeFld, BabyMedLocationFld, BabyMedInitialsFld, BabyMedCommentsFld )

                VacMVL _ ->
                    ( BabyVacDateFld, BabyVacTimeFld, BabyVacLocationFld, BabyVacInitialsFld, BabyVacCommentsFld )

                LabMVL _ ->
                    ( NotUsed, NotUsed, NotUsed, NotUsed, NotUsed )


        medVacEdit medVacLab name useLocation mvlRec browserSupportsDate errors =
            let
                refId =
                    case medVacLab of
                        MedMVL id ->
                            id

                        VacMVL id ->
                            id

                        LabMVL id ->
                            id
            in
            H.div
                [ HA.class "form-border u-high"
                , HA.style
                    [ ( "padding", "0.5em" )
                    ]
                ]
                [ H.h3 [ HA.class "c-text--brand mw-header-3" ]
                    [ H.text name ]
                , H.div [ HA.class "form-wrapper u-small" ]
                    [ H.div [ HA.class "o-fieldset mw-form-field-2x" ]
                        [ if browserSupportsDate then
                            H.div [ HA.class "c-card" ]
                                [ H.div [ HA.class "c-card__item" ]
                                    [ H.div [ HA.class "c-text--loud" ]
                                        [ H.text "Date and time" ]
                                    ]
                                , H.div [ HA.class "c-card__body dateTimeModalBody" ]
                                    [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                        [ Form.formFieldDate (FldChgIntString refId >> FldChgSubMsg dateFld)
                                            "Date"
                                            "e.g. 08/14/2017"
                                            False
                                            mvlRec.date
                                            (getErr dateFld errors)
                                        , Form.formField (FldChgIntString refId >> FldChgSubMsg timeFld)
                                            "Time"
                                            "24 hr format, 14:44"
                                            False
                                            mvlRec.time
                                            (getErr timeFld errors)
                                        ]
                                    ]
                                ]
                          else
                            -- Browser does not support date.
                            H.div [ HA.class "c-card" ]
                                [ H.div [ HA.class "c-card__body" ]
                                    [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                        [ Form.formFieldDatePicker OpenDatePickerSubMsg
                                            (DynamicDateField type_ typeId)
                                            "Date"
                                            "e.g. 08/14/2017"
                                            False
                                            mvlRec.date
                                            (getErr dateFld errors)
                                        , Form.formField (FldChgIntString refId >> FldChgSubMsg timeFld)
                                            "Time"
                                            "24 hr format, 14:44"
                                            False
                                            mvlRec.time
                                            (getErr timeFld errors)
                                        ]
                                    ]
                                ]
                        ]
                    , if useLocation then
                        H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                            [ Form.formField (FldChgIntString refId >> FldChgSubMsg locationFld)
                                "Location"
                                ""
                                True
                                mvlRec.location
                                (getErr locationFld errors)
                            ]
                      else
                        H.text ""
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgIntString refId >> FldChgSubMsg initialsFld)
                            "Initials"
                            ""
                            True
                            mvlRec.initials
                            (getErr initialsFld errors)
                        ]
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgIntString refId >> FldChgSubMsg commentsFld)
                            "Comments"
                            ""
                            True
                            mvlRec.comments
                            (getErr commentsFld errors)
                        ]
                    ]
                , H.div
                    [ HA.class "right-to-left"
                    , HA.style
                        [ ( "width", "100%" )
                        , ( "margin", "0.2em 1em 0.5em 0" )
                        ]
                    ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--brand u-small"
                        , HE.onClick <| HandleBabyMedVacLabModal CloseSaveDialog (Just medVacLab)
                        ]
                        [ H.text "Save" ]
                    ]
                ]
    in
    case mvl of
        MedMVL refId ->
            medVacEdit (MedMVL refId) name useLocation mvlRec browserSupportsDate errors

        VacMVL refId ->
            medVacEdit (VacMVL refId) name useLocation mvlRec browserSupportsDate errors

        LabMVL _ ->
            H.text ""


babyMedVacView : MedVacLab -> String -> Bool -> MedVacFlds -> Html SubMsg
babyMedVacView mvl name useLocation mvlRec =
    let
        dateStr =
            case U.maybeDatePlusTime mvlRec.date mvlRec.time of
                Just d ->
                    U.dateToDateMonString d "-"
                        |> flip (++) " "
                        |> flip (++) (Maybe.withDefault "" mvlRec.time)

                Nothing ->
                    ""

        location =
            Maybe.withDefault "" mvlRec.location

        initials =
            Maybe.withDefault "" mvlRec.initials

        comments =
            Maybe.withDefault "" mvlRec.comments

        babyMVView mvl =
            H.div [ HA.class "form-padding form-border-light" ]
                [ H.span [ HA.class "c-text--brand" ]
                    [ H.span [ HA.class "c-text--loud" ]
                        [ H.text <| name ++ ": " ]
                    , H.button
                        [ HA.type_ "button"
                        , HA.class "c-button u-color-white u-xsmall"
                        , HA.style [ ( "float", "right" ) ]
                        , HE.onClick <|
                            HandleBabyMedVacLabModal EditDialog
                                (Just mvl)
                        ]
                        [ H.text "Edit" ]
                    ]
                , H.span [ HA.class "c-text" ]
                    [ H.text <| dateStr ]
                , if String.length location > 0 then
                    H.span [ HA.class "c-text" ]
                        [ H.text <| " @ " ++ location ]
                  else
                    H.text ""
                , if String.length comments > 0 then
                    H.span [ HA.class "c-text" ]
                        [ H.text <| ", " ++ comments ]
                  else
                    H.text ""
                , if String.length initials > 0 then
                    H.span [ HA.class "c-text--quiet" ]
                        [ H.text <| " -- " ++ initials ]
                  else
                    H.text ""
                ]

    in
    case mvl of
        MedMVL refId ->
            babyMVView mvl

        VacMVL refId ->
            babyMVView mvl

        LabMVL _ ->
            H.text ""



-- View Continued Postpartum checks --


{-| Display the various components of continued postpartum checks.
-}
viewContPostpartumChecks : ViewEditStageConfig -> Html SubMsg
viewContPostpartumChecks cfg =
    let
        dateSort a b =
            U.sortDate U.AscendingSort a.checkDatetime b.checkDatetime

        checks =
            List.sortWith dateSort cfg.model.contPostpartumCheckRecords
                |> List.map viewContPostpartumCheck
    in
    H.div []
        [ H.h3 [] [ H.text cfg.title ]
        , H.div
            [ HA.style [ ( "margin-bottom", "1em" ) ]
            , HA.classList [ ( "isHidden", not cfg.isShown ) ]
            ]
            checks
        , H.button
            [ HA.type_ "button"
            , HA.class "c-button c-button u-small"
            , HA.classList [ ( "isHidden", not cfg.isShown ) ]
            , HE.onClick <| HandleContPostpartumCheckModal OpenDialog Nothing
            ]
            [ H.text "Add Continued Postpartum Check" ]
        , dialogContPostpartumCheckEdit cfg
        ]


{-| Displays a view of a single continued postpartum check.
-}
viewContPostpartumCheck : ContPostpartumCheckRecord -> Html SubMsg
viewContPostpartumCheck rec =
    let
        checkDate =
            U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep rec.checkDatetime

        field lbl val =
            H.div [ HA.class "u-small" ]
                [ H.span
                    [ HA.class "c-text--quiet"
                    , HA.style [ ( "display", "inline-block" ), ( "min-width", "5.0em" ) ]
                    ]
                    [ H.text <| lbl ++ ": " ]
                , H.span [ HA.class "c-text--loud" ]
                    [ H.text val ]
                ]

        toStringDefault val =
            stringDefault (Maybe.map toString val)

        stringDefault val =
            Maybe.withDefault "" val

        yesNoBool bool =
            case bool of
                Just True ->
                    "Yes"

                _ ->
                    "No"

        bp =
            case ( rec.motherSystolic, rec.motherDiastolic ) of
                ( Just sys, Just dia ) ->
                    toString sys ++ " / " ++ toString dia

                ( _, _ ) ->
                    ""
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
                    HandleContPostpartumCheckModal EditDialog
                        (Just (ContPostpartumCheckId rec.id))
                ]
                [ H.text "Edit" ]
            ]
        , H.div [ HA.class "c-card__item" ]
            [ H.div [ HA.class "contPP-wrapper" ]
                [ H.div [ HA.class "c-card contPP-content" ]
                    [ H.div [ HA.class "c-card__item u-small u-color-white accent-bg" ]
                        [ H.text "Mother" ]
                    , field "BP" bp
                    , field "CR" <| toStringDefault rec.motherCR
                    , field "Temp" <| toStringDefault rec.motherTemp
                    , field "Fundus" <| stringDefault rec.motherFundus
                    , field "EBL" <| toStringDefault rec.motherEBL
                    ]
                , H.div [ HA.class "c-card contPP-content" ]
                    [ H.div [ HA.class "c-card__item u-small u-color-white accent-bg" ]
                        [ H.text "Baby" ]
                    , field "Bfed" (yesNoBool rec.babyBFed)
                    , field "Temp" <| toStringDefault rec.babyTemp
                    , field "RR" <| toStringDefault rec.babyRR
                    , field "CR" <| toStringDefault rec.babyCR
                    ]
                ]
            ]
        , H.div [ HA.class "c-card__item" ]
            [ H.text <| stringDefault rec.comments ]
        ]


{-| Allows user to edit a new or existing continued postpartum check.
-}
dialogContPostpartumCheckEdit : ViewEditStageConfig -> Html SubMsg
dialogContPostpartumCheckEdit cfg =
    let
        errors =
            validateContPostpartumCheck cfg.model

        getMsgSD fld modelFld =
            List.map (\sd -> ( FldChgStringList sd.selectKey >> FldChgSubMsg fld, sd )) modelFld
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
            [ H.text "Continued Postpartum Check" ]
        , H.div [ HA.class "form-wrapper u-small" ]
            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                [ if cfg.model.browserSupportsDate then
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Check date and time" ]
                            ]
                        , H.div [ HA.class "c-card__body dateTimeModalBody" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDate (FldChgString >> FldChgSubMsg CPCCheckDateFld)
                                    "Date"
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.cpcCheckDate
                                    (getErr CPCCheckDateFld errors)
                                , Form.formField (FldChgString >> FldChgSubMsg CPCCheckTimeFld)
                                    "Time"
                                    "24 hr format, 14:44"
                                    False
                                    cfg.model.cpcCheckTime
                                    (getErr CPCCheckTimeFld errors)
                                ]
                            ]
                        ]
                  else
                    -- Browser does not support date.
                    H.div [ HA.class "c-card" ]
                        [ H.div [ HA.class "c-card__body" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDatePicker OpenDatePickerSubMsg
                                    ContPostpartumCheckDateField
                                    "Date"
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.cpcCheckDate
                                    (getErr CPCCheckDateFld errors)
                                , Form.formField (FldChgString >> FldChgSubMsg CPCCheckTimeFld)
                                    "Time"
                                    "24 hr format, 14:44"
                                    False
                                    cfg.model.cpcCheckTime
                                    (getErr CPCCheckTimeFld errors)
                                ]
                            ]
                        ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg CPCMotherSystolicFld)
                        "Mother systolic"
                        ""
                        True
                        cfg.model.cpcMotherSystolic
                        (getErr CPCMotherSystolicFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg CPCMotherDiastolicFld)
                        "Mother diastolic"
                        ""
                        True
                        cfg.model.cpcMotherDiastolic
                        (getErr CPCMotherDiastolicFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg CPCMotherCRFld)
                        "Mother CR"
                        ""
                        True
                        cfg.model.cpcMotherCR
                        (getErr CPCMotherCRFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg CPCMotherTempFld)
                        "Mother temperature"
                        ""
                        True
                        cfg.model.cpcMotherTemp
                        (getErr CPCMotherTempFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg CPCMotherFundusFld)
                        "Mother Fundus"
                        ""
                        True
                        cfg.model.cpcMotherFundus
                        (getErr CPCMotherFundusFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg CPCMotherEBLFld)
                        "Mother EBL"
                        ""
                        True
                        cfg.model.cpcMotherEBL
                        (getErr CPCMotherEBLFld errors)
                    ]
                , Form.checkbox "Baby BFed" (FldChgBool >> FldChgSubMsg CPCBabyBFedFld) cfg.model.cpcBabyBFed
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg CPCBabyTempFld)
                        "Baby Temperature"
                        ""
                        True
                        cfg.model.cpcBabyTemp
                        (getErr CPCBabyTempFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg CPCBabyRRFld)
                        "Baby RR"
                        ""
                        True
                        cfg.model.cpcBabyRR
                        (getErr CPCBabyRRFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg CPCBabyCRFld)
                        "Baby CR"
                        ""
                        True
                        cfg.model.cpcBabyCR
                        (getErr CPCBabyCRFld errors)
                    ]
                , Form.formTextareaField (FldChgString >> FldChgSubMsg CPCCommentsFld)
                    "Comments"
                    ""
                    True
                    cfg.model.cpcComments
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
                    HandleContPostpartumCheckModal CloseSaveDialog
                        cfg.model.currContPostpartumCheckId
                ]
                [ H.text "Save" ]
            ]
        ]



-- View newborn exams --


dialogNewbornExamSummary : ViewEditStageConfig -> Html SubMsg
dialogNewbornExamSummary cfg =
    case cfg.isEditing of
        True ->
            dialogNewbornExamSummaryEdit cfg

        False ->
            dialogNewbornExamSummaryView cfg


dialogNewbornExamSummaryEdit : ViewEditStageConfig -> Html SubMsg
dialogNewbornExamSummaryEdit cfg =
    let
        errors =
            validateNewbornExam cfg.model

        getMsgSD fld modelFld =
            List.map (\sd -> ( FldChgStringList sd.selectKey >> FldChgSubMsg fld, sd )) modelFld
    in
    H.div
        [ HA.classList [ ( "isHidden", not cfg.isShown && cfg.isEditing ) ]
        , HA.class "u-high"
        , HA.style
            [ ( "padding", "0.8em" )
            , ( "margin-top", "0.8em" )
            ]
        ]
        [ H.h3 [ HA.class "c-text--brand mw-header-3" ]
            [ H.text "Newborn Exam - Edit" ]
        , H.div [ HA.class "form-wrapper u-small" ]
            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                [ if cfg.model.browserSupportsDate then
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Exam date and time" ]
                            ]
                        , H.div [ HA.class "c-card__body dateTimeModalBody" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDate (FldChgString >> FldChgSubMsg NBSDateFld)
                                    "Date"
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.nbsDate
                                    (getErr NBSDateFld errors)
                                , Form.formField (FldChgString >> FldChgSubMsg NBSTimeFld)
                                    "Time"
                                    "24 hr format, 14:44"
                                    False
                                    cfg.model.nbsTime
                                    (getErr NBSTimeFld errors)
                                ]
                            ]
                        ]
                  else
                    -- Browser does not support date.
                    H.div [ HA.class "c-card" ]
                        [ H.div [ HA.class "c-card__body" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDatePicker OpenDatePickerSubMsg
                                    NewBornExamDateField
                                    "Date"
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.nbsDate
                                    (getErr NBSDateFld errors)
                                , Form.formField (FldChgString >> FldChgSubMsg NBSTimeFld)
                                    "Time"
                                    "24 hr format, 14:44"
                                    False
                                    cfg.model.nbsTime
                                    (getErr NBSTimeFld errors)
                                ]
                            ]
                        ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg NBSExaminersFld)
                        "Examiners"
                        ""
                        True
                        cfg.model.nbsExaminers
                        (getErr NBSExaminersFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg NBSRRFld)
                        "Respiratory rate"
                        ""
                        True
                        cfg.model.nbsRR
                        (getErr NBSRRFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg NBSHRFld)
                        "Heart rate"
                        ""
                        True
                        cfg.model.nbsHR
                        (getErr NBSHRFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg NBSTemperatureFld)
                        "Temperature"
                        ""
                        True
                        cfg.model.nbsTemperature
                        (getErr NBSTemperatureFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg NBSLengthFld)
                        "Length"
                        ""
                        True
                        cfg.model.nbsLength
                        (getErr NBSLengthFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg NBSHeadCirFld)
                        "Head circumference"
                        ""
                        True
                        cfg.model.nbsHeadCir
                        (getErr NBSHeadCirFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg NBSChestCirFld)
                        "Chest circumference"
                        ""
                        True
                        cfg.model.nbsChestCir
                        (getErr NBSChestCirFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSAppearanceFld cfg.model.nbsAppearance)
                        "Appearance"
                        (getErr NBSAppearanceFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSColorFld cfg.model.nbsColor)
                        "Color"
                        (getErr NBSColorFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSSkinFld cfg.model.nbsSkin)
                        "Skin"
                        (getErr NBSSkinFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSHeadFld cfg.model.nbsHead)
                        "Head"
                        (getErr NBSHeadFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSEyesFld cfg.model.nbsEyes)
                        "Eyes"
                        (getErr NBSEyesFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSEarsFld cfg.model.nbsEars)
                        "Ears"
                        (getErr NBSEarsFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSNoseFld cfg.model.nbsNose)
                        "Nose"
                        (getErr NBSNoseFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSMouthFld cfg.model.nbsMouth)
                        "Mouth"
                        (getErr NBSMouthFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSNeckFld cfg.model.nbsNeck)
                        "Neck"
                        (getErr NBSNeckFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSChestFld cfg.model.nbsChest)
                        "Chest"
                        (getErr NBSChestFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSLungsFld cfg.model.nbsLungs)
                        "Lungs"
                        (getErr NBSLungsFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSHeartFld cfg.model.nbsHeart)
                        "Heart"
                        (getErr NBSHeartFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSAbdomenFld cfg.model.nbsAbdomen)
                        "Abdomen"
                        (getErr NBSAbdomenFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSHipsFld cfg.model.nbsHips)
                        "Hips"
                        (getErr NBSHipsFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSCordFld cfg.model.nbsCord)
                        "Cord"
                        (getErr NBSCordFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSFemoralPulsesFld cfg.model.nbsFemoralPulses)
                        "Femoral Pulses"
                        (getErr NBSFemoralPulsesFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSGenitaliaFld cfg.model.nbsGenitalia)
                        "Genitalia"
                        (getErr NBSGenitaliaFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSAnusFld cfg.model.nbsAnus)
                        "Anus"
                        (getErr NBSAnusFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSBackFld cfg.model.nbsBack)
                        "Back"
                        (getErr NBSBackFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field mw-form-field-vertical" ]
                    [ Form.checkboxSelectData (getMsgSD NBSExtremitiesFld cfg.model.nbsExtremities)
                        "Extremities"
                        (getErr NBSExtremitiesFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.formField (FldChgString >> FldChgSubMsg NBSEstGAFld)
                        "Estimated GA"
                        ""
                        True
                        cfg.model.nbsEstGA
                        (getErr NBSEstGAFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.checkbox "Moro Reflex"
                        (FldChgBool >> FldChgSubMsg NBSMoroReflexFld)
                        cfg.model.nbsMoroReflex
                    , H.text (getErr NBSMoroReflexFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg NBSMoroReflexCommentFld)
                        "Moro Comments"
                        ""
                        True
                        cfg.model.nbsMoroReflexComment
                        (getErr NBSMoroReflexCommentFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.checkbox "Palmar Reflex"
                        (FldChgBool >> FldChgSubMsg NBSPalmarReflexFld)
                        cfg.model.nbsPalmarReflex
                    , H.text (getErr NBSPalmarReflexFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg NBSPalmarReflexCommentFld)
                        "Palmar Comments"
                        ""
                        True
                        cfg.model.nbsPalmarReflexComment
                        (getErr NBSPalmarReflexCommentFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.checkbox "Stepping Reflex"
                        (FldChgBool >> FldChgSubMsg NBSSteppingReflexFld)
                        cfg.model.nbsSteppingReflex
                    , H.text (getErr NBSSteppingReflexFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg NBSSteppingReflexCommentFld)
                        "Stepping Comments"
                        ""
                        True
                        cfg.model.nbsSteppingReflexComment
                        (getErr NBSSteppingReflexCommentFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.checkbox "Plantar Reflex"
                        (FldChgBool >> FldChgSubMsg NBSPlantarReflexFld)
                        cfg.model.nbsPlantarReflex
                    , H.text (getErr NBSPlantarReflexFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg NBSPlantarReflexCommentFld)
                        "Plantar Comments"
                        ""
                        True
                        cfg.model.nbsPlantarReflexComment
                        (getErr NBSPlantarReflexCommentFld errors)
                    ]
                , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                    [ Form.checkbox "Babinski Reflex"
                        (FldChgBool >> FldChgSubMsg NBSBabinskiReflexFld)
                        cfg.model.nbsBabinskiReflex
                    , H.text (getErr NBSBabinskiReflexFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg NBSBabinskiReflexCommentFld)
                        "Babinski Comments"
                        ""
                        True
                        cfg.model.nbsBabinskiReflexComment
                        (getErr NBSBabinskiReflexCommentFld errors)
                    ]
                , Form.formTextareaField (FldChgString >> FldChgSubMsg NBSCommentsFld)
                    "Newborn Exam Comments"
                    ""
                    True
                    cfg.model.nbsComments
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
                , HE.onClick cfg.saveMsg
                ]
                [ H.text "Save" ]
            ]
        ]


dialogNewbornExamSummaryView : ViewEditStageConfig -> Html SubMsg
dialogNewbornExamSummaryView cfg =
    let
        dateString date =
            U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep date

        yesNoBool bool =
            case bool of
                Just True ->
                    "Yes"

                _ ->
                    "No"

        viewField label value =
            H.div [ HA.class "mw-form-field-2x" ]
                [ H.span [ HA.class "c-text--loud" ]
                    [ H.text <| label ++ ": " ]
                , H.span [ HA.class "" ]
                    [ H.text value ]
                ]

        maybeWithDefault func val =
            Maybe.map func val
                |> Maybe.withDefault ""
    in
    case cfg.model.newbornExamRecord of
        Nothing ->
            H.text ""

        Just rec ->
            H.div
                [ HA.classList [ ( "isHidden", not cfg.isShown && not cfg.isEditing ) ]
                , HA.class "u-high"
                , HA.style
                    [ ( "padding", "0.8em" )
                    , ( "margin-top", "0.8em" )
                    ]
                ]
                [ H.h3 [ HA.class "c-text--brand mw-header-3" ]
                    [ H.text "Newborn Exam Summary" ]
                , H.div []
                    [ H.div
                        [ HA.class "o-fieldset form-wrapper"
                        ]
                        [ viewField "Exam Date/time" <| dateString rec.examDatetime
                        , viewField "Examiners" rec.examiners
                        , viewField "RR" <| maybeWithDefault toString rec.rr
                        , viewField "HR" <| maybeWithDefault toString rec.hr
                        , viewField "Temperature" <| maybeWithDefault toString rec.temperature
                        , viewField "Length" <| maybeWithDefault toString rec.length
                        , viewField "Head cir" <| maybeWithDefault toString rec.headCir
                        , viewField "Chest cir" <| maybeWithDefault toString rec.chestCir
                        , viewField "Appearance" <| maybeWithDefault U.pipeToComma rec.appearance
                        , viewField "Color" <| maybeWithDefault U.pipeToComma rec.color
                        , viewField "Skin" <| maybeWithDefault U.pipeToComma rec.skin
                        , viewField "Head" <| maybeWithDefault U.pipeToComma rec.head
                        , viewField "Eyes" <| maybeWithDefault U.pipeToComma rec.eyes
                        , viewField "Ears" <| maybeWithDefault U.pipeToComma rec.ears
                        , viewField "Nose" <| maybeWithDefault U.pipeToComma rec.nose
                        , viewField "Mouth" <| maybeWithDefault U.pipeToComma rec.mouth
                        , viewField "Neck" <| maybeWithDefault U.pipeToComma rec.neck
                        , viewField "Chest" <| maybeWithDefault U.pipeToComma rec.chest
                        , viewField "Lungs" <| maybeWithDefault U.pipeToComma rec.lungs
                        , viewField "Heart" <| maybeWithDefault U.pipeToComma rec.heart
                        , viewField "Abdomen" <| maybeWithDefault U.pipeToComma rec.abdomen
                        , viewField "Hips" <| maybeWithDefault U.pipeToComma rec.hips
                        , viewField "Cord" <| maybeWithDefault U.pipeToComma rec.cord
                        , viewField "Femoral pulses" <| maybeWithDefault U.pipeToComma rec.femoralPulses
                        , viewField "Genitalia" <| maybeWithDefault U.pipeToComma rec.genitalia
                        , viewField "Anus" <| maybeWithDefault U.pipeToComma rec.anus
                        , viewField "Back" <| maybeWithDefault U.pipeToComma rec.back
                        , viewField "Extremities" <| maybeWithDefault U.pipeToComma rec.extremities
                        , viewField "Est GA" <| Maybe.withDefault "" rec.estGA
                        , viewField "Moro reflex" <| yesNoBool rec.moroReflex
                        , viewField "Moro comment" <| Maybe.withDefault "" rec.moroReflexComment
                        , viewField "Palmar reflex" <| yesNoBool rec.palmarReflex
                        , viewField "Palmar comment" <| Maybe.withDefault "" rec.palmarReflexComment
                        , viewField "Stepping reflex" <| yesNoBool rec.steppingReflex
                        , viewField "Stepping comment" <| Maybe.withDefault "" rec.steppingReflexComment
                        , viewField "Plantar reflex" <| yesNoBool rec.plantarReflex
                        , viewField "Plantar comment" <| Maybe.withDefault "" rec.plantarReflexComment
                        , viewField "Babinski reflex" <| yesNoBool rec.babinskiReflex
                        , viewField "Babinski comment" <| Maybe.withDefault "" rec.babinskiReflexComment
                        , viewField "Comments" <| Maybe.withDefault "" rec.comments
                        ]
                    , H.div [ HA.class "spacedButtons" ]
                        [ H.button
                            [ HA.type_ "button"
                            , HA.class "c-button u-small"
                            , HE.onClick cfg.closeMsg
                            ]
                            [ H.text "Close" ]
                        , H.button
                            [ HA.type_ "button"
                            , HA.class "c-button c-button--ghost u-small"
                            , HE.onClick cfg.editMsg
                            ]
                            [ H.text "Edit" ]
                        ]
                    ]
                ]


viewWhatIsComing : Model -> Html SubMsg
viewWhatIsComing model =
    H.div []
        [ H.h3 [ HA.class "c-heading u-medium" ]
            [ H.text "What else will be on this page eventually?" ]
        , H.ul []
            [ H.li [] [ H.text "Baby medications, vaccinations, and labs" ]
            , H.li [] [ H.text "Mother medications" ]
            , H.li [] [ H.text "Discharge checklist" ]
            , H.li [] [ H.text "Discharge vitals" ]
            ]
        ]



-- VALIDATION of the ContPP Model form fields, not the records sent to the server. --


type alias FieldError =
    ( Field, String )


validateNewbornExam : Model -> List FieldError
validateNewbornExam =
    Validate.all
        [ .nbsDate >> ifInvalid U.validateDate (NBSDateFld => "Date of exam must be provided.")
        , .nbsTime >> ifInvalid U.validateTime (NBSTimeFld => "Exam time must be provided, ex: hh:mm.")
        , .nbsExaminers >> ifInvalid U.validatePopulatedString (NBSExaminersFld => "Examiners must be provided.")
        ]


validateContPostpartumCheck : Model -> List FieldError
validateContPostpartumCheck =
    Validate.all
        [ .cpcCheckDate >> ifInvalid U.validateDate (CPCCheckDateFld => "Date of check must be provided.")
        , .cpcCheckTime >> ifInvalid U.validateTime (CPCCheckTimeFld => "Time of check must be provided.")
        ]


validateBabyMedication : Bool -> MedVacFlds -> List FieldError
validateBabyMedication useLocation =
    Validate.all
        [ .date >> ifInvalid U.validateDate (BabyMedDateFld => "Date of medication must be provided.")
        , .time >> ifInvalid U.validateTime (BabyMedTimeFld => "Time of medication must be provided.")
        , if useLocation then
            .location >> ifInvalid U.validatePopulatedString (BabyMedLocationFld => "Location must be provided.")
          else
            \_ -> []
        ]


validateBabyVaccination : Bool -> MedVacFlds -> List FieldError
validateBabyVaccination useLocation =
    Validate.all
        [ .date >> ifInvalid U.validateDate (BabyVacDateFld => "Date of medication must be provided.")
        , .time >> ifInvalid U.validateTime (BabyVacTimeFld => "Time of medication must be provided.")
        , if useLocation then
            .location >> ifInvalid U.validatePopulatedString (BabyVacLocationFld => "Location must be provided.")
          else
            \_ -> []
        ]
