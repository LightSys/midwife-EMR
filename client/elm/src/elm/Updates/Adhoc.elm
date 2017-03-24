module Updates.Adhoc exposing (adhocUpdate)

-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (..)
import Types exposing (..)


adhocUpdate : AdhocResponseMessage -> Model -> ( Model, Cmd Msg )
adhocUpdate msg model =
    case msg of
        AdhocLoginResponseMsg resp ->
            case ( resp.success, resp.errorCode ) of
                ( True, LoginSuccessErrorCode ) ->
                    -- TODO: go back to last good location once we have navigation.
                    { model
                        | userProfile = userProfileFromAuthResponse resp
                        , loginForm = initialModel.loginForm
                    }
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
                    { model | userProfile = userProfileFromAuthResponse resp } ! []

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


userProfileFromAuthResponse : AuthResponse -> Maybe UserProfile
userProfileFromAuthResponse resp =
    case
        ( resp.userId
        , resp.username
        , resp.firstname
        , resp.lastname
        , resp.role_id
        )
    of
        -- Build out an UserProfile if we have a minimum of the fields from the server that we need.
        ( Just userId, Just username, Just firstname, Just lastname, Just role_id ) ->
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
                    resp.isLoggedIn

        _ ->
            Nothing
