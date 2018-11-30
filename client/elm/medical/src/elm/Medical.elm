module Medical exposing (..)

-- LOCAL IMPORTS --

import Data.Admitting exposing (AdmittingSubMsg(..))
import Data.Baby exposing (BabyId(..), babyRecordNewToBabyRecord)
import Data.BabyLab exposing (BabyLabId(..), babyLabRecordNewToBabyLabRecord)
import Data.BabyMedication exposing (BabyMedicationId(..), babyMedicationRecordNewToBabyMedicationRecord)
import Data.BabyVaccination exposing (BabyVaccinationId(..), babyVaccinationRecordNewToBabyVaccinationRecord)
import Data.BirthCert exposing (SubMsg(..))
import Data.BirthCertificate
    exposing
        ( BirthCertificateId(..)
        , birthCertificateRecordNewToBirthCertificateRecord
        )
import Data.ContPP exposing (SubMsg(..))
import Data.ContPostpartumCheck exposing (ContPostpartumCheckId(..), contPostpartumCheckRecordNewToContPostpartumCheckRecord)
import Data.DataCache as DCache exposing (DataCache(..))
import Data.DatePicker as DDP exposing (DateField(..), DateFieldMessage(..))
import Data.Discharge exposing (DischargeId(..), dischargeRecordNewToDischargeRecord)
import Data.Labor as Labor exposing (LaborId(..), LaborRecord, laborRecordNewToLaborRecord)
import Data.LaborDelIpp exposing (SubMsg(..))
import Data.LaborStage1 exposing (LaborStage1Id(..), laborStage1RecordNewToLaborStage1Record)
import Data.LaborStage2 exposing (LaborStage2Id(..), laborStage2RecordNewToLaborStage2Record)
import Data.LaborStage3 exposing (LaborStage3Id(..), laborStage3RecordNewToLaborStage3Record)
import Data.Log exposing (logToValue, severityToString, Severity(..))
import Data.Membrane exposing (MembraneId(..), membraneRecordNewToMembraneRecord)
import Data.Message exposing (DataNotificationMsg, IncomingMessage(..), MsgType(..), wrapPayload)
import Data.MotherMedication exposing (MotherMedicationId(..), motherMedicationRecordNewToMotherMedicationRecord)
import Data.NewbornExam exposing (NewbornExamId(..), newbornExamRecordNewToNewbornExamRecord)
import Data.Patient exposing (PatientRecord)
import Data.Postpartum exposing (SubMsg(..))
import Data.PostpartumCheck exposing (PostpartumCheckId(..), postpartumCheckRecordNewToPostpartumCheckRecord)
import Data.Pregnancy as Pregnancy exposing (PregnancyId(..), PregnancyRecord, getPregId)
import Data.Processing exposing (ProcessId(..))
import Data.SelectQuery exposing (SelectQuery, selectQueryToValue)
import Data.Session as Session exposing (Session, clientTouch, doTouch, serverTouch)
import Data.SystemMessage exposing (SystemMessageType(..))
import Data.Table exposing (Table(..))
import Data.TableRecord exposing (TableRecord(..))
import Data.Toast exposing (ToastRecord, ToastType(..))
import Date exposing (Date)
import Dict exposing (Dict)
import Html as H exposing (Html)
import Json.Decode as JD
import Json.Decode.Pipeline as Pipeline exposing (decode, optional, required)
import Json.Encode as JE
import List.Extra as LE
import Model exposing (Model, Page(..), PageState(..))
import Msg exposing (Msg(..), ProcessType(..), logInfo)
import Navigation exposing (Location)
import Page.Admitting as PageAdmitting
import Page.BirthCert as PageBirthCert
import Page.ContPP as PageContPP
import Page.Errored as Errored exposing (PageLoadError, view)
import Page.LaborDelIpp as PageLaborDelIpp
import Page.NotFound as NotFound exposing (view)
import Page.Postpartum as PagePostpartum
import Ports
import Processing
import Route exposing (Route(..), fromLocation)
import Task exposing (Task)
import Time exposing (Time)
import Util as U exposing ((=>))
import Views.Page as ViewsPage exposing (ActivePage)
import Window


type alias Flags =
    { pregId : Maybe String
    , currTime : Float
    , browserSupportsDate : Bool
    }


flagsDecoder : JD.Decoder Flags
flagsDecoder =
    decode Flags
        |> required "pregId" (JD.nullable JD.string)
        |> required "currTime" JD.float
        |> required "browserSupportsDate" JD.bool


decodeFlagsFromJson : JD.Value -> Flags
decodeFlagsFromJson json =
    JD.decodeValue flagsDecoder json
        |> Result.withDefault (Flags Nothing 0 False)


init : JD.Value -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        flagsDecoded =
            decodeFlagsFromJson flags

        pregId =
            case flagsDecoded.pregId of
                Just pid ->
                    String.toInt pid
                        |> Result.map PregnancyId
                        |> Result.toMaybe

                Nothing ->
                    Nothing

        ( newModel, newCmd ) =
            setRoute (Route.fromLocation location) <|
                Model.initialModel flagsDecoded.browserSupportsDate
                    pregId
                    flagsDecoded.currTime
    in
    ( newModel
    , Cmd.batch [ newCmd, Task.perform (\s -> WindowResize (Just s)) Window.size ]
    )



-- VIEW --


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage model False page

        TransitioningFrom page ->
            viewPage model True page


viewPage : Model -> Bool -> Page -> Html Msg
viewPage model isLoading page =
    let
        frame =
            ViewsPage.frame model.window isLoading model.currPregId model.session.user model.toast
    in
    case page of
        Blank ->
            H.text "Blank page"

        NotFound ->
            NotFound.view model.session
                |> frame ViewsPage.Other

        Admitting subModel ->
            PageAdmitting.view model.window model.session subModel
                |> frame ViewsPage.Admitting
                |> H.map AdmittingMsg

        BirthCert subModel ->
            PageBirthCert.view model.window model.session subModel
                |> frame ViewsPage.BirthCert
                |> H.map BirthCertMsg

        ContPP subModel ->
            PageContPP.view model.window model.session subModel
                |> frame ViewsPage.ContPP
                |> H.map ContPPMsg

        LaborDelIpp subModel ->
            PageLaborDelIpp.view model.window model.session subModel
                |> frame ViewsPage.LaborDelIpp
                |> H.map LaborDelIppMsg

        Postpartum subModel ->
            PagePostpartum.view model.window model.session subModel
                |> frame ViewsPage.Postpartum
                |> H.map PostpartumMsg

        Errored subModel ->
            Errored.view model.session subModel
                |> frame ViewsPage.Other


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page



-- UPDATE --


getPregnancyRecordFromCache : Dict String DataCache -> Maybe PregnancyRecord
getPregnancyRecordFromCache dc =
    case DCache.get Pregnancy dc of
        Just (PregnancyDataCache prec) ->
            Just prec

        _ ->
            Nothing


getPatientRecordFromCache : Dict String DataCache -> Maybe PatientRecord
getPatientRecordFromCache dc =
    case DCache.get Patient dc of
        Just (PatientDataCache prec) ->
            Just prec

        _ ->
            Nothing


getLaborRecordFromCache : Dict String DataCache -> Maybe LaborRecord
getLaborRecordFromCache dc =
    case DCache.get Labor dc of
        Just (LaborDataCache lrec) ->
            Just lrec

        _ ->
            Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg noAutoTouchModel =
    let
        -- We assume that the msg is some form of user interaction with the
        -- client application, so we "touch" the session accordingly and store
        -- the result in model. Those conditions below that do not represent
        -- some sort of client interaction should use the noAutoTouchModel
        -- instead of model.
        model =
            { noAutoTouchModel | session = clientTouch noAutoTouchModel.session noAutoTouchModel.currTime }

        page =
            getPage model.pageState

        updateForPage page routingMsg theModel subUpdate subMsg subModel =
            let
                ( newModel, innerCmd, outerCmd ) =
                    subUpdate subMsg subModel
            in
            ( { theModel | pageState = Loaded (page newModel) }, Cmd.batch [ outerCmd, Cmd.map routingMsg innerCmd ] )
    in
    case ( msg, page ) of
        ( Noop, _ ) ->
            model => Cmd.none

        ( Tick time, page ) ->
            -- 1. Keep the current time in the Model.
            -- 2. Reduce the secondsLeft of the active toast if there is one.
            -- 3. "Touch" the server in order to keep the user's session
            --    active if necessary.
            -- 4. Finally, send the time down to the pages that are interested.
            let
                newToast =
                    case noAutoTouchModel.toast of
                        Just t ->
                            if t.secondsLeft - 1 <= 0 then
                                Nothing
                            else
                                Just { t | secondsLeft = t.secondsLeft - 1 }

                        Nothing ->
                            Nothing

                ( newSession, newCmd ) =
                    doTouch noAutoTouchModel.session noAutoTouchModel.currTime

                newModel =
                    { noAutoTouchModel
                        | currTime = time
                        , toast = newToast
                        , session = newSession
                    }

                -- We send the time to all of the pages that are interested here.
                ( newModel2, newCmd2 ) =
                    case page of
                        Admitting subModel ->
                            updateForPage Admitting
                                AdmittingMsg
                                newModel
                                (PageAdmitting.update newModel.session)
                                (AdmittingTick time)
                                subModel

                        BirthCert subModel ->
                            updateForPage BirthCert
                                BirthCertMsg
                                newModel
                                (PageBirthCert.update newModel.session)
                                (BirthCertTick time)
                                subModel

                        ContPP subModel ->
                            updateForPage ContPP
                                ContPPMsg
                                newModel
                                (PageContPP.update newModel.session)
                                (ContPPTick time)
                                subModel

                        LaborDelIpp subModel ->
                            updateForPage LaborDelIpp
                                LaborDelIppMsg
                                newModel
                                (PageLaborDelIpp.update newModel.session)
                                (LaborDelIppTick time)
                                subModel

                        Postpartum subModel ->
                            updateForPage Postpartum
                                PostpartumMsg
                                newModel
                                (PagePostpartum.update newModel.session)
                                (PostpartumTick time)
                                subModel

                        _ ->
                            newModel => Cmd.none
            in
            newModel2 => Cmd.batch [ newCmd, newCmd2 ]

        ( Log severity msg, _ ) ->
            -- Write a message to the console in development and to the server always.
            model
                => (wrapPayload (ProcessId -1)
                        AdhocClientConsole
                        (logToValue severity
                            (Debug.log (severityToString severity) msg)
                            model.currTime
                        )
                        |> Ports.outgoing
                   )

        ( Toast msgs seconds toastType, _ ) ->
            -- Publish a toast for the user to see.
            { model | toast = Just <| ToastRecord msgs seconds toastType } => Cmd.none

        ( WindowResize size, _ ) ->
            -- Keep the current window size in the Model.
            { model | window = size } => Cmd.none

        ( SetDialogActive bool, _ ) ->
            -- This allows the top-level to know whether one of the pages has a dialog
            -- open, which changes the route in order that the browser back button only
            -- closes the dialog instead of truly going back a page. By knowing whether
            -- a setRoute request is due to a dialog being open or not allows us to
            -- decide whether we need to request all of the data for the page or not.
            -- This in turn makes the user experience more seamless.
            { model | dialogActive = bool } => Cmd.none

        ( Message incoming, _ ) ->
            -- All messages from the server come through here first.
            -- We record the time of the last contact with the server in order
            -- to better maintain a session with the server. See
            -- Data/Session.elm for details. We use noAutoTouchModel
            -- because this is not a client touch, but a server touch.
            updateMessage incoming
                { noAutoTouchModel
                    | session = serverTouch noAutoTouchModel.session noAutoTouchModel.currTime
                }

        ( ProcessTypeMsg processType msgType jeVal, _ ) ->
            -- Send a message to the server and store the required information
            -- in the model for processing the server response.
            -- NOTE: currently data queries do not come through here.
            let
                ( processId, processStore ) =
                    Processing.add processType Nothing model.processStore
            in
            ( { model | processStore = processStore }
            , Ports.outgoing <| wrapPayload processId msgType jeVal
            )

        ( AdmittingLoaded pregId, _ ) ->
            let
                laborRecord =
                    getLaborRecordFromCache model.dataCache

                patientRecord =
                    getPatientRecordFromCache model.dataCache

                pregnancyRecord =
                    getPregnancyRecordFromCache model.dataCache

                ( subModel, newStore, newCmd ) =
                    PageAdmitting.buildModel model.browserSupportsDate
                        model.currTime
                        model.processStore
                        pregId
                        patientRecord
                        pregnancyRecord
                        laborRecord
            in
            { model
                | pageState = Loaded (Admitting subModel)
                , processStore = newStore
            }
                => newCmd

        ( AdmittingSelectQuery tbl key relatedTables, Admitting subModel ) ->
            -- Request by the sub page to retrieve additional data from the
            -- server after the page's initialization and load is already
            -- complete.
            let
                ( store, newCmd ) =
                    PageAdmitting.getTablesByCacheOrServer model.processStore tbl key relatedTables model.dataCache
            in
            { model | processStore = store } => newCmd

        ( BirthCertLoaded pregId laborRec, _ ) ->
            -- This page has enough of what it needs from the server in order
            -- to display the page. The newCmd returned from
            -- PageBirthCert.buildModel may request more data from the server.
            let
                -- Get the labor stage 2 record from the data cache which the
                -- init function just requested records from the server for.
                babyRec =
                    case DCache.get Baby model.dataCache of
                        Just (BabyDataCache babyRec) ->
                            Just babyRec

                        _ ->
                            Nothing

                stage2 =
                    case DCache.get LaborStage2 model.dataCache of
                        Just (LaborStage2DataCache s2) ->
                            Just s2

                        _ ->
                            Nothing

                patientRecord =
                    getPatientRecordFromCache model.dataCache

                pregnancyRecord =
                    getPregnancyRecordFromCache model.dataCache

                ( subModel, newStore, newCmd ) =
                    PageBirthCert.buildModel laborRec
                        stage2
                        babyRec
                        model.browserSupportsDate
                        model.currTime
                        model.processStore
                        pregId
                        patientRecord
                        pregnancyRecord
            in
            { model
                | pageState = Loaded (BirthCert subModel)
                , processStore = newStore
            }
                => newCmd

        ( BirthCertMsg subMsg, BirthCert subModel ) ->
            -- All BirthCert page sub messages are routed here.
            let
                -- If the subMsg is DataCache, revise the subMsg by adding
                -- the current dataCache to it.
                newSubMsg =
                    case subMsg of
                        Data.BirthCert.DataCache _ tbl ->
                            Data.BirthCert.DataCache (Just model.dataCache) tbl

                        _ ->
                            subMsg
            in
            updateForPage BirthCert
                BirthCertMsg
                model
                (PageBirthCert.update model.session)
                newSubMsg
                subModel

        ( BirthCertSelectQuery tbl key relatedTables, BirthCert subModel ) ->
            -- Request by the sub page to retrieve additional data from the
            -- server after the page's initialization and load is already
            -- complete.
            let
                ( store, newCmd ) =
                    PageBirthCert.getTablesByCacheOrServer model.processStore tbl key relatedTables model.dataCache
            in
            { model | processStore = store } => newCmd

        ( ContPPLoaded pregId laborRec, _ ) ->
            -- This page has enough of what it needs from the server in order
            -- to display the page. The newCmd returned from
            -- PageContPP.buildModel may request more data from the server.
            let
                -- Get the labor stage records from the data cache which the
                -- init function just requested records from the server for.
                ( babyRec, stage1, stage2, stage3, contPPCheck, motherMedication, discharge ) =
                    ( case DCache.get Baby model.dataCache of
                        Just (BabyDataCache baby) ->
                            Just baby

                        _ ->
                            Nothing
                    , case DCache.get LaborStage1 model.dataCache of
                        Just (LaborStage1DataCache s1) ->
                            Just s1

                        _ ->
                            Nothing
                    , case DCache.get LaborStage2 model.dataCache of
                        Just (LaborStage2DataCache s2) ->
                            Just s2

                        _ ->
                            Nothing
                    , case DCache.get LaborStage3 model.dataCache of
                        Just (LaborStage3DataCache s3) ->
                            Just s3

                        _ ->
                            Nothing
                    , case DCache.get ContPostpartumCheck model.dataCache of
                        Just (ContPostpartumCheckDataCache recs) ->
                            -- Not a Maybe.
                            recs

                        _ ->
                            []
                    , case DCache.get MotherMedication model.dataCache of
                        Just (MotherMedicationDataCache recs) ->
                            recs

                        _ ->
                            []
                    , case DCache.get Discharge model.dataCache of
                        Just (DischargeDataCache rec) ->
                            Just rec

                        _ ->
                            Nothing
                    )

                patientRecord =
                    getPatientRecordFromCache model.dataCache

                pregnancyRecord =
                    getPregnancyRecordFromCache model.dataCache

                ( subModel, newStore, newCmd ) =
                    PageContPP.buildModel laborRec
                        stage1
                        stage2
                        stage3
                        contPPCheck
                        motherMedication
                        discharge
                        babyRec
                        model.browserSupportsDate
                        model.currTime
                        model.processStore
                        pregId
                        patientRecord
                        pregnancyRecord
            in
            { model
                | pageState = Loaded (ContPP subModel)
                , processStore = newStore
            }
                => newCmd

        ( ContPPMsg subMsg, ContPP subModel ) ->
            -- All ContPP page sub messages are routed here.
            let
                -- If the subMsg is DataCache, revise the subMsg by adding
                -- the current dataCache to it.
                newSubMsg =
                    case subMsg of
                        Data.ContPP.DataCache _ tbl ->
                            Data.ContPP.DataCache (Just model.dataCache) tbl

                        _ ->
                            subMsg
            in
            updateForPage ContPP
                ContPPMsg
                model
                (PageContPP.update model.session)
                newSubMsg
                subModel

        ( ContPPSelectQuery tbl key relatedTables, ContPP subModel ) ->
            -- Request by the sub page to retrieve additional data from the
            -- server after the page's initialization and load is already
            -- complete.
            let
                ( store, newCmd ) =
                    PageContPP.getTablesByCacheOrServer model.processStore tbl key relatedTables model.dataCache
            in
            { model | processStore = store } => newCmd

        ( LaborDelIppLoaded pregId, _ ) ->
            -- This page has enough of what it needs from the server in order
            -- to display the page. The newCmd returned from
            -- PageLaborDelIpp.buildModel may request more data from the server.
            let
                laborRecord =
                    getLaborRecordFromCache model.dataCache

                patientRecord =
                    getPatientRecordFromCache model.dataCache

                pregnancyRecord =
                    getPregnancyRecordFromCache model.dataCache

                ( subModel, newStore, newCmd ) =
                    PageLaborDelIpp.buildModel model.browserSupportsDate
                        model.currTime
                        model.processStore
                        pregId
                        patientRecord
                        pregnancyRecord
                        laborRecord
            in
            { model
                | pageState = Loaded (LaborDelIpp subModel)
                , processStore = newStore
            }
                => newCmd

        ( LaborDelIppMsg subMsg, LaborDelIpp subModel ) ->
            -- All LaborDelIpp page sub messages are routed here.
            let
                -- If the subMsg is DataCache, revise the subMsg by adding
                -- the current dataCache to it.
                newSubMsg =
                    case subMsg of
                        Data.LaborDelIpp.DataCache _ tbl ->
                            Data.LaborDelIpp.DataCache (Just model.dataCache) tbl

                        _ ->
                            subMsg
            in
            updateForPage LaborDelIpp
                LaborDelIppMsg
                model
                (PageLaborDelIpp.update model.session)
                newSubMsg
                subModel

        ( LaborDelIppSelectQuery tbl key relatedTables, LaborDelIpp subModel ) ->
            -- Request by the sub page to retrieve additional data from the
            -- server after the page's initialization and load is already
            -- complete.
            let
                ( store, newCmd ) =
                    PageLaborDelIpp.getTablesByCacheOrServer model.processStore tbl key relatedTables model.dataCache
            in
            { model | processStore = store } => newCmd

        ( PostpartumLoaded pregId laborRec, _ ) ->
            -- This page has enough of what it needs from the server in order
            -- to display the page. The newCmd returned from
            -- PagePostpartum.buildModel may request more data from the server.
            let
                -- Get the labor stage records from the data cache which the
                -- init function just requested records from the server for.
                ( babyRec, stage1, stage2, stage3, contPPChecks, postpartumCheck ) =
                    ( case DCache.get Baby model.dataCache of
                        Just (BabyDataCache baby) ->
                            Just baby

                        _ ->
                            Nothing
                    , case DCache.get LaborStage1 model.dataCache of
                        Just (LaborStage1DataCache s1) ->
                            Just s1

                        _ ->
                            Nothing
                    , case DCache.get LaborStage2 model.dataCache of
                        Just (LaborStage2DataCache s2) ->
                            Just s2

                        _ ->
                            Nothing
                    , case DCache.get LaborStage3 model.dataCache of
                        Just (LaborStage3DataCache s3) ->
                            Just s3

                        _ ->
                            Nothing
                    , case DCache.get ContPostpartumCheck model.dataCache of
                        Just (ContPostpartumCheckDataCache recs) ->
                            -- Not a Maybe.
                            recs

                        _ ->
                            []
                    , case DCache.get PostpartumCheck model.dataCache of
                        Just (PostpartumCheckDataCache recs) ->
                            -- Not a Maybe.
                            recs

                        _ ->
                            []
                    )

                patientRecord =
                    getPatientRecordFromCache model.dataCache

                pregnancyRecord =
                    getPregnancyRecordFromCache model.dataCache

                ( subModel, newStore, newCmd ) =
                    PagePostpartum.buildModel laborRec
                        stage1
                        stage2
                        stage3
                        contPPChecks
                        babyRec
                        postpartumCheck
                        model.browserSupportsDate
                        model.currTime
                        model.processStore
                        pregId
                        patientRecord
                        pregnancyRecord
            in
            { model
                | pageState = Loaded (Postpartum subModel)
                , processStore = newStore
            }
                => newCmd

        ( PostpartumMsg subMsg, Postpartum subModel ) ->
            -- All Postpartum page sub messages are routed here.
            let
                -- If the subMsg is DataCache, revise the subMsg by adding
                -- the current dataCache to it.
                newSubMsg =
                    case subMsg of
                        Data.Postpartum.DataCache _ tbl ->
                            Data.Postpartum.DataCache (Just model.dataCache) tbl

                        _ ->
                            subMsg
            in
            updateForPage Postpartum
                PostpartumMsg
                model
                (PagePostpartum.update model.session)
                newSubMsg
                subModel

        ( PostpartumSelectQuery tbl key relatedTables, Postpartum subModel ) ->
            -- Request by the sub page to retrieve additional data from the
            -- server after the page's initialization and load is already
            -- complete.
            let
                ( store, newCmd ) =
                    PagePostpartum.getTablesByCacheOrServer model.processStore tbl key relatedTables model.dataCache
            in
            { model | processStore = store } => newCmd

        ( AdmittingMsg subMsg, Admitting subModel ) ->
            -- All Admitting page sub messages are routed here.
            let
                -- If the subMsg is DataCache, revise the subMsg by adding
                -- the current dataCache to it.
                newSubMsg =
                    case subMsg of
                        Data.Admitting.DataCache _ tbl ->
                            Data.Admitting.DataCache (Just model.dataCache) tbl

                        _ ->
                            subMsg
            in
            updateForPage Admitting
                AdmittingMsg
                model
                (PageAdmitting.update model.session)
                newSubMsg
                subModel

        ( SetRoute route, page ) ->
            -- Handle route changes.
            let
                ( newModel, newCmd ) =
                    setRoute route model
            in
            -- If we are returning from an open dialog, inform the page to
            -- close all dialogs.
            if model.dialogActive && not newModel.dialogActive then
                case page of
                    BirthCert subModel ->
                        updateForPage BirthCert
                            BirthCertMsg
                            newModel
                            (PageBirthCert.update model.session)
                            Data.BirthCert.CloseAllDialogs
                            subModel

                    ContPP subModel ->
                        updateForPage ContPP
                            ContPPMsg
                            newModel
                            (PageContPP.update model.session)
                            Data.ContPP.CloseAllDialogs
                            subModel

                    LaborDelIpp subModel ->
                        updateForPage LaborDelIpp
                            LaborDelIppMsg
                            newModel
                            (PageLaborDelIpp.update model.session)
                            Data.LaborDelIpp.CloseAllDialogs
                            subModel

                    Postpartum subModel ->
                        updateForPage Postpartum
                            PostpartumMsg
                            newModel
                            (PagePostpartum.update model.session)
                            Data.Postpartum.CloseAllDialogs
                            subModel

                    _ ->
                        newModel => newCmd
            else
                newModel => newCmd

        ( OpenDatePicker id, _ ) ->
            -- For browsers without native date support in the input element,
            -- open a jQueryUI datepicker for the user.
            model => Ports.openDatePicker (JE.string id)

        ( IncomingDatePicker dateFieldMsg, Admitting subModel ) ->
            -- For browsers without native date support in the input element,
            -- receive the user's date selection from the jQueryUI datepicker.
            updateForPage Admitting
                AdmittingMsg
                model
                (PageAdmitting.update model.session)
                (Data.Admitting.DateFieldSubMsg dateFieldMsg)
                subModel

        ( IncomingDatePicker dateFieldMsg, BirthCert subModel ) ->
            -- For browsers without native date support in the input element,
            -- receive the user's date selection from the jQueryUI datepicker.
            updateForPage BirthCert
                BirthCertMsg
                model
                (PageBirthCert.update model.session)
                (Data.BirthCert.DateFieldSubMsg dateFieldMsg)
                subModel

        ( IncomingDatePicker dateFieldMsg, LaborDelIpp subModel ) ->
            -- For browsers without native date support in the input element,
            -- receive the user's date selection from the jQueryUI datepicker.
            updateForPage LaborDelIpp
                LaborDelIppMsg
                model
                (PageLaborDelIpp.update model.session)
                (Data.LaborDelIpp.DateFieldSubMsg dateFieldMsg)
                subModel

        ( IncomingDatePicker dateFieldMsg, ContPP subModel ) ->
            -- For browsers without native date support in the input element,
            -- receive the user's date selection from the jQueryUI datepicker.
            updateForPage ContPP
                ContPPMsg
                model
                (PageContPP.update model.session)
                (Data.ContPP.DateFieldSubMsg dateFieldMsg)
                subModel

        ( IncomingDatePicker dateFieldMsg, Postpartum subModel ) ->
            -- For browsers without native date support in the input element,
            -- receive the user's date selection from the jQueryUI datepicker.
            updateForPage Postpartum
                PostpartumMsg
                model
                (PagePostpartum.update model.session)
                (Data.Postpartum.DateFieldSubMsg dateFieldMsg)
                subModel

        ( theMsg, thePage ) ->
            -- We should never get here.
            -- TODO: properly raise an error here.
            let
                message =
                    "Unhandled msg of "
                        ++ toString theMsg
                        ++ " and page of "
                        ++ toString thePage
                        ++ " in Medical.update."
            in
            model => logInfo message


{-| Handle all Msg.Message variations.
-}
updateMessage : IncomingMessage -> Model -> ( Model, Cmd Msg )
updateMessage incoming model =
    case incoming of
        UnknownMessage str ->
            model => (logInfo <| "UnknownMessage: " ++ str)

        SiteMessage siteMsg ->
            -- Note: we are discarding siteMsg.payload.updatedAt until we need it.
            { model | siteMessages = siteMsg.payload.data } => Cmd.none

        SystemMessage sysMsgType ->
            -- We only have one type of system message so far and that is designed
            -- to immediately get everyone out of the system.
            let
                newCmd =
                    case sysMsgType of
                        SystemMode 2 ->
                            Navigation.load "/logout"

                        _ ->
                            Cmd.none
            in
            model => newCmd

        DataAddMessage dataAddMsg ->
            -- Results of attempting to add a record on the server.
            -- If server responded positively, add the new record obtained
            -- from the processStore to the top-level model after attaching
            -- the id received from the server. Then pass the new record to
            -- the page per the Msg retrieved from the processStore.
            let
                -- Use the messageId returned from the server to acquire the
                -- Msg reserved in our store by the originating "event".
                ( processType, processStore ) =
                    Processing.remove (ProcessId dataAddMsg.messageId) model.processStore

                ( newModel, newCmd ) =
                    case dataAddMsg.response.success of
                        True ->
                            case processType of
                                Just (AddBabyType (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) babyRecordNew) ->
                                    let
                                        babyRec =
                                            babyRecordNewToBabyRecord
                                                (BabyId dataAddMsg.response.id)
                                                babyRecordNew

                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ Baby ])
                                    in
                                    ( { model | dataCache = DCache.put (BabyDataCache babyRec) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (AddBabyLabType (ContPPMsg (Data.ContPP.DataCache _ _)) babyLabRecordNew) ->
                                    -- Note: this is BabyLabRecord, not BabyLabTypeRecord.
                                    let
                                        babyLabRec =
                                            babyLabRecordNewToBabyLabRecord
                                                (BabyLabId dataAddMsg.response.id)
                                                babyLabRecordNew

                                        dc =
                                            case DCache.get BabyLab model.dataCache of
                                                Just (BabyLabDataCache recs) ->
                                                    DCache.put (BabyLabDataCache (babyLabRec :: recs)) model.dataCache

                                                _ ->
                                                    DCache.put (BabyLabDataCache [ babyLabRec ]) model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ BabyLab ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (AddBabyMedicationType (ContPPMsg (Data.ContPP.DataCache _ _)) babyMedicationRecordNew) ->
                                    -- Note: this is BabyMedicationRecord, not BabyMedicationTypeRecord.
                                    let
                                        babyMedicationRec =
                                            babyMedicationRecordNewToBabyMedicationRecord
                                                (BabyMedicationId dataAddMsg.response.id)
                                                babyMedicationRecordNew

                                        dc =
                                            case DCache.get BabyMedication model.dataCache of
                                                Just (BabyMedicationDataCache recs) ->
                                                    DCache.put (BabyMedicationDataCache (babyMedicationRec :: recs)) model.dataCache

                                                _ ->
                                                    DCache.put (BabyMedicationDataCache [ babyMedicationRec ]) model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ BabyMedication ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (AddBabyVaccinationType (ContPPMsg (Data.ContPP.DataCache _ _)) babyVaccinationRecordNew) ->
                                    -- Note: this is BabyVaccinationRecord, not BabyVaccinationTypeRecord.
                                    let
                                        babyVaccinationRec =
                                            babyVaccinationRecordNewToBabyVaccinationRecord
                                                (BabyVaccinationId dataAddMsg.response.id)
                                                babyVaccinationRecordNew

                                        dc =
                                            case DCache.get BabyVaccination model.dataCache of
                                                Just (BabyVaccinationDataCache recs) ->
                                                    DCache.put (BabyVaccinationDataCache (babyVaccinationRec :: recs)) model.dataCache

                                                _ ->
                                                    DCache.put (BabyVaccinationDataCache [ babyVaccinationRec ]) model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ BabyVaccination ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (AddBirthCertificateType (BirthCertMsg (Data.BirthCert.DataCache _ _)) birthCertificateRecordNew) ->
                                    let
                                        birthCertificateRec =
                                            birthCertificateRecordNewToBirthCertificateRecord
                                                (BirthCertificateId dataAddMsg.response.id)
                                                birthCertificateRecordNew

                                        subMsg =
                                            Data.BirthCert.DataCache (Just model.dataCache) (Just [ BirthCertificate ])
                                    in
                                    ( { model | dataCache = DCache.put (BirthCertificateDataCache birthCertificateRec) model.dataCache }
                                    , Task.perform BirthCertMsg (Task.succeed subMsg)
                                    )

                                Just (AddContPostpartumCheckType (ContPPMsg (Data.ContPP.DataCache _ _)) contPostpartumCheckRecordNew) ->
                                    let
                                        -- Server accepted new record; create normal record.
                                        contPostpartumCheckRec =
                                            contPostpartumCheckRecordNewToContPostpartumCheckRecord
                                                (ContPostpartumCheckId dataAddMsg.response.id)
                                                contPostpartumCheckRecordNew

                                        -- Add the record to the data cache. We are not storing separately
                                        -- in top-level model.
                                        dc =
                                            case DCache.get ContPostpartumCheck model.dataCache of
                                                Just (ContPostpartumCheckDataCache recs) ->
                                                    DCache.put (ContPostpartumCheckDataCache (contPostpartumCheckRec :: recs)) model.dataCache

                                                _ ->
                                                    DCache.put (ContPostpartumCheckDataCache [ contPostpartumCheckRec ]) model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ ContPostpartumCheck ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (AddDischargeType (ContPPMsg (Data.ContPP.DataCache _ _)) dischargeRecordNew) ->
                                    let
                                        dischargeRec =
                                            dischargeRecordNewToDischargeRecord
                                                (DischargeId dataAddMsg.response.id)
                                                dischargeRecordNew

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ Discharge ])
                                    in
                                    ( { model | dataCache = DCache.put (DischargeDataCache dischargeRec) model.dataCache }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (AddLaborType (AdmittingMsg (AdmitForLaborSaved lrn _)) laborRecNew) ->
                                    let
                                        laborRec =
                                            laborRecordNewToLaborRecord
                                                (LaborId dataAddMsg.response.id)
                                                laborRecNew

                                        dc =
                                            DCache.put (LaborDataCache laborRec) model.dataCache

                                        subMsg =
                                            AdmitForLaborSaved lrn (Just <| LaborId dataAddMsg.response.id)
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform AdmittingMsg (Task.succeed subMsg)
                                    )

                                Just (AddLaborStage1Type (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) laborStage1RecordNew) ->
                                    let
                                        laborStage1Rec =
                                            laborStage1RecordNewToLaborStage1Record
                                                (LaborStage1Id dataAddMsg.response.id)
                                                laborStage1RecordNew

                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ LaborStage1 ])
                                    in
                                    ( { model | dataCache = DCache.put (LaborStage1DataCache laborStage1Rec) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (AddLaborStage2Type (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) laborStage2RecordNew) ->
                                    let
                                        laborStage2Rec =
                                            laborStage2RecordNewToLaborStage2Record
                                                (LaborStage2Id dataAddMsg.response.id)
                                                laborStage2RecordNew

                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ LaborStage2 ])
                                    in
                                    ( { model | dataCache = DCache.put (LaborStage2DataCache laborStage2Rec) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (AddLaborStage3Type (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) laborStage3RecordNew) ->
                                    let
                                        laborStage3Rec =
                                            laborStage3RecordNewToLaborStage3Record
                                                (LaborStage3Id dataAddMsg.response.id)
                                                laborStage3RecordNew

                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ LaborStage3 ])
                                    in
                                    ( { model | dataCache = DCache.put (LaborStage3DataCache laborStage3Rec) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (AddMembraneType (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) membraneRecordNew) ->
                                    let
                                        membraneRec =
                                            membraneRecordNewToMembraneRecord
                                                (MembraneId dataAddMsg.response.id)
                                                membraneRecordNew

                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ Membrane ])
                                    in
                                    ( { model | dataCache = DCache.put (MembraneDataCache membraneRec) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (AddMotherMedicationType (ContPPMsg (Data.ContPP.DataCache _ _)) motherMedicationRecordNew) ->
                                    -- Note: this is MotherMedicationRecord, not MotherMedicationTypeRecord.
                                    let
                                        motherMedicationRec =
                                            motherMedicationRecordNewToMotherMedicationRecord
                                                (MotherMedicationId dataAddMsg.response.id)
                                                motherMedicationRecordNew

                                        dc =
                                            case DCache.get MotherMedication model.dataCache of
                                                Just (MotherMedicationDataCache recs) ->
                                                    DCache.put (MotherMedicationDataCache (motherMedicationRec :: recs)) model.dataCache

                                                _ ->
                                                    DCache.put (MotherMedicationDataCache [ motherMedicationRec ]) model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ MotherMedication ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (AddNewbornExamType (ContPPMsg (Data.ContPP.DataCache _ _)) newbornExamRecordNew) ->
                                    let
                                        newbornExamRec =
                                            newbornExamRecordNewToNewbornExamRecord
                                                (NewbornExamId dataAddMsg.response.id)
                                                newbornExamRecordNew

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ NewbornExam ])
                                    in
                                    ( { model | dataCache = DCache.put (NewbornExamDataCache newbornExamRec) model.dataCache }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (AddPostpartumCheckType (PostpartumMsg (Data.Postpartum.DataCache _ _)) postpartumCheckRecordNew) ->
                                    let
                                        -- Server accepted new record; create normal record.
                                        postpartumCheckRec =
                                            postpartumCheckRecordNewToPostpartumCheckRecord
                                                (PostpartumCheckId dataAddMsg.response.id)
                                                postpartumCheckRecordNew

                                        -- Add the record to the data cache. We are not storing separately
                                        -- in top-level model.
                                        dc =
                                            case DCache.get PostpartumCheck model.dataCache of
                                                Just (PostpartumCheckDataCache recs) ->
                                                    DCache.put (PostpartumCheckDataCache (postpartumCheckRec :: recs)) model.dataCache

                                                _ ->
                                                    DCache.put (PostpartumCheckDataCache [ postpartumCheckRec ]) model.dataCache

                                        subMsg =
                                            Data.Postpartum.DataCache (Just model.dataCache) (Just [ PostpartumCheck ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform PostpartumMsg (Task.succeed subMsg)
                                    )

                                _ ->
                                    let
                                        msgText =
                                            "OOPS, unhandled processType in Medical.updateMessage in the DataAddMessage branch."
                                    in
                                    ( model, logInfo msgText )

                        False ->
                            -- This could be due to a session timeout, among other issues.
                            case dataAddMsg.response.errorCode of
                                "SessionExpiredErrorCode" ->
                                    ( model
                                    , Msg.toastWarn
                                        [ "Sorry: " ++ dataAddMsg.response.msg ++ " Please go back to Prenatal, login, and then try again." ]
                                        10
                                    )

                                _ ->
                                    ( model, logInfo <| toString dataAddMsg.response )
            in
            { newModel | processStore = processStore } => newCmd

        DataChgMessage dataChgMsg ->
            -- Results of attempting to update a record on the server.
            -- If server responded positively, update the record obtained
            -- from the processStore to the top-level model then pass the
            -- record to the page per the Msg retrieved from the processStore.
            --
            -- TODO: refactor to process DataAddMessage and DataChgMessage with
            -- the same function.
            let
                -- Use the messageId returned from the server to acquire the
                -- Msg reserved in our store by the originating "event".
                ( processType, processStore ) =
                    Processing.remove (ProcessId dataChgMsg.messageId) model.processStore

                ( newModel, newCmd ) =
                    case dataChgMsg.response.success of
                        True ->
                            case processType of
                                Just (UpdateBabyType (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) babyRecord) ->
                                    let
                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ Baby ])
                                    in
                                    ( { model | dataCache = DCache.put (BabyDataCache babyRecord) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateBabyLabType (ContPPMsg (Data.ContPP.DataCache _ _)) babyLabRecord) ->
                                    let
                                        -- Updating the data cache with the updated record.
                                        dc =
                                            case DCache.get BabyLab model.dataCache of
                                                Just (BabyLabDataCache recs) ->
                                                    let
                                                        newRecs =
                                                            LE.replaceIf (\b -> b.id == babyLabRecord.id)
                                                                babyLabRecord
                                                                recs
                                                    in
                                                    DCache.put (BabyLabDataCache newRecs) model.dataCache

                                                _ ->
                                                    model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ BabyLab ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateBabyMedicationType (ContPPMsg (Data.ContPP.DataCache _ _)) babyMedicationRecord) ->
                                    let
                                        -- Updating the data cache with the updated record.
                                        dc =
                                            case DCache.get BabyMedication model.dataCache of
                                                Just (BabyMedicationDataCache recs) ->
                                                    let
                                                        newRecs =
                                                            LE.replaceIf (\b -> b.id == babyMedicationRecord.id)
                                                                babyMedicationRecord
                                                                recs
                                                    in
                                                    DCache.put (BabyMedicationDataCache newRecs) model.dataCache

                                                _ ->
                                                    model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ BabyMedication ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateBabyVaccinationType (ContPPMsg (Data.ContPP.DataCache _ _)) babyVaccinationRecord) ->
                                    let
                                        -- Updating the data cache with the updated record.
                                        dc =
                                            case DCache.get BabyVaccination model.dataCache of
                                                Just (BabyVaccinationDataCache recs) ->
                                                    let
                                                        newRecs =
                                                            LE.replaceIf (\b -> b.id == babyVaccinationRecord.id)
                                                                babyVaccinationRecord
                                                                recs
                                                    in
                                                    DCache.put (BabyVaccinationDataCache newRecs) model.dataCache

                                                _ ->
                                                    model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ BabyVaccination ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateBirthCertificateType (BirthCertMsg (Data.BirthCert.DataCache _ _)) birthCertificateRecord) ->
                                    let
                                        subMsg =
                                            Data.BirthCert.DataCache (Just model.dataCache) (Just [ BirthCertificate ])
                                    in
                                    ( { model | dataCache = DCache.put (BirthCertificateDataCache birthCertificateRecord) model.dataCache }
                                    , Task.perform BirthCertMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateContPostpartumCheckType (ContPPMsg (Data.ContPP.DataCache _ _)) contPostpartumCheckRecord) ->
                                    let
                                        -- Updating the data cache with the updated record.
                                        dc =
                                            case DCache.get ContPostpartumCheck model.dataCache of
                                                Just (ContPostpartumCheckDataCache recs) ->
                                                    let
                                                        newRecs =
                                                            LE.replaceIf (\c -> c.id == contPostpartumCheckRecord.id)
                                                                contPostpartumCheckRecord
                                                                recs
                                                    in
                                                    DCache.put (ContPostpartumCheckDataCache newRecs) model.dataCache

                                                _ ->
                                                    model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ ContPostpartumCheck ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateDischargeType (ContPPMsg (Data.ContPP.DataCache _ _)) dischargeRecord) ->
                                    let
                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ Discharge ])
                                    in
                                    ( { model | dataCache = DCache.put (DischargeDataCache dischargeRecord) model.dataCache }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateLaborType (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) laborRecord) ->
                                    let
                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ Labor ])
                                    in
                                    ( { model | dataCache = DCache.put (LaborDataCache laborRecord) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateLaborType (AdmittingMsg (Data.Admitting.DataCache _ _)) laborRecord) ->
                                    let
                                        subMsg =
                                            Data.Admitting.DataCache (Just model.dataCache) (Just [ Labor ])
                                    in
                                    ( { model | dataCache = DCache.put (LaborDataCache laborRecord) model.dataCache }
                                    , Task.perform AdmittingMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateLaborStage1Type (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) laborStage1Record) ->
                                    let
                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ LaborStage1 ])
                                    in
                                    ( { model | dataCache = DCache.put (LaborStage1DataCache laborStage1Record) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateLaborStage2Type (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) laborStage2Record) ->
                                    let
                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ LaborStage2 ])
                                    in
                                    ( { model | dataCache = DCache.put (LaborStage2DataCache laborStage2Record) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateLaborStage3Type (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) laborStage3Record) ->
                                    let
                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ LaborStage3 ])
                                    in
                                    ( { model | dataCache = DCache.put (LaborStage3DataCache laborStage3Record) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateMembraneType (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) membraneRecord) ->
                                    let
                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ Membrane ])
                                    in
                                    ( { model | dataCache = DCache.put (MembraneDataCache membraneRecord) model.dataCache }
                                    , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateMotherMedicationType (ContPPMsg (Data.ContPP.DataCache _ _)) motherMedicationRecord) ->
                                    let
                                        -- Updating the data cache with the updated record.
                                        dc =
                                            case DCache.get MotherMedication model.dataCache of
                                                Just (MotherMedicationDataCache recs) ->
                                                    let
                                                        newRecs =
                                                            LE.replaceIf (\b -> b.id == motherMedicationRecord.id)
                                                                motherMedicationRecord
                                                                recs
                                                    in
                                                    DCache.put (MotherMedicationDataCache newRecs) model.dataCache

                                                _ ->
                                                    model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ MotherMedication ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (UpdateNewbornExamType (ContPPMsg (Data.ContPP.DataCache _ _)) newbornExamRecord) ->
                                    let
                                        subMsg =
                                            Data.ContPP.DataCache (Just model.dataCache) (Just [ NewbornExam ])
                                    in
                                    ( { model | dataCache = DCache.put (NewbornExamDataCache newbornExamRecord) model.dataCache }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (UpdatePostpartumCheckType (PostpartumMsg (Data.Postpartum.DataCache _ _)) postpartumCheckRecord) ->
                                    let
                                        -- Updating the data cache with the updated record.
                                        dc =
                                            case DCache.get PostpartumCheck model.dataCache of
                                                Just (PostpartumCheckDataCache recs) ->
                                                    let
                                                        newRecs =
                                                            LE.replaceIf (\c -> c.id == postpartumCheckRecord.id)
                                                                postpartumCheckRecord
                                                                recs
                                                    in
                                                    DCache.put (PostpartumCheckDataCache newRecs) model.dataCache

                                                _ ->
                                                    model.dataCache

                                        subMsg =
                                            Data.Postpartum.DataCache (Just model.dataCache) (Just [ PostpartumCheck ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform PostpartumMsg (Task.succeed subMsg)
                                    )

                                _ ->
                                    let
                                        msgText =
                                            "OOPS, unhandled processType in Medical.updateMessage in the DataChgMessage branch: "
                                                ++ toString processType
                                    in
                                    ( model, logInfo msgText )

                        False ->
                            -- This could be due to a session timeout, among other issues.
                            case dataChgMsg.response.errorCode of
                                "SessionExpiredErrorCode" ->
                                    ( model
                                    , Msg.toastWarn
                                        [ "Sorry: " ++ dataChgMsg.response.msg ++ " Please go back to Prenatal, login, and then try again." ]
                                        10
                                    )

                                _ ->
                                    ( model, logInfo <| toString dataChgMsg.response )
            in
            { newModel | processStore = processStore } => newCmd

        DataDelMessage dataDelMsg ->
            -- Results of attempting to delete a record on the server.
            -- If server responded positively, delete the record from
            -- the processStore in the top-level model.
            -- Then pass the new record to the page per the Msg
            -- retrieved from the processStore.
            let
                -- Use the messageId returned from the server to acquire the
                -- Msg reserved in our store by the originating "event".
                ( processType, processStore ) =
                    Processing.remove (ProcessId dataDelMsg.messageId) model.processStore

                ( newModel, newCmd ) =
                    case dataDelMsg.response.success of
                        True ->
                            case processType of
                                Just (DelBabyMedicationType (ContPPMsg (Data.ContPP.DataCache _ _)) babyMedicationId) ->
                                    -- Note: this is BabyMedicationRecord, not BabyMedicationTypeRecord.
                                    let
                                        dc =
                                            case DCache.get BabyMedication model.dataCache of
                                                Just (BabyMedicationDataCache recs) ->
                                                    let
                                                        newRecs =
                                                            List.filter (\r -> r.id /= babyMedicationId) recs
                                                    in
                                                    DCache.put (BabyMedicationDataCache newRecs) model.dataCache

                                                _ ->
                                                    model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just dc) (Just [ BabyMedication ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (DelBabyVaccinationType (ContPPMsg (Data.ContPP.DataCache _ _)) babyVaccinationId) ->
                                    -- Note: this is BabyVaccinationRecord, not BabyVaccinationTypeRecord.
                                    let
                                        dc =
                                            case DCache.get BabyVaccination model.dataCache of
                                                Just (BabyVaccinationDataCache recs) ->
                                                    let
                                                        newRecs =
                                                            List.filter (\r -> r.id /= babyVaccinationId) recs
                                                    in
                                                    DCache.put (BabyVaccinationDataCache newRecs) model.dataCache

                                                _ ->
                                                    model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just dc) (Just [ BabyVaccination ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (DelBabyLabType (ContPPMsg (Data.ContPP.DataCache _ _)) babyLabId) ->
                                    -- Note: this is BabyLabRecord, not BabyLabTypeRecord.
                                    let
                                        dc =
                                            case DCache.get BabyLab model.dataCache of
                                                Just (BabyLabDataCache recs) ->
                                                    let
                                                        newRecs =
                                                            List.filter (\r -> r.id /= babyLabId) recs
                                                    in
                                                    DCache.put (BabyLabDataCache newRecs) model.dataCache

                                                _ ->
                                                    model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just dc) (Just [ BabyLab ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                Just (DelMotherMedicationType (ContPPMsg (Data.ContPP.DataCache _ _)) babyMedicationId) ->
                                    -- Note: this is MotherMedicationRecord, not MotherMedicationTypeRecord.
                                    let
                                        dc =
                                            case DCache.get MotherMedication model.dataCache of
                                                Just (MotherMedicationDataCache recs) ->
                                                    let
                                                        newRecs =
                                                            List.filter (\r -> r.id /= babyMedicationId) recs
                                                    in
                                                    DCache.put (MotherMedicationDataCache newRecs) model.dataCache

                                                _ ->
                                                    model.dataCache

                                        subMsg =
                                            Data.ContPP.DataCache (Just dc) (Just [ MotherMedication ])
                                    in
                                    ( { model | dataCache = dc }
                                    , Task.perform ContPPMsg (Task.succeed subMsg)
                                    )

                                _ ->
                                    let
                                        _ =
                                            Debug.log
                                                "Medical: update function, missing DataDelMessage dataDelMsg case"
                                            <|
                                                toString processType
                                    in
                                    ( model, Cmd.none )

                        False ->
                            -- This could be due to a session timeout, among other issues.
                            case dataDelMsg.response.errorCode of
                                "SessionExpiredErrorCode" ->
                                    ( model
                                    , Msg.toastWarn
                                        [ "Sorry: " ++ dataDelMsg.response.msg ++ " Please go back to Prenatal, login, and then try again." ]
                                        10
                                    )

                                _ ->
                                    ( model, logInfo <| toString dataDelMsg.response )
            in
            { newModel | processStore = processStore } => newCmd

        DataNotificationMessage dataNotificationMsg ->
            -- The payload field has what we want.
            model => handleDataNotification dataNotificationMsg model

        DataSelectMessage dataMsg ->
            -- Results of requests for data from the server.
            let
                -- Use the messageId returned from the server to acquire the
                -- Msg reserved in our store by the originating "event".
                ( processType, processStore ) =
                    Processing.remove (ProcessId dataMsg.messageId) model.processStore

                -- Store any data sent from the server into the top-level model
                -- so that pages that need the same data may get it from the top-level
                -- rather than issuing another data request.
                newModel =
                    case dataMsg.response.success of
                        True ->
                            List.foldl
                                (\tr mdl ->
                                    case tr of
                                        TableRecordBaby recs ->
                                            let
                                                dictList =
                                                    List.map (\rec -> ( rec.id, rec )) recs

                                                -- DataCache gets one baby record since we
                                                -- do not yet handle multiple births.
                                                dc =
                                                    case List.head recs of
                                                        Just r ->
                                                            DCache.put (BabyDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl
                                                | dataCache = dc
                                            }

                                        TableRecordBabyLab recs ->
                                            { mdl | dataCache = DCache.put (BabyLabDataCache recs) mdl.dataCache }

                                        TableRecordBabyLabType recs ->
                                            -- This is a lookup table, so we always replace the contents
                                            -- of the data cache with what we receive.
                                            { mdl | dataCache = DCache.put (BabyLabTypeDataCache recs) mdl.dataCache }

                                        TableRecordBabyMedication recs ->
                                            { mdl | dataCache = DCache.put (BabyMedicationDataCache recs) mdl.dataCache }

                                        TableRecordBabyMedicationType recs ->
                                            -- This is a lookup table, so we always replace the contents
                                            -- of the data cache with what we receive.
                                            { mdl | dataCache = DCache.put (BabyMedicationTypeDataCache recs) mdl.dataCache }

                                        TableRecordBabyVaccination recs ->
                                            { mdl | dataCache = DCache.put (BabyVaccinationDataCache recs) mdl.dataCache }

                                        TableRecordBabyVaccinationType recs ->
                                            -- This is a lookup table, so we always replace the contents
                                            -- of the data cache with what we receive.
                                            { mdl | dataCache = DCache.put (BabyVaccinationTypeDataCache recs) mdl.dataCache }

                                        TableRecordBirthCertificate recs ->
                                            let
                                                dc =
                                                    case List.head recs of
                                                        Just r ->
                                                            DCache.put (BirthCertificateDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }

                                        TableRecordContPostpartumCheck recs ->
                                            let
                                                dc =
                                                    DCache.put (ContPostpartumCheckDataCache recs) mdl.dataCache
                                            in
                                            -- Only adding contPostpartumCheck records into data cache.
                                            { mdl | dataCache = dc }

                                        TableRecordDischarge recs ->
                                            -- There should ever be only one discharge record
                                            -- sent because there is only one allowed per
                                            -- labor, but the data arrives in an array anyway.
                                            let
                                                dc =
                                                    case List.head recs of
                                                        Just r ->
                                                            DCache.put (DischargeDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }

                                        TableRecordKeyValue recs ->
                                            let
                                                kvCache =
                                                    List.map (\rec -> ( rec.kvKey, rec )) recs
                                                        |> Dict.fromList
                                            in
                                            { mdl | dataCache = DCache.put (KeyValueDataCache kvCache) mdl.dataCache }

                                        TableRecordLabor recs ->
                                            let
                                                dc =
                                                    case List.head recs of
                                                        Just r ->
                                                            DCache.put (LaborDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }

                                        TableRecordLaborStage1 recs ->
                                            -- There should ever be only one stage 1 record
                                            -- sent because there is only one allowed per
                                            -- labor, but the data arrives in an array anyway.
                                            let
                                                dc =
                                                    case List.head recs of
                                                        Just r ->
                                                            DCache.put (LaborStage1DataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }

                                        TableRecordLaborStage2 recs ->
                                            -- There should ever be only one stage 2 record
                                            -- sent because there is only one allowed per
                                            -- labor, but the data arrives in an array anyway.
                                            let
                                                dc =
                                                    case List.head recs of
                                                        Just r ->
                                                            DCache.put (LaborStage2DataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }

                                        TableRecordLaborStage3 recs ->
                                            -- There should ever be only one stage 3 record
                                            -- sent because there is only one allowed per
                                            -- labor, but the data arrives in an array anyway.
                                            let
                                                dc =
                                                    case List.head recs of
                                                        Just r ->
                                                            DCache.put (LaborStage3DataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }

                                        TableRecordMembrane recs ->
                                            let
                                                dc =
                                                    case List.head recs of
                                                        Just r ->
                                                            DCache.put (MembraneDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }

                                        TableRecordMotherMedication recs ->
                                            { mdl | dataCache = DCache.put (MotherMedicationDataCache recs) mdl.dataCache }

                                        TableRecordMotherMedicationType recs ->
                                            -- This is a lookup table, so we always replace the contents
                                            -- of the data cache with what we receive.
                                            { mdl | dataCache = DCache.put (MotherMedicationTypeDataCache recs) mdl.dataCache }

                                        TableRecordNewbornExam recs ->
                                            let
                                                dc =
                                                    case List.head recs of
                                                        Just r ->
                                                            DCache.put (NewbornExamDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }

                                        TableRecordPatient recs ->
                                            -- We only ever want one patient in our store at a time.
                                            let
                                                rec =
                                                    List.head recs

                                                dc =
                                                    case rec of
                                                        Just r ->
                                                            DCache.put (PatientDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }

                                        TableRecordPostpartumCheck recs ->
                                            let
                                                dc =
                                                    DCache.put (PostpartumCheckDataCache recs) mdl.dataCache
                                            in
                                            -- Only adding contPostpartumCheck records into data cache.
                                            { mdl | dataCache = dc }

                                        TableRecordPregnancy recs ->
                                            -- We only ever want one pregnancy in our store at a time.
                                            let
                                                rec =
                                                    List.head recs

                                                dc =
                                                    case rec of
                                                        Just r ->
                                                            DCache.put (PregnancyDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }

                                        TableRecordSelectData recs ->
                                            let
                                                dc =
                                                    DCache.put (SelectDataDataCache recs) mdl.dataCache
                                            in
                                            { mdl | dataCache = dc }
                                )
                                model
                                dataMsg.response.data

                        False ->
                            -- TODO: handle failure better here.
                            model
            in
            let
                newModel2 =
                    { newModel | processStore = processStore }
            in
            case processType of
                -- Send the message retrieved from the processing store.
                Just (AddBabyType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddBabyLabType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddBabyMedicationType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddBabyVaccinationType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddBirthCertificateType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddContPostpartumCheckType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddDischargeType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddMotherMedicationType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddPostpartumCheckType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateContPostpartumCheckType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateBabyType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (DelBabyLabType msg id) ->
                    newModel2 => Task.perform (always msg) (Task.succeed id)

                Just (UpdateBabyLabType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (DelBabyMedicationType msg id) ->
                    newModel2 => Task.perform (always msg) (Task.succeed id)

                Just (UpdateBabyMedicationType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (DelBabyVaccinationType msg id) ->
                    newModel2 => Task.perform (always msg) (Task.succeed id)

                Just (UpdateBabyVaccinationType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateBirthCertificateType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateDischargeType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddLaborType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateLaborType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddLaborStage1Type msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateLaborStage1Type msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddLaborStage2Type msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateLaborStage2Type msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddLaborStage3Type msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateLaborStage3Type msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddMembraneType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateMembraneType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (DelMotherMedicationType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateMotherMedicationType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (AddNewbornExamType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdateNewbornExamType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (UpdatePostpartumCheckType msg _) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Just (SelectQueryType msg selectQuery) ->
                    newModel2 => Task.perform (always msg) (Task.succeed True)

                Nothing ->
                    newModel2 => Cmd.none


{-| Generate a Cmd to retrieve needed data from the server based
upon the DataNotificationMsg sent. Note that for subtables with
as foreign key matching another table that we track, it will just
get all of the subtable records rather than handling things differently
depending upon if the notification was regarding an add, change,
or delete.

Note that we do not handle lookup tables because they are edge case
and should rarely change.

-}
handleDataNotification : DataNotificationMsg -> Model -> Cmd Msg
handleDataNotification notification model =
    case Data.Message.stringToMsgType notification.msgType of
        Just AddChgDelType ->
            let
                getFK table list =
                    LE.find (\fk -> fk.table == table) list

                -- Generates a Cmd to retrieve and load data for the current page
                -- if the notification id matches the id of the table that we
                -- already have and we are on a page that we care about.
                getMsg table currId notificationId tables =
                    if currId == notificationId then
                        (case model.pageState of
                            Loaded page ->
                                case page of
                                    Admitting _ ->
                                        AdmittingSelectQuery table (Just currId) tables

                                    ContPP _ ->
                                        ContPPSelectQuery table (Just currId) tables

                                    LaborDelIpp _ ->
                                        LaborDelIppSelectQuery table (Just currId) tables

                                    Postpartum _ ->
                                        PostpartumSelectQuery table (Just currId) tables

                                    BirthCert _ ->
                                        BirthCertSelectQuery table (Just currId) tables

                                    _ ->
                                        Noop

                            _ ->
                                Noop
                        )
                            |> (\msg -> Task.perform (always msg) (Task.succeed True))
                    else
                        Cmd.none
            in
            case notification.payload.table of
                Baby ->
                    case DCache.get Baby model.dataCache of
                        Just (BabyDataCache rec) ->
                            getMsg Baby rec.id notification.payload.id []

                        _ ->
                            Cmd.none

                BabyLab ->
                    -- Subtable of baby: get all records.
                    case ( DCache.get Baby model.dataCache, getFK Baby notification.payload.foreignKeys ) of
                        ( Just (BabyDataCache baby), Just fk ) ->
                            getMsg Baby baby.id fk.id [ BabyLab ]

                        _ ->
                            Cmd.none

                BabyMedication ->
                    -- Subtable of baby: get all records.
                    case ( DCache.get Baby model.dataCache, getFK Baby notification.payload.foreignKeys ) of
                        ( Just (BabyDataCache baby), Just fk ) ->
                            getMsg Baby baby.id fk.id [ BabyMedication ]

                        _ ->
                            Cmd.none

                BabyVaccination ->
                    -- Subtable of baby: get all records.
                    case ( DCache.get Baby model.dataCache, getFK Baby notification.payload.foreignKeys ) of
                        ( Just (BabyDataCache baby), Just fk ) ->
                            getMsg Baby baby.id fk.id [ BabyVaccination ]

                        _ ->
                            Cmd.none

                BirthCertificate ->
                    case DCache.get BirthCertificate model.dataCache of
                        Just (BirthCertificateDataCache bc) ->
                            getMsg BirthCertificate bc.id notification.payload.id []

                        _ ->
                            Cmd.none

                ContPostpartumCheck ->
                    -- Subtable of labor: get all records.
                    case ( DCache.get Labor model.dataCache, getFK Labor notification.payload.foreignKeys ) of
                        ( Just (LaborDataCache labor), Just fk ) ->
                            getMsg Labor labor.id fk.id [ ContPostpartumCheck ]

                        _ ->
                            Cmd.none

                Discharge ->
                    -- Subtable of labor but there is only one record allowed.
                    case DCache.get Discharge model.dataCache of
                        Just (DischargeDataCache rec) ->
                            getMsg Discharge rec.id notification.payload.id []

                        _ ->
                            Cmd.none

                Labor ->
                    case DCache.get Labor model.dataCache of
                        Just (LaborDataCache rec) ->
                            getMsg Labor rec.id notification.payload.id []

                        _ ->
                            Cmd.none

                LaborStage1 ->
                    -- Subtable of labor but there is only one record allowed.
                    case DCache.get LaborStage1 model.dataCache of
                        Just (LaborStage1DataCache rec) ->
                            getMsg LaborStage1 rec.id notification.payload.id []

                        _ ->
                            Cmd.none

                LaborStage2 ->
                    -- Subtable of labor but there is only one record allowed.
                    case DCache.get LaborStage2 model.dataCache of
                        Just (LaborStage2DataCache rec) ->
                            getMsg LaborStage2 rec.id notification.payload.id []

                        _ ->
                            Cmd.none

                LaborStage3 ->
                    -- Subtable of labor but there is only one record allowed.
                    case DCache.get LaborStage3 model.dataCache of
                        Just (LaborStage3DataCache rec) ->
                            getMsg LaborStage3 rec.id notification.payload.id []

                        _ ->
                            Cmd.none

                Membrane ->
                    -- Subtable of labor but there is only one record allowed.
                    case DCache.get Membrane model.dataCache of
                        Just (MembraneDataCache rec) ->
                            getMsg Membrane rec.id notification.payload.id []

                        _ ->
                            Cmd.none

                MotherMedication ->
                    -- Subtable of labor: get all records.
                    case ( DCache.get Labor model.dataCache, getFK Labor notification.payload.foreignKeys ) of
                        ( Just (LaborDataCache labor), Just fk ) ->
                            getMsg Labor labor.id fk.id [ MotherMedication ]

                        _ ->
                            Cmd.none

                NewbornExam ->
                    -- Subtable of baby but there is only one record allowed.
                    case DCache.get NewbornExam model.dataCache of
                        Just (NewbornExamDataCache exam) ->
                            getMsg NewbornExam exam.id notification.payload.id []

                        _ ->
                            Cmd.none

                PostpartumCheck ->
                    -- Subtable of labor: get all records.
                    case ( DCache.get Labor model.dataCache, getFK Labor notification.payload.foreignKeys ) of
                        ( Just (LaborDataCache labor), Just fk ) ->
                            getMsg Labor labor.id fk.id [ PostpartumCheck ]

                        _ ->
                            Cmd.none

                _ ->
                    Cmd.none

        _ ->
            Cmd.none


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition processStore cmd =
            { model
                | pageState = TransitioningFrom (getPage model.pageState)
                , processStore = processStore
            }
                => cmd

        errored =
            pageErrored model
    in
    case maybeRoute of
        Nothing ->
            { model | pageState = Loaded NotFound } => Cmd.none

        Just Route.AdmittingRoute ->
            case model.currPregId of
                Just pid ->
                    PageAdmitting.init pid model.session model.processStore
                        |> (\( store, cmd ) -> transition store cmd)

                Nothing ->
                    { model | pageState = Loaded NotFound } => Cmd.none

        Just Route.BirthCertificateRoute ->
            if model.dialogActive then
                -- We are coming back from an open dialog, so no need to
                -- retrieve data from the server all over again.
                { model | dialogActive = False } => Cmd.none
            else
                case ( model.currPregId, DCache.get Labor model.dataCache ) of
                    ( Just pid, Just (LaborDataCache laborRec) ) ->
                        PageBirthCert.init pid laborRec model.session model.processStore
                            |> (\( store, cmd ) -> transition store cmd)

                    ( _, _ ) ->
                        -- We don't go there if we are not ready.
                        model => Cmd.none

        Just Route.BirthCertificateDialogRoute ->
            model => Cmd.none

        Just Route.ContPPRoute ->
            if model.dialogActive then
                -- We are coming back from an open dialog, so no need to
                -- retrieve data from the server all over again.
                { model | dialogActive = False } => Cmd.none
            else
                case ( model.currPregId, DCache.get Labor model.dataCache ) of
                    ( Just pregId, Just (LaborDataCache laborRecord) ) ->
                        PageContPP.init pregId laborRecord model.session model.processStore
                            |> (\( store, cmd ) -> transition store cmd)

                    ( _, _ ) ->
                        -- We don't go there if we are not ready.
                        model => Cmd.none

        Just Route.ContPPDialogRoute ->
            model => Cmd.none

        Just Route.LaborDelIppRoute ->
            case model.currPregId of
                Just pid ->
                    if model.dialogActive then
                        -- We are coming back from an open dialog, so no need to
                        -- retrieve data from the server all over again.
                        { model | dialogActive = False } => Cmd.none
                    else
                        PageLaborDelIpp.init pid model.session model.processStore
                            |> (\( store, cmd ) -> transition store cmd)

                Nothing ->
                    { model | pageState = Loaded NotFound } => Cmd.none

        Just Route.LaborDelIppDialogRoute ->
            model => Cmd.none

        Just Route.PostpartumRoute ->
            if model.dialogActive then
                -- We are coming back from an open dialog, so no need to
                -- retrieve data from the server all over again.
                { model | dialogActive = False } => Cmd.none
            else
                case ( model.currPregId, DCache.get Labor model.dataCache ) of
                    ( Just pregId, Just (LaborDataCache laborRecord) ) ->
                        PagePostpartum.init pregId laborRecord model.session model.processStore
                            |> (\( store, cmd ) -> transition store cmd)

                    ( _, _ ) ->
                        -- We don't go there if we are not ready.
                        model => Cmd.none

        Just Route.PostpartumDialogRoute ->
            model => Cmd.none


pageErrored : Model -> ActivePage -> String -> ( Model, Cmd msg )
pageErrored model activePage errorMessage =
    let
        error =
            Errored.pageLoadError activePage errorMessage
    in
    { model | pageState = Loaded (Errored error) } => Cmd.none



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes (\s -> WindowResize (Just s))
        , Time.every Time.second Tick
        , Ports.incoming Data.Message.decodeIncoming
            |> Sub.map Message
        , Ports.selectedDate DDP.decodeSelectedDate
            |> Sub.map IncomingDatePicker
        ]



-- MAIN --


main : Program JD.Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
