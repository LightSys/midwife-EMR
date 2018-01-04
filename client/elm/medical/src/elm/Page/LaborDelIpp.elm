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

import Const exposing (FldChgValue(..))
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
import Data.LaborStage3
    exposing
        ( isLaborStage3RecordComplete
        , LaborStage3Record
        , LaborStage3RecordNew
        , laborStage3RecordNewToValue
        , laborStage3RecordToValue
        , schultzDuncan2String
        , string2SchultzDuncan
        )
import Data.LaborDelIpp
    exposing
        ( Dialog(..)
        , Field(..)
        , SubMsg(..)
        )
import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (getPregId, PregnancyId(..), PregnancyRecord)
import Data.PregnancyHeader as PregHeaderData
import Data.Processing exposing (ProcessId(..))
import Data.SelectQuery exposing (SelectQuery, selectQueryToValue)
import Data.Session as Session exposing (Session)
import Data.Table exposing (Table(..))
import Msg exposing (logConsole, Msg(..), ProcessType(..), toastInfo, toastWarn, toastError)
import Page.Errored as Errored exposing (PageLoadError)
import Ports
import Processing exposing (ProcessStore)
import Route
import Util as U exposing ((=>))
import Views.Form as Form
import Views.PregnancyHeader as PregHeaderView


-- MODEL --


type DateTimeModal
    = NoDateTimeModal
    | Stage1DateTimeModal
    | Stage2DateTimeModal
    | Stage3DateTimeModal
    | FalseLaborDateTimeModal


type StageSummaryModal
    = NoStageSummaryModal
    | Stage1SummaryViewModal
    | Stage1SummaryEditModal
    | Stage2SummaryViewModal
    | Stage2SummaryEditModal
    | Stage3SummaryModal
    | Stage3SummaryViewModal
    | Stage3SummaryEditModal


type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , pregnancy_id : PregnancyId
    , currLaborId : Maybe LaborId
    , currPregHeaderContent : PregHeaderData.PregHeaderContent
    , dataCache : Dict String DataCache
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    , laborRecords : Maybe (Dict Int LaborRecord)
    , laborStage1Record : Maybe LaborStage1Record
    , laborStage2Record : Maybe LaborStage2Record
    , laborStage3Record : Maybe LaborStage3Record
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
    , stage3SummaryModal : StageSummaryModal
    , s3PlacentaDeliverySpontaneous : Maybe Bool
    , s3PlacentaDeliveryAMTSL : Maybe Bool
    , s3PlacentaDeliveryCCT : Maybe Bool
    , s3PlacentaDeliveryManual : Maybe Bool
    , s3MaternalPosition : Maybe String
    , s3TxBloodLoss1 : Maybe String
    , s3TxBloodLoss2 : Maybe String
    , s3TxBloodLoss3 : Maybe String
    , s3TxBloodLoss4 : Maybe String
    , s3TxBloodLoss5 : Maybe String
    , s3PlacentaShape : Maybe String
    , s3PlacentaInsertion : Maybe String
    , s3PlacentaNumVessels : Maybe String
    , s3SchultzDuncan : Maybe String
    , s3PlacentaMembranesComplete : Maybe Bool
    , s3PlacentaOther : Maybe String
    , s3Comments : Maybe String
    , falseLaborDateTimeModal : DateTimeModal
    , falseLaborDate : Maybe Date
    , falseLaborTime : Maybe String
    }


{-| Builds the initial model for the page. If the pregnancy has more than
one labor record, the most recent is always chosen.
-}
buildModel :
    Bool
    -> Time
    -> ProcessStore
    -> PregnancyId
    -> Maybe PatientRecord
    -> Maybe PregnancyRecord
    -> Maybe (Dict Int LaborRecord)
    -> ( Model, ProcessStore, Cmd Msg )
buildModel browserSupportsDate currTime store pregId patrec pregRec laborRecs =
    let
        -- Sort by the admittanceDate, descending.
        admitSort a b =
            U.sortDate U.DescendingSort a.admittanceDate b.admittanceDate

        -- Determine state of the labor by labor records, if any, and
        -- request additional records from the server if needed.
        ( laborId, ( newStore, newOuterMsg ) ) =
            case laborRecs of
                Just recs ->
                    -- Get the most recent labor record.
                    case
                        List.sortWith admitSort (Dict.values recs)
                            |> List.head
                    of
                        Just rec ->
                            ( Just <| LaborId rec.id
                            , getLaborDetails (LaborId rec.id) store
                            )

                        Nothing ->
                            -- Since no labor is selected, we cannot be on this page.
                            ( Nothing
                            , ( store
                              , Just Route.AdmittingRoute
                                  |> Task.succeed
                                  |> Task.perform SetRoute
                              )
                            )

                Nothing ->
                    -- Since no labor is selected, we cannot be on this page.
                    ( Nothing
                    , ( store
                        , Just Route.AdmittingRoute
                            |> Task.succeed
                            |> Task.perform SetRoute
                        )
                    )
    in
        ( Model browserSupportsDate
            currTime
            pregId
            laborId
            PregHeaderData.LaborContent
            Dict.empty
            patrec
            pregRec
            laborRecs
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
            SelectQuery Labor (Just (getLaborId lid)) [ LaborStage1, LaborStage2, LaborStage3 ]

        ( processId, processStore ) =
            Processing.add
                (SelectQueryType
                    (LaborDelIppMsg
                        (DataCache Nothing
                            (Just [ LaborStage1, LaborStage2, LaborStage3 ])
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

        isEditingS3 =
            if model.stage3SummaryModal == Stage3SummaryEditModal then
                True
            else
                not (isStage3SummaryDone model)

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
                (FldChgString >> FldChgSubMsg Stage1MobilityFld)

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

        dialogStage3Config =
            DialogStage3Summary
                (model.stage3SummaryModal
                    == Stage3SummaryViewModal
                    || model.stage3SummaryModal
                    == Stage3SummaryEditModal
                )
                isEditingS3
                "Stage 3 Summary"
                model
                (HandleStage3SummaryModal CloseNoSaveDialog)
                (HandleStage3SummaryModal CloseSaveDialog)
                (HandleStage3SummaryModal EditDialog)

        -- Ascertain whether we have a labor in process already.
        pregHeader =
            case ( model.patientRecord, model.pregnancyRecord ) of
                ( Just patRec, Just pregRec ) ->
                    let
                        laborInfo =
                            PregHeaderData.LaborInfo model.laborRecords
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
                [ viewLaborDetails model
                , dialogStage1Summary dialogStage1Config
                , dialogStage2Summary dialogStage2Config
                , dialogStage3Summary dialogStage3Config
                  --, viewDetailsTableTEMP model
                , viewDetailsNotImplemented model
                ]
            ]


viewLaborDetails : Model -> Html SubMsg
viewLaborDetails model =
    H.div [ HA.class "content-flex-wrapper" ]
        [ viewStages model ]


viewDetailsNotImplemented : Model -> Html SubMsg
viewDetailsNotImplemented model =
    H.h3
        []
        [ H.text "Use paper for labor details" ]


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


isStage3SummaryDone : Model -> Bool
isStage3SummaryDone model =
    case model.laborStage3Record of
        Just rec ->
            isLaborStage3RecordComplete rec

        _ ->
            False


{-| View the buttons used to set false labor and stage 1, 2, and 3 date/time
and related fields. Do not show all options, but only what makes sense for
this progression of the labor.

Logic:
  - hide false labor if labor stage 1 exists and has fullDialation set.
  - hide stage 1 if labor record has falseLabor set to True.
  - hide stage 2 if stage 1 is hidden or labor stage 1 does not exist
    or does not have fullDilation set.
  - hide stage 3 if stage 2 is hidden or labor stage 2 does not exist
    or does not have birthDatetime set.
-}
viewStages : Model -> Html SubMsg
viewStages model =
    let
        hideFalse =
            case model.laborStage1Record of
                Just s1Rec ->
                    s1Rec.fullDialation /= Nothing

                Nothing ->
                    False

        hideS1 =
            case ( model.laborRecords, model.currLaborId ) of
                ( Just recs, Just lid ) ->
                    case Dict.get (getLaborId lid) recs of
                        Just rec ->
                            rec.falseLabor

                        Nothing ->
                            False

                ( _, _ ) ->
                    -- Should not get here.
                    False

        hideS2 =
            hideS1
                || case model.laborStage1Record of
                    Just rec ->
                        rec.fullDialation == Nothing

                    Nothing ->
                        True

        hideS3 =
            hideS2
                || case model.laborStage2Record of
                    Just rec ->
                        rec.birthDatetime == Nothing

                    Nothing ->
                        True
    in
        H.div [ HA.class "stage-wrapper" ]
            [ H.div
                [ HA.class "stage-content"
                , HA.classList [ ( "isHidden", hideFalse ) ]
                ]
                [ H.div [ HA.class "c-text--brand c-text--loud" ]
                    [ H.text "False Labor" ]
                , H.div []
                    [ H.label [ HA.class "c-field c-field--choice c-field-minPadding" ]
                        [ H.button
                            [ HA.class "c-button c-button--ghost-brand u-small"
                            , HE.onClick <| HandleFalseLaborDateTimeModal OpenDialog
                            ]
                            [ H.text <|
                                case ( model.laborRecords, model.currLaborId ) of
                                    ( Just recs, Just lid ) ->
                                        case Dict.get (getLaborId lid) recs of
                                            Just rec ->
                                                case ( rec.falseLabor, rec.dischargeDate ) of
                                                    ( True, Just d ) ->
                                                        U.dateTimeHMFormatter
                                                            U.MDYDateFmt
                                                            U.DashDateSep
                                                            d

                                                    ( _, _ ) ->
                                                        "Click to set"

                                            Nothing ->
                                                "Click to set"

                                    ( _, _ ) ->
                                        -- TODO: handle this path better.
                                        "Click to set"
                            ]
                        , if model.browserSupportsDate then
                            Form.dateTimeModal (model.falseLaborDateTimeModal == FalseLaborDateTimeModal)
                                "False Labor Date/Time"
                                (FldChgString >> FldChgSubMsg FalseLaborDateFld)
                                (FldChgString >> FldChgSubMsg FalseLaborTimeFld)
                                (HandleFalseLaborDateTimeModal CloseNoSaveDialog)
                                (HandleFalseLaborDateTimeModal CloseSaveDialog)
                                ClearFalseLaborDateTime
                                model.falseLaborDate
                                model.falseLaborTime
                          else
                            Form.dateTimePickerModal (model.falseLaborDateTimeModal == FalseLaborDateTimeModal)
                                "False Labor Date/Time"
                                OpenDatePickerSubMsg
                                (FldChgString >> FldChgSubMsg FalseLaborDateFld)
                                (FldChgString >> FldChgSubMsg FalseLaborTimeFld)
                                (HandleFalseLaborDateTimeModal CloseNoSaveDialog)
                                (HandleFalseLaborDateTimeModal CloseSaveDialog)
                                ClearFalseLaborDateTime
                                model.falseLaborDate
                                model.falseLaborTime
                        ]
                    ]
                ]
            , H.div
                [ HA.class "stage-content"
                , HA.classList [ ( "isHidden", hideS1 ) ]
                ]
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
                                (FldChgString >> FldChgSubMsg Stage1DateFld)
                                (FldChgString >> FldChgSubMsg Stage1TimeFld)
                                (HandleStage1DateTimeModal CloseNoSaveDialog)
                                (HandleStage1DateTimeModal CloseSaveDialog)
                                ClearStage1DateTime
                                model.stage1Date
                                model.stage1Time
                          else
                            Form.dateTimePickerModal (model.stage1DateTimeModal == Stage1DateTimeModal)
                                "Stage 1 Date/Time"
                                OpenDatePickerSubMsg
                                (FldChgString >> FldChgSubMsg Stage1DateFld)
                                (FldChgString >> FldChgSubMsg Stage1TimeFld)
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
            , H.div
                [ HA.class "stage-content"
                , HA.classList [ ( "isHidden", hideS2 ) ]
                ]
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
                                (FldChgString >> FldChgSubMsg Stage2DateFld)
                                (FldChgString >> FldChgSubMsg Stage2TimeFld)
                                (HandleStage2DateTimeModal CloseNoSaveDialog)
                                (HandleStage2DateTimeModal CloseSaveDialog)
                                ClearStage2DateTime
                                model.stage2Date
                                model.stage2Time
                          else
                            Form.dateTimePickerModal (model.stage2DateTimeModal == Stage2DateTimeModal)
                                "Stage 2 Date/Time"
                                OpenDatePickerSubMsg
                                (FldChgString >> FldChgSubMsg Stage2DateFld)
                                (FldChgString >> FldChgSubMsg Stage2TimeFld)
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
            , H.div
                [ HA.class "stage-content"
                , HA.classList [ ( "isHidden", hideS3 ) ]
                ]
                [ H.div [ HA.class "c-text--brand c-text--loud" ]
                    [ H.text "Stage 3" ]
                , H.div []
                    [ H.label [ HA.class "c-field c-field--choice c-field-minPadding" ]
                        [ H.button
                            [ HA.class "c-button c-button--ghost-brand u-small"
                            , HE.onClick <| HandleStage3DateTimeModal OpenDialog
                            ]
                            [ H.text <|
                                case model.laborStage3Record of
                                    Just ls3rec ->
                                        case ls3rec.placentaDatetime of
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
                            Form.dateTimeModal (model.stage3DateTimeModal == Stage3DateTimeModal)
                                "Stage 3 Date/Time"
                                (FldChgString >> FldChgSubMsg Stage3DateFld)
                                (FldChgString >> FldChgSubMsg Stage3TimeFld)
                                (HandleStage3DateTimeModal CloseNoSaveDialog)
                                (HandleStage3DateTimeModal CloseSaveDialog)
                                ClearStage3DateTime
                                model.stage3Date
                                model.stage3Time
                          else
                            Form.dateTimePickerModal (model.stage3DateTimeModal == Stage3DateTimeModal)
                                "Stage 3 Date/Time"
                                OpenDatePickerSubMsg
                                (FldChgString >> FldChgSubMsg Stage3DateFld)
                                (FldChgString >> FldChgSubMsg Stage3TimeFld)
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
                        , HE.onClick <| HandleStage3SummaryModal OpenDialog
                        ]
                        [ if isStage3SummaryDone model then
                            H.i [ HA.class "fa fa-check" ]
                                [ H.text "" ]
                          else
                            H.span [] [ H.text "" ]
                        , H.text " Summary"
                        ]
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
                            case cfg.model.laborRecords of
                                Just lrecs ->
                                    case Dict.get rec.labor_id lrecs of
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
                        (FldChgString >> FldChgSubMsg Stage1MobilityFld)
                        False
                        [ "Moved around"
                        , "Didn't move much"
                        , "Movement restricted"
                        ]
                        (getErr Stage1MobilityFld errors)
                    ]
                , H.div []
                    [ Form.formField (FldChgString >> FldChgSubMsg Stage1DurationLatentFld)
                        "Duration latent (minutes)"
                        "Number of minutes"
                        True
                        cfg.model.s1DurationLatent
                        (getErr Stage1DurationLatentFld errors)
                    , Form.formField (FldChgString >> FldChgSubMsg Stage1DurationActiveFld)
                        "Duration active (minutes)"
                        "Number of minutes"
                        True
                        cfg.model.s1DurationActive
                        (getErr Stage1DurationActiveFld errors)
                    ]
                , Form.formTextareaFieldMin30em (FldChgString >> FldChgSubMsg Stage1CommentsFld)
                    "Comments"
                    "Meds, IV, Complications, Notes, etc."
                    True
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
                            case cfg.model.laborRecords of
                                Just lrecs ->
                                    case Dict.get rec.labor_id lrecs of
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
                        (FldChgString >> FldChgSubMsg Stage2BirthTypeFld)
                        False
                        [ "Vaginal" ]
                        (getErr Stage2BirthTypeFld errors)
                    , Form.radioFieldsetOther "Position for birth"
                        "position"
                        cfg.model.s2BirthPosition
                        (FldChgString >> FldChgSubMsg Stage2BirthPositionFld)
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
                        [ Form.formField (FldChgString >> FldChgSubMsg Stage2DurationPushingFld)
                            "Duration of pushing"
                            "Number of minutes"
                            True
                            cfg.model.s2DurationPushing
                            (getErr Stage2DurationPushingFld errors)
                        ]
                    , Form.radioFieldsetOther "Baby's presentation at birth"
                        "presentation"
                        cfg.model.s2BirthPresentation
                        (FldChgString >> FldChgSubMsg Stage2BirthPresentationFld)
                        False
                        [ "ROA"
                        , "ROP"
                        , "LOA"
                        , "LOP"
                        ]
                        (getErr Stage2BirthPresentationFld errors)
                    , Form.checkbox "Cord was wrapped" (FldChgBool >> FldChgSubMsg Stage2CordWrapFld) cfg.model.s2CordWrap
                    , Form.radioFieldsetOther "Cord wrap type"
                        "cordwraptype"
                        cfg.model.s2CordWrapType
                        (FldChgString >> FldChgSubMsg Stage2CordWrapTypeFld)
                        False
                        [ "Nuchal"
                        , "Body"
                        , "Cut on perineum"
                        ]
                        (getErr Stage2CordWrapTypeFld errors)
                    , Form.radioFieldsetOther "Delivery type"
                        "deliverytype"
                        cfg.model.s2DeliveryType
                        (FldChgString >> FldChgSubMsg Stage2DeliveryTypeFld)
                        False
                        [ "Spontaneous"
                        , "Interventive"
                        , "Vacuum"
                        ]
                        (getErr Stage2DeliveryTypeFld errors)
                    , Form.checkbox "Shoulder Dystocia" (FldChgBool >> FldChgSubMsg Stage2ShoulderDystociaFld) cfg.model.s2ShoulderDystocia
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgString >> FldChgSubMsg Stage2ShoulderDystociaMinutesFld)
                            "Shoulder dystocia minutes"
                            "Number of minutes"
                            True
                            cfg.model.s2ShoulderDystociaMinutes
                            (getErr Stage2ShoulderDystociaMinutesFld errors)
                        ]
                    , Form.checkbox "Laceration" (FldChgBool >> FldChgSubMsg Stage2LacerationFld) cfg.model.s2Laceration
                    , Form.checkbox "Episiotomy" (FldChgBool >> FldChgSubMsg Stage2EpisiotomyFld) cfg.model.s2Episiotomy
                    , Form.checkbox "Repair" (FldChgBool >> FldChgSubMsg Stage2RepairFld) cfg.model.s2Repair
                    , Form.radioFieldset "Degree"
                        "degree"
                        cfg.model.s2Degree
                        (FldChgString >> FldChgSubMsg Stage2DegreeFld)
                        False
                        [ "1st"
                        , "2nd"
                        , "3rd"
                        , "4th"
                        ]
                        (getErr Stage2DegreeFld errors)
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgString >> FldChgSubMsg Stage2LacerationRepairedByFld)
                            "Laceration repaired by"
                            "Initials or lastname"
                            True
                            cfg.model.s2LacerationRepairedBy
                            (getErr Stage2LacerationRepairedByFld errors)
                        ]
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgString >> FldChgSubMsg Stage2BirthEBLFld)
                            "EBL at birth"
                            "in cc"
                            True
                            cfg.model.s2BirthEBL
                            (getErr Stage2BirthEBLFld errors)
                        ]
                    , Form.radioFieldset "Meconium"
                        "meconium"
                        cfg.model.s2Meconium
                        (FldChgString >> FldChgSubMsg Stage2MeconiumFld)
                        False
                        [ "None"
                        , "Lt"
                        , "Mod"
                        , "Thick"
                        ]
                        (getErr Stage2MeconiumFld errors)
                    , Form.formTextareaField (FldChgString >> FldChgSubMsg Stage2CommentsFld)
                        "Comments"
                        "Meds, IV, Complications, Notes, etc."
                        True
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

        ( shoulderDystocia, laceration, episiotomy, repair, degree, repairedBy, ebl, meconium, comments ) =
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
                    , Maybe.withDefault "" rec.comments
                    )

                Nothing ->
                    ( "", "", "", "", "", "", "", "", "" )

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



-- Modal for Stage 3 Summary --


type alias DialogStage3Summary =
    { isShown : Bool
    , isEditing : Bool
    , title : String
    , model : Model
    , closeMsg : SubMsg
    , saveMsg : SubMsg
    , editMsg : SubMsg
    }


dialogStage3Summary : DialogStage3Summary -> Html SubMsg
dialogStage3Summary cfg =
    case cfg.isEditing of
        True ->
            dialogStage3SummaryEdit cfg

        False ->
            dialogStage3SummaryView cfg


dialogStage3SummaryView : DialogStage3Summary -> Html SubMsg
dialogStage3SummaryView cfg =
    let
        yesNoBool bool =
            case bool of
                Just True ->
                    "Yes"

                _ ->
                    "No"

        ( delSpon, delAMTSL, delCCT, delMan, matPos, txBL1, txBL2, txBL3 ) =
            case cfg.model.laborStage3Record of
                Just rec ->
                    ( yesNoBool rec.placentaDeliverySpontaneous
                    , yesNoBool rec.placentaDeliveryAMTSL
                    , yesNoBool rec.placentaDeliveryCCT
                    , yesNoBool rec.placentaDeliveryManual
                    , Maybe.withDefault "" rec.maternalPosition
                    , Maybe.withDefault "" rec.txBloodLoss1
                    , Maybe.withDefault "" rec.txBloodLoss2
                    , Maybe.withDefault "" rec.txBloodLoss3
                    )

                Nothing ->
                    ( "", "", "", "", "", "", "", "" )

        ( shape, insertion, numVessels, schDun, complete, other, comments ) =
            case cfg.model.laborStage3Record of
                Just rec ->
                    ( Maybe.withDefault "" rec.placentaShape
                    , Maybe.withDefault "" rec.placentaInsertion
                    , Maybe.map toString rec.placentaNumVessels
                        |> Maybe.withDefault ""
                    , Maybe.map schultzDuncan2String rec.schultzDuncan
                        |> Maybe.withDefault ""
                    , yesNoBool rec.placentaMembranesComplete
                    , Maybe.withDefault "" rec.placentaOther
                    , Maybe.withDefault "" rec.comments
                    )

                Nothing ->
                    ( "", "", "", "", "", "", "" )

        treatment =
            [ txBL1, txBL2, txBL3 ]
                |> List.filter (\t -> String.length t > 0)
                |> String.join ", "

        s3Total =
            case cfg.model.laborStage3Record of
                Just s3Rec ->
                    case cfg.model.laborStage2Record of
                        Just s2Rec ->
                            case ( s2Rec.birthDatetime, s3Rec.placentaDatetime ) of
                                ( Just bdt, Just pdt ) ->
                                    U.diff2DatesString bdt pdt

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
                [ H.text "Stage 3 Summary" ]
            , H.div []
                [ H.div
                    [ HA.class "o-fieldset form-wrapper"
                    ]
                    [ H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Stage 3 Total: " ]
                        , H.span [ HA.class "" ]
                            [ H.text s3Total ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Delivery spontaneous: " ]
                        , H.span [ HA.class "" ]
                            [ H.text delSpon ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Delivery AMTSL: " ]
                        , H.span [ HA.class "" ]
                            [ H.text delAMTSL ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Delivery CCT: " ]
                        , H.span [ HA.class "" ]
                            [ H.text delCCT ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Delivery manual: " ]
                        , H.span [ HA.class "" ]
                            [ H.text delMan ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Maternal position: " ]
                        , H.span [ HA.class "" ]
                            [ H.text matPos ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Treatments: " ]
                        , H.span [ HA.class "" ]
                            [ H.text treatment ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Placenta shape: " ]
                        , H.span [ HA.class "" ]
                            [ H.text shape ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Plancenta insertion: " ]
                        , H.span [ HA.class "" ]
                            [ H.text insertion ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Placenta num vessels: " ]
                        , H.span [ HA.class "" ]
                            [ H.text numVessels ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Schultz/Duncan: " ]
                        , H.span [ HA.class "" ]
                            [ H.text schDun ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Membranes complete: " ]
                        , H.span [ HA.class "" ]
                            [ H.text complete ]
                        ]
                    , H.div [ HA.class "mw-form-field-2x" ]
                        [ H.span [ HA.class "c-text--loud" ]
                            [ H.text "Placenta other: " ]
                        , H.span [ HA.class "" ]
                            [ H.text other ]
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


dialogStage3SummaryEdit : DialogStage3Summary -> Html SubMsg
dialogStage3SummaryEdit cfg =
    let
        errors =
            validateStage3 cfg.model

        deliveryFlds =
            [ Stage3PlacentaDeliverySpontaneousFld
            , Stage3PlacentaDeliveryAMTSLFld
            , Stage3PlacentaDeliveryCCTFld
            , Stage3PlacentaDeliveryManualFld
            ]

        deliveryErrorStr =
            List.filter (\( f, s ) -> List.member f deliveryFlds) errors
                |> List.map Tuple.second
                |> String.join ", "
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
                [ H.text "Stage 3 Summary - Edit" ]
            , H.div [ HA.class "form-wrapper u-small" ]
                [ H.div
                    [ HA.class "o-fieldset form-wrapper"
                    ]
                    [ H.label [ HA.class "c-label o-form-element mw-form-field" ]
                        [ H.span
                            [ HA.class "c-text--loud" ]
                            [ H.text "Placenta Delivery" ]
                        , Form.checkbox "Spontaneous"
                            (FldChgBool >> FldChgSubMsg Stage3PlacentaDeliverySpontaneousFld)
                            cfg.model.s3PlacentaDeliverySpontaneous
                        , Form.checkbox "AMTSL"
                            (FldChgBool >> FldChgSubMsg Stage3PlacentaDeliveryAMTSLFld)
                            cfg.model.s3PlacentaDeliveryAMTSL
                        , Form.checkbox "CCT"
                            (FldChgBool >> FldChgSubMsg Stage3PlacentaDeliveryCCTFld)
                            cfg.model.s3PlacentaDeliveryCCT
                        , Form.checkbox "Manual"
                            (FldChgBool >> FldChgSubMsg Stage3PlacentaDeliveryManualFld)
                            cfg.model.s3PlacentaDeliveryManual
                        , if String.length deliveryErrorStr > 0 then
                            H.div
                                [ HA.class "c-text--mono c-text--loud u-xsmall u-bg-yellow"
                                , HA.style
                                    [ ( "padding", "0.25em 0.25em" )
                                    , ( "margin", "0.75em 0 1.25em 0" )
                                    ]
                                ]
                                [ H.text deliveryErrorStr ]
                          else
                            H.span [] []
                        ]
                    , Form.radioFieldsetOther "Maternal Position"
                        "maternalPosition"
                        cfg.model.s3MaternalPosition
                        (FldChgString >> FldChgSubMsg Stage3MaternalPositionFld)
                        False
                        [ "Semi-sitting"
                        , "Lying on back"
                        , "Squat"
                        ]
                        (getErr Stage3MaternalPositionFld errors)
                    , H.div [ HA.class "mw-form-field" ]
                        [ H.span
                            [ HA.class "c-text--loud" ]
                            [ H.text "Tx for Blood Loss" ]
                        , Form.checkboxString "Oxytocin"
                            (FldChgString >> FldChgSubMsg Stage3TxBloodLoss1Fld)
                            cfg.model.s3TxBloodLoss1
                        , Form.checkboxString "IV"
                            (FldChgString >> FldChgSubMsg Stage3TxBloodLoss2Fld)
                            cfg.model.s3TxBloodLoss2
                        , Form.checkboxString "Bi-Manual Compression External/Internal"
                            (FldChgString >> FldChgSubMsg Stage3TxBloodLoss3Fld)
                            cfg.model.s3TxBloodLoss3
                        ]
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgString >> FldChgSubMsg Stage3PlacentaShapeFld)
                            "Placenta Shape"
                            "shape"
                            True
                            cfg.model.s3PlacentaShape
                            (getErr Stage3PlacentaShapeFld errors)
                        ]
                    , Form.radioFieldsetOther "Placenta Insertion"
                        "placentaInsertion"
                        cfg.model.s3PlacentaInsertion
                        (FldChgString >> FldChgSubMsg Stage3PlacentaInsertionFld)
                        False
                        [ "Central"
                        , "Semi-central"
                        , "Marginal"
                        ]
                        (getErr Stage3PlacentaInsertionFld errors)
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgString >> FldChgSubMsg Stage3PlacentaNumVesselsFld)
                            "Number vessels"
                            "a number"
                            True
                            cfg.model.s3PlacentaNumVessels
                            (getErr Stage3PlacentaNumVesselsFld errors)
                        ]
                    , Form.radioFieldset "Schultz/Duncan"
                        "schultzDuncan"
                        cfg.model.s3SchultzDuncan
                        (FldChgString >> FldChgSubMsg Stage3SchultzDuncanFld)
                        False
                        [ "Schultz"
                        , "Duncan"
                        ]
                        (getErr Stage3SchultzDuncanFld errors)
                    , H.div [ HA.class "" ]
                        [ H.span
                            [ HA.class "c-text--loud" ]
                            [ H.text "Placenta Membrane" ]
                        , Form.checkbox "Is Complete"
                            (FldChgBool >> FldChgSubMsg Stage3PlacentaMembranesCompleteFld)
                            cfg.model.s3PlacentaMembranesComplete
                        ]
                    , H.fieldset [ HA.class "o-fieldset mw-form-field" ]
                        [ Form.formField (FldChgString >> FldChgSubMsg Stage3PlacentaOtherFld)
                            "Inspection notes"
                            "notes"
                            True
                            cfg.model.s3PlacentaOther
                            (getErr Stage3PlacentaOtherFld errors)
                        ]
                    , Form.formTextareaField (FldChgString >> FldChgSubMsg Stage3CommentsFld)
                        "Comments"
                        ""
                        True
                        cfg.model.s3Comments
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
                                    { m | laborRecords = Just recs }

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
                                    Debug.log "LaborDelIpp.refreshModelFromCache: Unhandled Table" <| toString t
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

        TickSubMsg time ->
            -- Keep the current time in the Model.
            ( { model | currTime = time }, Cmd.none, Cmd.none )

        OpenDatePickerSubMsg id ->
            ( model, Cmd.none, Task.perform OpenDatePicker (Task.succeed id) )

        DateFieldSubMsg dateFldMsg ->
            -- For browsers that do not support a native date field.
            case dateFldMsg of
                DateFieldMessage { dateField, date } ->
                    case dateField of
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

                        _ ->
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

                        Stage3MaternalPositionFld ->
                            { model | s3MaternalPosition = Just value }

                        Stage3TxBloodLoss1Fld ->
                            let
                                _ =
                                    Debug.log "s3TxBloodLoss1" <| toString value
                            in
                                { model | s3TxBloodLoss1 = Just value }

                        Stage3TxBloodLoss2Fld ->
                            { model | s3TxBloodLoss2 = Just value }

                        Stage3TxBloodLoss3Fld ->
                            { model | s3TxBloodLoss3 = Just value }

                        Stage3TxBloodLoss4Fld ->
                            { model | s3TxBloodLoss4 = Just value }

                        Stage3TxBloodLoss5Fld ->
                            { model | s3TxBloodLoss5 = Just value }

                        Stage3PlacentaShapeFld ->
                            { model | s3PlacentaShape = Just value }

                        Stage3PlacentaInsertionFld ->
                            { model | s3PlacentaInsertion = Just value }

                        Stage3PlacentaNumVesselsFld ->
                            { model | s3PlacentaNumVessels = Just <| U.filterStringLikeInt value }

                        Stage3SchultzDuncanFld ->
                            -- TODO: need validity check here?
                            { model | s3SchultzDuncan = Just value }

                        Stage3PlacentaOtherFld ->
                            { model | s3PlacentaOther = Just value }

                        Stage3CommentsFld ->
                            { model | s3Comments = Just value }

                        FalseLaborDateFld ->
                            { model | falseLaborDate = Date.fromString value |> Result.toMaybe }

                        FalseLaborTimeFld ->
                            { model | falseLaborTime = Just <| U.filterStringLikeTime value }

                        _ ->
                            let
                                _ =
                                    Debug.log "LaborDelIpp.update FldChgSubMsg"
                                        "Unknown field encountered in FldChgString. Possible mismatch between Field and FldChgValue."
                            in
                                model
                    , Cmd.none
                    , Cmd.none
                    )

                FldChgBool value ->
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

                        Stage3PlacentaDeliverySpontaneousFld ->
                            { model | s3PlacentaDeliverySpontaneous = Just value }

                        Stage3PlacentaDeliveryAMTSLFld ->
                            { model | s3PlacentaDeliveryAMTSL = Just value }

                        Stage3PlacentaDeliveryCCTFld ->
                            { model | s3PlacentaDeliveryCCT = Just value }

                        Stage3PlacentaDeliveryManualFld ->
                            { model | s3PlacentaDeliveryManual = Just value }

                        Stage3PlacentaMembranesCompleteFld ->
                            { model | s3PlacentaMembranesComplete = Just value }

                        _ ->
                            let
                                _ =
                                    Debug.log "LaborDelIpp.update FldChgSubMsg"
                                        "Unknown field encountered in FldChgBool. Possible mismatch between Field and FldChgValue."
                            in
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
                -- fields with the contents of that record. But since it is possible
                -- that the laborStage2Record may only have minimal content, allow
                -- form fields in model to be used as alternatives.
                OpenDialog ->
                    let
                        newModel =
                            case model.laborStage2Record of
                                Just rec ->
                                    { model
                                        | s2BirthType = U.maybeOr rec.birthType model.s2BirthType
                                        , s2BirthPosition = U.maybeOr rec.birthPosition model.s2BirthPosition
                                        , s2DurationPushing = U.maybeOr (Maybe.map toString rec.durationPushing) model.s2DurationPushing
                                        , s2BirthPresentation = U.maybeOr rec.birthPresentation model.s2BirthPresentation
                                        , s2CordWrap = U.maybeOr rec.cordWrap model.s2CordWrap
                                        , s2CordWrapType = U.maybeOr rec.cordWrapType model.s2CordWrapType
                                        , s2DeliveryType = U.maybeOr rec.deliveryType model.s2DeliveryType
                                        , s2ShoulderDystocia = U.maybeOr rec.shoulderDystocia model.s2ShoulderDystocia
                                        , s2ShoulderDystociaMinutes = U.maybeOr (Maybe.map toString rec.shoulderDystociaMinutes) model.s2ShoulderDystociaMinutes
                                        , s2Laceration = U.maybeOr rec.laceration model.s2Laceration
                                        , s2Episiotomy = U.maybeOr rec.episiotomy model.s2Episiotomy
                                        , s2Repair = U.maybeOr rec.repair model.s2Repair
                                        , s2Degree = U.maybeOr rec.degree model.s2Degree
                                        , s2LacerationRepairedBy = U.maybeOr rec.lacerationRepairedBy model.s2LacerationRepairedBy
                                        , s2BirthEBL = U.maybeOr (Maybe.map toString rec.birthEBL) model.s2BirthEBL
                                        , s2Meconium = U.maybeOr rec.meconium model.s2Meconium
                                        , s2Comments = U.maybeOr rec.comments model.s2Comments
                                    }

                                Nothing ->
                                    model
                    in
                        -- We set the modal to View but it will show the edit screen
                        -- if there are fields not complete.
                        --
                        -- The if below allows the summary button to toggle on/off the form.
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
            case dialogState of
                OpenDialog ->
                    ( case ( model.stage3Date, model.stage3Time ) of
                        ( Nothing, Nothing ) ->
                            -- If not yet set, the set the date/time to
                            -- current as a convenience to user.
                            { model
                                | stage3DateTimeModal = Stage3DateTimeModal
                                , stage3Date = Just <| Date.fromTime model.currTime
                                , stage3Time = Just <| U.timeToTimeString model.currTime
                            }

                        ( _, _ ) ->
                            { model | stage3DateTimeModal = Stage3DateTimeModal }
                    , Cmd.none
                    , Cmd.none
                    )

                CloseNoSaveDialog ->
                    ( { model | stage3DateTimeModal = NoDateTimeModal }, Cmd.none, Cmd.none )

                EditDialog ->
                    -- This dialog option is not used for stage 3 date time.
                    ( model, Cmd.none, Cmd.none )

                CloseSaveDialog ->
                    -- Close and potentially send initial LaborStage3Record
                    -- to server as an add or update if it validates. An add will
                    -- send a LaborStage3RecordNew and an update uses the full
                    -- LaborStage3Record. The initial add is only sent if
                    -- both date and time are valid.
                    case validateStage3New model of
                        [] ->
                            let
                                outerMsg =
                                    case ( model.laborStage3Record, model.stage3Date, model.stage3Time ) of
                                        -- A laborStage3 record already exists, so update it.
                                        ( Just rec, Just d, Just t ) ->
                                            case U.stringToTimeTuple t of
                                                Just ( h, m ) ->
                                                    let
                                                        newRec =
                                                            { rec | placentaDatetime = Just (U.datePlusTimeTuple d ( h, m )) }
                                                    in
                                                        ProcessTypeMsg
                                                            (UpdateLaborStage3Type
                                                                (LaborDelIppMsg
                                                                    (DataCache Nothing (Just [ LaborStage3 ]))
                                                                )
                                                                newRec
                                                            )
                                                            ChgMsgType
                                                            (laborStage3RecordToValue newRec)

                                                Nothing ->
                                                    Noop

                                        ( Just rec, Nothing, Nothing ) ->
                                            -- User unset the placentaDatetime, so update the server.
                                            let
                                                newRec =
                                                    { rec | placentaDatetime = Nothing }
                                            in
                                                ProcessTypeMsg
                                                    (UpdateLaborStage3Type
                                                        (LaborDelIppMsg
                                                            (DataCache Nothing (Just [ LaborStage3 ]))
                                                        )
                                                        newRec
                                                    )
                                                    ChgMsgType
                                                    (laborStage3RecordToValue newRec)

                                        ( Nothing, Just _, Just _ ) ->
                                            -- Create a new laborStage3 record.
                                            case deriveLaborStage3RecordNew model of
                                                Just laborStage3RecNew ->
                                                    ProcessTypeMsg
                                                        (AddLaborStage3Type
                                                            (LaborDelIppMsg
                                                                -- Request top-level to provide data in
                                                                -- the dataCache once received from server.
                                                                (DataCache Nothing (Just [ LaborStage3 ]))
                                                            )
                                                            laborStage3RecNew
                                                        )
                                                        AddMsgType
                                                        (laborStage3RecordNewToValue laborStage3RecNew)

                                                Nothing ->
                                                    Noop

                                        ( _, _, _ ) ->
                                            Noop
                            in
                                ( { model
                                    | stage3DateTimeModal = NoDateTimeModal
                                  }
                                , Cmd.none
                                , Task.perform (always outerMsg) (Task.succeed True)
                                )

                        errors ->
                            -- TODO: show errors to user somehow???
                            ( { model | stage3DateTimeModal = NoDateTimeModal }
                            , Cmd.none
                            , logConsole <| toString errors
                            )

        HandleStage3SummaryModal dialogState ->
            case dialogState of
                -- If there already is a laborStage3Record, then populate the form
                -- fields with the contents of that record. But since it is possible
                -- that the laborStage3Record may only have minimal content, allow
                -- form fields in model to be used as alternatives.
                OpenDialog ->
                    let
                        newModel =
                            case model.laborStage3Record of
                                Just rec ->
                                    { model
                                        | s3PlacentaDeliverySpontaneous = U.maybeOr rec.placentaDeliverySpontaneous model.s3PlacentaDeliverySpontaneous
                                        , s3PlacentaDeliveryAMTSL = U.maybeOr rec.placentaDeliveryAMTSL model.s3PlacentaDeliveryAMTSL
                                        , s3PlacentaDeliveryCCT = U.maybeOr rec.placentaDeliveryCCT model.s3PlacentaDeliveryCCT
                                        , s3PlacentaDeliveryManual = U.maybeOr rec.placentaDeliveryManual model.s3PlacentaDeliveryManual
                                        , s3MaternalPosition = U.maybeOr rec.maternalPosition model.s3MaternalPosition
                                        , s3TxBloodLoss1 = U.maybeOr rec.txBloodLoss1 model.s3TxBloodLoss1
                                        , s3TxBloodLoss2 = U.maybeOr rec.txBloodLoss2 model.s3TxBloodLoss2
                                        , s3TxBloodLoss3 = U.maybeOr rec.txBloodLoss3 model.s3TxBloodLoss3
                                        , s3TxBloodLoss4 = U.maybeOr rec.txBloodLoss4 model.s3TxBloodLoss4
                                        , s3TxBloodLoss5 = U.maybeOr rec.txBloodLoss5 model.s3TxBloodLoss5
                                        , s3PlacentaShape = U.maybeOr rec.placentaShape model.s3PlacentaShape
                                        , s3PlacentaInsertion = U.maybeOr rec.placentaInsertion model.s3PlacentaInsertion
                                        , s3PlacentaNumVessels = U.maybeOr (Maybe.map toString rec.placentaNumVessels) model.s3PlacentaNumVessels
                                        , s3SchultzDuncan = U.maybeOr (Maybe.map schultzDuncan2String rec.schultzDuncan) model.s3SchultzDuncan
                                        , s3PlacentaMembranesComplete = U.maybeOr rec.placentaMembranesComplete model.s3PlacentaMembranesComplete
                                        , s3PlacentaOther = U.maybeOr rec.placentaOther model.s3PlacentaOther
                                        , s3Comments = U.maybeOr rec.comments model.s3Comments
                                    }

                                Nothing ->
                                    model
                    in
                        -- We set the modal to View but it will show the edit screen
                        -- if there are fields not complete.
                        --
                        -- The if below allows the summary button to toggle on/off the form.
                        ( { newModel
                            | stage3SummaryModal =
                                if newModel.stage3SummaryModal == NoStageSummaryModal then
                                    Stage3SummaryViewModal
                                else
                                    NoStageSummaryModal
                          }
                        , Cmd.none
                        , Cmd.none
                        )

                CloseNoSaveDialog ->
                    -- We keep whatever, if anything, the user entered into the
                    -- form fields.
                    ( { model | stage3SummaryModal = NoStageSummaryModal }
                    , Cmd.none
                    , Cmd.none
                    )

                EditDialog ->
                    -- Transitioning from a viewing summary state to editing again by
                    -- explicitly setting the mode to edit. This is different that
                    -- Stage3SummaryViewModal in that we are forcing edit here.
                    ( { model | stage3SummaryModal = Stage3SummaryEditModal }
                    , Cmd.none
                    , Cmd.none
                    )

                CloseSaveDialog ->
                    -- We save to the database if the form fields validate.
                    case validateStage3 model of
                        [] ->
                            let
                                outerMsg =
                                    case model.laborStage3Record of
                                        Just s3Rec ->
                                            -- A Stage 2 record already exists, so update it.
                                            let
                                                newRec =
                                                    { s3Rec
                                                        | placentaDeliverySpontaneous = model.s3PlacentaDeliverySpontaneous
                                                        , placentaDeliveryAMTSL = model.s3PlacentaDeliveryAMTSL
                                                        , placentaDeliveryCCT = model.s3PlacentaDeliveryCCT
                                                        , placentaDeliveryManual = model.s3PlacentaDeliveryManual
                                                        , maternalPosition = model.s3MaternalPosition
                                                        , txBloodLoss1 = model.s3TxBloodLoss1
                                                        , txBloodLoss2 = model.s3TxBloodLoss2
                                                        , txBloodLoss3 = model.s3TxBloodLoss3
                                                        , txBloodLoss4 = model.s3TxBloodLoss4
                                                        , txBloodLoss5 = model.s3TxBloodLoss5
                                                        , placentaShape = model.s3PlacentaShape
                                                        , placentaInsertion = model.s3PlacentaInsertion
                                                        , placentaNumVessels = U.maybeStringToMaybeInt model.s3PlacentaNumVessels
                                                        , schultzDuncan = string2SchultzDuncan (Maybe.withDefault "" model.s3SchultzDuncan)
                                                        , placentaMembranesComplete = model.s3PlacentaMembranesComplete
                                                        , placentaOther = model.s3PlacentaOther
                                                        , comments = model.s3Comments
                                                    }
                                            in
                                                ProcessTypeMsg
                                                    (UpdateLaborStage3Type
                                                        (LaborDelIppMsg
                                                            (DataCache Nothing (Just [ LaborStage3 ]))
                                                        )
                                                        newRec
                                                    )
                                                    ChgMsgType
                                                    (laborStage3RecordToValue newRec)

                                        Nothing ->
                                            -- Need to create a new stage 3 record for the server.
                                            case deriveLaborStage3RecordNew model of
                                                Just laborStage3RecNew ->
                                                    ProcessTypeMsg
                                                        (AddLaborStage3Type
                                                            (LaborDelIppMsg
                                                                -- Request top-level to provide data in
                                                                -- the dataCache once received from server.
                                                                (DataCache Nothing (Just [ LaborStage3 ]))
                                                            )
                                                            laborStage3RecNew
                                                        )
                                                        AddMsgType
                                                        (laborStage3RecordNewToValue laborStage3RecNew)

                                                Nothing ->
                                                    LogConsole "deriveLaborStage3RecordNew returned a Nothing"
                            in
                                ( { model | stage3SummaryModal = NoStageSummaryModal }
                                , Cmd.none
                                , Task.perform (always outerMsg) (Task.succeed True)
                                )

                        errors ->
                            let
                                msgs =
                                    List.map Tuple.second errors
                            in
                                ( { model | stage3SummaryModal = NoStageSummaryModal }
                                , Cmd.none
                                , toastError msgs 10
                                )

        HandleFalseLaborDateTimeModal dialogState ->
            -- The user has just opened the modal to set the date/time for a
            -- false labor. We default to the current date/time for convenience if
            -- this is an open event, but only if the date/time has not already
            -- been previously selected.
            case dialogState of
                OpenDialog ->
                    ( case ( model.falseLaborDate, model.falseLaborTime ) of
                        ( Nothing, Nothing ) ->
                            -- If not yet set, the set the date/time to
                            -- current as a convenience to user.
                            { model
                                | falseLaborDateTimeModal = FalseLaborDateTimeModal
                                , falseLaborDate = Just <| Date.fromTime model.currTime
                                , falseLaborTime = Just <| U.timeToTimeString model.currTime
                            }

                        ( _, _ ) ->
                            { model | falseLaborDateTimeModal = FalseLaborDateTimeModal }
                    , Cmd.none
                    , Cmd.none
                    )

                CloseNoSaveDialog ->
                    ( { model | falseLaborDateTimeModal = NoDateTimeModal }, Cmd.none, Cmd.none )

                EditDialog ->
                    -- This dialog option is not used for false labor date time.
                    ( model, Cmd.none, Cmd.none )

                CloseSaveDialog ->
                    -- Close and send LaborRecord to server as an update.
                    case ( model.falseLaborDate, model.falseLaborTime, model.currLaborId, model.laborRecords ) of
                        ( Just d, Just t, Just laborId, Just recs ) ->
                            -- Setting date/time and setting the labor as a false labor.
                            case Dict.get (getLaborId laborId) recs of
                                Just laborRecord ->
                                    case U.stringToTimeTuple t of
                                        Just ( h, m ) ->
                                            let
                                                newLaborRec =
                                                    { laborRecord
                                                        | dischargeDate = Just (U.datePlusTimeTuple d ( h, m ))
                                                        , falseLabor = True
                                                    }

                                                outerMsg =
                                                    ProcessTypeMsg
                                                        (UpdateLaborType
                                                            (LaborDelIppMsg
                                                                (DataCache Nothing (Just [ Labor ]))
                                                            )
                                                            newLaborRec
                                                        )
                                                        ChgMsgType
                                                        (laborRecordToValue newLaborRec)
                                            in
                                                ( { model
                                                    | falseLaborDateTimeModal = NoDateTimeModal
                                                  }
                                                , Cmd.none
                                                , Task.perform (always outerMsg) (Task.succeed True)
                                                )

                                        Nothing ->
                                            -- Time in the form is not right, so do nothing.
                                            ( model, Cmd.none, Cmd.none )

                                Nothing ->
                                    -- Shouldn't get here because there has to be a labor record.
                                    ( { model
                                        | falseLaborDateTimeModal = NoDateTimeModal
                                        , falseLaborDate = Nothing
                                        , falseLaborTime = Nothing
                                      }
                                    , Cmd.none
                                    , Cmd.none
                                    )

                        ( _, _, Just laborId, Just recs ) ->
                            -- Clearing the date/time therefore undoing the false labor
                            -- and updating the server accordingly.
                            case Dict.get (getLaborId laborId) recs of
                                Just laborRecord ->
                                    let
                                        newLaborRec =
                                            { laborRecord
                                                | dischargeDate = Nothing
                                                , falseLabor = False
                                            }

                                        outerMsg =
                                            ProcessTypeMsg
                                                (UpdateLaborType
                                                    (LaborDelIppMsg
                                                        (DataCache Nothing (Just [ Labor ]))
                                                    )
                                                    newLaborRec
                                                )
                                                ChgMsgType
                                                (laborRecordToValue newLaborRec)
                                    in
                                        ( { model
                                            | falseLaborDateTimeModal = NoDateTimeModal
                                          }
                                        , Cmd.none
                                        , Task.perform (always outerMsg) (Task.succeed True)
                                        )

                                Nothing ->
                                    -- Shouldn't get here because labor record not found.
                                    ( model, Cmd.none, Cmd.none )

                        ( _, _, _, _ ) ->
                            -- Shouldn't get here because there has to be a labor record.
                            ( model, Cmd.none, Cmd.none )

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

        ClearFalseLaborDateTime ->
            ( { model
                | falseLaborDate = Nothing
                , falseLaborTime = Nothing
              }
            , Cmd.none
            , Cmd.none
            )

        LaborDetailsLoaded ->
            ( model, Cmd.none, logConsole "LaborDelIpp.update LaborDetailsLoaded" )

        ViewLaborRecord laborId ->
            ( { model
                | currLaborId = Just laborId
              }
            , Cmd.none
            , Cmd.none
            )


{-| Derive a LaborStage1RecordNew from the form fields, if possible.
-}
deriveLaborStage1RecordNew : Model -> Maybe LaborStage1RecordNew
deriveLaborStage1RecordNew model =
    case model.currLaborId of
        Just (LaborId id) ->
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
    case model.currLaborId of
        Just (LaborId id) ->
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


deriveLaborStage3RecordNew : Model -> Maybe LaborStage3RecordNew
deriveLaborStage3RecordNew model =
    case model.currLaborId of
        Just (LaborId id) ->
            let
                placentaDatetime =
                    case ( model.stage3Date, model.stage3Time ) of
                        ( Just d, Just t ) ->
                            case U.stringToTimeTuple t of
                                Just tt ->
                                    Just <| U.datePlusTimeTuple d tt

                                Nothing ->
                                    Nothing

                        ( _, _ ) ->
                            Nothing
            in
                LaborStage3RecordNew placentaDatetime
                    model.s3PlacentaDeliverySpontaneous
                    model.s3PlacentaDeliveryAMTSL
                    model.s3PlacentaDeliveryCCT
                    model.s3PlacentaDeliveryManual
                    model.s3MaternalPosition
                    model.s3TxBloodLoss1
                    model.s3TxBloodLoss2
                    model.s3TxBloodLoss3
                    model.s3TxBloodLoss4
                    model.s3TxBloodLoss5
                    model.s3PlacentaShape
                    model.s3PlacentaInsertion
                    (U.maybeStringToMaybeInt model.s3PlacentaNumVessels)
                    (string2SchultzDuncan (Maybe.withDefault "" model.s3SchultzDuncan))
                    model.s3PlacentaMembranesComplete
                    model.s3PlacentaOther
                    model.s3Comments
                    id
                    |> Just

        _ ->
            Nothing



-- VALIDATION of the LaborDelIpp Model form fields, not the records sent to the server. --


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


validateStage3New : Model -> List FieldError
validateStage3New =
    Validate.all
        [ .stage3Time >> ifInvalid U.validateJustTime (Stage3TimeFld => "Time must be provided in hh:mm format.")
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


validateStage3 : Model -> List FieldError
validateStage3 =
    Validate.all
        [ (\mdl ->
            -- All four bools are not Nothing and not all False.
            if
                (U.validateBool mdl.s3PlacentaDeliverySpontaneous
                    && U.validateBool mdl.s3PlacentaDeliveryAMTSL
                    && U.validateBool mdl.s3PlacentaDeliveryCCT
                    && U.validateBool mdl.s3PlacentaDeliveryManual
                )
                    || ((not <| Maybe.withDefault False mdl.s3PlacentaDeliverySpontaneous)
                            && (not <| Maybe.withDefault False mdl.s3PlacentaDeliveryAMTSL)
                            && (not <| Maybe.withDefault False mdl.s3PlacentaDeliveryCCT)
                            && (not <| Maybe.withDefault False mdl.s3PlacentaDeliveryManual)
                       )
            then
                [ (Stage3PlacentaDeliverySpontaneousFld => "You must check one of the placenta delivery types.") ]
            else
                []
          )
        , .s3MaternalPosition >> ifInvalid U.validatePopulatedString (Stage3MaternalPositionFld => "Maternal position must be provided.")
        , .s3PlacentaShape >> ifInvalid U.validatePopulatedString (Stage3PlacentaShapeFld => "Placenta shape must be provided.")
        , .s3PlacentaInsertion >> ifInvalid U.validatePopulatedString (Stage3PlacentaInsertionFld => "Placenta insertion must be provided.")
        , .s3PlacentaNumVessels >> ifInvalid U.validateInt (Stage3PlacentaNumVesselsFld => "Number of vessels must be provided.")
        , .s3SchultzDuncan >> ifInvalid U.validatePopulatedString (Stage3SchultzDuncanFld => "Schultz or Duncan presentation must be provided.")
        ]
