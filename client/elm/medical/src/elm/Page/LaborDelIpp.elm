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
import Dict exposing (Dict)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import List.Extra as LE
import Task exposing (Task)
import Time exposing (Time)
import Validate exposing (ifBlank, ifInvalid, ifNotInt)
import Window


-- LOCAL IMPORTS --

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
        )
import Data.LaborStage1
    exposing
        ( laborStage1RecordNewToLaborStage1Record
        , laborStage1RecordToValue
        , laborStage1RecordNewToValue
        , LaborStage1Id(..)
        , LaborStage1Record
        , LaborStage1RecordNew
        )
import Data.LaborDelIpp exposing (Dialog(..), Field(..), SubMsg(..))
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


type StageSummaryModal
    = NoStageSummaryModal
    | Stage1SummaryViewModal
    | Stage1SummaryEditModal
    | Stage2SummaryModal
    | Stage3SummaryModal


type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , pregnancy_id : PregnancyId
    , currPregHeaderContent : PregHeaderContent
    , dataCache : Dict String DataCache
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    , laborRecord : Maybe (List LaborRecord)
    , laborStage1Record : Maybe LaborStage1Record
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
    , stage1DateTimeModal : DateTimeModal
    , stage1Date : Maybe Date
    , stage1Time : Maybe String
    , stage1SummaryModal : StageSummaryModal
    , s1Mobility : Maybe String
    , s1DurationLatent : Maybe String
    , s1DurationActive : Maybe String
    , s1Comments : Maybe String
    , stage2DateTimeModal : DateTimeModal
    , stage2Date : Maybe Date
    , stage2Time : Maybe String
    , stage3DateTimeModal : DateTimeModal
    , stage3Date : Maybe Date
    , stage3Time : Maybe String
    }


buildModel : Bool -> Time -> ProcessStore -> PregnancyId -> Maybe PatientRecord -> Maybe PregnancyRecord -> Maybe (List LaborRecord) -> ( Model, ProcessStore, Cmd Msg )
buildModel browserSupportsDate currTime store pregId patrec pregRec laborRecs =
    let
        -- Sort by the admittanceDate, descending.
        admitSort a b =
            U.sortDate U.DescendingSort a.admittanceDate b.admittanceDate

        -- Determine state of the labor by labor records, if any, and
        -- request additional records from the server if needed.
        ( laborState, ( newStore, newOuterMsg ) ) =
            case laborRecs of
                Just recs ->
                    case
                        List.sortWith admitSort recs
                            |> List.head
                    of
                        Just rec ->
                            if rec.endLaborDate == Nothing then
                                ( AdmittedLaborState (LaborId rec.id)
                                , getLaborDetails (LaborId rec.id) store
                                )
                            else if rec.falseLabor then
                                ( NotStartedLaborState, ( store, Cmd.none ) )
                            else
                                ( EndedLaborState (LaborId rec.id)
                                , getLaborDetails (LaborId rec.id) store
                                )

                        Nothing ->
                            ( NotStartedLaborState, ( store, Cmd.none ) )

                Nothing ->
                    ( NotStartedLaborState, ( store, Cmd.none ) )

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
    in
        ( Model browserSupportsDate
            currTime
            pregId
            pregHeaderContent
            Dict.empty
            patrec
            pregRec
            laborRecs
            Nothing
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
            NoStageSummaryModal
            Nothing
            Nothing
            Nothing
            Nothing
            NoDateTimeModal
            Nothing
            Nothing
            NoDateTimeModal
            Nothing
            Nothing
        , newStore
        , newOuterMsg
        )


{-| Request all of the labor details records from the server. This module
will receive data via the DataCache SubMsg where we specify which tables
we are interested in obtaining.
-}
getLaborDetails : LaborId -> ProcessStore -> ( ProcessStore, Cmd Msg )
getLaborDetails lid store =
    let
        selectQuery =
            SelectQuery Labor (Just (getLaborId lid)) [ LaborStage1 ]

        ( processId, processStore ) =
            Processing.add
                (SelectQueryType
                    (LaborDelIppMsg
                        (DataCache Nothing
                            (Just [ LaborStage1 ])
                        )
                    )
                    selectQuery
                )
                Nothing
                store

        msg =
            wrapPayload processId SelectMsgType (selectQueryToValue selectQuery)
    in
        processStore
            => Ports.outgoing msg


{-| On initialization, the Model will be updated by a call to buildModel once
the initial data has arrived from the server. Hence, the SubMsg does not need
to be DataCache, which is used subsequent to first page load.
-}
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
                    -- TODO: Show labor details as well as means to end labor.
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
                , Form.formTextareaField (FldChgSubMsg CommentsFld) "Comments" model.comments 3
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


{-| Determine if the summary fields of stage one
are sufficiently populated. Note that this does not
include the fullDialation field.
-}
isStage1SummaryDone : Model -> Bool
isStage1SummaryDone model =
    case model.laborStage1Record of
        Just rec ->
            case
                ( rec.mobility
                , rec.durationLatent
                , rec.durationActive
                )
            of
                ( Just _, Just _, Just _ ) ->
                    True

                ( _, _, _ ) ->
                    False

        Nothing ->
            False


viewStages : Model -> Html SubMsg
viewStages model =
    let
        isEditing =
            if model.stage1SummaryModal == Stage1SummaryEditModal then
                True
            else
                not (isStage1SummaryDone model)

        dialogStage1Config =
            DialogStage1Summary
                (model.stage1SummaryModal
                    == Stage1SummaryViewModal
                    || model.stage1SummaryModal
                    == Stage1SummaryEditModal
                )
                isEditing
                "Stage 1 Summary"
                model
                (HandleStage1SummaryModal CloseNoSaveDialog)
                (HandleStage1SummaryModal CloseSaveDialog)
                (HandleStage1SummaryModal EditDialog)
                (FldChgSubMsg Stage1MobilityFld)
    in
        H.div [ HA.class "stage-wrapper" ]
            [ H.div [ HA.class "stage-content" ]
                [ H.div [ HA.class "c-text--brand c-text--loud" ]
                    [ H.text "Stage 1" ]
                , H.div []
                    [ H.label [ HA.class "c-field c-field--choice c-field-minPadding" ]
                        [ H.button
                            [ HA.class "c-button c-button--ghost-brand u-small"
                            , HE.onClick <| HandleStage1DateTimeModal OpenDialog
                            ]
                            [ H.text <|
                                case model.laborStage1Record of
                                    Just ls1rec ->
                                        case ls1rec.fullDialation of
                                            Just d ->
                                                U.dateTimeHMFormatter
                                                    U.MDYDateFmt
                                                    U.DashDateSep
                                                    d

                                            Nothing ->
                                                "Click to set"

                                    Nothing ->
                                        "Click to set"
                            ]
                        , if model.browserSupportsDate then
                            Form.dateTimeModal (model.stage1DateTimeModal == Stage1DateTimeModal)
                                "Stage 1 Date/Time"
                                (FldChgSubMsg Stage1DateFld)
                                (FldChgSubMsg Stage1TimeFld)
                                (HandleStage1DateTimeModal CloseNoSaveDialog)
                                (HandleStage1DateTimeModal CloseSaveDialog)
                                ClearStage1DateTime
                                model.stage1Date
                                model.stage1Time
                          else
                            Form.dateTimePickerModal (model.stage1DateTimeModal == Stage1DateTimeModal)
                                "Stage 1 Date/Time"
                                OpenDatePickerSubMsg
                                (FldChgSubMsg Stage1DateFld)
                                (FldChgSubMsg Stage1TimeFld)
                                (HandleStage1DateTimeModal CloseNoSaveDialog)
                                (HandleStage1DateTimeModal CloseSaveDialog)
                                ClearStage1DateTime
                                model.stage1Date
                                model.stage1Time
                        ]
                    ]
                , H.div []
                    [ H.button
                        [ HA.class "c-button c-button--ghost-brand u-small"
                        , HE.onClick <| HandleStage1SummaryModal OpenDialog
                        ]
                        [ if isStage1SummaryDone model then
                            H.i [ HA.class "fa fa-check" ]
                                [ H.text "" ]
                          else
                            H.span [] [ H.text "" ]
                        , H.text " Summary"
                        ]
                    , dialogStage1Summary dialogStage1Config
                    ]
                ]
            , H.div [ HA.class "stage-content" ]
                [ H.div [ HA.class "c-text--brand c-text--loud" ]
                    [ H.text "Stage 2" ]
                , H.div []
                    [ H.label [ HA.class "c-field c-field--choice c-field-minPadding" ]
                        [ H.button
                            [ HA.class "c-button c-button--ghost-brand u-small"
                            , HE.onClick <| HandleStage2DateTimeModal OpenDialog
                            ]
                            [ H.text <| "Not implemented" ]
                        , if model.browserSupportsDate then
                            Form.dateTimeModal (model.stage2DateTimeModal == Stage2DateTimeModal)
                                "Stage 2 Date/Time"
                                (FldChgSubMsg Stage2DateFld)
                                (FldChgSubMsg Stage2TimeFld)
                                (HandleStage2DateTimeModal CloseNoSaveDialog)
                                (HandleStage2DateTimeModal CloseSaveDialog)
                                ClearStage2DateTime
                                model.stage2Date
                                model.stage2Time
                          else
                            Form.dateTimePickerModal (model.stage2DateTimeModal == Stage2DateTimeModal)
                                "Stage 2 Date/Time"
                                OpenDatePickerSubMsg
                                (FldChgSubMsg Stage2DateFld)
                                (FldChgSubMsg Stage2TimeFld)
                                (HandleStage2DateTimeModal CloseNoSaveDialog)
                                (HandleStage2DateTimeModal CloseSaveDialog)
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
                            , HE.onClick <| HandleStage3DateTimeModal OpenDialog
                            ]
                            [ H.text <| "Not Implemented" ]
                        , if model.browserSupportsDate then
                            Form.dateTimeModal (model.stage3DateTimeModal == Stage3DateTimeModal)
                                "Stage 3 Date/Time"
                                (FldChgSubMsg Stage3DateFld)
                                (FldChgSubMsg Stage3TimeFld)
                                (HandleStage3DateTimeModal CloseNoSaveDialog)
                                (HandleStage3DateTimeModal CloseSaveDialog)
                                ClearStage3DateTime
                                model.stage3Date
                                model.stage3Time
                          else
                            Form.dateTimePickerModal (model.stage3DateTimeModal == Stage3DateTimeModal)
                                "Stage 3 Date/Time"
                                OpenDatePickerSubMsg
                                (FldChgSubMsg Stage3DateFld)
                                (FldChgSubMsg Stage3TimeFld)
                                (HandleStage3DateTimeModal CloseNoSaveDialog)
                                (HandleStage3DateTimeModal CloseSaveDialog)
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


type alias DialogStage1Summary =
    { isShown : Bool
    , isEditing : Bool
    , title : String
    , model : Model
    , closeMsg : SubMsg
    , saveMsg : SubMsg
    , editMsg : SubMsg
    , mobilityMsg : String -> SubMsg
    }


dialogStage1Summary : DialogStage1Summary -> Html SubMsg
dialogStage1Summary cfg =
    case cfg.isEditing of
        True ->
            -- We display the form for editing by default.
            dialogStage1SummaryEdit cfg

        False ->
            -- We display the summary results in a more concise form if not editing.
            dialogStage1SummaryView cfg


{-| Allow user to edit stage one summary fields.
-}
dialogStage1SummaryEdit : DialogStage1Summary -> Html SubMsg
dialogStage1SummaryEdit cfg =
    H.div [ HA.classList [ ( "c-overlay c-overlay--transparent", cfg.isShown ) ] ]
        [ H.div
            [ HA.class "o-modal"
            , HA.classList [ ( "isHidden", not cfg.isShown && cfg.isEditing ) ]
            ]
            [ H.div [ HA.class "c-card" ]
                [ H.div [ HA.class "c-card__header accent-bg accent-contrast-fg" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--close"
                        , HE.onClick cfg.closeMsg
                        ]
                        [ H.text "x" ]
                    , H.h4 [ HA.class "c-heading" ]
                        [ H.text cfg.title ]
                    ]
                , H.div
                    [ HA.class "c-card__body o-panel"
                    , HA.style
                        -- Need to restrict the body in order for the panel to work.
                        [ ( "height", "230px" )
                        , ( "max-height", "230px" )
                        ]
                    ]
                    [ H.div
                        [ HA.class "o-fieldset form-wrapper"
                          -- BlazeCSS fieldset has too much margin at top for modal.
                        , HA.style [ ( "margin-top", "0" ) ]
                        ]
                        [ H.fieldset [ HA.class "o-fieldset mw-form-field-2x" ]
                            [ H.legend [ HA.class "o-fieldset__legend" ]
                                [ H.span [ HA.class "c-text--loud" ]
                                    [ H.text "Mobility" ]
                                ]
                            , Form.radio
                                ( "Moved around", "mobility", (FldChgSubMsg Stage1MobilityFld), cfg.model.s1Mobility )
                            , Form.radio
                                ( "Didn't move much", "mobility", (FldChgSubMsg Stage1MobilityFld), cfg.model.s1Mobility )
                            , Form.radio
                                ( "Movement restricted", "mobility", (FldChgSubMsg Stage1MobilityFld), cfg.model.s1Mobility )
                            ]
                        , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                            [ Form.formField (FldChgSubMsg Stage1DurationLatentFld)
                                "Duration latent"
                                "Number of minutes"
                                cfg.model.s1DurationLatent
                            , Form.formField (FldChgSubMsg Stage1DurationActiveFld)
                                "Duration active"
                                "Number of minutes"
                                cfg.model.s1DurationActive
                            ]
                        , Form.formTextareaField (FldChgSubMsg Stage1CommentsFld)
                            "Comments"
                            cfg.model.s1Comments
                            3
                        ]
                    ]
                , H.div [ HA.class "c-card__footer modalButtons accent-bg accent-contrast-fg" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button u-small"
                        , HE.onClick cfg.closeMsg
                        ]
                        [ H.text "Cancel" ]
                    , H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--brand"
                        , HE.onClick cfg.saveMsg
                        ]
                        [ H.text "Save" ]
                    ]
                ]
            ]
        ]


{-| Display the stage one summary, including the first stage total,
if available.
-}
dialogStage1SummaryView : DialogStage1Summary -> Html SubMsg
dialogStage1SummaryView cfg =
    let
        ( mobility, latent, active, comments, s1Total ) =
            case cfg.model.laborStage1Record of
                Just rec ->
                    ( Maybe.withDefault "" rec.mobility
                    , Maybe.map toString rec.durationLatent
                        |> Maybe.withDefault ""
                    , Maybe.map toString rec.durationActive
                        |> Maybe.withDefault ""
                    , Maybe.withDefault "" rec.comments
                    , case rec.fullDialation of
                        Just fd ->
                            case cfg.model.laborRecord of
                                Just lrecs ->
                                    case LE.find (\r -> r.id == rec.labor_id) lrecs of
                                        Just laborRec ->
                                            U.diff2DatesString laborRec.startLaborDate fd

                                        Nothing ->
                                            ""

                                Nothing ->
                                    ""

                        Nothing ->
                            ""
                    )

                Nothing ->
                    ( "", "", "", "", "" )
    in
        H.div [ HA.classList [ ( "c-overlay c-overlay--transparent", cfg.isShown ) ] ]
            [ H.div
                [ HA.class "o-modal"
                , HA.classList [ ( "isHidden", not cfg.isShown && not cfg.isEditing ) ]
                ]
                [ H.div [ HA.class "c-card" ]
                    [ H.div [ HA.class "c-card__header accent-bg accent-contrast-fg" ]
                        [ H.button
                            [ HA.type_ "button"
                            , HA.class "c-button c-button--close"
                            , HE.onClick cfg.closeMsg
                            ]
                            [ H.text "x" ]
                        , H.h4 [ HA.class "c-heading" ]
                            [ H.text cfg.title ]
                        ]
                    , H.div
                        [ HA.class "c-card__body o-panel"
                        , HA.style
                            -- Need to restrict the body in order for the panel to work.
                            [ ( "height", "230px" )
                            , ( "max-height", "230px" )
                            ]
                        ]
                        [ H.div
                            [ HA.class ""
                              -- BlazeCSS fieldset has too much margin at top for modal.
                            , HA.style [ ( "margin-top", "0" ) ]
                            ]
                            [ H.div []
                                [ H.span [ HA.class "c-text--loud" ]
                                    [ H.text "Stage 1 Total: " ]
                                , H.span [ HA.class "" ]
                                    [ H.text s1Total ]
                                ]
                            , H.div []
                                [ H.span [ HA.class "c-text--loud" ]
                                    [ H.text "Mobility: " ]
                                , H.span [ HA.class "" ]
                                    [ H.text mobility ]
                                ]
                            , H.div []
                                [ H.span [ HA.class "c-text--loud" ]
                                    [ H.text "Duration Latent: " ]
                                , H.span [ HA.class "" ]
                                    [ H.text latent ]
                                , H.span [ HA.class "" ]
                                    [ H.text " minutes" ]
                                ]
                            , H.div []
                                [ H.span [ HA.class "c-text--loud" ]
                                    [ H.text "Duration Active: " ]
                                , H.span [ HA.class "" ]
                                    [ H.text active ]
                                , H.span [ HA.class "" ]
                                    [ H.text " minutes" ]
                                ]
                            , H.div []
                                [ H.span [ HA.class "c-text--loud" ]
                                    [ H.text "Comments: " ]
                                , H.span [ HA.class "" ]
                                    [ H.text comments ]
                                ]
                            ]
                        ]
                    , H.div [ HA.class "c-card__footer modalButtons accent-bg accent-contrast-fg" ]
                        [ H.button
                            [ HA.type_ "button"
                            , HA.class "c-button c-button u-small"
                            , HE.onClick cfg.closeMsg
                            ]
                            [ H.text "Close" ]
                        , H.button
                            -- TODO: make this an Edit button and need a new message
                            [ HA.type_ "button"
                            , HA.class "c-button c-button--brand"
                            , HE.onClick cfg.editMsg
                            ]
                            [ H.text "Edit" ]
                        ]
                    ]
                ]
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
                        LaborStage1 ->
                            case DataCache.get t dc of
                                Just (LaborStage1DataCache rec) ->
                                    { m | laborStage1Record = Just rec }

                                _ ->
                                    m

                        _ ->
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
            -- The user submitted a new labor record to be sent to the server.
            case validateAdmittance model of
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

                Stage1MobilityFld ->
                    { model | s1Mobility = Just value }

                Stage1DurationLatentFld ->
                    { model | s1DurationLatent = Just <| U.filterStringLikeInt value }

                Stage1DurationActiveFld ->
                    { model | s1DurationActive = Just <| U.filterStringLikeInt value }

                Stage1CommentsFld ->
                    { model | s1Comments = Just value }
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

        HandleStage1DateTimeModal dialogState ->
            case dialogState of
                OpenDialog ->
                    ( case ( model.stage1Date, model.stage1Time ) of
                        ( Nothing, Nothing ) ->
                            -- If not yet set, the set the date/time to
                            -- current as a convenience to user.
                            { model
                                | stage1DateTimeModal = Stage1DateTimeModal
                                , stage1Date = Just <| Date.fromTime model.currTime
                                , stage1Time = Just <| U.timeToTimeString model.currTime
                            }

                        ( _, _ ) ->
                            { model | stage1DateTimeModal = Stage1DateTimeModal }
                    , Cmd.none
                    , Cmd.none
                    )

                CloseNoSaveDialog ->
                    ( { model | stage1DateTimeModal = NoDateTimeModal }, Cmd.none, Cmd.none )

                EditDialog ->
                    -- This dialog option is not used for stage 1 date time.
                    ( model, Cmd.none, Cmd.none )

                CloseSaveDialog ->
                    -- Close and potentially send initial LaborStage1Record
                    -- to server as an add or update if it validates. An add will
                    -- send a LaborStage1RecordNew and an update uses the full
                    -- LaborStage1Record. The initial add is only sent if
                    -- both date and time are valid.
                    case validateStage1New model of
                        [] ->
                            let
                                outerMsg =
                                    case ( model.laborStage1Record, model.stage1Date, model.stage1Time ) of
                                        -- A laborStage1 record already exists, so update it.
                                        ( Just rec, Just d, Just t ) ->
                                            case U.stringToTimeTuple t of
                                                Just ( h, m ) ->
                                                    let
                                                        newRec =
                                                            { rec | fullDialation = Just (U.datePlusTimeTuple d ( h, m )) }
                                                    in
                                                        ProcessTypeMsg
                                                            (UpdateLaborStage1Type
                                                                (LaborDelIppMsg
                                                                    (DataCache Nothing (Just [ LaborStage1 ]))
                                                                )
                                                                newRec
                                                            )
                                                            ChgMsgType
                                                            (laborStage1RecordToValue newRec)

                                                Nothing ->
                                                    Noop

                                        ( Just rec, Nothing, Nothing ) ->
                                            -- User unset the fullDialation date/time, so update the server.
                                            let
                                                newRec =
                                                    { rec | fullDialation = Nothing }
                                            in
                                                ProcessTypeMsg
                                                    (UpdateLaborStage1Type
                                                        (LaborDelIppMsg
                                                            (DataCache Nothing (Just [ LaborStage1 ]))
                                                        )
                                                        newRec
                                                    )
                                                    ChgMsgType
                                                    (laborStage1RecordToValue newRec)

                                        ( Nothing, Just _, Just _ ) ->
                                            -- Create a new laborStage1 record.
                                            case deriveLaborStage1RecordNew model of
                                                Just laborStage1RecNew ->
                                                    ProcessTypeMsg
                                                        (AddLaborStage1Type
                                                            (LaborDelIppMsg
                                                                -- Request top-level to provide data in
                                                                -- the dataCache once received from server.
                                                                (DataCache Nothing (Just [ LaborStage1 ]))
                                                            )
                                                            laborStage1RecNew
                                                        )
                                                        AddMsgType
                                                        (laborStage1RecordNewToValue laborStage1RecNew)

                                                Nothing ->
                                                    Noop

                                        ( _, _, _ ) ->
                                            Noop
                            in
                                ( { model
                                    | stage1DateTimeModal = NoDateTimeModal
                                  }
                                , Cmd.none
                                , Task.perform (always outerMsg) (Task.succeed True)
                                )

                        errors ->
                            -- TODO: show errors to user somehow???
                            ( { model | stage1DateTimeModal = NoDateTimeModal }
                            , Cmd.none
                            , logConsole <| toString errors
                            )

        HandleStage1SummaryModal dialogState ->
            case dialogState of
                -- If there already is a laborStage1Record, then populate the form
                -- fields with the contents of that record.
                OpenDialog ->
                    let
                        ( mobility, latent, active, comments ) =
                            case model.laborStage1Record of
                                Just rec ->
                                    ( rec.mobility
                                    , Maybe.map toString rec.durationLatent
                                    , Maybe.map toString rec.durationActive
                                    , rec.comments
                                    )

                                Nothing ->
                                    ( Nothing
                                    , Nothing
                                    , Nothing
                                    , Nothing
                                    )
                    in
                        -- We set the modal to View but it will show the edit screen
                        -- if there are fields not complete.
                        ( { model
                            | stage1SummaryModal = Stage1SummaryViewModal
                            , s1Mobility = mobility
                            , s1DurationLatent = latent
                            , s1DurationActive = active
                            , s1Comments = comments
                          }
                        , Cmd.none
                        , Cmd.none
                        )

                CloseNoSaveDialog ->
                    -- We keep whatever, if anything, the user entered into the
                    -- form fields.
                    ( { model | stage1SummaryModal = NoStageSummaryModal }
                    , Cmd.none
                    , Cmd.none
                    )

                EditDialog ->
                    -- Transitioning from a viewing summary state to editing again by
                    -- explicitly setting the mode to edit. This is different that
                    -- Stage1SummaryViewModal in that we are forcing edit here.
                    ( { model | stage1SummaryModal = Stage1SummaryEditModal }
                    , Cmd.none
                    , Cmd.none
                    )

                CloseSaveDialog ->
                    -- We save to the database if the form fields validate.
                    case validateStage1 model of
                        [] ->
                            let
                                outerMsg =
                                    case model.laborStage1Record of
                                        Just s1Rec ->
                                            -- A Stage 1 record already exists, so update it.
                                            let
                                                newRec =
                                                    { s1Rec
                                                        | mobility = model.s1Mobility
                                                        , durationLatent = U.maybeStringToMaybeInt model.s1DurationLatent
                                                        , durationActive = U.maybeStringToMaybeInt model.s1DurationActive
                                                        , comments = model.s1Comments
                                                    }
                                            in
                                                ProcessTypeMsg
                                                    (UpdateLaborStage1Type
                                                        (LaborDelIppMsg
                                                            (DataCache Nothing (Just [ LaborStage1 ]))
                                                        )
                                                        newRec
                                                    )
                                                    ChgMsgType
                                                    (laborStage1RecordToValue newRec)

                                        Nothing ->
                                            -- Need to create a new stage 1 record for the server.
                                            case deriveLaborStage1RecordNew model of
                                                Just laborStage1RecNew ->
                                                    ProcessTypeMsg
                                                        (AddLaborStage1Type
                                                            (LaborDelIppMsg
                                                                -- Request top-level to provide data in
                                                                -- the dataCache once received from server.
                                                                (DataCache Nothing (Just [ LaborStage1 ]))
                                                            )
                                                            laborStage1RecNew
                                                        )
                                                        AddMsgType
                                                        (laborStage1RecordNewToValue laborStage1RecNew)

                                                Nothing ->
                                                    LogConsole "deriveLaborStage1RecordNew returned a Nothing"
                            in
                                ( { model | stage1SummaryModal = NoStageSummaryModal }
                                , Cmd.none
                                , Task.perform (always outerMsg) (Task.succeed True)
                                )

                        errors ->
                            -- TODO: Show errors to user?
                            ( { model | stage1SummaryModal = NoStageSummaryModal }
                            , Cmd.none
                            , logConsole <| toString errors
                            )

        HandleStage2DateTimeModal dialogState ->
            -- The user has just opened the modal to set the date/time for stage 2
            -- completion. We default to the current date/time for convenience if
            -- this is an open event, but only if the date/time has not already
            -- been previously selected.
            let
                ( s2d, s2t ) =
                    case model.stage2DateTimeModal == NoDateTimeModal of
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
                    | stage2DateTimeModal =
                        if model.stage2DateTimeModal == NoDateTimeModal then
                            Stage2DateTimeModal
                        else
                            NoDateTimeModal
                    , stage2Date = s2d
                    , stage2Time = s2t
                  }
                , Cmd.none
                , Cmd.none
                )

        HandleStage3DateTimeModal dialogState ->
            -- The user has just opened the modal to set the date/time for stage 3
            -- completion. We default to the current date/time for convenience if
            -- this is an open event, but only if the date/time has not already
            -- been previously selected.
            let
                ( s3d, s3t ) =
                    case model.stage3DateTimeModal == NoDateTimeModal of
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
                    | stage3DateTimeModal =
                        if model.stage3DateTimeModal == NoDateTimeModal then
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

        LaborDetailsLoaded ->
            ( model, Cmd.none, Cmd.none )


{-| Derive a LaborStage1RecordNew from the form fields, if possible.
-}
deriveLaborStage1RecordNew : Model -> Maybe LaborStage1RecordNew
deriveLaborStage1RecordNew model =
    case model.laborState of
        AdmittedLaborState (LaborId id) ->
            -- We have an admittance record, so we are allowed to have
            -- a stage one record too.
            let
                fullDialation =
                    case ( model.stage1Date, model.stage1Time ) of
                        ( Just d, Just t ) ->
                            case U.stringToTimeTuple t of
                                Just tt ->
                                    Just <| U.datePlusTimeTuple d tt

                                Nothing ->
                                    Nothing

                        ( _, _ ) ->
                            Nothing
            in
                LaborStage1RecordNew fullDialation
                    model.s1Mobility
                    (U.maybeStringToMaybeInt model.s1DurationLatent)
                    (U.maybeStringToMaybeInt model.s1DurationActive)
                    model.s1Comments
                    id
                    |> Just

        _ ->
            Nothing


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


type alias FieldError =
    ( Field, String )


validateAdmittance : Model -> List FieldError
validateAdmittance =
    Validate.all
        [ .admittanceDate >> ifInvalid U.validateDate (AdmittanceDateFld => "Date of admittance must be provided.")
        , .admittanceTime >> ifInvalid U.validateTime (AdmittanceTimeFld => "Admitting time must be provided, ex: hh:mm.")
        , .laborDate >> ifInvalid U.validateDate (LaborDateFld => "Date of the start of labor must be provided.")
        , .laborTime >> ifInvalid U.validateTime (LaborTimeFld => "Start of labor time must be provided, ex: hh:mm.")
        , .pos >> ifInvalid U.validatePopulatedString (PosFld => "POS must be provided.")
        , .fh >> ifInvalid U.validateInt (FhFld => "FH must be provided.")
        , .fht >> ifInvalid U.validateInt (FhtFld => "FHT must be provided.")
        , .systolic >> ifInvalid U.validateInt (SystolicFld => "Systolic must be provided.")
        , .diastolic >> ifInvalid U.validateInt (DiastolicFld => "Diastolic must be provided.")
        , .cr >> ifInvalid U.validateInt (CrFld => "CR must be provided.")
        , .temp >> ifInvalid U.validateFloat (TempFld => "Temp must be provided.")
        ]


validateStage1New : Model -> List FieldError
validateStage1New =
    Validate.all
        [ .stage1Time >> ifInvalid U.validateJustTime (Stage1TimeFld => "Time must be provided in hh:mm format.")
        ]


validateStage1 : Model -> List FieldError
validateStage1 =
    Validate.all
        [ .s1Mobility >> ifInvalid U.validatePopulatedString (Stage1MobilityFld => "Mobility must be provided.")
        , .s1DurationLatent >> ifInvalid U.validatePopulatedString (Stage1DurationLatentFld => "Duration latent must be provided.")
        , .s1DurationActive >> ifInvalid U.validatePopulatedString (Stage1DurationActiveFld => "Duration active must be provided.")
        ]
