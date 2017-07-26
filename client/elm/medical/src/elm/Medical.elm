module Medical exposing (..)

import Html as H exposing (Html)
import Json.Decode as JD
import Json.Decode.Pipeline as Pipeline exposing (decode, optional, required)
import Navigation exposing (Location)
import Task
import Window


-- LOCAL IMPORTS --

import Data.Pregnancy as Pregnancy exposing (getPregId, PregnancyId(..))
import Data.Session as Session exposing (Session)
import Page.Errored as Errored exposing (PageLoadError, view)
import Page.LaborDelIpp as LaborDelIpp
import Page.NotFound as NotFound exposing (view)
import Route exposing (fromLocation, Route(..))
import Views.Page as Page exposing (ActivePage)
import Util exposing ((=>))


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | LaborDelIpp LaborDelIpp.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- MODEL --


type alias Model =
    { pageState : PageState
    , session : Session
    , currPregId : Maybe PregnancyId
    , window: Maybe Window.Size
    }


type alias Flags =
    { pregId : Maybe String
    }


flagsDecoder : JD.Decoder Flags
flagsDecoder =
    decode Flags
        |> required "pregId" (JD.nullable JD.string)


decodeFlagsFromJson : JD.Value -> Flags
decodeFlagsFromJson json =
    JD.decodeValue flagsDecoder json
        |> Result.withDefault (Flags Nothing)


init : JD.Value -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        pregId =
            case (decodeFlagsFromJson flags).pregId of
                Just pid ->
                    String.toInt pid
                        |> Result.map PregnancyId
                        |> Result.toMaybe

                Nothing ->
                    Nothing

        (newModel, newCmd) =
            setRoute (Route.fromLocation location)
                { pageState = Loaded <| initialPage pregId
                , session = { user = Nothing }
                , currPregId = pregId
                , window = Nothing
                }
    in
    ( newModel
    , Cmd.batch [ newCmd, Task.perform (\s -> WindowResize (Just s)) Window.size ]
    )


initialPage : Maybe PregnancyId -> Page
initialPage pregId =
    case pregId of
        Just pid ->
            LaborDelIpp { pregnancy_id = pid }

        Nothing ->
            Blank



-- VIEW --


view : Model -> Html Msg
view model =
    let
        _ =
            Debug.log "view" <| toString model
    in
        case model.pageState of
            Loaded page ->
                viewPage model.window model.currPregId model.session False page

            TransitioningFrom page ->
                viewPage model.window model.currPregId model.session True page


viewPage : Maybe Window.Size -> Maybe PregnancyId -> Session -> Bool -> Page -> Html Msg
viewPage winSize pregId session isLoading page =
    let
        frame =
            Page.frame winSize isLoading pregId session.user
    in
        case page of
            Blank ->
                H.text "Blank page"

            NotFound ->
                NotFound.view session
                    |> frame Page.Other

            LaborDelIpp subModel ->
                LaborDelIpp.view winSize session subModel
                    |> frame Page.LaborDelIpp
                    |> H.map LaborDelIppMsg

            Errored subModel ->
                Errored.view session subModel
                    |> frame Page.Other


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page



-- UPDATE --


type Msg
    = Noop
    | WindowResize (Maybe Window.Size)
    | SetRoute (Maybe Route)
    | LaborDelIppLoaded (Result PageLoadError LaborDelIpp.Model)
    | LaborDelIppMsg LaborDelIpp.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            model => Cmd.none

        WindowResize size ->
            { model | window = size } => Cmd.none

        _ ->
            model => Cmd.none



setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            { model | pageState = TransitioningFrom (getPage model.pageState) }
                => Task.attempt toMsg task

        errored =
            pageErrored model
    in
        case maybeRoute of
            Nothing ->
                { model | pageState = Loaded NotFound } => Cmd.none

            Just (Route.LaborDelIpp) ->
                case model.currPregId of
                    Just pid ->
                        transition LaborDelIppLoaded (LaborDelIpp.init pid model.session)

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
        [ Window.resizes (\s -> WindowResize (Just s)) ]



-- MAIN --


main : Program JD.Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
