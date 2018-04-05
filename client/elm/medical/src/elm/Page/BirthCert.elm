module Page.BirthCert
    exposing
        ( buildModel
        , closeAllDialogs
        , getTablesByCacheOrServer
        , init
        , Model
        , update
        , view
        )

import Const exposing (Dialog(..), FldChgValue(..))
import Data.Baby
    exposing
        ( BabyRecord
        )
import Data.BirthCert
    exposing
        ( Field(..)
        , SubMsg(..)
        )
import Data.BirthCertificate
    exposing
        ( BirthCertificateRecord
        , BirthCertificateRecordNew
        , birthCertificateRecordNewToValue
        , birthCertificateRecordToValue
        )
import Data.DataCache as DataCache exposing (DataCache(..))
import Data.DatePicker exposing (DateField(..), DateFieldMessage(..), dateFieldToString)
import Data.KeyValue exposing (KeyValueRecord)
import Data.Labor
    exposing
        ( LaborId(..)
        , LaborRecord
        , getLaborId
        )
import Data.LaborStage2 exposing (LaborStage2Record)
import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Patient exposing (PatientRecord)
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
import Window


-- MODEL --


type ViewEditState
    = BirthCertificateViewState
    | BirthCertificateEditState


type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , pregnancy_id : PregnancyId
    , currLaborId : Maybe LaborId
    , dataCache : Dict String DataCache
    , pendingSelectQuery : Dict String Table
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    , laborRecord : LaborRecord
    , laborStage2Record : Maybe LaborStage2Record
    , babyRecord : Maybe BabyRecord
    , selectDataRecords : List SelectDataRecord
    , keyValueRecords : Dict String KeyValueRecord
    , birthCertificateRecord : Maybe BirthCertificateRecord
    , birthCertificateViewEditState : ViewEditState
    , bcBirthOrder : Maybe String
    , bcMotherMaidenLastname : Maybe String
    , bcMotherMiddlename : Maybe String
    , bcMotherFirstname : Maybe String
    , bcMotherCitizenship : Maybe String
    , bcMotherNumChildrenBornAlive : Maybe String
    , bcMotherNumChildrenLiving : Maybe String
    , bcMotherNumChildrenBornAliveNowDead : Maybe String
    , bcMotherAddress : Maybe String
    , bcMotherCity : Maybe String
    , bcMotherProvince : Maybe String
    , bcMotherCountry : Maybe String
    , bcFatherLastname : Maybe String
    , bcFatherMiddlename : Maybe String
    , bcFatherFirstname : Maybe String
    , bcFatherCitizenship : Maybe String
    , bcFatherReligion : Maybe String
    , bcFatherOccupation : Maybe String
    , bcFatherAgeAtBirth : Maybe String
    , bcFatherAddress : Maybe String
    , bcFatherCity : Maybe String
    , bcFatherProvince : Maybe String
    , bcFatherCountry : Maybe String
    , bcDateOfMarriage : Maybe Date
    , bcCityOfMarriage : Maybe String
    , bcProvinceOfMarriage : Maybe String
    , bcCountryOfMarriage : Maybe String
    , bcAttendantType : Maybe String
    , bcAttendantOther : Maybe String
    , bcAttendantFullname : Maybe String
    , bcAttendantTitle : Maybe String
    , bcAttendantAddr1 : Maybe String
    , bcAttendantAddr2 : Maybe String
    , bcInformantFullname : Maybe String
    , bcInformantRelationToChild : Maybe String
    , bcInformantAddress : Maybe String
    , bcPreparedByFullname : Maybe String
    , bcPreparedByTitle : Maybe String
    , bcCommTaxNumber : Maybe String
    , bcCommTaxDate : Maybe Date
    , bcCommTaxPlace : Maybe String
    , bcReceivedByName : Maybe String
    , bcReceivedByTitle : Maybe String
    , bcAffiateName : Maybe String
    , bcAffiateAddress : Maybe String
    , bcAffiateCitizenshipCountry : Maybe String
    , bcAffiateReason : Maybe String
    , bcAffiateIAm : Maybe String
    , bcAffiateCommTaxNumber : Maybe String
    , bcAffiateCommTaxDate : Maybe Date
    , bcAffiateCommTaxPlace : Maybe String
    , bcComments : Maybe String
    , printingPage1Top : Maybe String
    , printingPage1Left : Maybe String
    , printingPage2Top : Maybe String
    , printingPage2Left : Maybe String
    , printingPaternity : Maybe Bool
    , printingDelayedRegistration : Maybe Bool
    }


{-| Updates the model to close all dialogs. Called by Medical.update in
the SetRoute message. This allows the back button to close a dialog.
-}
closeAllDialogs : Model -> Model
closeAllDialogs model =
    { model
        | birthCertificateViewEditState = BirthCertificateViewState
    }


{-| Get records from the server that we don't already have like baby and
postpartum checks.
-}
init : PregnancyId -> LaborRecord -> Session -> ProcessStore -> ( ProcessStore, Cmd Msg )
init pregId laborRec session store =
    let
        selectQuery =
            SelectQuery Labor
                (Just laborRec.id)
                [ LaborStage2
                , Baby
                ]

        ( processId, processStore ) =
            Processing.add (SelectQueryType (BirthCertLoaded pregId laborRec) selectQuery) Nothing store

        msg =
            wrapPayload processId SelectMsgType (selectQueryToValue selectQuery)
    in
    processStore
        => Ports.outgoing msg


{-| Builds the initial model for the page.
-}
buildModel :
    LaborRecord
    -> Maybe LaborStage2Record
    -> Maybe BabyRecord
    -> Bool
    -> Time
    -> ProcessStore
    -> PregnancyId
    -> Maybe PatientRecord
    -> Maybe PregnancyRecord
    -> ( Model, ProcessStore, Cmd Msg )
buildModel laborRec stage2Rec babyRecord browserSupportsDate currTime store pregId patRec pregRec =
    let
        getBirthCertificateCmd =
            case babyRecord of
                Just baby ->
                    getTables Baby (Just baby.id) [ BirthCertificate ]

                Nothing ->
                    logConsole "Baby record not available in BirthCert.buildModel."

        -- Get the keyValue lookup table that this page will need.
        getKeyValueCmd =
            getTables KeyValue Nothing []
    in
    ( { browserSupportsDate = browserSupportsDate
      , currTime = currTime
      , pregnancy_id = pregId
      , currLaborId = Just (LaborId laborRec.id)
      , dataCache = Dict.empty
      , pendingSelectQuery = Dict.empty
      , patientRecord = patRec
      , pregnancyRecord = pregRec
      , laborRecord = laborRec
      , laborStage2Record = stage2Rec
      , babyRecord = babyRecord
      , selectDataRecords = []
      , keyValueRecords = Dict.empty
      , birthCertificateRecord = Nothing
      , birthCertificateViewEditState = BirthCertificateEditState
      , bcBirthOrder = Nothing
      , bcMotherMaidenLastname = Nothing
      , bcMotherMiddlename = Nothing
      , bcMotherFirstname = Nothing
      , bcMotherCitizenship = Nothing
      , bcMotherNumChildrenBornAlive = Nothing
      , bcMotherNumChildrenLiving = Nothing
      , bcMotherNumChildrenBornAliveNowDead = Nothing
      , bcMotherAddress = Nothing
      , bcMotherCity = Nothing
      , bcMotherProvince = Nothing
      , bcMotherCountry = Nothing
      , bcFatherLastname = Nothing
      , bcFatherMiddlename = Nothing
      , bcFatherFirstname = Nothing
      , bcFatherCitizenship = Nothing
      , bcFatherReligion = Nothing
      , bcFatherOccupation = Nothing
      , bcFatherAgeAtBirth = Nothing
      , bcFatherAddress = Nothing
      , bcFatherCity = Nothing
      , bcFatherProvince = Nothing
      , bcFatherCountry = Nothing
      , bcDateOfMarriage = Nothing
      , bcCityOfMarriage = Nothing
      , bcProvinceOfMarriage = Nothing
      , bcCountryOfMarriage = Nothing
      , bcAttendantType = Nothing
      , bcAttendantOther = Nothing
      , bcAttendantFullname = Nothing
      , bcAttendantTitle = Nothing
      , bcAttendantAddr1 = Nothing
      , bcAttendantAddr2 = Nothing
      , bcInformantFullname = Nothing
      , bcInformantRelationToChild = Nothing
      , bcInformantAddress = Nothing
      , bcPreparedByFullname = Nothing
      , bcPreparedByTitle = Nothing
      , bcCommTaxNumber = Nothing
      , bcCommTaxDate = Nothing
      , bcCommTaxPlace = Nothing
      , bcReceivedByName = Nothing
      , bcReceivedByTitle = Nothing
      , bcAffiateName = Nothing
      , bcAffiateAddress = Nothing
      , bcAffiateCitizenshipCountry = Nothing
      , bcAffiateReason = Nothing
      , bcAffiateIAm = Nothing
      , bcAffiateCommTaxNumber = Nothing
      , bcAffiateCommTaxDate = Nothing
      , bcAffiateCommTaxPlace = Nothing
      , bcComments = Nothing
      , printingPage1Top = Just "0"
      , printingPage1Left = Just "0"
      , printingPage2Top = Just "0"
      , printingPage2Left = Just "0"
      , printingPaternity = Nothing
      , printingDelayedRegistration = Nothing
      }
        |> populateModelBirthCertificateFields
    , store
    , Cmd.batch
        [ getBirthCertificateCmd
        , getKeyValueCmd
        ]
    )

{-| Generate an top-level module command to retrieve additional data which checks
first in the data cache, and secondarily from the server.
-}
getTables : Table -> Maybe Int -> List Table -> Cmd Msg
getTables table key relatedTables =
    Task.perform
        (always (BirthCertSelectQuery table key relatedTables))
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
                        Data.BirthCert.DataCache Nothing (Just dataCacheTables)
                            |> BirthCertMsg
                in
                store => Task.perform (always cachedMsg) (Task.succeed True)
            else
                let
                    selectQuery =
                        SelectQuery table key relatedTbls

                    ( processId, processStore ) =
                        Processing.add
                            (SelectQueryType
                                (BirthCertMsg
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

                        BirthCertificate ->
                            case DataCache.get t dc of
                                Just (BirthCertificateDataCache rec) ->
                                    { m | birthCertificateRecord = Just rec }

                                _ ->
                                    m

                        KeyValue ->
                            case DataCache.get t dc of
                                Just (KeyValueDataCache recs) ->
                                    { m | keyValueRecords = recs }

                                _ ->
                                    m

                        Labor ->
                            case DataCache.get t dc of
                                Just (LaborDataCache rec) ->
                                    { m | laborRecord = rec }

                                _ ->
                                    m

                        LaborStage2 ->
                            case DataCache.get t dc of
                                Just (LaborStage2DataCache rec) ->
                                    { m | laborStage2Record = Just rec }

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
                                    Debug.log "BirthCertificate.refreshModelFromCache: Unhandled Table" <| toString t
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
        BirthCertTick time ->
            -- Keep the current time in the Model.
            ( { model | currTime = time }, Cmd.none, Cmd.none )

        CloseAllDialogs ->
            -- Close all of the open dialogs that we have. This may be called
            -- when the user uses the back button to back out of a dialog.
            ( closeAllDialogs model, Cmd.none, Cmd.none )

        DataCache dc tbls ->
            let
                newModel =
                    case ( dc, tbls ) of
                        ( Just dataCache, tables ) ->
                            let
                                newModel =
                                    refreshModelFromCache dataCache (Maybe.withDefault [] tables) model

                                -- If data has come in then update the form fields and set
                                -- the viewstate to view assuming that if a record was saved
                                -- to the server, then it is complete enough to assume view
                                -- rather than edit.
                                newModel2 =
                                    case tables of
                                        Just tbls ->
                                            List.foldl
                                                (\tbl mdl ->
                                                    if tbl == BirthCertificate then
                                                        populateModelBirthCertificateFields mdl
                                                            |> (\mdl ->
                                                                    { mdl
                                                                        | birthCertificateViewEditState =
                                                                            BirthCertificateViewState
                                                                    }
                                                               )
                                                    else if tbl == KeyValue then
                                                        populateModelBirthCertificateFields mdl
                                                            |> (\mdl ->
                                                                    { mdl
                                                                        | birthCertificateViewEditState =
                                                                            BirthCertificateViewState
                                                                    }
                                                               )
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
            in
            ( newModel, Cmd.none, Cmd.none )

        DateFieldSubMsg dateFldMsg ->
            -- For browsers that do not support a native date field.
            case dateFldMsg of
                DateFieldMessage { dateField, date } ->
                    case dateField of
                        BirthCertDateOfMarriageField ->
                            ( { model | bcDateOfMarriage = Just date }, Cmd.none, Cmd.none )

                        BirthCertDateOfCommTaxField ->
                            ( { model | bcCommTaxDate = Just date }, Cmd.none, Cmd.none )

                        BirthCertDateOfAffiateCommTaxField ->
                            ( { model | bcAffiateCommTaxDate = Just date }, Cmd.none, Cmd.none )

                        UnknownDateField str ->
                            ( model, Cmd.none, logConsole str )

                        _ ->
                            let
                                _ =
                                    Debug.log "BirthCert DateFieldSubMsg" <| toString dateFldMsg
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
                        BCBirthOrderFld ->
                            { model | bcBirthOrder = Just value }

                        BCMotherMaidenLastnameFld ->
                            { model | bcMotherMaidenLastname = Just value }

                        BCMotherMiddlenameFld ->
                            { model | bcMotherMiddlename = Just value }

                        BCMotherFirstnameFld ->
                            { model | bcMotherFirstname = Just value }

                        BCMotherCitizenshipFld ->
                            { model | bcMotherCitizenship = Just value }

                        BCMotherNumChildrenBornAliveFld ->
                            { model | bcMotherNumChildrenBornAlive = Just <| U.filterStringLikeInt value }

                        BCMotherNumChildrenLivingFld ->
                            { model | bcMotherNumChildrenLiving = Just <| U.filterStringLikeInt value }

                        BCMotherNumChildrenBornAliveNowDeadFld ->
                            { model | bcMotherNumChildrenBornAliveNowDead = Just <| U.filterStringLikeInt value }

                        BCMotherAddressFld ->
                            { model | bcMotherAddress = Just value }

                        BCMotherCityFld ->
                            { model | bcMotherCity = Just value }

                        BCMotherProvinceFld ->
                            { model | bcMotherProvince = Just value }

                        BCMotherCountryFld ->
                            { model | bcMotherCountry = Just value }

                        BCFatherLastnameFld ->
                            { model | bcFatherLastname = Just value }

                        BCFatherMiddlenameFld ->
                            { model | bcFatherMiddlename = Just value }

                        BCFatherFirstnameFld ->
                            { model | bcFatherFirstname = Just value }

                        BCFatherCitizenshipFld ->
                            { model | bcFatherCitizenship = Just value }

                        BCFatherReligionFld ->
                            { model | bcFatherReligion = Just value }

                        BCFatherOccupationFld ->
                            { model | bcFatherOccupation = Just value }

                        BCFatherAgeAtBirthFld ->
                            { model | bcFatherAgeAtBirth = Just <| U.filterStringLikeInt value }

                        BCFatherAddressFld ->
                            { model | bcFatherAddress = Just value }

                        BCFatherCityFld ->
                            { model | bcFatherCity = Just value }

                        BCFatherProvinceFld ->
                            { model | bcFatherProvince = Just value }

                        BCFatherCountryFld ->
                            { model | bcFatherCountry = Just value }

                        BCDateOfMarriageFld ->
                            { model | bcDateOfMarriage = Date.fromString value |> Result.toMaybe }

                        BCCityOfMarriageFld ->
                            { model | bcCityOfMarriage = Just value }

                        BCProvinceOfMarriageFld ->
                            { model | bcProvinceOfMarriage = Just value }

                        BCCountryOfMarriageFld ->
                            { model | bcCountryOfMarriage = Just value }

                        BCAttendantTypeFld ->
                            { model | bcAttendantType = Just value }

                        BCAttendantOtherFld ->
                            { model | bcAttendantOther = Just value }

                        BCAttendantFullnameFld ->
                            { model | bcAttendantFullname = Just value }

                        BCAttendantTitleFld ->
                            { model | bcAttendantTitle = Just value }

                        BCAttendantAddr1Fld ->
                            { model | bcAttendantAddr1 = Just value }

                        BCAttendantAddr2Fld ->
                            { model | bcAttendantAddr2 = Just value }

                        BCInformantFullnameFld ->
                            { model | bcInformantFullname = Just value }

                        BCInformantRelationToChildFld ->
                            { model | bcInformantRelationToChild = Just value }

                        BCInformantAddressFld ->
                            { model | bcInformantAddress = Just value }

                        BCPreparedByFullnameFld ->
                            { model | bcPreparedByFullname = Just value }

                        BCPreparedByTitleFld ->
                            { model | bcPreparedByTitle = Just value }

                        BCCommTaxNumberFld ->
                            { model | bcCommTaxNumber = Just value }

                        BCCommTaxDateFld ->
                            { model | bcCommTaxDate = Date.fromString value |> Result.toMaybe }

                        BCCommTaxPlaceFld ->
                            { model | bcCommTaxPlace = Just value }

                        BCReceivedByNameFld ->
                            { model | bcReceivedByName = Just value }

                        BCReceivedByTitleFld ->
                            { model | bcReceivedByTitle = Just value }

                        BCAffiateNameFld ->
                            { model | bcAffiateName = Just value }

                        BCAffiateAddressFld ->
                            { model | bcAffiateAddress = Just value }

                        BCAffiateCitizenshipCountryFld ->
                            { model | bcAffiateCitizenshipCountry = Just value }

                        BCAffiateReasonFld ->
                            { model | bcAffiateReason = Just value }

                        BCAffiateIAmFld ->
                            { model | bcAffiateIAm = Just value }

                        BCAffiateCommTaxNumberFld ->
                            { model | bcAffiateCommTaxNumber = Just value }

                        BCAffiateCommTaxDateFld ->
                            { model | bcAffiateCommTaxDate = Date.fromString value |> Result.toMaybe }

                        BCAffiateCommTaxPlace ->
                            { model | bcAffiateCommTaxPlace = Just value }

                        BCCommentsFld ->
                            { model | bcComments = Just value }

                        PrintingPage1TopFld ->
                            { model | printingPage1Top = Just <| U.filterStringLikeIntOrNegInt value }

                        PrintingPage1LeftFld ->
                            { model | printingPage1Left = Just <| U.filterStringLikeIntOrNegInt value }

                        PrintingPage2TopFld ->
                            { model | printingPage2Top = Just <| U.filterStringLikeIntOrNegInt value }

                        PrintingPage2LeftFld ->
                            { model | printingPage2Left = Just <| U.filterStringLikeIntOrNegInt value }

                        _ ->
                            let
                                _ =
                                    Debug.log "BirthCert.update FldChgSubMsg"
                                        "Unknown field encountered in FldChgString. Possible mismatch between Field and FldChgValue."
                            in
                            model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgStringList selectKey isChecked ->
                    ( model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgBool value ->
                    ( case fld of
                        PrintingPaternityFld ->
                            { model | printingPaternity = Just value }

                        PrintingDelayedRegistrationFld ->
                            { model | printingDelayedRegistration = Just value }

                        _ ->
                            let
                                _ =
                                    Debug.log "BirthCert.update FldChgSubMsg"
                                        "Unknown field encountered in FldChgBool. Possible mismatch between Field and FldChgValue."
                            in
                            model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgIntString intVal strVal ->
                    ( model
                    , Cmd.none
                    , Cmd.none
                    )

        HandleBirthCertificateModal dialogState ->
            case dialogState of
                OpenDialog ->
                    -- This is not used since there is no button to open the view.
                    ( model, Cmd.none, Cmd.none )

                EditDialog ->
                    ( { model | birthCertificateViewEditState = BirthCertificateEditState }
                    , Cmd.none
                    , if model.birthCertificateViewEditState == BirthCertificateViewState then
                        Cmd.batch
                            [ Route.addDialogUrl Route.BirthCertificateRoute
                            , Task.perform SetDialogActive <| Task.succeed True
                            ]
                      else
                        Cmd.none
                    )

                CloseNoSaveDialog ->
                    ( { model | birthCertificateViewEditState = BirthCertificateViewState }
                    , Cmd.none
                    , Route.back
                    )

                CloseSaveDialog ->
                    case validateBirthCertificate model of
                        [] ->
                            let
                                outerMsg =
                                    case ( model.babyRecord, model.birthCertificateRecord ) of
                                        ( Just baby, Just bcRec ) ->
                                            -- Updating an existing BirthCertificateRecord.
                                            let
                                                newBirthCertificate =
                                                    { bcRec
                                                        | birthOrder =
                                                            Maybe.withDefault bcRec.birthOrder
                                                                model.bcBirthOrder
                                                        , motherMaidenLastname =
                                                            Maybe.withDefault bcRec.motherMaidenLastname
                                                                model.bcMotherMaidenLastname
                                                        , motherMiddlename =
                                                            U.maybeOr model.bcMotherMiddlename
                                                                bcRec.motherMiddlename
                                                        , motherFirstname =
                                                            Maybe.withDefault bcRec.motherFirstname
                                                                model.bcMotherFirstname
                                                        , motherCitizenship =
                                                            Maybe.withDefault bcRec.motherCitizenship
                                                                model.bcMotherCitizenship
                                                        , motherNumChildrenBornAlive =
                                                            Maybe.withDefault bcRec.motherNumChildrenBornAlive
                                                                (U.maybeStringToMaybeInt model.bcMotherNumChildrenBornAlive)
                                                        , motherNumChildrenLiving =
                                                            Maybe.withDefault bcRec.motherNumChildrenLiving
                                                                (U.maybeStringToMaybeInt model.bcMotherNumChildrenLiving)
                                                        , motherNumChildrenBornAliveNowDead =
                                                            Maybe.withDefault bcRec.motherNumChildrenBornAliveNowDead
                                                                (U.maybeStringToMaybeInt model.bcMotherNumChildrenBornAliveNowDead)
                                                        , motherAddress =
                                                            Maybe.withDefault bcRec.motherAddress
                                                                model.bcMotherAddress
                                                        , motherCity =
                                                            Maybe.withDefault bcRec.motherCity
                                                                model.bcMotherCity
                                                        , motherProvince =
                                                            Maybe.withDefault bcRec.motherProvince
                                                                model.bcMotherProvince
                                                        , motherCountry =
                                                            Maybe.withDefault bcRec.motherCountry
                                                                model.bcMotherCountry
                                                        , fatherLastname =
                                                            U.maybeOr model.bcFatherLastname
                                                                bcRec.fatherLastname
                                                        , fatherMiddlename =
                                                            U.maybeOr model.bcFatherMiddlename
                                                                bcRec.fatherMiddlename
                                                        , fatherFirstname =
                                                            U.maybeOr model.bcFatherFirstname
                                                                bcRec.fatherFirstname
                                                        , fatherCitizenship =
                                                            U.maybeOr model.bcFatherCitizenship
                                                                bcRec.fatherCitizenship
                                                        , fatherReligion =
                                                            U.maybeOr model.bcFatherReligion
                                                                bcRec.fatherReligion
                                                        , fatherOccupation =
                                                            U.maybeOr model.bcFatherOccupation
                                                                bcRec.fatherOccupation
                                                        , fatherAgeAtBirth =
                                                            U.maybeOr (U.maybeStringToMaybeInt model.bcFatherAgeAtBirth)
                                                                bcRec.fatherAgeAtBirth
                                                        , fatherAddress =
                                                            U.maybeOr model.bcFatherAddress
                                                                bcRec.fatherAddress
                                                        , fatherCity =
                                                            U.maybeOr model.bcFatherCity
                                                                bcRec.fatherCity
                                                        , fatherProvince =
                                                            U.maybeOr model.bcFatherProvince
                                                                bcRec.fatherProvince
                                                        , fatherCountry =
                                                            U.maybeOr model.bcFatherCountry
                                                                bcRec.fatherCountry
                                                        , dateOfMarriage = model.bcDateOfMarriage
                                                        , cityOfMarriage =
                                                            U.maybeOr model.bcCityOfMarriage
                                                                bcRec.cityOfMarriage
                                                        , provinceOfMarriage =
                                                            U.maybeOr model.bcProvinceOfMarriage
                                                                bcRec.provinceOfMarriage
                                                        , countryOfMarriage =
                                                            U.maybeOr model.bcCountryOfMarriage
                                                                bcRec.countryOfMarriage
                                                        , attendantType =
                                                            Maybe.withDefault bcRec.attendantType
                                                                model.bcAttendantType
                                                        , attendantOther =
                                                            U.maybeOr model.bcAttendantOther
                                                                bcRec.attendantOther
                                                        , attendantFullname =
                                                            Maybe.withDefault bcRec.attendantFullname
                                                                model.bcAttendantFullname
                                                        , attendantTitle =
                                                            U.maybeOr model.bcAttendantTitle
                                                                bcRec.attendantTitle
                                                        , attendantAddr1 =
                                                            U.maybeOr model.bcAttendantAddr1
                                                                bcRec.attendantAddr1
                                                        , attendantAddr2 =
                                                            U.maybeOr model.bcAttendantAddr2
                                                                bcRec.attendantAddr2
                                                        , informantFullname =
                                                            Maybe.withDefault bcRec.informantFullname
                                                                model.bcInformantFullname
                                                        , informantRelationToChild =
                                                            Maybe.withDefault bcRec.informantRelationToChild
                                                                model.bcInformantRelationToChild
                                                        , informantAddress =
                                                            Maybe.withDefault bcRec.informantAddress
                                                                model.bcInformantAddress
                                                        , preparedByFullname =
                                                            Maybe.withDefault bcRec.preparedByFullname
                                                                model.bcPreparedByFullname
                                                        , preparedByTitle =
                                                            Maybe.withDefault bcRec.preparedByTitle
                                                                model.bcPreparedByTitle
                                                        , commTaxNumber =
                                                            U.maybeOr model.bcCommTaxNumber
                                                                bcRec.commTaxNumber
                                                        , commTaxDate =
                                                            U.maybeOr model.bcCommTaxDate
                                                                bcRec.commTaxDate
                                                        , commTaxPlace =
                                                            U.maybeOr model.bcCommTaxPlace
                                                                bcRec.commTaxPlace
                                                        , receivedByName =
                                                            U.maybeOr model.bcReceivedByName
                                                                bcRec.receivedByName
                                                        , receivedByTitle =
                                                            U.maybeOr model.bcReceivedByTitle
                                                                bcRec.receivedByTitle
                                                        , affiateName =
                                                            U.maybeOr model.bcAffiateName
                                                                bcRec.affiateName
                                                        , affiateAddress =
                                                            U.maybeOr model.bcAffiateAddress
                                                                bcRec.affiateAddress
                                                        , affiateCitizenshipCountry =
                                                            U.maybeOr model.bcAffiateCitizenshipCountry
                                                                bcRec.affiateCitizenshipCountry
                                                        , affiateReason =
                                                            U.maybeOr model.bcAffiateReason
                                                                bcRec.affiateReason
                                                        , affiateIAm =
                                                            U.maybeOr model.bcAffiateIAm
                                                                bcRec.affiateIAm
                                                        , affiateCommTaxNumber =
                                                            U.maybeOr model.bcAffiateCommTaxNumber
                                                                bcRec.affiateCommTaxNumber
                                                        , affiateCommTaxDate =
                                                            U.maybeOr model.bcAffiateCommTaxDate
                                                                bcRec.affiateCommTaxDate
                                                        , affiateCommTaxPlace =
                                                            U.maybeOr model.bcAffiateCommTaxPlace
                                                                bcRec.affiateCommTaxPlace
                                                        , comments =
                                                            U.maybeOr model.bcComments
                                                                bcRec.comments
                                                    }
                                            in
                                            ProcessTypeMsg
                                                (UpdateBirthCertificateType
                                                    (BirthCertMsg
                                                        (DataCache Nothing (Just [ BirthCertificate ]))
                                                    )
                                                    newBirthCertificate
                                                )
                                                ChgMsgType
                                                (birthCertificateRecordToValue newBirthCertificate)

                                        ( Just baby, Nothing ) ->
                                            -- Creating a new BirthCertificateRecord.
                                            case deriveBirthCertificateRecordNew model of
                                                Just bc ->
                                                    ProcessTypeMsg
                                                        (AddBirthCertificateType
                                                            (BirthCertMsg
                                                                -- Request top-level to provide data in
                                                                -- the dataCache once received from server.
                                                                (DataCache Nothing (Just [ BirthCertificate ]))
                                                            )
                                                            bc
                                                        )
                                                        AddMsgType
                                                        (birthCertificateRecordNewToValue bc)

                                                Nothing ->
                                                    LogConsole "deriveBirthCertificateRecordNew returned a Nothing"

                                        ( Nothing, _ ) ->
                                            -- Something is very wrong.
                                            LogConsole "No baby record found. Unable to save birth certificate."
                            in
                            ( { model | birthCertificateViewEditState = BirthCertificateViewState }
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
                            ( { model | birthCertificateViewEditState = BirthCertificateEditState }
                            , Cmd.none
                            , toastError msgs 10
                            )

        OpenDatePickerSubMsg id ->
            ( model, Cmd.none, Task.perform OpenDatePicker (Task.succeed id) )


{-| Prefill the birth certificate fields in the model according to the
data that we have in order to save the user some typing.
-}
populateModelBirthCertificateFields : Model -> Model
populateModelBirthCertificateFields model =
    case model.birthCertificateRecord of
        Just bcRec ->
            { model
                | bcBirthOrder = Just bcRec.birthOrder
                , bcMotherMaidenLastname = Just bcRec.motherMaidenLastname
                , bcMotherMiddlename = bcRec.motherMiddlename
                , bcMotherFirstname = Just bcRec.motherFirstname
                , bcMotherCitizenship = Just bcRec.motherCitizenship
                , bcMotherNumChildrenBornAlive = Just <| toString bcRec.motherNumChildrenBornAlive
                , bcMotherNumChildrenLiving = Just <| toString bcRec.motherNumChildrenLiving
                , bcMotherNumChildrenBornAliveNowDead = Just <| toString bcRec.motherNumChildrenBornAliveNowDead
                , bcMotherAddress = Just bcRec.motherAddress
                , bcMotherCity = Just bcRec.motherCity
                , bcMotherProvince = Just bcRec.motherProvince
                , bcMotherCountry = Just bcRec.motherCountry
                , bcFatherLastname = bcRec.fatherLastname
                , bcFatherMiddlename = bcRec.fatherLastname
                , bcFatherFirstname = bcRec.fatherFirstname
                , bcFatherCitizenship = bcRec.fatherCitizenship
                , bcFatherReligion = bcRec.fatherReligion
                , bcFatherOccupation = bcRec.fatherOccupation
                , bcFatherAgeAtBirth = Maybe.map toString bcRec.fatherLastname
                , bcFatherAddress = bcRec.fatherAddress
                , bcFatherCity = bcRec.fatherCity
                , bcFatherProvince = bcRec.fatherProvince
                , bcFatherCountry = bcRec.fatherCountry
                , bcDateOfMarriage = bcRec.dateOfMarriage
                , bcCityOfMarriage = bcRec.cityOfMarriage
                , bcProvinceOfMarriage = bcRec.provinceOfMarriage
                , bcCountryOfMarriage = bcRec.countryOfMarriage
                , bcAttendantType = Just bcRec.attendantType
                , bcAttendantOther = bcRec.attendantOther
                , bcAttendantFullname = Just bcRec.attendantFullname
                , bcAttendantTitle = bcRec.attendantTitle
                , bcAttendantAddr1 = bcRec.attendantAddr1
                , bcAttendantAddr2 = bcRec.attendantAddr2
                , bcInformantFullname = Just bcRec.informantFullname
                , bcInformantRelationToChild = Just bcRec.informantRelationToChild
                , bcInformantAddress = Just bcRec.informantAddress
                , bcPreparedByFullname = Just bcRec.preparedByFullname
                , bcPreparedByTitle = Just bcRec.preparedByTitle
                , bcCommTaxNumber = bcRec.commTaxNumber
                , bcCommTaxDate = bcRec.commTaxDate
                , bcCommTaxPlace = bcRec.commTaxPlace
                , bcReceivedByName = bcRec.receivedByName
                , bcReceivedByTitle = bcRec.receivedByTitle
                , bcAffiateName = bcRec.affiateName
                , bcAffiateAddress = bcRec.affiateAddress
                , bcAffiateCitizenshipCountry = bcRec.affiateCitizenshipCountry
                , bcAffiateReason = bcRec.affiateReason
                , bcAffiateIAm = bcRec.affiateIAm
                , bcAffiateCommTaxNumber = bcRec.affiateCommTaxNumber
                , bcAffiateCommTaxDate = bcRec.affiateCommTaxDate
                , bcAffiateCommTaxPlace = bcRec.affiateCommTaxPlace
                , bcComments = bcRec.comments
            }

        Nothing ->
            let
                defaultCitizenship =
                    Data.KeyValue.getKeyValueValueByKey
                        "birthCertDefaultCitizenship"
                        model.keyValueRecords

                defaultCountry =
                    Data.KeyValue.getKeyValueValueByKey
                        "birthCertDefaultCountry"
                        model.keyValueRecords

                defaultAttendantTitle =
                    Data.KeyValue.getKeyValueValueByKey
                        "birthCertDefaultAttendantTitle"
                        model.keyValueRecords

                defaultAttendantAddr1 =
                    Data.KeyValue.getKeyValueValueByKey
                        "birthCertDefaultAttendantAddr1"
                        model.keyValueRecords

                defaultAttendantAddr2 =
                    Data.KeyValue.getKeyValueValueByKey
                        "birthCertDefaultAttendantAddr2"
                        model.keyValueRecords

                defaultReceivedByName =
                    Data.KeyValue.getKeyValueValueByKey
                        "birthCertDefaultReceivedByName"
                        model.keyValueRecords

                defaultReceivedByTitle =
                    Data.KeyValue.getKeyValueValueByKey
                        "birthCertDefaultReceivedByTitle"
                        model.keyValueRecords
            in
            case model.pregnancyRecord of
                Just pregRec ->
                    let
                        -- Logic for use in the Philippines: if married, the
                        -- maiden name is pulled from the maidenname field on the
                        -- pregnancy record. If not married, the maiden name is
                        -- pulled from the lastname field on the pregnancy record.
                        motherLastname =
                            case
                                ( pregRec.lastname
                                , pregRec.maidenname
                                , pregRec.maritalStatus
                                )
                            of
                                ( lastname, Just maidenname, Just status ) ->
                                    case status of
                                        "Married" ->
                                            maidenname

                                        _ ->
                                            lastname

                                ( lastname, _, _ ) ->
                                    lastname
                    in
                    { model
                        | bcMotherMaidenLastname = Just motherLastname
                        , bcMotherFirstname = Just pregRec.firstname
                        , bcMotherCitizenship = defaultCitizenship
                        , bcMotherCity = pregRec.city
                        , bcMotherProvince = pregRec.state
                        , bcMotherCountry = defaultCountry
                        , bcFatherCitizenship = defaultCitizenship
                        , bcFatherCountry = defaultCountry
                        , bcCountryOfMarriage = defaultCountry

                        -- Note: cannot pull from keyValue for attendant type
                        -- because of the specific radio options allowed in
                        -- the view and the database.
                        , bcAttendantType = Just "Midwife"
                        , bcAttendantTitle = defaultAttendantTitle
                        , bcAttendantAddr1 = defaultAttendantAddr1
                        , bcAttendantAddr2 = defaultAttendantAddr2
                        , bcReceivedByName = defaultReceivedByName
                        , bcReceivedByTitle = defaultReceivedByTitle
                    }

                Nothing ->
                    model


{-| We assume that we have passed validation, so for Maybe String fields
we just use Maybe.withDefault to convert.
-}
deriveBirthCertificateRecordNew : Model -> Maybe BirthCertificateRecordNew
deriveBirthCertificateRecordNew model =
    case model.babyRecord of
        Just baby ->
            case
                ( Maybe.map String.toInt model.bcMotherNumChildrenBornAlive
                , Maybe.map String.toInt model.bcMotherNumChildrenLiving
                , Maybe.map String.toInt model.bcMotherNumChildrenBornAliveNowDead
                )
            of
                ( Just (Ok alive), Just (Ok living), Just (Ok dead) ) ->
                    Just <|
                        BirthCertificateRecordNew (Maybe.withDefault "" model.bcBirthOrder)
                            (Maybe.withDefault "" model.bcMotherMaidenLastname)
                            model.bcMotherMiddlename
                            (Maybe.withDefault "" model.bcMotherFirstname)
                            (Maybe.withDefault "" model.bcMotherCitizenship)
                            alive
                            living
                            dead
                            (Maybe.withDefault "" model.bcMotherAddress)
                            (Maybe.withDefault "" model.bcMotherCity)
                            (Maybe.withDefault "" model.bcMotherProvince)
                            (Maybe.withDefault "" model.bcMotherCountry)
                            model.bcFatherLastname
                            model.bcFatherMiddlename
                            model.bcFatherFirstname
                            model.bcFatherCitizenship
                            model.bcFatherReligion
                            model.bcFatherOccupation
                            (U.maybeStringToMaybeInt model.bcFatherAgeAtBirth)
                            model.bcFatherAddress
                            model.bcFatherCity
                            model.bcFatherProvince
                            model.bcFatherCountry
                            model.bcDateOfMarriage
                            model.bcCityOfMarriage
                            model.bcProvinceOfMarriage
                            model.bcCountryOfMarriage
                            (Maybe.withDefault "" model.bcAttendantType)
                            model.bcAttendantOther
                            (Maybe.withDefault "" model.bcAttendantFullname)
                            model.bcAttendantTitle
                            model.bcAttendantAddr1
                            model.bcAttendantAddr2
                            (Maybe.withDefault "" model.bcInformantFullname)
                            (Maybe.withDefault "" model.bcInformantRelationToChild)
                            (Maybe.withDefault "" model.bcInformantAddress)
                            (Maybe.withDefault "" model.bcPreparedByFullname)
                            (Maybe.withDefault "" model.bcPreparedByTitle)
                            model.bcCommTaxNumber
                            model.bcCommTaxDate
                            model.bcCommTaxPlace
                            model.bcReceivedByName
                            model.bcReceivedByTitle
                            model.bcAffiateName
                            model.bcAffiateAddress
                            model.bcAffiateCitizenshipCountry
                            model.bcAffiateReason
                            model.bcAffiateIAm
                            model.bcAffiateCommTaxNumber
                            model.bcAffiateCommTaxDate
                            model.bcAffiateCommTaxPlace
                            model.bcComments
                            baby.id

                ( _, _, _ ) ->
                    Nothing

        Nothing ->
            Nothing



-- VIEW --


{-| Configuration for a dialog.
-}
type alias ViewEditConfig =
    { isShown : Bool
    , isEditing : Bool
    , title : String
    , model : Model
    , closeMsg : SubMsg
    , saveMsg : SubMsg
    , editMsg : SubMsg
    }


getErr : Field -> List FieldError -> String
getErr fld errors =
    case LE.find (\fe -> Tuple.first fe == fld) errors of
        Just fe ->
            Tuple.second fe

        Nothing ->
            ""


{-| If we allowed the user to save a record to the server,
we assume that it is complete enough.
-}
isBirthCertificateDone : Model -> Bool
isBirthCertificateDone model =
    model.birthCertificateRecord /= Nothing


view : Maybe Window.Size -> Session -> Model -> Html SubMsg
view size session model =
    let
        incBy incAmt maybeNum =
            case maybeNum of
                Just num ->
                    toString (num + incAmt)

                Nothing ->
                    ""

        ( motherLast, motherFirst, gravida, para, living ) =
            case ( model.laborStage2Record, model.pregnancyRecord ) of
                ( Just ls2Rec, Just pregRec ) ->
                    ( pregRec.lastname
                    , pregRec.firstname
                    , incBy 0 pregRec.gravida
                    , if ls2Rec.birthDatetime /= Nothing then
                        incBy 1 pregRec.para
                      else
                        incBy 0 pregRec.para
                    , incBy 1 pregRec.living
                    )

                ( _, _ ) ->
                    ( "", "", "", "", "" )

        ( babyLast, babyFirst, babyMiddle ) =
            case model.babyRecord of
                Just babyRec ->
                    ( Maybe.withDefault "" babyRec.lastname
                    , Maybe.withDefault "" babyRec.firstname
                    , Maybe.withDefault "" babyRec.middlename
                    )

                Nothing ->
                    ( "", "", "" )

        isEditingBirthCertificate =
            if model.birthCertificateViewEditState == BirthCertificateEditState then
                True
            else
                not (isBirthCertificateDone model)

        birthCertificateViewEditConfig =
            ViewEditConfig
                (model.birthCertificateViewEditState
                    == BirthCertificateViewState
                    || model.birthCertificateViewEditState
                    == BirthCertificateEditState
                )
                isEditingBirthCertificate
                "Birth Certificate"
                model
                (HandleBirthCertificateModal CloseNoSaveDialog)
                (HandleBirthCertificateModal CloseSaveDialog)
                (HandleBirthCertificateModal EditDialog)

        header =
            H.div
                [ HA.class "u-high"
                , HA.style
                    [ ( "padding-left", "0.5em" )
                    , ( "padding-right", "0.5em" )
                    ]
                ]
                [ H.div []
                    [ H.span [ HA.class "c-text--quiet" ]
                        [ H.text "Mother: " ]
                    , H.span [ HA.class "c-text--loud" ]
                        [ H.text <| motherLast ++ ", " ++ motherFirst ]
                    , U.nbsp " " "("
                    , H.span [ HA.class "c-text--quiet" ]
                        [ H.text "G: " ]
                    , H.span [ HA.class "c-text--loud" ]
                        [ H.text gravida ]
                    , U.nbsp " " " "
                    , H.span [ HA.class "c-text--quiet" ]
                        [ H.text "P: " ]
                    , H.span [ HA.class "c-text--loud" ]
                        [ H.text para ]
                    , U.nbsp " " " "
                    , H.span [ HA.class "c-text--quiet" ]
                        [ H.text "L: " ]
                    , H.span [ HA.class "c-text--loud" ]
                        [ H.text living ]
                    , H.span []
                        [ H.text ")" ]
                    ]
                , H.div []
                    [ H.span [ HA.class "c-text--quiet" ]
                        [ H.text "Baby Last: " ]
                    , H.span [ HA.class "c-text--loud" ]
                        [ H.text babyLast ]
                    , H.span
                        [ HA.class "c-text--quiet"
                        , HA.style [ ( "margin-left", "1em" ) ]
                        ]
                        [ H.text "First: " ]
                    , H.span [ HA.class "c-text--loud" ]
                        [ H.text babyFirst ]
                    , H.span
                        [ HA.class "c-text--quiet"
                        , HA.style [ ( "margin-left", "1em" ) ]
                        ]
                        [ H.text "Middle: " ]
                    , H.span [ HA.class "c-text--loud" ]
                        [ H.text babyMiddle ]
                    ]
                ]
    in
    H.div [ HA.class "content-wrapper" ]
        [ H.h1 [ HA.class "c-heading u-large" ]
            [ H.text "Birth Certificate Worksheet" ]
        , header
        , viewEditBirthCertificate birthCertificateViewEditConfig
        ]


viewEditBirthCertificate : ViewEditConfig -> Html SubMsg
viewEditBirthCertificate cfg =
    case cfg.isEditing of
        True ->
            editBirthCertificate cfg

        False ->
            viewBirthCertificate cfg


viewBirthCertificate : ViewEditConfig -> Html SubMsg
viewBirthCertificate cfg =
    let
        displayDate date =
            case date of
                Just d ->
                    U.dateFormatter U.MDYDateFmt U.DashDateSep d

                Nothing ->
                    ""

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

        babyIdStr =
            case cfg.model.babyRecord of
                Just baby ->
                    toString baby.id

                Nothing ->
                    ""
    in
    case cfg.model.birthCertificateRecord of
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
                [ H.div []
                    [ H.div
                        [ HA.class "o-fieldset form-wrapper"
                        ]
                        [ viewField "Birth order" rec.birthOrder
                        , viewField "Mother maiden name" rec.motherMaidenLastname
                        , viewField "Mother middle name" <| Maybe.withDefault "" rec.motherMiddlename
                        , viewField "Mother first name" rec.motherFirstname
                        , viewField "Mother citizenship" rec.motherCitizenship
                        , viewField "Nbr children born alive" <| toString rec.motherNumChildrenBornAlive
                        , viewField "Nbr children living incl newborn" <| toString rec.motherNumChildrenLiving
                        , viewField "Nbr children born alive but now dead" <| toString rec.motherNumChildrenBornAliveNowDead
                        , viewField "Mother address" rec.motherAddress
                        , viewField "Mother city" rec.motherCity
                        , viewField "Mother province" rec.motherProvince
                        , viewField "Mother country" rec.motherCountry
                        , viewField "Father last name" <| Maybe.withDefault "" rec.fatherLastname
                        , viewField "Father middle name" <| Maybe.withDefault "" rec.fatherMiddlename
                        , viewField "Father first name" <| Maybe.withDefault "" rec.fatherFirstname
                        , viewField "Father citizenship" <| Maybe.withDefault "" rec.fatherCitizenship
                        , viewField "Father religion" <| Maybe.withDefault "" rec.fatherReligion
                        , viewField "Father occupation" <| Maybe.withDefault "" rec.fatherOccupation
                        , viewField "Father age at baby birth" <| maybeWithDefault toString rec.fatherAgeAtBirth
                        , viewField "Father address" <| Maybe.withDefault "" rec.fatherAddress
                        , viewField "Father city" <| Maybe.withDefault "" rec.fatherCity
                        , viewField "Father province" <| Maybe.withDefault "" rec.fatherProvince
                        , viewField "Father country" <| Maybe.withDefault "" rec.fatherCountry
                        , viewField "Date of marriage" <| displayDate rec.dateOfMarriage
                        , viewField "City of marriage" <| Maybe.withDefault "" rec.cityOfMarriage
                        , viewField "Province of marriage" <| Maybe.withDefault "" rec.provinceOfMarriage
                        , viewField "Country of marriage" <| Maybe.withDefault "" rec.countryOfMarriage
                        , viewField "Attendant type" rec.attendantType
                        , viewField "Attendant type if other" <| Maybe.withDefault "" rec.attendantOther
                        , viewField "Attendant full name" rec.attendantFullname
                        , viewField "Attendant title" <| Maybe.withDefault "" rec.attendantTitle
                        , viewField "Attendant address line 1" <| Maybe.withDefault "" rec.attendantAddr1
                        , viewField "Attendant address line 2" <| Maybe.withDefault "" rec.attendantAddr2
                        , viewField "Informant full name" rec.informantFullname
                        , viewField "Informant relation to child" rec.informantRelationToChild
                        , viewField "Informant address" rec.informantAddress
                        , viewField "Prepared by full name" rec.preparedByFullname
                        , viewField "Prepared by title" rec.preparedByTitle
                        , viewField "Comm tax number" <| Maybe.withDefault "" rec.commTaxNumber
                        , viewField "Comm tax date" <| displayDate rec.commTaxDate
                        , viewField "Comm tax place" <| Maybe.withDefault "" rec.commTaxPlace
                        , viewField "Received by full name" <| Maybe.withDefault "" rec.receivedByName
                        , viewField "Received by title" <| Maybe.withDefault "" rec.receivedByTitle
                        , viewField "Affiate full name" <| Maybe.withDefault "" rec.affiateName
                        , viewField "Affiate address" <| Maybe.withDefault "" rec.affiateAddress
                        , viewField "Affiate country of citizenship" <| Maybe.withDefault "" rec.affiateCitizenshipCountry
                        , viewField "Affiate reason" <| Maybe.withDefault "" rec.affiateReason
                        , viewField "Affiate I am" <| Maybe.withDefault "" rec.affiateIAm
                        , viewField "Affiate comm tax number" <| Maybe.withDefault "" rec.affiateCommTaxNumber
                        , viewField "Affiate comm tax date" <| displayDate rec.affiateCommTaxDate
                        , viewField "Affiate comm tax place" <| Maybe.withDefault "" rec.affiateCommTaxPlace
                        , viewField "Comments" <| Maybe.withDefault "" rec.comments
                        ]
                    , H.div
                        [ HA.class "spacedButtons"

                        -- In order to float the edit button below to the right. Also, the
                        -- span above the button is there to allow the button to float right.
                        , HA.style [ ( "overflow", "hidden" ) ]
                        ]
                        [ H.span [] [ H.text "" ]
                        , H.button
                            [ HA.type_ "button"
                            , HA.class "c-button c-button--ghost u-small"
                            , HA.style [ ( "float", "right" ) ]
                            , HE.onClick cfg.editMsg
                            ]
                            [ H.text "Edit" ]
                        ]
                    ]
                , H.div
                    [ HA.class "u-high"
                    , HA.style
                        [ ( "margin-top", "1em" )
                        , ( "padding", "0.5em 0.5em" )
                        ]
                    ]
                    [ H.h1 [ HA.class "c-heading u-medium" ]
                        [ H.text "Printing" ]
                    , H.div []
                        [ H.text
                            """
                                Specify the left and top offsets in order to properly align with the
                                birth certificate form. Offsets of 0 correspond to 1/2 inch margin.
                                Offsets are by points and there are 72 points per inch. Therefore, a
                                offset of 72 will produce a margin of 1.5 inches. Negative offsets are
                                allowed, for example, to achieve a 1/4 inch margin, use -36.
                                """
                        ]
                    , H.div
                        [ HA.class "o-fieldset form-wrapper"
                        ]
                        [ H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                            [ Form.formField (FldChgString >> FldChgSubMsg PrintingPage1TopFld)
                                "Top offset page one"
                                ""
                                True
                                cfg.model.printingPage1Top
                                (getErr PrintingPage1TopFld [])
                            ]
                        , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                            [ Form.formField (FldChgString >> FldChgSubMsg PrintingPage1LeftFld)
                                "Left offset page one"
                                ""
                                True
                                cfg.model.printingPage1Left
                                (getErr PrintingPage1LeftFld [])
                            ]
                        , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                            [ Form.formField (FldChgString >> FldChgSubMsg PrintingPage2TopFld)
                                "Top offset page two"
                                ""
                                True
                                cfg.model.printingPage2Top
                                (getErr PrintingPage2TopFld [])
                            ]
                        , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                            [ Form.formField (FldChgString >> FldChgSubMsg PrintingPage2LeftFld)
                                "Left offset page two"
                                ""
                                True
                                cfg.model.printingPage2Left
                                (getErr PrintingPage2LeftFld [])
                            ]
                        , H.div [ HA.class "mw-form-field-wide" ]
                            [ H.span
                                [ HA.class "c-text--loud" ]
                                [ H.text "Print these sections?" ]
                            , Form.checkboxWide "Paternity"
                                (FldChgBool >> FldChgSubMsg PrintingPaternityFld)
                                cfg.model.printingPaternity
                            , Form.checkboxWide "Delayed Registration"
                                (FldChgBool >> FldChgSubMsg PrintingDelayedRegistrationFld)
                                cfg.model.printingDelayedRegistration
                            ]
                        ]
                    , H.div
                        [ HA.class "spacedButtons"

                        -- In order to float the edit button below to the right. Also, the
                        -- span above the button is there to allow the button to float right.
                        , HA.style [ ( "overflow", "hidden" ) ]
                        ]
                        [ H.span [] [ H.text "" ]
                        , H.a
                            [ HA.type_ "button"
                            , HA.class "c-button c-button--primary u-medium"
                            , HA.style [ ( "float", "right" ) ]
                            , HA.href <|
                                printBirthCertificate babyIdStr
                                    (Maybe.withDefault "0" cfg.model.printingPage1Top)
                                    (Maybe.withDefault "0" cfg.model.printingPage1Left)
                                    (Maybe.withDefault "0" cfg.model.printingPage2Top)
                                    (Maybe.withDefault "0" cfg.model.printingPage2Left)
                                    cfg.model.printingPaternity
                                    cfg.model.printingDelayedRegistration
                            , HA.target "_blank"
                            ]
                            [ H.text "Print" ]
                        ]
                    ]
                ]


printBirthCertificate : String -> String -> String -> String -> String -> Maybe Bool -> Maybe Bool -> String
printBirthCertificate babyId top1 left1 top2 left2 paternity delayed =
    let
        yesNoBool value =
            case value of
                Just val ->
                    if val then
                        "Y"
                    else
                        "N"

                Nothing ->
                    "N"

        pat =
            yesNoBool paternity

        delReg =
            yesNoBool delayed
    in
    "/printBirthCertificate/"
        ++ String.join "/"
            [ babyId, top1, left1, top2, left2, pat, delReg ]


editBirthCertificate : ViewEditConfig -> Html SubMsg
editBirthCertificate cfg =
    let
        errors =
            validateBirthCertificate cfg.model

        fieldset fld lbl value =
            H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                [ Form.formField (FldChgString >> FldChgSubMsg fld)
                    lbl
                    ""
                    True
                    value
                    (getErr fld errors)
                ]
    in
    H.div
        [ HA.classList [ ( "isHidden", not cfg.isShown && cfg.isEditing ) ]
        , HA.class "u-high"
        , HA.style
            [ ( "padding", "0.8em" )
            , ( "margin-top", "0.8em" )
            ]
        ]
        [ H.div [ HA.class "form-wrapper u-small" ]
            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                [ fieldset BCBirthOrderFld "Birth order" cfg.model.bcBirthOrder
                , fieldset BCMotherMaidenLastnameFld "Mother maiden name" cfg.model.bcMotherMaidenLastname
                , fieldset BCMotherMiddlenameFld "Mother middle name" cfg.model.bcMotherMiddlename
                , fieldset BCMotherFirstnameFld "Mother first name" cfg.model.bcMotherFirstname
                , fieldset BCMotherCitizenshipFld "Mother citizenship" cfg.model.bcMotherCitizenship
                , fieldset BCMotherNumChildrenBornAliveFld "Number children born alive" cfg.model.bcMotherNumChildrenBornAlive
                , fieldset BCMotherNumChildrenLivingFld "Number children living incl newborn" cfg.model.bcMotherNumChildrenLiving
                , fieldset BCMotherNumChildrenBornAliveNowDeadFld "Number children born live, now dead" cfg.model.bcMotherNumChildrenBornAliveNowDead
                , fieldset BCMotherAddressFld "Mother address" cfg.model.bcMotherAddress
                , fieldset BCMotherCityFld "Mother city" cfg.model.bcMotherCity
                , fieldset BCMotherProvinceFld "Mother province" cfg.model.bcMotherProvince
                , fieldset BCMotherCountryFld "Mother country" cfg.model.bcMotherCountry
                , fieldset BCFatherLastnameFld "Father last name" cfg.model.bcFatherLastname
                , fieldset BCFatherMiddlenameFld "Father middle name" cfg.model.bcFatherMiddlename
                , fieldset BCFatherFirstnameFld "Father first name" cfg.model.bcFatherFirstname
                , fieldset BCFatherCitizenshipFld "Father citizenship" cfg.model.bcFatherCitizenship
                , fieldset BCFatherReligionFld "Father religion" cfg.model.bcFatherReligion
                , fieldset BCFatherOccupationFld "Father occupation" cfg.model.bcFatherOccupation
                , fieldset BCFatherAgeAtBirthFld "Father age at baby birth" cfg.model.bcFatherAgeAtBirth
                , fieldset BCFatherAddressFld "Father address" cfg.model.bcFatherAddress
                , fieldset BCFatherCityFld "Father city" cfg.model.bcFatherCity
                , fieldset BCFatherProvinceFld "Father province" cfg.model.bcFatherProvince
                , fieldset BCFatherCountryFld "Father country" cfg.model.bcFatherCountry
                , if cfg.model.browserSupportsDate then
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Marriage date" ]
                            ]
                        , H.div [ HA.class "c-card__body dateTimeModalBody" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDate (FldChgString >> FldChgSubMsg BCDateOfMarriageFld)
                                    ""
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.bcDateOfMarriage
                                    (getErr BCDateOfMarriageFld errors)
                                ]
                            ]
                        ]
                  else
                    -- Browser does not support date.
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Date of Marriage" ]
                            ]
                        , H.div [ HA.class "c-card__body" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDatePicker OpenDatePickerSubMsg
                                    BirthCertDateOfMarriageField
                                    ""
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.bcDateOfMarriage
                                    (getErr BCDateOfMarriageFld errors)
                                ]
                            ]
                        ]
                , fieldset BCCityOfMarriageFld "City of marriage" cfg.model.bcCityOfMarriage
                , fieldset BCProvinceOfMarriageFld "Province of marriage" cfg.model.bcProvinceOfMarriage
                , fieldset BCCountryOfMarriageFld "Country of marriage" cfg.model.bcCountryOfMarriage
                , Form.radioFieldset "Attendant type"
                    "attendantType"
                    cfg.model.bcAttendantType
                    (FldChgString >> FldChgSubMsg BCAttendantTypeFld)
                    False
                    [ "Physician"
                    , "Nurse"
                    , "Midwife"
                    , "Hilot"
                    , "Other"
                    ]
                    (getErr BCAttendantTypeFld errors)
                , fieldset BCAttendantOtherFld "Specify attendant if Other" cfg.model.bcAttendantOther
                , fieldset BCAttendantFullnameFld "Attendant full name" cfg.model.bcAttendantFullname
                , fieldset BCAttendantTitleFld "Attendant title" cfg.model.bcAttendantTitle
                , fieldset BCAttendantAddr1Fld "Attendant addr line 1" cfg.model.bcAttendantAddr1
                , fieldset BCAttendantAddr2Fld "Attendant addr line 2" cfg.model.bcAttendantAddr2
                , fieldset BCInformantFullnameFld "Informant full name" cfg.model.bcInformantFullname
                , fieldset BCInformantRelationToChildFld "Informant relation to child" cfg.model.bcInformantRelationToChild
                , fieldset BCInformantAddressFld "Informant address" cfg.model.bcInformantAddress
                , fieldset BCPreparedByFullnameFld "Prepared by full name" cfg.model.bcPreparedByFullname
                , fieldset BCPreparedByTitleFld "Prepared by title" cfg.model.bcPreparedByTitle
                , fieldset BCCommTaxNumberFld "Partner's comm tax number" cfg.model.bcCommTaxNumber
                , if cfg.model.browserSupportsDate then
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Date of partner's comm tax" ]
                            ]
                        , H.div [ HA.class "c-card__body dateTimeModalBody" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDate (FldChgString >> FldChgSubMsg BCCommTaxDateFld)
                                    ""
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.bcCommTaxDate
                                    (getErr BCCommTaxDateFld errors)
                                ]
                            ]
                        ]
                  else
                    -- Browser does not support date.
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Date of partner's comm tax" ]
                            ]
                        , H.div [ HA.class "c-card__body" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDatePicker OpenDatePickerSubMsg
                                    BirthCertDateOfCommTaxField
                                    ""
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.bcCommTaxDate
                                    (getErr BCCommTaxDateFld errors)
                                ]
                            ]
                        ]
                , fieldset BCCommTaxPlaceFld "Partner's comm tax place" cfg.model.bcCommTaxPlace
                , fieldset BCReceivedByNameFld "Received by full name" cfg.model.bcReceivedByName
                , fieldset BCReceivedByTitleFld "Received by title" cfg.model.bcReceivedByTitle
                , fieldset BCAffiateNameFld "Affiate full name" cfg.model.bcAffiateName
                , fieldset BCAffiateAddressFld "Affiate address" cfg.model.bcAffiateAddress
                , fieldset BCAffiateCitizenshipCountryFld "Affiate's country of citizenship" cfg.model.bcAffiateCitizenshipCountry
                , fieldset BCAffiateReasonFld "Reason for delay" cfg.model.bcAffiateReason
                , fieldset BCAffiateIAmFld "Affiate I am" cfg.model.bcAffiateIAm
                , fieldset BCAffiateCommTaxNumberFld "Affiate comm tax number" cfg.model.bcAffiateCommTaxNumber
                , if cfg.model.browserSupportsDate then
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Date of affiate's comm tax" ]
                            ]
                        , H.div [ HA.class "c-card__body dateTimeModalBody" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDate (FldChgString >> FldChgSubMsg BCAffiateCommTaxDateFld)
                                    ""
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.bcAffiateCommTaxDate
                                    (getErr BCAffiateCommTaxDateFld errors)
                                ]
                            ]
                        ]
                  else
                    -- Browser does not support date.
                    H.div [ HA.class "c-card mw-form-field-2x" ]
                        [ H.div [ HA.class "c-card__item" ]
                            [ H.div [ HA.class "c-text--loud" ]
                                [ H.text "Date of affiate's comm tax" ]
                            ]
                        , H.div [ HA.class "c-card__body" ]
                            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                                [ Form.formFieldDatePicker OpenDatePickerSubMsg
                                    BirthCertDateOfAffiateCommTaxField
                                    ""
                                    "e.g. 08/14/2017"
                                    False
                                    cfg.model.bcAffiateCommTaxDate
                                    (getErr BCAffiateCommTaxDateFld errors)
                                ]
                            ]
                        ]
                , fieldset BCAffiateCommTaxPlace "Affiate comm tax place" cfg.model.bcAffiateCommTaxPlace
                , Form.formTextareaField (FldChgString >> FldChgSubMsg BCCommentsFld)
                    "Comments"
                    ""
                    True
                    cfg.model.bcComments
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



-- VALIDATION --


type alias FieldError =
    ( Field, String )


validateBirthCertificate : Model -> List FieldError
validateBirthCertificate =
    Validate.all
        [ .bcBirthOrder >> ifInvalid U.validatePopulatedString (BCBirthOrderFld => "* required")
        , .bcMotherMaidenLastname >> ifInvalid U.validatePopulatedString (BCMotherMaidenLastnameFld => "* required")
        , .bcMotherFirstname >> ifInvalid U.validatePopulatedString (BCMotherFirstnameFld => "* required")
        , .bcMotherCitizenship >> ifInvalid U.validatePopulatedString (BCMotherCitizenshipFld => "* required")
        , .bcMotherNumChildrenBornAlive >> ifInvalid U.validateInt (BCMotherNumChildrenBornAliveFld => "* required")
        , .bcMotherNumChildrenLiving >> ifInvalid U.validateInt (BCMotherNumChildrenLivingFld => "* required")
        , .bcMotherNumChildrenBornAliveNowDead >> ifInvalid U.validateInt (BCMotherNumChildrenBornAliveNowDeadFld => "* required")
        , .bcMotherAddress >> ifInvalid U.validatePopulatedString (BCMotherAddressFld => "* required")
        , .bcMotherCity >> ifInvalid U.validatePopulatedString (BCMotherCityFld => "* required")
        , .bcMotherCountry >> ifInvalid U.validatePopulatedString (BCMotherCountryFld => "* required")
        , .bcAttendantType >> ifInvalid U.validatePopulatedString (BCAttendantTypeFld => "* required")
        , \mdl ->
            if mdl.bcAttendantType == Just "Other" && String.length (Maybe.withDefault "" mdl.bcAttendantOther) == 0 then
                [ BCAttendantOtherFld => "* required" ]
            else
                []
        , .bcAttendantFullname >> ifInvalid U.validatePopulatedString (BCAttendantFullnameFld => "* required")
        , .bcAttendantTitle >> ifInvalid U.validatePopulatedString (BCAttendantTitleFld => "* required")
        , .bcAttendantAddr1 >> ifInvalid U.validatePopulatedString (BCAttendantAddr1Fld => "* required")
        , .bcAttendantAddr2 >> ifInvalid U.validatePopulatedString (BCAttendantAddr2Fld => "* required")
        , .bcInformantFullname >> ifInvalid U.validatePopulatedString (BCInformantFullnameFld => "* required")
        , .bcInformantRelationToChild >> ifInvalid U.validatePopulatedString (BCInformantRelationToChildFld => "* required")
        , .bcInformantAddress >> ifInvalid U.validatePopulatedString (BCInformantAddressFld => "* required")
        , .bcPreparedByFullname >> ifInvalid U.validatePopulatedString (BCPreparedByFullnameFld => "* required")
        , .bcPreparedByTitle >> ifInvalid U.validatePopulatedString (BCPreparedByTitleFld => "* required")
        ]
