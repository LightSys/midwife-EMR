module Updates.Adhoc exposing (adhocUpdate)

import Task

-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (..)
import Types exposing (..)
import Utils exposing (setPageDefs, setDefaultSelectedPage)


adhocUpdate : AdhocResponseMessage -> Model -> ( Model, Cmd Msg )
adhocUpdate msg model =
    case msg of
        AdhocLoginResponseMsg resp ->
            case ( resp.success, resp.errorCode ) of
                ( True, LoginSuccessErrorCode ) ->
                    -- TODO: go back to last good location once we have navigation.
                    ({ model
                        | userProfile = userProfileFromAuthResponse resp
                        , loginForm = initialModel.loginForm
                     }
                        |> setPageDefs
                        |> setDefaultSelectedPage
                    )
                        ! []

                ( _, _ ) ->
                    let
                        _ =
                            Debug.log "AdhocLoginResponseMsg" <| toString resp
                    in
                        model ! []

        AdhocUserProfileResponseMsg resp ->
            case ( resp.success, resp.errorCode ) of
                ( True, UserProfileSuccessErrorCode ) ->
                    let
                        newModel =
                            ({ model
                                | userProfile = userProfileFromAuthResponse resp
                            }
                                |> setPageDefs
                                |> setDefaultSelectedPage
                            )

                        newCmds =
                            prefetchCmdsByRole newModel
                    in
                        newModel ! newCmds

                ( _, _ ) ->
                    let
                        _ =
                            Debug.log "AdhocLoginResponseMsg" <| toString resp
                    in
                        model ! []

        AdhocUnknownMsg msg ->
            let
                _ =
                    Debug.log "AdhocUnknownMsg" <| toString msg
            in
                model ! []


prefetchCmdsByRole : Model -> List ( Cmd Msg )
prefetchCmdsByRole ({userProfile} as model) =
    case userProfile of
        Just profile ->
            case profile.roleName of
                "administrator" ->
                    let
                        qry1 =
                            SelectQuery User Nothing Nothing Nothing

                        qry2 =
                            SelectQuery Role Nothing Nothing Nothing
                    in
                        [ Task.perform (always <| SelectQueryMsg qry1) (Task.succeed True)
                        , Task.perform (always <| SelectQueryMsg qry2) (Task.succeed True)
                        ]

                _ ->
                    []
        Nothing ->
            []


userProfileFromAuthResponse : AuthResponse -> Maybe UserProfile
userProfileFromAuthResponse resp =
    case
        ( resp.userId
        , resp.username
        , resp.firstname
        , resp.lastname
        , resp.role_id
        , resp.roleName
        )
    of
        -- Build out an UserProfile if we have a minimum of the fields from the server that we need.
        ( Just userId, Just username, Just firstname, Just lastname, Just role_id, Just roleName ) ->
            Just <|
                UserProfile userId
                    username
                    firstname
                    lastname
                    (Maybe.withDefault "" resp.email)
                    (Maybe.withDefault "" resp.lang)
                    (Maybe.withDefault "" resp.shortName)
                    (Maybe.withDefault "" resp.displayName)
                    role_id
                    roleName
                    resp.isLoggedIn

        _ ->
            Nothing
