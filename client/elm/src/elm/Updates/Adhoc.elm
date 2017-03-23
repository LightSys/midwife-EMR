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
                    let
                        userProfile =
                            case
                                ( resp.userId
                                , resp.username
                                , resp.firstname
                                , resp.lastname
                                , resp.email
                                , resp.lang
                                , resp.shortName
                                , resp.displayName
                                , resp.role_id
                                )
                            of
                                -- Build out an UserProfile if we have all the fields
                                -- from the server that we need.
                                ( Just userId, Just username, Just firstname, Just lastname, Just email, Just lang, Just shortName, Just displayName, Just role_id ) ->
                                    Just <| UserProfile userId username firstname lastname email lang shortName displayName role_id True

                                _ ->
                                    Nothing
                    in
                        { model | userProfile = userProfile } ! []

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
