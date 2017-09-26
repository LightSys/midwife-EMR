module Medical exposing (..)

import Html as H exposing (Html)
import Json.Decode as JD
import Json.Decode.Pipeline as Pipeline exposing (decode, optional, required)
import Json.Encode as JE
import Navigation exposing (Location)
import Task exposing (Task)
import Window


-- LOCAL IMPORTS --

import Data.DataCache as DCache exposing (DataCache(..))
import Data.DatePicker as DDP exposing (DateField(..), DateFieldMessage(..))
import Data.Labor as Labor exposing (laborRecordNewToLaborRecord, LaborId(..), LaborRecord)
import Data.LaborDelIpp exposing (SubMsg(..))
import Data.LaborStage1 exposing (LaborStage1Id(..), laborStage1RecordNewToLaborStage1Record)
import Data.Message exposing (IncomingMessage(..), MsgType(..), wrapPayload)
import Data.Pregnancy as Pregnancy exposing (getPregId, PregnancyId(..))
import Data.Processing exposing (ProcessId(..))
import Data.Session as Session exposing (Session)
import Data.Table exposing (Table(..))
import Data.TableRecord exposing (TableRecord(..))
import Model exposing (Model, Page(..), PageState(..))
import Msg exposing (logConsole, Msg(..), ProcessType(..))
import Page.Errored as Errored exposing (PageLoadError, view)
import Page.LaborDelIpp as PageLaborDelIpp
import Page.NotFound as NotFound exposing (view)
import Ports
import Route exposing (fromLocation, Route(..))
import Processing
import Views.Page as Page exposing (ActivePage)
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
            Page.frame model.window isLoading model.currPregId model.session.user
    in
        case page of
            Blank ->
                H.text "Blank page"

            NotFound ->
                NotFound.view model.session
                    |> frame Page.Other

            LaborDelIpp subModel ->
                PageLaborDelIpp.view model.window model.session subModel
                    |> frame Page.LaborDelIpp
                    |> H.map LaborDelIppMsg

            Errored subModel ->
                Errored.view model.session subModel
                    |> frame Page.Other


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page



-- UPDATE --


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        page =
            getPage model.pageState

        updateForPage page routingMsg subUpdate subMsg subModel =
            let
                ( newModel, innerCmd, outerCmd ) =
                    subUpdate subMsg subModel
            in
                ( { model | pageState = Loaded (page newModel) }, Cmd.batch [ outerCmd, Cmd.map routingMsg innerCmd ] )
    in
        case ( msg, page ) of
            ( Noop, _ ) ->
                model => Cmd.none

            ( Tick time, _ ) ->
                -- Keep the current time in the Model.
                { model | currTime = time } => Cmd.none

            ( LogConsole msg, _ ) ->
                -- Write a message out to the console.
                let
                    _ =
                        Debug.log "LogConsole" msg
                in
                    model => Cmd.none

            ( WindowResize size, _ ) ->
                -- Keep the current window size in the Model.
                { model | window = size } => Cmd.none

            ( Message incoming, _ ) ->
                -- All messages from the server come through here first.
                updateMessage incoming model

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
                            model.laborRecord

                    _ =
                        Debug.log "newCmd" <| toString newCmd
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
                            (DataCache _ tbl) ->
                                DataCache (Just model.dataCache) tbl

                            _ ->
                                subMsg
                in
                    updateForPage LaborDelIpp LaborDelIppMsg (PageLaborDelIpp.update model.session) newSubMsg subModel

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
                    (PageLaborDelIpp.update model.session)
                    (Data.LaborDelIpp.DateFieldSubMsg dateFieldMsg)
                    subModel

            ( AddLabor, LaborDelIpp subModel ) ->
                -- TODO: Is this being used?
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
                                Just (AddLaborType (LaborDelIppMsg (AdmitForLaborSaved lrn _)) laborRecNew) ->
                                    let
                                        laborRecs =
                                            laborRecordNewToLaborRecord
                                                (LaborId dataAddMsg.response.id)
                                                laborRecNew
                                                |> flip U.addToMaybeList model.laborRecord

                                        subMsg =
                                            AdmitForLaborSaved lrn (Just <| LaborId dataAddMsg.response.id)
                                    in
                                        ( { model | laborRecord = laborRecs }
                                        , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                        )

                                Just (AddLaborStage1Type (LaborDelIppMsg (DataCache _ _)) laborStage1RecordNew) ->
                                    let
                                        laborStage1Rec =
                                            laborStage1RecordNewToLaborStage1Record
                                                (LaborStage1Id dataAddMsg.response.id)
                                                laborStage1RecordNew

                                        subMsg =
                                            DataCache (Just model.dataCache) (Just [ LaborStage1 ])
                                    in
                                        ( { model | dataCache = DCache.put (LaborStage1DataCache laborStage1Rec) model.dataCache }
                                        , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                        )

                                _ ->
                                    let
                                        msgText =
                                            "OOPS, unhandled processType in Medical.updateMessage in the DataAddMessage branch."
                                    in
                                        ( model, logConsole msgText )

                        False ->
                            ( model, Cmd.none )
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
                                Just (UpdateLaborStage1Type (LaborDelIppMsg (DataCache _ _)) laborStage1Record) ->
                                    let
                                        subMsg =
                                            DataCache (Just model.dataCache) (Just [ LaborStage1 ])
                                    in
                                        ( { model | dataCache = DCache.put (LaborStage1DataCache laborStage1Record) model.dataCache }
                                        , Task.perform LaborDelIppMsg (Task.succeed subMsg)
                                        )

                                _ ->
                                    let
                                        msgText =
                                            "OOPS, unhandled processType in Medical.updateMessage in the DataChgMessage branch."
                                    in
                                        ( model, logConsole msgText )


                        False ->
                            ( model, Cmd.none )

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
                                        TableRecordLabor recs ->
                                            { mdl | laborRecord = Just recs }

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
                                                { mdl | patientRecord = rec , dataCache = dc }

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
                        Just (AddLaborType msg _) ->
                            newModel2 => Task.perform (always msg) (Task.succeed True)

                        Just (AddLaborStage1Type msg _) ->
                            newModel2 => Task.perform (always msg) (Task.succeed True)

                        Just (UpdateLaborStage1Type msg _) ->
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

            Just (Route.LaborDelIppRoute) ->
                case model.currPregId of
                    Just pid ->
                        PageLaborDelIpp.init pid model.session model.processStore
                            |> (\( store, cmd ) -> transition store cmd)

                    Nothing ->
                        { model | pageState = Loaded NotFound } => Cmd.none


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
        , Time.every Time.second TickSubMsg
            |> Sub.map LaborDelIppMsg
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
