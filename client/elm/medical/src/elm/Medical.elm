module Medical exposing (..)

import Date exposing (Date)
import Dict exposing (Dict)
import Html as H exposing (Html)
import Json.Decode as JD
import Json.Decode.Pipeline as Pipeline exposing (decode, optional, required)
import Json.Encode as JE
import List.Extra as LE
import Navigation exposing (Location)
import Task exposing (Task)
import Window


-- LOCAL IMPORTS --

import Data.Admitting exposing (AdmittingSubMsg(..))
import Data.Baby exposing (BabyId(..), babyRecordNewToBabyRecord)
import Data.DataCache as DCache exposing (DataCache(..))
import Data.DatePicker as DDP exposing (DateField(..), DateFieldMessage(..))
import Data.Labor as Labor exposing (laborRecordNewToLaborRecord, LaborId(..), LaborRecord)
import Data.LaborDelIpp exposing (SubMsg(..))
import Data.LaborStage1 exposing (LaborStage1Id(..), laborStage1RecordNewToLaborStage1Record)
import Data.LaborStage2 exposing (LaborStage2Id(..), laborStage2RecordNewToLaborStage2Record)
import Data.LaborStage3 exposing (LaborStage3Id(..), laborStage3RecordNewToLaborStage3Record)
import Data.Message exposing (IncomingMessage(..), MsgType(..), wrapPayload)
import Data.Postpartum exposing (SubMsg(..))
import Data.Pregnancy as Pregnancy exposing (getPregId, PregnancyId(..))
import Data.Processing exposing (ProcessId(..))
import Data.Session as Session exposing (Session, clientTouch, doTouch, serverTouch)
import Data.Table exposing (Table(..))
import Data.TableRecord exposing (TableRecord(..))
import Data.Toast exposing (ToastRecord, ToastType(..))
import Model exposing (Model, Page(..), PageState(..))
import Msg exposing (logConsole, Msg(..), ProcessType(..))
import Page.Errored as Errored exposing (PageLoadError, view)
import Page.Admitting as PageAdmitting
import Page.LaborDelIpp as PageLaborDelIpp
import Page.Postpartum as PagePostpartum
import Page.NotFound as NotFound exposing (view)
import Ports
import Route exposing (fromLocation, Route(..))
import Processing
import Views.Page as ViewsPage exposing (ActivePage)
import Time exposing (Time)
import Util as U exposing ((=>))


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
                            LaborDelIpp subModel ->
                                updateForPage LaborDelIpp
                                    LaborDelIppMsg
                                    newModel
                                    (PageLaborDelIpp.update newModel.session)
                                    (TickSubMsg time)
                                    subModel

                            Admitting subModel ->
                                updateForPage Admitting
                                    AdmittingMsg
                                    newModel
                                    (PageAdmitting.update newModel.session)
                                    (AdmittingTickSubMsg time)
                                    subModel

                            _ ->
                                newModel => Cmd.none
                in
                    newModel2 => Cmd.batch [ newCmd, newCmd2 ]

            ( LogConsole msg, _ ) ->
                -- Write a message out to the console.
                let
                    _ =
                        Debug.log "LogConsole" msg
                in
                    model => Cmd.none

            ( Toast msgs seconds toastType, _ ) ->
                -- Publish a toast for the user to see.
                { model | toast = Just <| ToastRecord msgs seconds toastType } => Cmd.none

            ( WindowResize size, _ ) ->
                -- Keep the current window size in the Model.
                { model | window = size } => Cmd.none

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
                -- TODO: For data queries, check if the data requirement can be
                -- satisfied by what the top-level model already has and supply it
                -- to the caller if available.
                -- TODO: if a request is made to the server for a data query, set up
                -- a notify subscription with the server to keep up to date on that
                -- information. Might want to do this when the data is returned
                -- from the server instead of here.
                let
                    ( processId, processStore ) =
                        Processing.add processType Nothing model.processStore

                    _ =
                        Debug.log "ProcessTypeMsg" <| toString jeVal
                in
                    ( { model | processStore = processStore }
                    , Ports.outgoing <| wrapPayload processId msgType jeVal
                    )

            ( AdmittingLoaded pregId, _ ) ->
                let
                    ( subModel, newStore, newCmd ) =
                        PageAdmitting.buildModel model.browserSupportsDate
                            model.currTime
                            model.processStore
                            pregId
                            model.patientRecord
                            model.pregnancyRecord
                            model.laborRecords
                in
                    { model
                        | pageState = Loaded (Admitting subModel)
                        , processStore = newStore
                    }
                        => newCmd

            ( LaborDelIppLoaded pregId, _ ) ->
                -- This page has enough of what it needs from the server in order
                -- to display the page. The newCmd returned from
                -- PageLaborDelIpp.buildModel may request more data from the server.
                let
                    ( subModel, newStore, newCmd ) =
                        PageLaborDelIpp.buildModel model.browserSupportsDate
                            model.currTime
                            model.processStore
                            pregId
                            model.patientRecord
                            model.pregnancyRecord
                            model.laborRecords
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

            ( PostpartumLoaded pregId laborRec, _ ) ->
                -- This page has enough of what it needs from the server in order
                -- to display the page. The newCmd returned from
                -- PagePostpartum.buildModel may request more data from the server.
                let
                    -- Get the labor stage records from the data cache which the
                    -- init function just requested records from the server for.
                    ( stage1, stage2, stage3 ) =
                        ( case DCache.get LaborStage1 model.dataCache of
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
                        )

                    ( subModel, newStore, newCmd ) =
                        PagePostpartum.buildModel laborRec
                            stage1
                            stage2
                            stage3
                            model.babyRecords
                            model.browserSupportsDate
                            model.currTime
                            model.processStore
                            pregId
                            model.patientRecord
                            model.pregnancyRecord
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

            ( SetRoute route, _ ) ->
                -- Handle route changes.
                let
                    _ =
                        Debug.log "update SetRoute" <| toString route
                in
                    setRoute route model

            ( OpenDatePicker id, _ ) ->
                -- For browsers without native date support in the input element,
                -- open a jQueryUI datepicker for the user.
                model => Ports.openDatePicker (JE.string id)

            ( IncomingDatePicker dateFieldMsg, LaborDelIpp subModel ) ->
                -- For browsers without native date support in the input element,
                -- receive the user's date selection from the jQueryUI datepicker.
                updateForPage LaborDelIpp
                    LaborDelIppMsg
                    model
                    (PageLaborDelIpp.update model.session)
                    (Data.LaborDelIpp.DateFieldSubMsg dateFieldMsg)
                    subModel

            ( AddLabor, LaborDelIpp subModel ) ->
                -- TODO: Is this being used?
                let
                    _ =
                        Debug.log "Medical.update ( AddLabor, LaborDelIpp subModel )" "Yes, this is being called but it does nothing yet."
                in
                    model => Cmd.none

            ( theMsg, thePage ) ->
                -- We should never get here.
                -- TODO: properly raise an error here.
                let
                    message =
                        "Unhandled msg of "
                            ++ (toString theMsg)
                            ++ " and page of "
                            ++ (toString thePage)
                            ++ " in Medical.update."
                in
                    model => (logConsole message)


{-| Handle all Msg.Message variations.
-}
updateMessage : IncomingMessage -> Model -> ( Model, Cmd Msg )
updateMessage incoming model =
    case incoming of
        UnknownMessage str ->
            model => (logConsole <| "UnknownMessage: " ++ str)

        SiteMessage siteMsg ->
            -- Note: we are discarding siteMsg.payload.updatedAt until we need it.
            { model | siteMessages = siteMsg.payload.data } => Cmd.none

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

                                Just (AddLaborType (AdmittingMsg (AdmitForLaborSaved lrn _)) laborRecNew) ->
                                    let
                                        laborRecs =
                                            laborRecordNewToLaborRecord
                                                (LaborId dataAddMsg.response.id)
                                                laborRecNew
                                                |> (\lr -> Dict.insert dataAddMsg.response.id lr (Maybe.withDefault Dict.empty model.laborRecords))
                                                |> Just

                                        subMsg =
                                            AdmitForLaborSaved lrn (Just <| LaborId dataAddMsg.response.id)
                                    in
                                        ( { model | laborRecords = laborRecs }
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

                                _ ->
                                    let
                                        msgText =
                                            "OOPS, unhandled processType in Medical.updateMessage in the DataAddMessage branch."
                                    in
                                        ( model, logConsole msgText )

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
                                    ( model, logConsole <| toString dataAddMsg.response )
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

                                Just (UpdateLaborType (LaborDelIppMsg (Data.LaborDelIpp.DataCache _ _)) laborRecord) ->
                                    -- TODO: why only updating the data cache here and not the top-level laborRecord?
                                    -- Don't we want to do both? But if we do, which is the master record?
                                    let
                                        laborRecs =
                                            Dict.insert dataChgMsg.response.id laborRecord (Maybe.withDefault Dict.empty model.laborRecords)

                                        subMsg =
                                            Data.LaborDelIpp.DataCache (Just model.dataCache) (Just [ Labor ])
                                    in
                                        ( { model
                                            | dataCache = DCache.put (LaborDataCache laborRecs) model.dataCache
                                            , laborRecords = Just laborRecs
                                          }
                                        , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                        )

                                Just (UpdateLaborType (AdmittingMsg (Data.Admitting.DataCache _ _)) laborRecord) ->
                                    let
                                        laborRecs =
                                            Dict.insert dataChgMsg.response.id laborRecord (Maybe.withDefault Dict.empty model.laborRecords)

                                        subMsg =
                                            Data.Admitting.DataCache (Just model.dataCache) (Just [ Labor ])
                                    in
                                        ( { model
                                            | dataCache = DCache.put (LaborDataCache laborRecs) model.dataCache
                                            , laborRecords = Just laborRecs
                                          }
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

                                _ ->
                                    let
                                        msgText =
                                            "OOPS, unhandled processType in Medical.updateMessage in the DataChgMessage branch: "
                                                ++ (toString processType)
                                    in
                                        ( model, logConsole msgText )

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
                                    ( model, logConsole <| toString dataChgMsg.response )
            in
                { newModel | processStore = processStore } => newCmd

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
                -- TODO: work out mechanism for detail pages to request data that the
                -- top-level model may already have.
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

                                                -- DataCache gets one baby record.
                                                dc =
                                                    case List.head recs of
                                                        Just r ->
                                                            DCache.put (BabyDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                                { mdl
                                                    | babyRecords = Just <| Dict.fromList dictList
                                                    , dataCache = dc
                                                }

                                        TableRecordLabor recs ->
                                            let
                                                dictList =
                                                    List.map (\rec -> ( rec.id, rec )) recs
                                            in
                                                { mdl | laborRecords = Just <| Dict.fromList dictList }

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

                                        TableRecordPatient recs ->
                                            -- We only ever want one patient in our store at a time.
                                            let
                                                -- TODO: eventually revise model to depend only on dataCache
                                                -- instead of separate patientRecord field in top-level model.
                                                rec =
                                                    List.head recs

                                                dc =
                                                    case rec of
                                                        Just r ->
                                                            DCache.put (PatientDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                                { mdl | patientRecord = rec, dataCache = dc }

                                        TableRecordPregnancy recs ->
                                            -- We only ever want one pregnancy in our store at a time.
                                            let
                                                -- TODO: eventually revise model to depend only on dataCache
                                                -- instead of separate pregnancyRecord field in top-level model.
                                                rec =
                                                    List.head recs

                                                dc =
                                                    case rec of
                                                        Just r ->
                                                            DCache.put (PregnancyDataCache r) mdl.dataCache

                                                        Nothing ->
                                                            mdl.dataCache
                                            in
                                                { mdl | pregnancyRecord = rec, dataCache = dc }
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

                        Just (AddLaborType msg _) ->
                            newModel2 => Task.perform (always msg) (Task.succeed True)

                        Just (AddLaborStage1Type msg _) ->
                            newModel2 => Task.perform (always msg) (Task.succeed True)

                        Just (UpdateBabyType msg _) ->
                            newModel2 => Task.perform (always msg) (Task.succeed True)

                        Just (UpdateLaborType msg _) ->
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

                        Just (SelectQueryType msg _) ->
                            newModel2 => Task.perform (always msg) (Task.succeed True)

                        Nothing ->
                            newModel2 => Cmd.none


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

            Just (Route.AdmittingRoute) ->
                case model.currPregId of
                    Just pid ->
                        PageAdmitting.init pid model.session model.processStore
                            |> (\( store, cmd ) -> transition store cmd)

                    Nothing ->
                        { model | pageState = Loaded NotFound } => Cmd.none

            Just (Route.LaborDelIppRoute) ->
                case model.currPregId of
                    Just pid ->
                        PageLaborDelIpp.init pid model.session model.processStore
                            |> (\( store, cmd ) -> transition store cmd)

                    Nothing ->
                        { model | pageState = Loaded NotFound } => Cmd.none

            Just (Route.PostpartumRoute) ->
                case ( model.currPregId, model.laborRecords ) of
                    ( Just pregId, Just recs ) ->
                        let
                            -- Get the most recent labor record which we assume is
                            -- the current one to use.
                            laborRec =
                                Dict.values recs
                                    |> LE.maximumBy
                                        (\lr ->
                                            if lr.falseLabor then
                                                -1
                                            else
                                                Date.toTime lr.admittanceDate
                                        )
                        in
                            case laborRec of
                                Just rec ->
                                    if not rec.falseLabor then
                                        PagePostpartum.init pregId rec model.session model.processStore
                                            |> (\( store, cmd ) -> transition store cmd)
                                    else
                                        -- We don't go there if we are not ready.
                                        model => Cmd.none

                                Nothing ->
                                    -- We don't go there if we are not ready.
                                    model => Cmd.none

                    ( _, _ ) ->
                        -- We don't go there if we are not ready.
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
