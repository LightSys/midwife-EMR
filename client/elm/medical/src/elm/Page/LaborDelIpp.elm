module Page.LaborDelIpp
    exposing
        ( Model
        , buildModel
        , init
        , update
        , view
        )

import Date exposing (Date, Month(..), day, month, year)
import Date.Extra.Compare as DEComp
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Task exposing (Task)
import Time exposing (Time)
import Validate exposing (ifBlank, ifInvalid, ifNotInt)
import Window


-- LOCAL IMPORTS --

import Data.DatePicker exposing (DateField(..), DateFieldMessage(..), dateFieldToString)
import Data.Labor
    exposing
        ( getLaborId
        , LaborId(..)
        , LaborRecord
        , LaborRecordNew
        , laborRecordNewToValue
        , laborRecordNewToLaborRecord
        )
import Data.LaborDelIpp exposing (Field(..), SubMsg(..))
import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (getPregId, PregnancyId(..), PregnancyRecord)
import Data.Processing exposing (ProcessId(..))
import Data.SelectQuery exposing (SelectQuery, selectQueryToValue)
import Data.Session as Session exposing (Session)
import Data.Table exposing (Table(..))
import Msg exposing (logConsole, Msg(..), ProcessType(..))
import Page.Errored as Errored exposing (PageLoadError)
import Ports
import Processing exposing (ProcessStore)
import Time exposing (Time)
import Util as U exposing ((=>))
import Views.Form as Form
import Views.PregnancyHeader as PregHeaderView exposing (PregHeaderContent(..))


-- MODEL --


type LaborState
    = NotStartedLaborState
    | AdmittingLaborState
    | AdmittedLaborState LaborId
    | EndedLaborState LaborId


type DateTimeModal
    = NoDateTimeModal
    | Stage1DateTimeModal
    | Stage2DateTimeModal
    | Stage3DateTimeModal


type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , pregnancy_id : PregnancyId
    , currPregHeaderContent : PregHeaderContent
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    , laborRecord : Maybe (List LaborRecord)
    , laborState : LaborState
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
    , stage1Modal : DateTimeModal
    , stage1Date : Maybe Date
    , stage1Time : Maybe String
    , stage2Modal : DateTimeModal
    , stage2Date : Maybe Date
    , stage2Time : Maybe String
    , stage3Modal : DateTimeModal
    , stage3Date : Maybe Date
    , stage3Time : Maybe String
    }


buildModel : Bool -> Time -> PregnancyId -> Maybe PatientRecord -> Maybe PregnancyRecord -> Maybe (List LaborRecord) -> Model
buildModel browserSupportsDate currTime pregId patrec pregRec laborRecs =
    let
        -- Sort by the admittanceDate, descending.
        admitSort a b =
            U.sortDate U.DescendingSort a.admittanceDate b.admittanceDate

        -- Determine state of the labor by labor records, if any.
        laborState =
            case laborRecs of
                Just recs ->
                    case
                        List.sortWith admitSort recs
                            |> List.head
                    of
                        Just rec ->
                            if rec.endLaborDate == Nothing then
                                AdmittedLaborState (LaborId rec.id)
                            else if rec.falseLabor then
                                NotStartedLaborState
                            else
                                EndedLaborState (LaborId rec.id)

                        Nothing ->
                            NotStartedLaborState

                Nothing ->
                    NotStartedLaborState

        pregHeaderContent =
            case laborState of
                NotStartedLaborState ->
                    PrenatalContent

                AdmittingLaborState ->
                    PrenatalContent

                AdmittedLaborState id ->
                    LaborContent

                EndedLaborState id ->
                    IPPContent

        _ =
            Debug.log "laborState" <| toString laborState
    in
        Model browserSupportsDate
            currTime
            pregId
            pregHeaderContent
            patrec
            pregRec
            laborRecs
            laborState
            Nothing
            Nothing
            Nothing
            Nothing
            Nothing
            Nothing
            Nothing
            Nothing
            Nothing
            Nothing
            Nothing
            Nothing
            []
            NoDateTimeModal
            Nothing
            Nothing
            NoDateTimeModal
            Nothing
            Nothing
            NoDateTimeModal
            Nothing
            Nothing


init : PregnancyId -> Session -> ProcessStore -> ( ProcessStore, Cmd Msg )
init pregId session store =
    let
        selectQuery =
            SelectQuery Pregnancy (Just (getPregId pregId)) [ Patient, Labor ]

        ( processId, processStore ) =
            Processing.add (SelectQueryType (LaborDelIppLoaded pregId) selectQuery) Nothing store

        msg =
            wrapPayload processId SelectMsgType (selectQueryToValue selectQuery)
    in
        processStore
            => Ports.outgoing msg


view : Maybe Window.Size -> Session -> Model -> Html SubMsg
view size session model =
    let
        -- Ascertain whether we have a labor in process already.
        pregHeader =
            case ( model.patientRecord, model.pregnancyRecord ) of
                ( Just patRec, Just pregRec ) ->
                    PregHeaderView.view patRec pregRec model.laborRecord model.currPregHeaderContent model.currTime size

                ( _, _ ) ->
                    H.text ""

        views =
            case model.laborState of
                NotStartedLaborState ->
                    [ viewAdmitButton
                    , viewLaborRecords model
                    ]

                AdmittingLaborState ->
                    [ viewAdmitForm model ]

                AdmittedLaborState id ->
                    -- TODO: Show labor details.
                    [ viewLaborDetails model ]

                EndedLaborState id ->
                    -- We allow a new labor and any past labors.
                    [ viewAdmitButton
                    , viewLaborRecords model
                    ]
    in
        H.div []
            [ pregHeader
            , H.div [ HA.class "content-wrapper" ] views
            ]


viewAdmitForm : Model -> Html SubMsg
viewAdmitForm model =
    H.div []
        [ H.h3 [ HA.class "c-text--brand mw-header-3" ] [ H.text "Admittance Details" ]
        , H.div []
            [ H.div [ HA.class "" ] [ Form.formErrors model.formErrors ]
            , H.div [ HA.class "o-fieldset form-wrapper" ]
                [ if model.browserSupportsDate then
                    Form.formFieldDate (FldChgSubMsg AdmittanceDateFld)
                        "Date admitted"
                        "e.g. 08/14/2017"
                        model.admittanceDate
                  else
                    Form.formFieldDatePicker OpenDatePickerSubMsg
                        LaborDelIppAdmittanceDateField
                        "Date admitted"
                        "e.g. 08/14/2017"
                        model.admittanceDate
                , Form.formField (FldChgSubMsg AdmittanceTimeFld) "Time admitted" "24 hr format, 14:44" model.admittanceTime
                , if model.browserSupportsDate then
                    Form.formFieldDate (FldChgSubMsg LaborDateFld)
                        "Date start of labor"
                        "e.g. 08/14/2017"
                        model.laborDate
                  else
                    Form.formFieldDatePicker OpenDatePickerSubMsg
                        LaborDelIppLaborDateField
                        "Date start of labor"
                        "e.g. 08/14/2017"
                        model.laborDate
                , Form.formField (FldChgSubMsg LaborTimeFld) "Time start of labor" "24 hr format, 09:00" model.laborTime
                , Form.formField (FldChgSubMsg PosFld) "POS" "pos" model.pos
                , Form.formField (FldChgSubMsg FhFld) "FH" "fh" model.fh
                , Form.formField (FldChgSubMsg FhtFld) "FHT" "fht" model.fht
                , Form.formField (FldChgSubMsg SystolicFld) "Systolic" "systolic" model.systolic
                , Form.formField (FldChgSubMsg DiastolicFld) "Diastolic" "diastolic" model.diastolic
                , Form.formField (FldChgSubMsg CrFld) "CR" "heart rate" model.cr
                , Form.formField (FldChgSubMsg TempFld) "Temp" "temperature" model.temp
                , Form.formTextareaField (FldChgSubMsg CommentsFld) "Comments" 3
                ]
            , if List.length model.formErrors > 0 then
                H.div
                    [ HA.class "u-small error-msg-right primary-fg"
                    ]
                    [ H.text "Errors detected, see details above." ]
              else
                H.span [] []
            , H.div [ HA.class "form-wrapper-end" ]
                [ Form.cancelSaveButtons CancelAdmitForLabor SaveAdmitForLabor
                ]
            ]
        ]


viewAdmitButton : Html SubMsg
viewAdmitButton =
    H.button
        [ HA.class "c-button c-button--brand u-xlarge"
        , HE.onClick AdmitForLabor
        ]
        [ H.text "Admit for Labor" ]


viewLaborDetails : Model -> Html SubMsg
viewLaborDetails model =
    H.div [ HA.class "content-flex-wrapper" ]
        [ H.div [ HA.class "c-tabs" ]
            [ H.div [ HA.class "c-tabs__headings" ]
                [ H.div [ HA.class "c-tab-heading c-tab-heading--active" ]
                    [ H.text "Labor" ]
                , H.div [ HA.class "c-tab-heading" ]
                    [ H.text "IPP" ]
                ]
            ]
        , viewStages model
        ]


viewStages : Model -> Html SubMsg
viewStages model =
    let
        displayDateTime dateFld timeFld =
            case ( dateFld, timeFld ) of
                ( Just d, Just t ) ->
                    case U.stringToTimeTuple t of
                        Just ( h, m ) ->
                            U.datePlusTimeTuple d ( h, m )
                                |> U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep

                        Nothing ->
                            "Click to set"

                ( _, _ ) ->
                    "Click to set"
    in
        H.div [ HA.class "stage-wrapper" ]
            [ H.div [ HA.class "stage-content" ]
                [ H.div [ HA.class "c-text--brand c-text--loud" ]
                    [ H.text "Stage 1" ]
                , H.div []
                    [ H.label [ HA.class "c-field c-field--choice c-field-minPadding" ]
                        [ H.button
                            [ HA.class "c-button c-button--ghost-brand u-small"
                            , HE.onClick HandleStage1DateTimeModal
                            ]
                            [ H.text <| displayDateTime model.stage1Date model.stage1Time ]
                        , if model.browserSupportsDate then
                            Form.dateTimeModal (model.stage1Modal == Stage1DateTimeModal)
                                "Stage 1 Date/Time"
                                (FldChgSubMsg Stage1DateFld)
                                (FldChgSubMsg Stage1TimeFld)
                                HandleStage1DateTimeModal
                                ClearStage1DateTime
                                model.stage1Date
                                model.stage1Time
                          else
                            Form.dateTimePickerModal (model.stage1Modal == Stage1DateTimeModal)
                                "Stage 1 Date/Time"
                                OpenDatePickerSubMsg
                                (FldChgSubMsg Stage1DateFld)
                                (FldChgSubMsg Stage1TimeFld)
                                HandleStage1DateTimeModal
                                ClearStage1DateTime
                                model.stage1Date
                                model.stage1Time
                        ]
                    ]
                , H.div []
                    [ H.button
                        [ HA.class "c-button c-button--ghost-brand u-small"
                        ]
                        [ H.text "Summary" ]
                    ]
                ]
            , H.div [ HA.class "stage-content" ]
                [ H.div [ HA.class "c-text--brand c-text--loud" ]
                    [ H.text "Stage 2" ]
                , H.div []
                    [ H.label [ HA.class "c-field c-field--choice c-field-minPadding" ]
                        [ H.button
                            [ HA.class "c-button c-button--ghost-brand u-small"
                            , HE.onClick HandleStage2DateTimeModal
                            ]
                            [ H.text <| displayDateTime model.stage2Date model.stage2Time ]
                        , if model.browserSupportsDate then
                            Form.dateTimeModal (model.stage2Modal == Stage2DateTimeModal)
                                "Stage 2 Date/Time"
                                (FldChgSubMsg Stage2DateFld)
                                (FldChgSubMsg Stage2TimeFld)
                                HandleStage2DateTimeModal
                                ClearStage2DateTime
                                model.stage2Date
                                model.stage2Time
                          else
                            Form.dateTimePickerModal (model.stage2Modal == Stage2DateTimeModal)
                                "Stage 2 Date/Time"
                                OpenDatePickerSubMsg
                                (FldChgSubMsg Stage2DateFld)
                                (FldChgSubMsg Stage2TimeFld)
                                HandleStage2DateTimeModal
                                ClearStage2DateTime
                                model.stage2Date
                                model.stage2Time
                        ]
                    ]
                , H.div []
                    [ H.button
                        [ HA.class "c-button c-button--ghost-brand u-small"
                        ]
                        [ H.text "Summary" ]
                    ]
                ]
            , H.div [ HA.class "stage-content" ]
                [ H.div [ HA.class "c-text--brand c-text--loud" ]
                    [ H.text "Stage 3" ]
                , H.div []
                    [ H.label [ HA.class "c-field c-field--choice c-field-minPadding" ]
                        [ H.button
                            [ HA.class "c-button c-button--ghost-brand u-small"
                            , HE.onClick HandleStage3DateTimeModal
                            ]
                            [ H.text <| displayDateTime model.stage3Date model.stage3Time ]
                        , if model.browserSupportsDate then
                            Form.dateTimeModal (model.stage3Modal == Stage3DateTimeModal)
                                "Stage 3 Date/Time"
                                (FldChgSubMsg Stage3DateFld)
                                (FldChgSubMsg Stage3TimeFld)
                                HandleStage3DateTimeModal
                                ClearStage3DateTime
                                model.stage3Date
                                model.stage3Time
                          else
                            Form.dateTimePickerModal (model.stage3Modal == Stage3DateTimeModal)
                                "Stage 3 Date/Time"
                                OpenDatePickerSubMsg
                                (FldChgSubMsg Stage3DateFld)
                                (FldChgSubMsg Stage3TimeFld)
                                HandleStage3DateTimeModal
                                ClearStage3DateTime
                                model.stage3Date
                                model.stage3Time
                        ]
                    ]
                , H.div []
                    [ H.button
                        [ HA.class "c-button c-button--ghost-brand u-small"
                        ]
                        [ H.text "Summary" ]
                    ]
                ]
              -- TODO: pull the following into the second stage summary??
              --, H.div [ HA.class "stage-content" ]
              --[ H.div [ HA.class "c-text--brand c-text--loud" ]
              --[ H.text "Stuff" ]
              --, H.div
              --[ HA.class "o-form-element"
              --, HA.style [ ("padding-top", "0") ]
              --]
              --[ H.div
              --[ HA.class "o-field"
              --]
              --[ H.label
              --[ HA.class "c-field c-field--choice c-field-minPadding"
              --, HA.for "eblbirth"
              --]
              --[ H.text "EBL @ birth" ]
              --, H.input
              --[ HA.class "c-field u-small c-field-minPadding"
              --, HA.id "eblbirth"
              --, HA.style [ ("width", "50%") ]
              --]
              --[]
              --]
              --]
              --]
            ]


{-| Show current admitting labor record and any historical
"false" labor records.
-}
viewLaborRecords : Model -> Html SubMsg
viewLaborRecords model =
    let
        showDate date =
            U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep date

        makeRow rec =
            H.tr [ HA.class "c-table__row c-table__row--clickable" ]
                [ H.td [ HA.class "c-table__cell" ]
                    [ H.text <| showDate rec.startLaborDate ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text <| showDate rec.admittanceDate ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text <|
                        case rec.endLaborDate of
                            Just d ->
                                showDate d

                            Nothing ->
                                ""
                    ]
                ]
    in
        case model.laborRecord of
            Just laborRecs ->
                if List.length laborRecs > 0 then
                    H.div []
                        [ H.h2 [ HA.class "c-heading" ]
                            [ H.text "Admitting Details" ]
                        , H.table [ HA.class "c-table c-table--condensed" ]
                            [ H.thead [ HA.class "c-table__head" ]
                                [ H.tr [ HA.class "c-table__row c-table__row--heading" ]
                                    [ H.th [ HA.class "c-table__cell" ]
                                        [ H.text "Labor" ]
                                    , H.th [ HA.class "c-table__cell" ]
                                        [ H.text "Admitted" ]
                                    , H.th [ HA.class "c-table__cell" ]
                                        [ H.text "False Labor" ]
                                    ]
                                ]
                            , H.tbody [ HA.class "c-table__body" ] <|
                                List.map makeRow
                                    (List.sortBy
                                        (\rec -> negate <| Date.toTime rec.admittanceDate)
                                        laborRecs
                                    )
                            ]
                        ]
                else
                    H.div [] [ H.text "" ]

            Nothing ->
                H.div [] [ H.text "" ]



-- UPDATE --


update : Session -> SubMsg -> Model -> ( Model, Cmd SubMsg, Cmd Msg )
update session msg model =
    case msg of
        PageNoop ->
            let
                _ =
                    Debug.log "PageNoop" "was called."
            in
                ( model, Cmd.none, Cmd.none )

        TickSubMsg time ->
            -- Keep the current time in the Model.
            ( { model | currTime = time }, Cmd.none, Cmd.none )

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
                    | laborState = AdmittingLaborState
                    , admittanceDate = admittanceDate
                  }
                , Cmd.none
                , Cmd.none
                )

        AdmitForLaborSaved laborRecNew lid ->
            -- The server returned the result of our request to add a new labor record.
            let
                _ =
                    Debug.log "AdmitForLaborSaved" <| toString laborRecNew

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
                            | laborState = AdmittedLaborState (LaborId nlr.id)
                            , laborRecord = U.addToMaybeList nlr model.laborRecord
                            , currPregHeaderContent = LaborContent
                        }

                    Nothing ->
                        model
                , Cmd.none
                , Cmd.none
                )

        CancelAdmitForLabor ->
            -- The user canceled the add labor form.
            ( { model
                | laborState = NotStartedLaborState
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

        SaveAdmitForLabor ->
            -- The user submitted a new labor record to the server.
            case validate model of
                [] ->
                    let
                        newOuterMsg =
                            case deriveLaborRecordNew model of
                                Just laborRecNew ->
                                    ProcessTypeMsg
                                        (AddLaborType
                                            (LaborDelIppMsg
                                                (AdmitForLaborSaved laborRecNew Nothing)
                                            )
                                            laborRecNew
                                        )
                                        AddMsgType
                                        (laborRecordNewToValue laborRecNew)

                                Nothing ->
                                    Noop
                    in
                        ( { model | formErrors = [] }
                        , Cmd.none
                        , Task.perform (always newOuterMsg) (Task.succeed True)
                        )

                errors ->
                    -- Add errors to model for user to address before submission.
                    ( { model | formErrors = errors }
                    , Cmd.none
                    , logConsole (toString errors)
                    )

        OpenDatePickerSubMsg id ->
            ( model, Cmd.none, Task.perform OpenDatePicker (Task.succeed id) )

        DateFieldSubMsg dateFldMsg ->
            -- For browsers that do not support a native date field.
            case dateFldMsg of
                DateFieldMessage { dateField, date } ->
                    case dateField of
                        LaborDelIppAdmittanceDateField ->
                            ( { model | admittanceDate = Just date }, Cmd.none, Cmd.none )

                        LaborDelIppLaborDateField ->
                            ( { model | laborDate = Just date }, Cmd.none, Cmd.none )

                        LaborDelIppStage1DateField ->
                            ( { model | stage1Date = Just date }, Cmd.none, Cmd.none )

                        LaborDelIppStage2DateField ->
                            ( { model | stage2Date = Just date }, Cmd.none, Cmd.none )

                        LaborDelIppStage3DateField ->
                            ( { model | stage3Date = Just date }, Cmd.none, Cmd.none )

                        UnknownDateField str ->
                            ( model, Cmd.none, logConsole str )

                UnknownDateFieldMessage str ->
                    ( model, Cmd.none, Cmd.none )

        FldChgSubMsg fld value ->
            -- All fields are handled here except for the date fields for browsers that
            -- do not support the input date type (see DateFieldSubMsg for those).
            ( case fld of
                AdmittanceDateFld ->
                    { model | admittanceDate = Date.fromString value |> Result.toMaybe }

                AdmittanceTimeFld ->
                    { model | admittanceTime = Just <| U.filterStringLikeTime value }

                LaborDateFld ->
                    { model | laborDate = Date.fromString value |> Result.toMaybe }

                LaborTimeFld ->
                    { model | laborTime = Just <| U.filterStringLikeTime value }

                PosFld ->
                    { model | pos = Just value }

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

                Stage1DateFld ->
                    { model | stage1Date = Date.fromString value |> Result.toMaybe }

                Stage1TimeFld ->
                    { model | stage1Time = Just <| U.filterStringLikeTime value }

                Stage2DateFld ->
                    { model | stage2Date = Date.fromString value |> Result.toMaybe }

                Stage2TimeFld ->
                    { model | stage2Time = Just <| U.filterStringLikeTime value }

                Stage3DateFld ->
                    { model | stage3Date = Date.fromString value |> Result.toMaybe }

                Stage3TimeFld ->
                    { model | stage3Time = Just <| U.filterStringLikeTime value }
            , Cmd.none
            , Cmd.none
            )

        NextPregHeaderContent ->
            let
                next =
                    case model.currPregHeaderContent of
                        PrenatalContent ->
                            LaborContent

                        LaborContent ->
                            IPPContent

                        IPPContent ->
                            PrenatalContent
            in
                ( { model | currPregHeaderContent = next }, Cmd.none, Cmd.none )

        HandleStage1DateTimeModal ->
            -- The user has just opened the modal to set the date/time for stage 1
            -- completion. We default to the current date/time for convenience if
            -- this is an open event, but only if the date/time has not already
            -- been previously selected.
            let
                ( s1d, s1t ) =
                    case model.stage1Modal == NoDateTimeModal of
                        True ->
                            case ( model.stage1Date, model.stage1Time ) of
                                ( Nothing, Nothing ) ->
                                    ( Just <| Date.fromTime model.currTime
                                    , Just <| U.timeToTimeString model.currTime
                                    )

                                ( _, _ ) ->
                                    ( model.stage1Date, model.stage1Time )

                        False ->
                            ( model.stage1Date, model.stage1Time )
            in
                ( { model
                    | stage1Modal =
                        if model.stage1Modal == NoDateTimeModal then
                            Stage1DateTimeModal
                        else
                            NoDateTimeModal
                    , stage1Date = s1d
                    , stage1Time = s1t
                  }
                , Cmd.none
                , Cmd.none
                )

        HandleStage2DateTimeModal ->
            -- The user has just opened the modal to set the date/time for stage 2
            -- completion. We default to the current date/time for convenience if
            -- this is an open event, but only if the date/time has not already
            -- been previously selected.
            let
                ( s2d, s2t ) =
                    case model.stage2Modal == NoDateTimeModal of
                        True ->
                            case ( model.stage2Date, model.stage2Time ) of
                                ( Nothing, Nothing ) ->
                                    ( Just <| Date.fromTime model.currTime
                                    , Just <| U.timeToTimeString model.currTime
                                    )

                                ( _, _ ) ->
                                    ( model.stage2Date, model.stage2Time )

                        False ->
                            ( model.stage2Date, model.stage2Time )
            in
                ( { model
                    | stage2Modal =
                        if model.stage2Modal == NoDateTimeModal then
                            Stage2DateTimeModal
                        else
                            NoDateTimeModal
                    , stage2Date = s2d
                    , stage2Time = s2t
                  }
                , Cmd.none
                , Cmd.none
                )

        HandleStage3DateTimeModal ->
            -- The user has just opened the modal to set the date/time for stage 3
            -- completion. We default to the current date/time for convenience if
            -- this is an open event, but only if the date/time has not already
            -- been previously selected.
            let
                ( s3d, s3t ) =
                    case model.stage3Modal == NoDateTimeModal of
                        True ->
                            case ( model.stage3Date, model.stage3Time ) of
                                ( Nothing, Nothing ) ->
                                    ( Just <| Date.fromTime model.currTime
                                    , Just <| U.timeToTimeString model.currTime
                                    )

                                ( _, _ ) ->
                                    ( model.stage3Date, model.stage3Time )

                        False ->
                            ( model.stage3Date, model.stage3Time )
            in
                ( { model
                    | stage3Modal =
                        if model.stage3Modal == NoDateTimeModal then
                            Stage3DateTimeModal
                        else
                            NoDateTimeModal
                    , stage3Date = s3d
                    , stage3Time = s3t
                  }
                , Cmd.none
                , Cmd.none
                )

        ClearStage1DateTime ->
            ( { model
                | stage1Date = Nothing
                , stage1Time = Nothing
              }
            , Cmd.none
            , Cmd.none
            )

        ClearStage2DateTime ->
            ( { model
                | stage2Date = Nothing
                , stage2Time = Nothing
              }
            , Cmd.none
            , Cmd.none
            )

        ClearStage3DateTime ->
            ( { model
                | stage3Date = Nothing
                , stage3Time = Nothing
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
        , ( (U.maybeStringToMaybeInt model.fht)
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



-- VALIDATION --


type Field
    = AdmittanceDateField
    | AdmittanceTimeField
    | LaborDateField
    | LaborTimeField
    | PosField
    | FhField
    | FhtField
    | SystolicField
    | DiastolicField
    | CrField
    | TempField
    | CommentsField


type alias FieldError =
    ( Field, String )


validate : Model -> List FieldError
validate =
    Validate.all
        [ .admittanceDate >> ifInvalid U.validateDate (AdmittanceDateField => "Date of admittance must be provided.")
        , .admittanceTime >> ifInvalid U.validateTime (AdmittanceTimeField => "Admitting time must be provided, ex: hh:mm.")
        , .laborDate >> ifInvalid U.validateDate (LaborDateField => "Date of the start of labor must be provided.")
        , .laborTime >> ifInvalid U.validateTime (LaborTimeField => "Start of labor time must be provided, ex: hh:mm.")
        , .pos >> ifInvalid U.validatePopulatedString (PosField => "POS must be provided.")
        , .fh >> ifInvalid U.validateInt (FhField => "FH must be provided.")
        , .fht >> ifInvalid U.validateInt (FhtField => "FHT must be provided.")
        , .systolic >> ifInvalid U.validateInt (SystolicField => "Systolic must be provided.")
        , .diastolic >> ifInvalid U.validateInt (DiastolicField => "Diastolic must be provided.")
        , .cr >> ifInvalid U.validateInt (CrField => "CR must be provided.")
        , .temp >> ifInvalid U.validateFloat (TempField => "Temp must be provided.")
        ]
