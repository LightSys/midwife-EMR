module Medical exposing (..)

import Html as H exposing (Html)
import Json.Decode as JD
import Json.Decode.Pipeline as Pipeline exposing (decode, optional, required)
import Navigation exposing (Location)
import Task exposing (Task)
import Window


-- LOCAL IMPORTS --

import Data.Message exposing (IncomingMessage(..))
import Data.Pregnancy as Pregnancy exposing (getPregId, PregnancyId(..))
import Data.Processing exposing (ProcessId(..))
import Data.Session as Session exposing (Session)
import Data.TableRecord exposing (TableRecord(..))
import Model exposing (Model, Page(..), PageState(..))
import Msg exposing (Msg(..), ProcessType(..))
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
    }


flagsDecoder : JD.Decoder Flags
flagsDecoder =
    decode Flags
        |> required "pregId" (JD.nullable JD.string)
        |> required "currTime" JD.float


decodeFlagsFromJson : JD.Value -> Flags
decodeFlagsFromJson json =
    JD.decodeValue flagsDecoder json
        |> Result.withDefault (Flags Nothing 0)


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

        currTime =
            flagsDecoded.currTime

        ( newModel, newCmd ) =
            setRoute (Route.fromLocation location) <|
                Model.initialModel pregId currTime
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
    case msg of
        Noop ->
            model => Cmd.none

        Tick time ->
            { model | currTime = time } => Cmd.none

        LogConsole msg ->
            let
                _ =
                    Debug.log "update: LogConsole" msg
            in
                model => Cmd.none

        WindowResize size ->
            { model | window = size } => Cmd.none

        Message incoming ->
            updateMessage incoming model

        LaborDelIppLoaded pregId ->
            { model
                | pageState =
                    PageLaborDelIpp.buildModel model.currTime pregId model.patientRecord model.pregnancyRecord
                        |> LaborDelIpp
                        |> Loaded
            }
                => Cmd.none

        _ ->
            model => Cmd.none


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


logConsole : String -> Cmd Msg
logConsole msg =
    Task.perform LogConsole (Task.succeed msg)


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
