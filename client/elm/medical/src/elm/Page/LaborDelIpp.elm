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
import Data.LaborStage2
    exposing
        ( isLaborStage2RecordComplete
        , LaborStage2Record
        , LaborStage2RecordNew
        , laborStage2RecordNewToValue
        , laborStage2RecordToValue
        )
import Data.LaborDelIpp exposing (Dialog(..), Field(..), FieldBool(..), SubMsg(..))
import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (getPregId, PregnancyId(..), PregnancyRecord)
import Data.Processing exposing (ProcessId(..))
import Data.SelectQuery exposing (SelectQuery, selectQueryToValue)
import Data.Session as Session exposing (Session)
import Data.Table exposing (Table(..))
import Msg exposing (logConsole, Msg(..), ProcessType(..), toastInfo, toastWarn, toastError)
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
    | Stage2SummaryViewModal
    | Stage2SummaryEditModal
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
    , laborStage2Record : Maybe LaborStage2Record
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
    , stage2SummaryModal : StageSummaryModal
    , s2BirthType : Maybe String
    , s2BirthPosition : Maybe String
    , s2DurationPushing : Maybe String
    , s2BirthPresentation : Maybe String
    , s2CordWrap : Maybe Bool
    , s2CordWrapType : Maybe String
    , s2DeliveryType : Maybe String
    , s2ShoulderDystocia : Maybe Bool
    , s2ShoulderDystociaMinutes : Maybe String
    , s2Laceration : Maybe Bool
    , s2Episiotomy : Maybe Bool
    , s2Repair : Maybe Bool
    , s2Degree : Maybe String
    , s2LacerationRepairedBy : Maybe String
    , s2BirthEBL : Maybe String
    , s2Meconium : Maybe String
    , s2Comments : Maybe String
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
            NoStageSummaryModal
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
            Nothing
            Nothing
            Nothing
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
            SelectQuery Labor (Just (getLaborId lid)) [ LaborStage1, LaborStage2 ]

        ( processId, processStore ) =
            Processing.add
                (SelectQueryType
                    (LaborDelIppMsg
                        (DataCache Nothing
                            (Just [ LaborStage1, LaborStage2 ])
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
        isEditingS1 =
            if model.stage1SummaryModal == Stage1SummaryEditModal then
                True
            else
                not (isStage1SummaryDone model)

        isEditingS2 =
            if model.stage2SummaryModal == Stage2SummaryEditModal then
                True
            else
                not (isStage2SummaryDone model)

        dialogStage1Config =
            DialogStage1Summary
                (model.stage1SummaryModal
                    == Stage1SummaryViewModal
                    || model.stage1SummaryModal
                    == Stage1SummaryEditModal
                )
                isEditingS1
                "Stage 1 Summary"
                model
                (HandleStage1SummaryModal CloseNoSaveDialog)
                (HandleStage1SummaryModal CloseSaveDialog)
                (HandleStage1SummaryModal EditDialog)
                (FldChgSubMsg Stage1MobilityFld)

        dialogStage2Config =
            DialogStage2Summary
                (model.stage2SummaryModal
                    == Stage2SummaryViewModal
                    || model.stage2SummaryModal
                    == Stage2SummaryEditModal
                )
                isEditingS2
                "Stage 2 Summary"
                model
                (HandleStage2SummaryModal CloseNoSaveDialog)
                (HandleStage2SummaryModal CloseSaveDialog)
                (HandleStage2SummaryModal EditDialog)
                (FldChgSubMsg Stage2BirthTypeFld)

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
                    [ viewLaborDetails model
                    , dialogStage1Summary dialogStage1Config
                    , dialogStage2Summary dialogStage2Config
                    , viewDetailsTableTEMP model
                    ]

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
                , Form.formField (FldChgSubMsg AdmittanceTimeFld) "Time admitted" "24 hr format, 14:44" False model.admittanceTime ""
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
                , Form.formField (FldChgSubMsg LaborTimeFld) "Time start of labor" "24 hr format, 09:00" False model.laborTime ""
                , Form.formField (FldChgSubMsg PosFld) "POS" "pos" False model.pos ""
                , Form.formField (FldChgSubMsg FhFld) "FH" "fh" False model.fh ""
                , Form.formField (FldChgSubMsg FhtFld) "FHT" "fht" False model.fht ""
                , Form.formField (FldChgSubMsg SystolicFld) "Systolic" "systolic" False model.systolic ""
                , Form.formField (FldChgSubMsg DiastolicFld) "Diastolic" "diastolic" False model.diastolic ""
                , Form.formField (FldChgSubMsg CrFld) "CR" "heart rate" False model.cr ""
                , Form.formField (FldChgSubMsg TempFld) "Temp" "temperature" False model.temp ""
                , Form.formTextareaField (FldChgSubMsg CommentsFld) "Comments" "" model.comments 3
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


{-| This is a placeholder for now in order to get a better idea of what the
page will look like eventually.
-}
viewDetailsTableTEMP : Model -> Html SubMsg
viewDetailsTableTEMP model =
    H.table
        [ HA.class "c-table c-table--striped u-small"
        , HA.style [ ( "margin-top", "1em" ) ]
        ]
        [ H.thead [ HA.class "c-table__head" ]
            [ H.tr [ HA.class "c-table__row c-table__row--heading" ]
                [ H.th
                    [ HA.class "c-table__cell"
                    , HA.style [ ( "flex", "0 0 8em" ) ]
                    ]
                    [ H.text "Date" ]
                , H.th
                    [ HA.class "c-table__cell"
                    , HA.style [ ( "flex", "0 0 6em" ) ]
                    ]
                    [ H.text "Time" ]
                , H.th [ HA.class "c-table__cell" ]
                    [ H.text "Dln" ]
                , H.th [ HA.class "c-table__cell" ]
                    [ H.text "Sys" ]
                , H.th [ HA.class "c-table__cell" ]
                    [ H.text "Dia" ]
                , H.th [ HA.class "c-table__cell" ]
                    [ H.text "FHT" ]
                , H.th
                    [ HA.style [ ( "flex", "0 0 50%" ) ]
                    ]
                    [ H.text "Comments" ]
                ]
            ]
        , H.tbody [ HA.class "c-table__body" ]
            [ H.tr [ HA.class "c-table__row" ]
                [ H.td
                    [ HA.class "c-table__cell"
                    , HA.style [ ( "flex", "0 0 8em" ) ]
                    ]
                    [ H.text "11-18-2017" ]
                , H.td
                    [ HA.class "c-table__cell"
                    , HA.style [ ( "flex", "0 0 6em" ) ]
                    ]
                    [ H.text "04:17 AM" ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text "" ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text "122" ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text "85" ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text "148" ]
                , H.td
                    [ HA.style [ ( "flex", "0 0 50%" ) ]
                    ]
                    [ H.text "Pt reports spotting just now. Pt report ctx starting at 8pm yesterday 15-30 min apart. Pt report BOW intact." ]
                ]
            , H.tr [ HA.class "c-table__row" ]
                [ H.td
                    [ HA.class "c-table__cell"
                    , HA.style [ ( "flex", "0 0 8em" ) ]
                    ]
                    [ H.text "11-18-2017" ]
                , H.td
                    [ HA.class "c-table__cell"
                    , HA.style [ ( "flex", "0 0 6em" ) ]
                    ]
                    [ H.text "04:37 AM" ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text "" ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text "" ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text "" ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text "140" ]
                , H.td
                    [ HA.style [ ( "flex", "0 0 50%" ) ]
                    ]
                    [ H.text "POS: ROA" ]
                ]
            ]
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


getErr : Field -> List FieldError -> String
getErr fld errors =
    case LE.find (\fe -> Tuple.first fe == fld) errors of
        Just fe ->
            Tuple.second fe

        Nothing ->
            ""


isStage2SummaryDone : Model -> Bool
isStage2SummaryDone model =
    case model.laborStage2Record of
        Just rec ->
            isLaborStage2RecordComplete rec

        _ ->
            False


viewStages : Model -> Html SubMsg
viewStages model =
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
                        [ H.text <|
                            case model.laborStage2Record of
                                Just ls2rec ->
                                    case ls2rec.birthDatetime of
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
                    , HE.onClick <| HandleStage2SummaryModal OpenDialog
                    ]
                    [ if isStage2SummaryDone model then
                        H.i [ HA.class "fa fa-check" ]
                            [ H.text "" ]
                      else
                        H.span [] [ H.text "" ]
                    , H.text " Summary"
                    ]
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



-- Modal for Stage 1 Summary --


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
    let
        errors =
            validateStage1 cfg.model

        s1Total =
            case cfg.model.laborStage1Record of
                Just rec ->
                    case rec.fullDialation of
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

                Nothing ->
                    ""
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
                [ H.text "Stage 1 Summary - Edit" ]
            , H.div [ HA.class "c-text--quiet" ]
                [ H.text <| "Stage 1 total: " ++ s1Total ]
            , H.div [ HA.class "form-wrapper u-small" ]
                [ H.div []
                    [ Form.radioFieldsetWide "Mobility"
                        "mobility"
                        cfg.model.s1Mobility
                        (FldChgSubMsg Stage1MobilityFld)
                        False
                        [ "Moved around"
                        , "Didn't move much"
                        , "Movement restricted"
                        ]
                        (getErr Stage1MobilityFld errors)
                    ]
                , H.div []
                    [ Form.formField (FldChgSubMsg Stage1DurationLatentFld)
                        "Duration latent (minutes)"
                        "Number of minutes"
                        True
                        cfg.model.s1DurationLatent
                        (getErr Stage1DurationLatentFld errors)
                    , Form.formField (FldChgSubMsg Stage1DurationActiveFld)
                        "Duration active (minutes)"
                        "Number of minutes"
                        True
                        cfg.model.s1DurationActive
                        (getErr Stage1DurationActiveFld errors)
                    ]
                , Form.formTextareaFieldMin30em (FldChgSubMsg Stage1CommentsFld)
                    "Comments"
                    "Meds, IV, Complications, Notes, etc."
                    cfg.model.s1Comments
                    3
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
        H.div
            [ HA.classList [ ( "isHidden", not cfg.isShown && not cfg.isEditing ) ]
            , HA.class "u-high"
            , HA.style
                [ ( "padding", "0.8em" )
                , ( "margin-top", "0.8em" )
                ]
            ]
            [ H.h3 [ HA.class "c-text--brand mw-header-3" ]
                [ H.text "Stage 1 Summary" ]
            , H.div [ HA.class "o-fieldset" ]
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
                , H.div [ HA.class "spacedButtons" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button u-small"
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



-- Modal for Stage 2 Summary --


type alias DialogStage2Summary =
    { isShown : Bool
    , isEditing : Bool
    , title : String
    , model : Model
    , closeMsg : SubMsg
    , saveMsg : SubMsg
    , editMsg : SubMsg
    , birthTypeMsg : String -> SubMsg
    }


dialogStage2Summary : DialogStage2Summary -> Html SubMsg
dialogStage2Summary cfg =
    case cfg.isEditing of
        True ->
            dialogStage2SummaryEdit cfg

        False ->
            dialogStage2SummaryView cfg


dialogStage2SummaryEdit : DialogStage2Summary -> Html SubMsg
dialogStage2SummaryEdit cfg =
    let
        errors =
            validateStage2 cfg.model
    in
        H.div
            [ HA.class "u-high"
            , HA.classList [ ( "isHidden", not cfg.isShown && cfg.isEditing ) ]
            , HA.style
                [ ( "padding", "0.8em" )
                , ( "margin-top", "0.8em" )
                ]
            ]
            [ H.h3 [ HA.class "c-text--brand mw-header-3" ]
                [ H.text "Stage 2 Summary - Edit" ]
            , H.div [ HA.class "form-wrapper u-small" ]
                [ H.div
                    [ HA.class "o-fieldset form-wrapper"
                    ]
                    [ Form.radioFieldsetOther "Birth type"
                        "birthType"
                        cfg.model.s2BirthType
                        (FldChgSubMsg Stage2BirthTypeFld)
                        False
                        [ "Vaginal" ]
                        (getErr Stage2BirthTypeFld errors)
                    , Form.radioFieldsetOther "Position for birth"
                        "position"
                        cfg.model.s2BirthPosition
                        (FldChgSubMsg Stage2BirthPositionFld)
                        False
                        [ "Semi-sitting"
                        , "Lying on back"
                        , "Side-Lying"
                        , "Stool or Antipolo"
                        , "Hands/Knees"
                        , "Squat"
                        ]
                        (getErr Stage2BirthPositionFld errors)
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgSubMsg Stage2DurationPushingFld)
                            "Duration of pushing"
                            "Number of minutes"
                            True
                            cfg.model.s2DurationPushing
                            (getErr Stage2DurationPushingFld errors)
                        ]
                    , Form.radioFieldsetOther "Baby's presentation at birth"
                        "presentation"
                        cfg.model.s2BirthPresentation
                        (FldChgSubMsg Stage2BirthPresentationFld)
                        False
                        [ "ROA"
                        , "ROP"
                        , "LOA"
                        , "LOP"
                        ]
                        (getErr Stage2BirthPresentationFld errors)
                    , Form.checkbox "Cord was wrapped" (FldChgBoolSubMsg Stage2CordWrapFld) cfg.model.s2CordWrap
                    , Form.radioFieldsetOther "Cord wrap type"
                        "cordwraptype"
                        cfg.model.s2CordWrapType
                        (FldChgSubMsg Stage2CordWrapTypeFld)
                        False
                        [ "Nuchal"
                        , "Body"
                        , "Cut on perineum"
                        ]
                        (getErr Stage2CordWrapTypeFld errors)
                    , Form.radioFieldsetOther "Delivery type"
                        "deliverytype"
                        cfg.model.s2DeliveryType
                        (FldChgSubMsg Stage2DeliveryTypeFld)
                        False
                        [ "Spontaneous"
                        , "Interventive"
                        , "Vacuum"
                        ]
                        (getErr Stage2DeliveryTypeFld errors)
                    , Form.checkbox "Shoulder Dystocia" (FldChgBoolSubMsg Stage2ShoulderDystociaFld) cfg.model.s2ShoulderDystocia
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgSubMsg Stage2ShoulderDystociaMinutesFld)
                            "Shoulder dystocia minutes"
                            "Number of minutes"
                            True
                            cfg.model.s2ShoulderDystociaMinutes
                            (getErr Stage2ShoulderDystociaMinutesFld errors)
                        ]
                    , Form.checkbox "Laceration" (FldChgBoolSubMsg Stage2LacerationFld) cfg.model.s2Laceration
                    , Form.checkbox "Episiotomy" (FldChgBoolSubMsg Stage2EpisiotomyFld) cfg.model.s2Episiotomy
                    , Form.checkbox "Repair" (FldChgBoolSubMsg Stage2RepairFld) cfg.model.s2Repair
                    , Form.radioFieldset "Degree"
                        "degree"
                        cfg.model.s2Degree
                        (FldChgSubMsg Stage2DegreeFld)
                        False
                        [ "1st"
                        , "2nd"
                        , "3rd"
                        , "4th"
                        ]
                        (getErr Stage2DegreeFld errors)
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgSubMsg Stage2LacerationRepairedByFld)
                            "Laceration repaired by"
                            "Initials or lastname"
                            True
                            cfg.model.s2LacerationRepairedBy
                            (getErr Stage2LacerationRepairedByFld errors)
                        ]
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgSubMsg Stage2BirthEBLFld)
                            "EBL at birth"
                            "in cc"
                            True
                            cfg.model.s2BirthEBL
                            (getErr Stage2BirthEBLFld errors)
                        ]
                    , Form.radioFieldset "Meconium"
                        "meconium"
                        cfg.model.s2Meconium
                        (FldChgSubMsg Stage2MeconiumFld)
                        False
                        [ "None"
                        , "Lt"
                        , "Mod"
                        , "Thick"
                        ]
                        (getErr Stage2MeconiumFld errors)
                    , Form.formTextareaField (FldChgSubMsg Stage2CommentsFld)
                        "Comments"
                        "Meds, IV, Complications, Notes, etc."
                        cfg.model.s2Comments
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


dialogStage2SummaryView : DialogStage2Summary -> Html SubMsg
dialogStage2SummaryView cfg =
    let
        ( birthType, birthPosition, durationPushing, birthPresentation, cordWrapAndType, deliveryType ) =
            case cfg.model.laborStage2Record of
                Just rec ->
                    ( Maybe.withDefault "" rec.birthType
                    , Maybe.withDefault "" rec.birthPosition
                    , Maybe.map toString rec.durationPushing
                        |> Maybe.withDefault ""
                    , Maybe.withDefault "" rec.birthPresentation
                    , Maybe.map2
                        (\c t ->
                            if c then
                                "Yes, " ++ t
                            else
                                "No"
                        )
                        rec.cordWrap
                        rec.cordWrapType
                        |> Maybe.withDefault "No"
                    , Maybe.withDefault "" rec.deliveryType
                    )

                Nothing ->
                    ( "", "", "", "", "", "" )

        ( shoulderDystocia, laceration, episiotomy, repair, degree, repairedBy, ebl, meconium ) =
            case cfg.model.laborStage2Record of
                Just rec ->
                    ( Maybe.map2
                        (\s m ->
                            if s then
                                "Yes, " ++ (toString m) ++ " minutes"
                            else
                                "No"
                        )
                        rec.shoulderDystocia
                        rec.shoulderDystociaMinutes
                        |> Maybe.withDefault "No"
                    , Maybe.map
                        (\l ->
                            if l then
                                "Yes"
                            else
                                "No"
                        )
                        rec.laceration
                        |> Maybe.withDefault "No"
                    , Maybe.map
                        (\e ->
                            if e then
                                "Yes"
                            else
                                "No"
                        )
                        rec.episiotomy
                        |> Maybe.withDefault "No"
                    , Maybe.map
                        (\r ->
                            if r then
                                "Yes"
                            else
                                "No"
                        )
                        rec.repair
                        |> Maybe.withDefault "No"
                    , Maybe.withDefault "None" rec.degree
                    , Maybe.withDefault "" rec.lacerationRepairedBy
                    , Maybe.map toString rec.birthEBL
                        |> Maybe.map (\e -> e ++ " cc")
                        |> Maybe.withDefault "0"
                    , Maybe.withDefault "None" rec.meconium
                    )

                Nothing ->
                    ( "", "", "", "", "", "", "", "" )

        s2Total =
            case cfg.model.laborStage2Record of
                Just s2Rec ->
                    case cfg.model.laborStage1Record of
                        Just s1Rec ->
                            case ( s1Rec.fullDialation, s2Rec.birthDatetime ) of
                                ( Just fd, Just bdt ) ->
                                    U.diff2DatesString fd bdt

                                ( _, _ ) ->
                                    ""

                        Nothing ->
                            ""

                Nothing ->
                    ""
    in
        H.div
            [ HA.classList [ ( "isHidden", not cfg.isShown && not cfg.isEditing ) ]
            , HA.class "u-high"
            , HA.style
                [ ( "padding", "0.8em" )
                , ( "margin-top", "0.8em" )
                ]
            ]
            [ H.h3 [ HA.class "c-text--brand mw-header-3" ]
                [ H.text "Stage 2 Summary" ]
            , H.div []
                [ H.div
                    [ HA.class "o-fieldset form-wrapper"
                    ]
                    [ H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Stage 2 Total: " ]
                        , H.span [ HA.class "" ]
                            [ H.text s2Total ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Birth type: " ]
                        , H.span [ HA.class "" ]
                            [ H.text birthType ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Delivery type: " ]
                        , H.span [ HA.class "" ]
                            [ H.text deliveryType ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Position for birth: " ]
                        , H.span [ HA.class "" ]
                            [ H.text birthPosition ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Duration of pushing: " ]
                        , H.span [ HA.class "" ]
                            [ H.text <| durationPushing ++ " minutes" ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Presentation at birth: " ]
                        , H.span [ HA.class "" ]
                            [ H.text birthPresentation ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Cord wrap: " ]
                        , H.span [ HA.class "" ]
                            [ H.text cordWrapAndType ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Shoulder dystocia: " ]
                        , H.span [ HA.class "" ]
                            [ H.text shoulderDystocia ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Laceration: " ]
                        , H.span [ HA.class "" ]
                            [ H.text laceration ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Episiotomy: " ]
                        , H.span [ HA.class "" ]
                            [ H.text episiotomy ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Repair: " ]
                        , H.span [ HA.class "" ]
                            [ H.text repair ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Degree: " ]
                        , H.span [ HA.class "" ]
                            [ H.text degree ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Laceration repaired by: " ]
                        , H.span [ HA.class "" ]
                            [ H.text repairedBy ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Est blood loss at birth: " ]
                        , H.span [ HA.class "" ]
                            [ H.text ebl ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Meconium: " ]
                        , H.span [ HA.class "" ]
                            [ H.text meconium ]
                        ]
                    ]
                , H.div [ HA.class "spacedButtons" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button u-small"
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

                        LaborStage2 ->
                            case DataCache.get t dc of
                                Just (LaborStage2DataCache rec) ->
                                    { m | laborStage2Record = Just rec }

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

        FldChgBoolSubMsg fld value ->
            -- Boolean fields.
            ( case fld of
                Stage2CordWrapFld ->
                    -- Clear the cord wrap type if this is unchecked.
                    if value == False then
                        { model
                            | s2CordWrap = Just value
                            , s2CordWrapType = Nothing
                        }
                    else
                        { model | s2CordWrap = Just value }

                Stage2ShoulderDystociaFld ->
                    { model | s2ShoulderDystocia = Just value }

                Stage2LacerationFld ->
                    -- Clear the degree field if this and laceration are unchecked.
                    if value == False then
                        if model.s2Episiotomy == Nothing || model.s2Episiotomy == Just False then
                            { model
                                | s2Laceration = Just value
                                , s2Degree = Nothing
                            }
                        else
                            { model | s2Laceration = Just value }
                    else
                        { model | s2Laceration = Just value }

                Stage2EpisiotomyFld ->
                    -- Clear the degree field if this and laceration are unchecked.
                    if value == False then
                        if model.s2Laceration == Nothing || model.s2Laceration == Just False then
                            { model
                                | s2Episiotomy = Just value
                                , s2Degree = Nothing
                            }
                        else
                            { model | s2Episiotomy = Just value }
                    else
                        { model | s2Episiotomy = Just value }

                Stage2RepairFld ->
                    -- Clear the degree and repaired by fields if this is unchecked.
                    if value == False then
                        { model
                            | s2Repair = Just value
                            , s2Degree = Nothing
                            , s2LacerationRepairedBy = Nothing
                        }
                    else
                        { model | s2Repair = Just value }
            , Cmd.none
            , Cmd.none
            )

        FldChgSubMsg fld value ->
            -- All fields are handled here except for the date fields for browsers that
            -- do not support the input date type (see DateFieldSubMsg for those) and
            -- the boolean fields handled by FldChgBoolSubMsg above.
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

                Stage1MobilityFld ->
                    { model | s1Mobility = Just value }

                Stage1DurationLatentFld ->
                    { model | s1DurationLatent = Just <| U.filterStringLikeInt value }

                Stage1DurationActiveFld ->
                    { model | s1DurationActive = Just <| U.filterStringLikeInt value }

                Stage1CommentsFld ->
                    { model | s1Comments = Just value }

                Stage2DateFld ->
                    { model | stage2Date = Date.fromString value |> Result.toMaybe }

                Stage2TimeFld ->
                    { model | stage2Time = Just <| U.filterStringLikeTime value }

                Stage2BirthDatetimeFld ->
                    -- TODO: What is this field for if we have Stage2DateFld and Stage2TimeFld?
                    model

                Stage2BirthTypeFld ->
                    { model | s2BirthType = Just value }

                Stage2BirthPositionFld ->
                    { model | s2BirthPosition = Just value }

                Stage2DurationPushingFld ->
                    { model | s2DurationPushing = Just <| U.filterStringLikeInt value }

                Stage2BirthPresentationFld ->
                    { model | s2BirthPresentation = Just value }

                Stage2CordWrapTypeFld ->
                    { model | s2CordWrapType = Just value }

                Stage2DeliveryTypeFld ->
                    { model | s2DeliveryType = Just value }

                Stage2ShoulderDystociaMinutesFld ->
                    { model | s2ShoulderDystociaMinutes = Just <| U.filterStringLikeInt value }

                Stage2DegreeFld ->
                    { model | s2Degree = Just value }

                Stage2LacerationRepairedByFld ->
                    { model | s2LacerationRepairedBy = Just value }

                Stage2BirthEBLFld ->
                    { model | s2BirthEBL = Just value }

                Stage2MeconiumFld ->
                    { model | s2Meconium = Just value }

                Stage2CommentsFld ->
                    { model | s2Comments = Just value }

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
                        -- Also, if we are not on the NoStageSummaryModal, we set the
                        -- modal to that which has the effect of allowing the Summary
                        -- button in the view to serve as a toggle.
                        ( { model
                            | stage1SummaryModal =
                                if model.stage1SummaryModal == NoStageSummaryModal then
                                    Stage1SummaryViewModal
                                else
                                    NoStageSummaryModal
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
            case dialogState of
                OpenDialog ->
                    ( case ( model.stage2Date, model.stage2Time ) of
                        ( Nothing, Nothing ) ->
                            -- If not yet set, the set the date/time to
                            -- current as a convenience to user.
                            { model
                                | stage2DateTimeModal = Stage2DateTimeModal
                                , stage2Date = Just <| Date.fromTime model.currTime
                                , stage2Time = Just <| U.timeToTimeString model.currTime
                            }

                        ( _, _ ) ->
                            { model | stage2DateTimeModal = Stage2DateTimeModal }
                    , Cmd.none
                    , Cmd.none
                    )

                CloseNoSaveDialog ->
                    ( { model | stage2DateTimeModal = NoDateTimeModal }, Cmd.none, Cmd.none )

                EditDialog ->
                    -- This dialog option is not used for stage 2 date time.
                    ( model, Cmd.none, Cmd.none )

                CloseSaveDialog ->
                    -- Close and potentially send initial LaborStage2Record
                    -- to server as an add or update if it validates. An add will
                    -- send a LaborStage2RecordNew and an update uses the full
                    -- LaborStage2Record. The initial add is only sent if
                    -- both date and time are valid.
                    case validateStage2New model of
                        [] ->
                            let
                                outerMsg =
                                    case ( model.laborStage2Record, model.stage2Date, model.stage2Time ) of
                                        -- A laborStage2 record already exists, so update it.
                                        ( Just rec, Just d, Just t ) ->
                                            case U.stringToTimeTuple t of
                                                Just ( h, m ) ->
                                                    let
                                                        newRec =
                                                            { rec | birthDatetime = Just (U.datePlusTimeTuple d ( h, m )) }
                                                    in
                                                        ProcessTypeMsg
                                                            (UpdateLaborStage2Type
                                                                (LaborDelIppMsg
                                                                    (DataCache Nothing (Just [ LaborStage2 ]))
                                                                )
                                                                newRec
                                                            )
                                                            ChgMsgType
                                                            (laborStage2RecordToValue newRec)

                                                Nothing ->
                                                    Noop

                                        ( Just rec, Nothing, Nothing ) ->
                                            -- User unset the birthDatetime, so update the server.
                                            let
                                                newRec =
                                                    { rec | birthDatetime = Nothing }
                                            in
                                                ProcessTypeMsg
                                                    (UpdateLaborStage2Type
                                                        (LaborDelIppMsg
                                                            (DataCache Nothing (Just [ LaborStage2 ]))
                                                        )
                                                        newRec
                                                    )
                                                    ChgMsgType
                                                    (laborStage2RecordToValue newRec)

                                        ( Nothing, Just _, Just _ ) ->
                                            -- Create a new laborStage2 record.
                                            case deriveLaborStage2RecordNew model of
                                                Just laborStage2RecNew ->
                                                    ProcessTypeMsg
                                                        (AddLaborStage2Type
                                                            (LaborDelIppMsg
                                                                -- Request top-level to provide data in
                                                                -- the dataCache once received from server.
                                                                (DataCache Nothing (Just [ LaborStage2 ]))
                                                            )
                                                            laborStage2RecNew
                                                        )
                                                        AddMsgType
                                                        (laborStage2RecordNewToValue laborStage2RecNew)

                                                Nothing ->
                                                    Noop

                                        ( _, _, _ ) ->
                                            Noop
                            in
                                ( { model
                                    | stage2DateTimeModal = NoDateTimeModal
                                  }
                                , Cmd.none
                                , Task.perform (always outerMsg) (Task.succeed True)
                                )

                        errors ->
                            -- TODO: show errors to user somehow???
                            ( { model | stage2DateTimeModal = NoDateTimeModal }
                            , Cmd.none
                            , logConsole <| toString errors
                            )

        HandleStage2SummaryModal dialogState ->
            case dialogState of
                -- If there already is a laborStage2Record, then populate the form
                -- fields with the contents of that record.
                OpenDialog ->
                    let
                        newModel =
                            case model.laborStage2Record of
                                Just rec ->
                                    { model
                                        | s2BirthType = rec.birthType
                                        , s2BirthPosition = rec.birthPosition
                                        , s2DurationPushing = Maybe.map toString rec.durationPushing
                                        , s2BirthPresentation = rec.birthPresentation
                                        , s2CordWrap = rec.cordWrap
                                        , s2CordWrapType = rec.cordWrapType
                                        , s2DeliveryType = rec.deliveryType
                                        , s2ShoulderDystocia = rec.shoulderDystocia
                                        , s2ShoulderDystociaMinutes = Maybe.map toString rec.shoulderDystociaMinutes
                                        , s2Laceration = rec.laceration
                                        , s2Episiotomy = rec.episiotomy
                                        , s2Repair = rec.repair
                                        , s2Degree = rec.degree
                                        , s2LacerationRepairedBy = rec.lacerationRepairedBy
                                        , s2BirthEBL = Maybe.map toString rec.birthEBL
                                        , s2Meconium = rec.meconium
                                        , s2Comments = rec.comments
                                    }

                                Nothing ->
                                    model
                    in
                        -- We set the modal to View but it will show the edit screen
                        -- if there are fields not complete.
                        ( { newModel
                            | stage2SummaryModal =
                                if newModel.stage2SummaryModal == NoStageSummaryModal then
                                    Stage2SummaryViewModal
                                else
                                    NoStageSummaryModal
                          }
                        , Cmd.none
                        , Cmd.none
                        )

                CloseNoSaveDialog ->
                    -- We keep whatever, if anything, the user entered into the
                    -- form fields.
                    ( { model | stage2SummaryModal = NoStageSummaryModal }
                    , Cmd.none
                    , Cmd.none
                    )

                EditDialog ->
                    -- Transitioning from a viewing summary state to editing again by
                    -- explicitly setting the mode to edit. This is different that
                    -- Stage2SummaryViewModal in that we are forcing edit here.
                    ( { model | stage2SummaryModal = Stage2SummaryEditModal }
                    , Cmd.none
                    , Cmd.none
                    )

                CloseSaveDialog ->
                    -- We save to the database if the form fields validate.
                    case validateStage2 model of
                        [] ->
                            let
                                outerMsg =
                                    case model.laborStage2Record of
                                        Just s2Rec ->
                                            -- A Stage 2 record already exists, so update it.
                                            let
                                                newRec =
                                                    { s2Rec
                                                        | birthType = model.s2BirthType
                                                        , birthPosition = model.s2BirthPosition
                                                        , durationPushing = U.maybeStringToMaybeInt model.s2DurationPushing
                                                        , birthPresentation = model.s2BirthPresentation
                                                        , cordWrap = model.s2CordWrap
                                                        , cordWrapType = model.s2CordWrapType
                                                        , deliveryType = model.s2DeliveryType
                                                        , shoulderDystocia = model.s2ShoulderDystocia
                                                        , shoulderDystociaMinutes = U.maybeStringToMaybeInt model.s2ShoulderDystociaMinutes
                                                        , laceration = model.s2Laceration
                                                        , episiotomy = model.s2Episiotomy
                                                        , repair = model.s2Repair
                                                        , degree = model.s2Degree
                                                        , lacerationRepairedBy = model.s2LacerationRepairedBy
                                                        , birthEBL = U.maybeStringToMaybeInt model.s2BirthEBL
                                                        , meconium = model.s2Meconium
                                                        , comments = model.s2Comments
                                                    }
                                            in
                                                ProcessTypeMsg
                                                    (UpdateLaborStage2Type
                                                        (LaborDelIppMsg
                                                            (DataCache Nothing (Just [ LaborStage2 ]))
                                                        )
                                                        newRec
                                                    )
                                                    ChgMsgType
                                                    (laborStage2RecordToValue newRec)

                                        Nothing ->
                                            -- Need to create a new stage 2 record for the server.
                                            case deriveLaborStage2RecordNew model of
                                                Just laborStage2RecNew ->
                                                    ProcessTypeMsg
                                                        (AddLaborStage2Type
                                                            (LaborDelIppMsg
                                                                -- Request top-level to provide data in
                                                                -- the dataCache once received from server.
                                                                (DataCache Nothing (Just [ LaborStage2 ]))
                                                            )
                                                            laborStage2RecNew
                                                        )
                                                        AddMsgType
                                                        (laborStage2RecordNewToValue laborStage2RecNew)

                                                Nothing ->
                                                    LogConsole "deriveLaborStage2RecordNew returned a Nothing"
                            in
                                ( { model | stage2SummaryModal = NoStageSummaryModal }
                                , Cmd.none
                                , Task.perform (always outerMsg) (Task.succeed True)
                                )

                        errors ->
                            let
                                msgs =
                                    List.map Tuple.second errors
                            in
                                ( { model | stage2SummaryModal = NoStageSummaryModal }
                                , Cmd.none
                                , toastError msgs 10
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


deriveLaborStage2RecordNew : Model -> Maybe LaborStage2RecordNew
deriveLaborStage2RecordNew model =
    case model.laborState of
        AdmittedLaborState (LaborId id) ->
            let
                birthDatetime =
                    case ( model.stage2Date, model.stage2Time ) of
                        ( Just d, Just t ) ->
                            case U.stringToTimeTuple t of
                                Just tt ->
                                    Just <| U.datePlusTimeTuple d tt

                                Nothing ->
                                    Nothing

                        ( _, _ ) ->
                            Nothing
            in
                LaborStage2RecordNew birthDatetime
                    model.s2BirthType
                    model.s2BirthPosition
                    (U.maybeStringToMaybeInt model.s2DurationPushing)
                    model.s2BirthPresentation
                    model.s2CordWrap
                    model.s2CordWrapType
                    model.s2DeliveryType
                    model.s2ShoulderDystocia
                    (U.maybeStringToMaybeInt model.s2ShoulderDystociaMinutes)
                    model.s2Laceration
                    model.s2Episiotomy
                    model.s2Repair
                    model.s2Degree
                    model.s2LacerationRepairedBy
                    (U.maybeStringToMaybeInt model.s2BirthEBL)
                    model.s2Meconium
                    model.s2Comments
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


{-| TODO: is this right?
-}
validateStage2New : Model -> List FieldError
validateStage2New =
    Validate.all
        [ .stage2Time >> ifInvalid U.validateJustTime (Stage2TimeFld => "Time must be provided in hh:mm format.")
        ]


validateStage2 : Model -> List FieldError
validateStage2 =
    Validate.all
        [ .s2BirthType >> ifInvalid U.validatePopulatedString (Stage2BirthTypeFld => "Birth type must be provided.")
        , .s2BirthPosition >> ifInvalid U.validatePopulatedString (Stage2BirthPositionFld => "Birth position must be provided.")
        , .s2DurationPushing >> ifInvalid U.validateInt (Stage2DurationPushingFld => "Duration pushing must be provided.")
        , .s2BirthPresentation >> ifInvalid U.validatePopulatedString (Stage2BirthPresentationFld => "Birth presentation must be provided.")
        , (\mdl ->
            if mdl.s2CordWrapType /= Nothing && (mdl.s2CordWrap == Nothing || mdl.s2CordWrap == Just False) then
                [ (Stage2CordWrapTypeFld => "Cord wrap type cannot be specified if cord wrap is not checked.") ]
            else if mdl.s2CordWrap == Just True && String.length (Maybe.withDefault "" mdl.s2CordWrapType) == 0 then
                [ (Stage2CordWrapTypeFld => "Cord wrap cannot be checked without also specifying cord wrap type.") ]
            else
                []
          )
        , .s2DeliveryType >> ifInvalid U.validatePopulatedString (Stage2DeliveryTypeFld => "Delivery type must be provided.")
        , (\mdl ->
            case U.maybeStringToMaybeInt mdl.s2ShoulderDystociaMinutes of
                Just m ->
                    if m > 0 && (mdl.s2ShoulderDystocia == Nothing || mdl.s2ShoulderDystocia == Just False) then
                        [ (Stage2ShoulderDystociaMinutesFld => "Shoulder dystocia minutes cannot be specified if shoulder dystocia is not checked.") ]
                    else
                        []

                Nothing ->
                    if mdl.s2ShoulderDystocia == Just True then
                        [ (Stage2ShoulderDystociaMinutesFld => "Shoulder dystocia cannot be checked without specifying shoulder dystocia minutes.") ]
                    else
                        []
          )
        , (\mdl ->
            if mdl.s2Laceration == Just True || mdl.s2Episiotomy == Just True then
                if mdl.s2Degree == Nothing then
                    [ (Stage2DegreeFld => "Degree must be specified if laceration or episiotomy is checked.") ]
                else
                    []
            else if mdl.s2Degree /= Nothing then
                [ (Stage2DegreeFld => "Either laceration and/or episiotomy must be checked if degree is specified.") ]
            else
                []
          )
        , (\mdl ->
            if mdl.s2Repair == Just True && String.length (Maybe.withDefault "" mdl.s2LacerationRepairedBy) == 0 then
                [ (Stage2LacerationRepairedByFld => "Laceration repaired by field must be provided if repair field is checked.") ]
            else
                []
          )
        , .s2BirthEBL >> ifInvalid U.validateInt (Stage2BirthEBLFld => "Estimated blood loss at birth must be provided.")
        , .s2Meconium >> ifInvalid U.validatePopulatedString (Stage2MeconiumFld => "Meconium must be provided.")
        ]
