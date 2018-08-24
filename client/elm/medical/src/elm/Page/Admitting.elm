module Page.Admitting
    exposing
        ( buildModel
        , getTablesByCacheOrServer
        , init
        , Model
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

import Const exposing (FldChgValue(..))
import Data.Admitting exposing (Field(..), AdmittingSubMsg(..))
import Data.DataCache as DataCache exposing (DataCache(..))
import Data.DatePicker exposing (DateField(..), DateFieldMessage(..), dateFieldToString)
import Data.Labor
    exposing
        ( getLaborId
        , LaborId(..)
        , LaborRecord
        , LaborRecordNew
        , laborRecordNewToValue
        , laborRecordNewToLaborRecord
        , laborRecordToValue
        )
import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (getPregId, PregnancyId(..), PregnancyRecord)
import Data.PregnancyHeader as PregHeaderData
import Data.SelectQuery exposing (SelectQuery, selectQueryToValue)
import Data.Session as Session exposing (Session)
import Data.Table exposing (Table(..))
import Msg exposing (logConsole, Msg(..), ProcessType(..), toastInfo, toastWarn, toastError)
import Ports
import Processing exposing (ProcessStore)
import Util as U exposing ((=>))
import Views.Form as Form
import Views.PregnancyHeader as PregHeaderView


-- MODEL --


type AdmissionState
    = AdmissionStateNone
    | AdmissionStateNew
    | AdmissionStateView LaborId
    | AdmissionStateEdit LaborId


type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , pregnancy_id : PregnancyId
    , currLaborId : Maybe LaborId
    , currPregHeaderContent : PregHeaderData.PregHeaderContent
    , dataCache : Dict String DataCache
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    , laborRecord : Maybe LaborRecord
    , admissionState : AdmissionState
    , admittanceDate : Maybe Date
    , admittanceTime : Maybe String
    , laborDate : Maybe Date
    , laborTime : Maybe String
    , pos : Maybe String
    , fh : Maybe String
    , fht : Maybe String
    , systolic : Maybe String
    , diastolic : Maybe String
    , cr : Maybe String
    , temp : Maybe String
    , comments : Maybe String
    , formErrors : List FieldError
    }


buildModel :
    Bool
    -> Time
    -> ProcessStore
    -> PregnancyId
    -> Maybe PatientRecord
    -> Maybe PregnancyRecord
    -> Maybe LaborRecord
    -> ( Model, ProcessStore, Cmd Msg )
buildModel browserSupportsDate currTime store pregId patrec pregRec laborRec =
    let
        ( admissionState, newOuterMsg ) =
            case laborRec of
                Just rec ->
                    ( AdmissionStateView (LaborId rec.id)
                    , Cmd.none
                    )

                Nothing ->
                    ( AdmissionStateNone
                    , Cmd.none
                    )

        ( pregHeaderContent, laborId ) =
            case admissionState of
                AdmissionStateNone ->
                    ( PregHeaderData.PrenatalContent, Nothing )

                AdmissionStateNew ->
                    ( PregHeaderData.PrenatalContent, Nothing )

                AdmissionStateView laborId ->
                    ( PregHeaderData.PrenatalContent, Just laborId )

                AdmissionStateEdit laborId ->
                    ( PregHeaderData.PrenatalContent, Just laborId )
    in
        ( { browserSupportsDate = browserSupportsDate
          , currTime = currTime
          , pregnancy_id = pregId
          , currLaborId = laborId
          , currPregHeaderContent = pregHeaderContent
          , dataCache = Dict.empty
          , patientRecord = patrec
          , pregnancyRecord = pregRec
          , laborRecord = laborRec
          , admissionState = admissionState
          , admittanceDate = Nothing
          , admittanceTime = Nothing
          , laborDate = Nothing
          , laborTime = Nothing
          , pos = Nothing
          , fh = Nothing
          , fht = Nothing
          , systolic = Nothing
          , diastolic = Nothing
          , cr = Nothing
          , temp = Nothing
          , comments = Nothing
          , formErrors = []
          }
        , store
        , newOuterMsg
        )

{-| Generate an top-level module command to retrieve additional data which checks
first in the data cache, and secondarily from the server.
-}
getTables : Table -> Maybe Int -> List Table -> Cmd Msg
getTables table key relatedTables =
    Task.perform
        (always (AdmittingSelectQuery table key relatedTables))
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
                        Data.Admitting.DataCache Nothing (Just dataCacheTables)
                            |> AdmittingMsg
                in
                store => Task.perform (always cachedMsg) (Task.succeed True)
            else
                let
                    selectQuery =
                        SelectQuery table key relatedTbls

                    ( processId, processStore ) =
                        Processing.add
                            (SelectQueryType
                                (AdmittingMsg
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




{-| On initialization, the Model will be updated by a call to buildModel once
the initial data has arrived from the server. Hence, the AdmittingSubMsg does not need
to be DataCache, which is used subsequent to first page load.
-}
init : PregnancyId -> Session -> ProcessStore -> ( ProcessStore, Cmd Msg )
init pregId session store =
    let
        selectQuery =
            SelectQuery Pregnancy (Just (getPregId pregId)) [ Patient, Labor ]

        ( processId, processStore ) =
            Processing.add (SelectQueryType (AdmittingLoaded pregId) selectQuery) Nothing store

        msg =
            wrapPayload processId SelectMsgType (selectQueryToValue selectQuery)
    in
        processStore
            => Ports.outgoing msg



-- VIEW --


view : Maybe Window.Size -> Session -> Model -> Html AdmittingSubMsg
view size session model =
    let
        pregHeader =
            case ( model.patientRecord, model.pregnancyRecord ) of
                ( Just patRec, Just pregRec ) ->
                    let
                        laborInfo =
                            PregHeaderData.LaborInfo model.laborRecord
                                Nothing
                                Nothing
                                Nothing
                                []
                    in
                        PregHeaderView.view patRec
                            pregRec
                            laborInfo
                            model.currPregHeaderContent
                            model.currTime
                            size

                ( _, _ ) ->
                    H.text ""

        views =
            case model.admissionState of
                AdmissionStateNone ->
                    [ viewAdmitButton
                    ]

                AdmissionStateNew ->
                    [ viewAdmitForm Nothing model ]

                AdmissionStateView laborId ->
                    [ viewAdmittingData model
                    ]

                AdmissionStateEdit laborId ->
                    [ viewAdmitForm (Just laborId) model ]
    in
        H.div []
            [ pregHeader |> H.map (\a -> RotatePregHeaderContent a)
            , H.div [ HA.class "content-wrapper" ] views
            ]


getErr : Field -> List FieldError -> String
getErr fld errors =
    case LE.find (\fe -> Tuple.first fe == fld) errors of
        Just fe ->
            Tuple.second fe

        Nothing ->
            ""


viewAdmittingData : Model -> Html AdmittingSubMsg
viewAdmittingData model =
    let
        ( admitDate, startDate, pos, fh, fht, sys, dia, cr ) =
            case model.laborRecord of
                Just rec ->
                    ( rec.admittanceDate |> U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep
                    , rec.startLaborDate |> U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep
                    , rec.pos
                    , toString rec.fh
                    , rec.fht
                    , toString rec.systolic
                    , toString rec.diastolic
                    , toString rec.cr
                    )

                Nothing ->
                    ( "", "", "", "", "", "", "", "" )

        ( temp, comments ) =
            case model.laborRecord of
                Just rec ->
                    ( toString rec.temp
                    , Maybe.withDefault "" rec.comments
                    )

                Nothing ->
                    ( "", "" )

        title =
            "Admitting Diagnosis"
    in
        H.div
            [ HA.class "u-high"
            , HA.style
                [ ( "padding", "0.8em" )
                , ( "margin-top", "0.8em" )
                ]
            ]
            [ H.h1 [ HA.class "c-heading u-large" ]
                [ H.text title ]
            , H.div []
                [ H.div [ HA.class "o-fieldset form-wrapper" ]
                    [ H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Admittance: " ]
                        , H.span [ HA.class "" ]
                            [ H.text admitDate ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Start labor: " ]
                        , H.span [ HA.class "" ]
                            [ H.text startDate ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "POS: " ]
                        , H.span [ HA.class "" ]
                            [ H.text pos ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "FH: " ]
                        , H.span [ HA.class "" ]
                            [ H.text fh ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "FHT: " ]
                        , H.span [ HA.class "" ]
                            [ H.text fht ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "BP: " ]
                        , H.span [ HA.class "" ]
                            [ H.text <| sys ++ " / " ++ dia ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "CR: " ]
                        , H.span [ HA.class "" ]
                            [ H.text cr ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Temp: " ]
                        , H.span [ HA.class "" ]
                            [ H.text temp ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Comments: " ]
                        , H.span [ HA.class "" ]
                            [ H.text comments ]
                        ]
                    ]
                , H.div [ HA.class "spacedButtons" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--ghost u-small"
                        , case model.currLaborId of
                            Just lid ->
                                HE.onClick (EditAdmittance lid)

                            Nothing ->
                                HA.class ""
                        ]
                        [ H.text "Edit" ]
                    ]
                ]
            ]


viewAdmitForm : Maybe LaborId -> Model -> Html AdmittingSubMsg
viewAdmitForm laborId model =
    let
        errors =
            validateAdmittance model
    in
        H.div []
            [ H.h3 [ HA.class "c-text--brand mw-header-3" ] [ H.text "Admittance Details" ]
            , H.div []
                [ H.div [ HA.class "" ] [ Form.formErrors model.formErrors ]
                , H.div [ HA.class "o-fieldset form-wrapper" ]
                    [ if model.browserSupportsDate then
                        Form.formFieldDate (FldChgString >> FldChgSubMsg AdmittanceDateFld)
                            "Date admitted"
                            "e.g. 08/14/2017"
                            True
                            model.admittanceDate
                            (getErr AdmittanceDateFld errors)
                      else
                        Form.formFieldDatePicker OpenDatePickerSubMsg
                            AdmittingAdmittanceDateField
                            "Date admitted"
                            "e.g. 08/14/2017"
                            True
                            model.admittanceDate
                            (getErr AdmittanceDateFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg AdmittanceTimeFld)
                        "Time admitted"
                        "24 hr format, 14:44"
                        True
                        model.admittanceTime
                        (getErr AdmittanceTimeFld errors)
                    , if model.browserSupportsDate then
                        Form.formFieldDate (FldChgString >> FldChgSubMsg LaborDateFld)
                            "Date start of labor"
                            "e.g. 08/14/2017"
                            True
                            model.laborDate
                            (getErr LaborDateFld errors)
                      else
                        Form.formFieldDatePicker OpenDatePickerSubMsg
                            AdmittingStartLaborDateField
                            "Date start of labor"
                            "e.g. 08/14/2017"
                            True
                            model.laborDate
                            (getErr LaborDateFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg LaborTimeFld)
                        "Time start of labor"
                        "24 hr format, 09:00"
                        True
                        model.laborTime
                        (getErr LaborTimeFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg PosFld)
                        "POS"
                        "pos"
                        True
                        model.pos
                        (getErr PosFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg FhFld)
                        "FH"
                        "fh"
                        True
                        model.fh
                        (getErr FhFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg FhtFld)
                        "FHT"
                        "fht"
                        True
                        model.fht
                        (getErr FhtFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg SystolicFld)
                        "Systolic"
                        "systolic"
                        True
                        model.systolic
                        (getErr SystolicFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg DiastolicFld)
                        "Diastolic"
                        "diastolic"
                        True
                        model.diastolic
                        (getErr DiastolicFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg CrFld)
                        "CR"
                        "heart rate"
                        True
                        model.cr
                        (getErr CrFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg TempFld)
                        "Temp"
                        "temperature"
                        True
                        model.temp
                        (getErr TempFld errors)
                    , Form.formTextareaField (FldChgString >> FldChgSubMsg CommentsFld)
                        "Comments"
                        ""
                        True
                        model.comments
                        3
                    ]
                , if List.length model.formErrors > 0 then
                    H.div
                        [ HA.class "u-small error-msg-right primary-fg"
                        ]
                        [ H.text "Errors detected, see details above." ]
                  else
                    H.span [] []
                , H.div [ HA.class "form-wrapper-end" ]
                    [ Form.cancelSaveButtons CancelAdmitForLabor
                        (SaveAdmitForLabor laborId)
                    ]
                ]
            ]


viewAdmitButton : Html AdmittingSubMsg
viewAdmitButton =
    H.button
        [ HA.class "c-button c-button--brand u-xlarge"
        , HE.onClick AdmitForLabor
        ]
        [ H.text "Admit for Labor" ]



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
                                Just (LaborDataCache rec) ->
                                    { m | laborRecord = Just rec }

                                _ ->
                                    m

                        _ ->
                            let
                                _ =
                                    Debug.log "Admitting.refreshModelFromCache: Unhandled Table" <| toString t
                            in
                                m
                )
                model
                tables
    in
        newModel


update : Session -> AdmittingSubMsg -> Model -> ( Model, Cmd AdmittingSubMsg, Cmd Msg )
update session msg model =
    case msg of
        AdmittingPageNoop ->
            ( model, Cmd.none, Cmd.none )

        AdmittingTick time ->
            ( { model | currTime = time }, Cmd.none, Cmd.none )

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

        DateFieldSubMsg dateFldMsg ->
            -- For browsers that do not support a native date field.
            case dateFldMsg of
                DateFieldMessage { dateField, date } ->
                    case dateField of
                        AdmittingAdmittanceDateField ->
                            ( { model | admittanceDate = Just date }, Cmd.none, Cmd.none )

                        AdmittingStartLaborDateField ->
                            ( { model | laborDate = Just date }, Cmd.none, Cmd.none )

                        UnknownDateField str ->
                            ( model, Cmd.none, logConsole <| "Unknown date field: " ++ str )

                        _ ->
                            -- This page is not the only one with date fields, we only
                            -- handle what we know about.
                            ( model, Cmd.none, Cmd.none )

                UnknownDateFieldMessage str ->
                    ( model, Cmd.none, Cmd.none )

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

        AdmitForLabor ->
            -- The user just pressed the Admit for Labor button in order to add a new labor record.
            let
                -- We default to the current date if it is not already filled.
                admittanceDate =
                    case model.admittanceDate of
                        Just d ->
                            Just d

                        Nothing ->
                            Just <| Date.fromTime model.currTime
            in
                ( { model
                    | admissionState = AdmissionStateNew
                    , admittanceDate = admittanceDate
                  }
                , Cmd.none
                , Cmd.none
                )

        CancelAdmitForLabor ->
            -- The user canceled the add or edit labor form.
            -- TODO: Determine what admissionState should be.
            let
                adState =
                    case model.currLaborId of
                        Just lid ->
                            AdmissionStateView lid

                        Nothing ->
                            AdmissionStateNone
            in
                ( { model
                    | admissionState = adState
                    , admittanceDate = Nothing
                    , admittanceTime = Nothing
                    , laborDate = Nothing
                    , laborTime = Nothing
                    , pos = Nothing
                    , fh = Nothing
                    , fht = Nothing
                    , systolic = Nothing
                    , diastolic = Nothing
                    , cr = Nothing
                    , temp = Nothing
                    , comments = Nothing
                    , formErrors = []
                  }
                , Cmd.none
                , Cmd.none
                )

        SaveAdmitForLabor laborId ->
            -- The user submitted a new labor record to be sent to the server.
            case validateAdmittance model of
                [] ->
                    let
                        newOuterMsg =
                            case model.laborRecord of
                                Just rec ->
                                    -- Saving an existing record; note that we do not handle
                                    -- the fields that do not make sense on this page such as
                                    -- earlyLabor and dischargeDate.
                                    let
                                        laborRec =
                                            { rec
                                                | admittanceDate =
                                                    U.deriveDateFromMaybeDateMaybeString
                                                        model.admittanceDate
                                                        model.admittanceTime
                                                        rec.admittanceDate
                                                , startLaborDate =
                                                    U.deriveDateFromMaybeDateMaybeString
                                                        model.laborDate
                                                        model.laborTime
                                                        rec.startLaborDate
                                                , pos = Maybe.withDefault "" model.pos
                                                , fh =
                                                    U.maybeStringToMaybeInt model.fh
                                                        |> Maybe.withDefault 0
                                                , fht = Maybe.withDefault "" model.fht
                                                , systolic =
                                                    U.maybeStringToMaybeInt model.systolic
                                                        |> Maybe.withDefault 0
                                                , diastolic =
                                                    U.maybeStringToMaybeInt model.diastolic
                                                        |> Maybe.withDefault 0
                                                , cr =
                                                    U.maybeStringToMaybeInt model.cr
                                                        |> Maybe.withDefault 0
                                                , temp =
                                                    U.maybeStringToMaybeFloat model.temp
                                                        |> Maybe.withDefault 0.0
                                                , comments = model.comments
                                            }
                                    in
                                        ProcessTypeMsg
                                            (UpdateLaborType
                                                (AdmittingMsg
                                                    (DataCache Nothing (Just [ Labor ]))
                                                )
                                                laborRec
                                            )
                                            ChgMsgType
                                            (laborRecordToValue laborRec)

                                Nothing ->
                                    -- Creating a new record.
                                    case deriveLaborRecordNew model of
                                        Just laborRecNew ->
                                            ProcessTypeMsg
                                                (AddLaborType
                                                    (AdmittingMsg
                                                        (AdmitForLaborSaved laborRecNew Nothing)
                                                    )
                                                    laborRecNew
                                                )
                                                AddMsgType
                                                (laborRecordNewToValue laborRecNew)

                                        Nothing ->
                                            Noop

                    in
                        ( { model
                            | formErrors = []
                            , admissionState =
                                case laborId of
                                    Just lid ->
                                        AdmissionStateView lid

                                    Nothing ->
                                        model.admissionState
                          }
                        , Cmd.none
                        , Task.perform (always newOuterMsg) (Task.succeed True)
                        )

                errors ->
                    -- Add errors to model for user to address before submission.
                    let
                        msgs =
                            List.map Tuple.second errors
                                |> flip (++) [ "Record was not saved." ]
                    in
                    ( { model | formErrors = errors }
                    , Cmd.none
                    , toastError msgs 10
                    )

        AdmitForLaborSaved laborRecNew lid ->
            -- The server returned the result of our request to add a new labor record.
            let
                newLaborRec =
                    case lid of
                        Just id ->
                            Just <| laborRecordNewToLaborRecord id laborRecNew

                        Nothing ->
                            Nothing
            in
                ( case newLaborRec of
                    Just nlr ->
                        { model
                            | admissionState = AdmissionStateView (LaborId nlr.id)
                            , laborRecord = Just nlr
                            , currPregHeaderContent = PregHeaderData.LaborContent
                            , currLaborId = lid
                        }

                    Nothing ->
                        model
                , Cmd.none
                , Cmd.none
                )

        EditAdmittance laborId ->
            case model.laborRecord of
                Just rec ->
                    -- Populate the fields of the form.
                    ( { model
                        | admissionState = AdmissionStateEdit laborId
                        , admittanceDate = Just rec.admittanceDate
                        , admittanceTime = Just <| U.dateToTimeString rec.admittanceDate
                        , laborDate = Just rec.startLaborDate
                        , laborTime = Just <| U.dateToTimeString rec.startLaborDate
                        , pos = Just rec.pos
                        , fh = Just (toString rec.fh)
                        , fht = Just rec.fht
                        , systolic = Just (toString rec.systolic)
                        , diastolic = Just (toString rec.diastolic)
                        , cr = Just (toString rec.cr)
                        , temp = Just (toString rec.temp)
                        , comments = rec.comments
                        , formErrors = []
                        }
                    , Cmd.none
                    , Cmd.none
                    )

                Nothing ->
                    ( model, Cmd.none, Cmd.none )

        OpenDatePickerSubMsg id ->
            ( model, Cmd.none, Task.perform OpenDatePicker (Task.succeed id) )

        FldChgSubMsg fld val ->
            -- All fields are handled here except for the date fields for browsers that
            -- do not support the input date type (see DateFieldSubMsg for those) and
            -- the boolean fields handled by FldChgBoolSubMsg above.
            case val of
                FldChgString value ->
                    ( case fld of
                        AdmittanceDateFld ->
                            { model | admittanceDate = U.stringToDateAddSubOffset value }

                        AdmittanceTimeFld ->
                            { model | admittanceTime = Just <| U.filterStringLikeTime value }

                        LaborDateFld ->
                            { model | laborDate = U.stringToDateAddSubOffset value }

                        LaborTimeFld ->
                            { model | laborTime = Just <| U.filterStringLikeTime value }

                        PosFld ->
                            { model | pos = Just <| String.toUpper value }

                        FhFld ->
                            { model | fh = Just <| U.filterStringLikeInt value }

                        FhtFld ->
                            { model | fht = Just value }

                        SystolicFld ->
                            { model | systolic = Just <| U.filterStringLikeInt value }

                        DiastolicFld ->
                            { model | diastolic = Just <| U.filterStringLikeInt value }

                        CrFld ->
                            { model | cr = Just <| U.filterStringLikeInt value }

                        TempFld ->
                            { model | temp = Just <| U.filterStringLikeFloat value }

                        CommentsFld ->
                            { model | comments = Just value }
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgStringList _ _ ->
                    ( model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgBool value ->
                    ( case fld of
                        _ ->
                            let
                                _ =
                                    Debug.log "Admitting.update FldChgSubMsg"
                                        "Unknown field encountered in FldChgBool. Possible mismatch between Field and FldChgValue."
                            in
                                model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgIntString intVal strVal ->
                    -- We don't have any of these fields in the page.
                    ( model
                    , Cmd.none
                    , Cmd.none
                    )

        ViewLaborRecord laborId ->
            ( { model
                | currLaborId = Just laborId
                , admissionState = AdmissionStateView laborId
              }
            , Cmd.none
            , Cmd.none
            )


{-| Derive a LaborRecordNew from the form fields, if possible.
-}
deriveLaborRecordNew : Model -> Maybe LaborRecordNew
deriveLaborRecordNew model =
    case
        ( ( model.admittanceDate
          , model.admittanceTime
          , model.laborDate
          , model.laborTime
          , model.pos
          , (U.maybeStringToMaybeInt model.fh)
          )
        , ( model.fht
          , (U.maybeStringToMaybeInt model.systolic)
          , (U.maybeStringToMaybeInt model.diastolic)
          , (U.maybeStringToMaybeInt model.cr)
          , (U.maybeStringToMaybeFloat model.temp)
          )
        )
    of
        ( ( Just aDate, Just aTime, Just lDate, Just lTime, Just pos, Just fh ), ( Just fht, Just systolic, Just diastolic, Just cr, Just temp ) ) ->
            let
                ( aTimeTuple, lTimeTuple ) =
                    ( U.stringToTimeTuple aTime, U.stringToTimeTuple lTime )
            in
                case ( aTimeTuple, lTimeTuple ) of
                    ( Just att, Just ltt ) ->
                        Just <|
                            LaborRecordNew (U.datePlusTimeTuple aDate att)
                                (U.datePlusTimeTuple lDate ltt)
                                pos
                                fh
                                fht
                                systolic
                                diastolic
                                cr
                                temp
                                model.comments
                                (getPregId model.pregnancy_id)

                    ( _, _ ) ->
                        Nothing

        ( ( _, _, _, _, _, _ ), ( _, _, _, _, _ ) ) ->
            Nothing



-- VALIDATION of the Admitting Model form fields, not the records sent to the server. --


type alias FieldError =
    ( Field, String )


validateAdmittance : Model -> List FieldError
validateAdmittance =
    Validate.all
        [ .admittanceDate >> ifInvalid U.validateReasonableDate (AdmittanceDateFld => "Valid date of admittance must be provided.")
        , .admittanceTime >> ifInvalid U.validateTime (AdmittanceTimeFld => "Admitting time must be provided, ex: hhmm.")
        , .laborDate >> ifInvalid U.validateReasonableDate (LaborDateFld => "Valid date of the start of labor must be provided.")
        , .laborTime >> ifInvalid U.validateTime (LaborTimeFld => "Start of labor time must be provided, ex: hhmm.")
        , .pos >> ifInvalid U.validatePopulatedString (PosFld => "POS must be provided.")
        , .fh >> ifInvalid U.validateInt (FhFld => "FH must be provided.")
        , .fht >> ifInvalid U.validatePopulatedString (FhtFld => "FHT must be provided.")
        , .systolic >> ifInvalid U.validateInt (SystolicFld => "Systolic must be provided.")
        , .diastolic >> ifInvalid U.validateInt (DiastolicFld => "Diastolic must be provided.")
        , .cr >> ifInvalid U.validateInt (CrFld => "CR must be provided.")
        , .temp >> ifInvalid U.validateFloat (TempFld => "Temp must be provided.")
        ]
