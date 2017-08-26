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
import Data.LaborDelIpp
import Data.Message exposing (IncomingMessage(..))
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
import Util exposing ((=>))


-- MODEL --


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
                { model | currTime = time } => Cmd.none

            ( LogConsole msg, _ ) ->
                let
                    _ =
                        Debug.log "update: LogConsole" msg
                in
                    model => Cmd.none

            ( WindowResize size, _ ) ->
                { model | window = size } => Cmd.none

            ( Message incoming, _ ) ->
                updateMessage incoming model

            ( LaborDelIppLoaded pregId, _ ) ->
                { model
                    | pageState =
                        PageLaborDelIpp.buildModel model.browserSupportsDate
                            model.currTime
                            pregId
                            model.patientRecord
                            model.pregnancyRecord
                            |> LaborDelIpp
                            |> Loaded
                }
                    => Cmd.none

            ( LaborDelIppMsg subMsg, LaborDelIpp subModel ) ->
                updateForPage LaborDelIpp LaborDelIppMsg (PageLaborDelIpp.update model.session) subMsg subModel

            ( SetRoute route, _ ) ->
                let
                    _ =
                        Debug.log "update SetRoute" <| toString route
                in
                    setRoute route model

            ( OpenDatePicker id, _ ) ->
                model => Ports.openDatePicker (JE.string id)

            ( IncomingDatePicker dateFieldMsg, LaborDelIpp subModel ) ->
                updateForPage LaborDelIpp
                    LaborDelIppMsg
                    (PageLaborDelIpp.update model.session)
                    (Data.LaborDelIpp.DateFieldSubMsg dateFieldMsg)
                    subModel

            ( _, _ ) ->
                model => (logConsole "Unhandled msg and page in Medical.update.")


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

        DataMessage dataMsg ->
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
                    Just (SelectQueryType msg sq) ->
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
