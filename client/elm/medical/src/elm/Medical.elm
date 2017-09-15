module Medical exposing (..)

import Html as H exposing (Html)
import Json.Decode as JD
import Json.Decode.Pipeline as Pipeline exposing (decode, optional, required)
import Json.Encode as JE
import Navigation exposing (Location)
import Task exposing (Task)
import Window


-- LOCAL IMPORTS --

import Data.DatePicker as DDP exposing (DateField(..), DateFieldMessage(..))
import Data.Labor as Labor exposing (laborRecordNewToLaborRecord, LaborId(..), LaborRecord)
import Data.LaborDelIpp exposing (SubMsg(..))
import Data.Message exposing (IncomingMessage(..), MsgType(..), wrapPayload)
import Data.Pregnancy as Pregnancy exposing (getPregId, PregnancyId(..))
import Data.Processing exposing (ProcessId(..))
import Data.Session as Session exposing (Session)
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
                -- This page has all it needs from the server and is ready to go.
                { model
                    | pageState =
                        PageLaborDelIpp.buildModel model.browserSupportsDate
                            model.currTime
                            pregId
                            model.patientRecord
                            model.pregnancyRecord
                            model.laborRecord
                            |> LaborDelIpp
                            |> Loaded
                }
                    => Cmd.none

            ( LaborDelIppMsg subMsg, LaborDelIpp subModel ) ->
                let
                    _ =
                        Debug.log "LaborDelIppMsg top-level" <| toString model.laborRecord
                    _ =
                        Debug.log "LaborDelIppMsg subModel" <| toString subModel
                in
                -- All LaborDelIpp page sub messages are routed here.
                updateForPage LaborDelIpp LaborDelIppMsg (PageLaborDelIpp.update model.session) subMsg subModel

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
            -- Add the new record obtained from the processStore to the
            -- top-level model after attaching the id received from the server.
            -- Then pass the new record to the page per the Msg retrieved
            -- from the processStore.
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

                                _ ->
                                    ( model, Cmd.none )

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

                -- Store any data sent from the server into the model.
                newModel =
                    case dataMsg.response.success of
                        True ->
                            List.foldl
                                (\tr mdl ->
                                    case tr of
                                        TableRecordLabor recs ->
                                            { mdl | laborRecord = Just recs }

                                        TableRecordPatient recs ->
                                            -- We only ever want one patient in our store at a time.
                                            { mdl | patientRecord = List.head recs }

                                        TableRecordPregnancy recs ->
                                            -- We only ever want one pregnancy in our store at a time.
                                            { mdl | pregnancyRecord = List.head recs }
                                )
                                model
                                dataMsg.response.data

                        False ->
                            -- TODO: handle failure better here.
                            model
            in
                case processType of
                    -- Send the message retrieved from the processing store.
                    Just (AddLaborType msg _) ->
                        { newModel | processStore = processStore }
                            => Task.perform (always msg) (Task.succeed True)

                    Just (SelectQueryType msg _) ->
                        { newModel | processStore = processStore }
                            => Task.perform (always msg) (Task.succeed True)

                    Nothing ->
                        newModel => Cmd.none


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
