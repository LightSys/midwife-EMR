module Updates.Adhoc exposing (adhocUpdate)

import Form
import Task


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (..)
import Task
import Types exposing (..)
import Utils exposing (addWarning, setPageDefs, setDefaultSelectedPage)


adhocUpdate : AdhocResponseMessage -> Model -> ( Model, Cmd Msg )
adhocUpdate msg model =
    case msg of
        AdhocLoginResponseMsg resp ->
            let
                _ =
                    Debug.log "AdhocLoginResponseMsg" <| toString resp
            in
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

                    ( True, LoginSuccessDifferentUserErrorCode ) ->
                        -- User logged in again from SPA login prompt, but as a different
                        -- user than previously. We totally clear the model by starting with
                        -- the initial model and request required info from the server again.
                        let
                            newModel =
                                ({ initialModel
                                    | userProfile = userProfileFromAuthResponse resp
                                    , loginForm = initialModel.loginForm
                                }
                                    |> setPageDefs
                                    |> setDefaultSelectedPage
                                    |> populateUserProfileForm
                                    |> registerUserProfileChanges
                                )

                            newCmds =
                                prefetchCmdsByRole newModel
                        in
                            newModel ! newCmds

                    ( _, _ ) ->
                        model ! []

        AdhocUnknownMsg msg ->
            let
                _ =
                    Debug.log "AdhocUnknownMsg" <| toString msg
            in
                model ! []

        AdhocUserProfileResponseMsg resp ->
            case ( resp.success, resp.errorCode ) of
                ( True, UserProfileSuccessErrorCode ) ->
                    let
                        newModel =
                            { model
                                | userProfile = userProfileFromAuthResponse resp
                            }
                                |> setPageDefs
                                |> setDefaultSelectedPage
                                |> populateUserProfileForm
                                |> registerUserProfileChanges

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

        AdhocUserProfileUpdateResponseMsg ({ success, errorCode, msg } as resp) ->
            -- Note that this change is initiated as a (UserProfileMsg UpdateUserProfile)
            -- message and that optimistic updates are not performed, meaning that
            -- the userProfile record in the top-level of the Model is not updated
            -- until the server confirms the change, which is handled below.
            let
                -- Save the user profile form data into the user profile upon success.
                newUserProfile =
                    case model.userProfile of
                        Just up ->
                            if success && errorCode == UserProfileUpdateSuccessErrorCode then
                                let
                                    ( recEmail, recShortName, recDisplayName ) =
                                        ( Form.getFieldAsString "email" model.userProfileForm |> .value
                                        , Form.getFieldAsString "shortName" model.userProfileForm |> .value
                                        , Form.getFieldAsString "displayName" model.userProfileForm |> .value
                                        )
                                in
                                    Just
                                        ({ up
                                            | email = Maybe.withDefault "" recEmail
                                            , shortName = Maybe.withDefault "" recShortName
                                            , displayName = Maybe.withDefault "" recDisplayName
                                         }
                                        )
                            else
                                model.userProfile

                        Nothing ->
                            model.userProfile

                -- Inform the user of any errors, and if not, refetch the user from the server
                -- if the user is an administrator.
                ( newModel, newCmd ) =
                    if not success || errorCode /= UserProfileUpdateSuccessErrorCode then
                        addWarning ("Oops, an error occurred. " ++ msg) model
                    else
                        case model.userProfile of
                            Just up ->
                                if up.roleName == "administrator" then
                                    ( model
                                    , [ SelectQuery User (Just up.userId) Nothing Nothing ]
                                        |> Task.succeed
                                        |> Task.perform SelectQueryMsg
                                    )
                                else
                                    ( model, Cmd.none )

                            Nothing ->
                                ( model, Cmd.none )
            in
                { newModel | userProfile = newUserProfile } ! [ newCmd ]


registerUserProfileChanges : Model -> Model
registerUserProfileChanges model =
    case model.userProfile of
        Just profile ->
            Model.addNotificationSubscription
                (NotificationSubscription User (NotifySubQualifierId profile.userId))
                model

        Nothing ->
            model


populateUserProfileForm : Model -> Model
populateUserProfileForm model =
    case model.userProfile of
        Just profile ->
            { model | userProfileForm = userProfileInitialForm profile }

        Nothing ->
            model


prefetchCmdsByRole : Model -> List (Cmd Msg)
prefetchCmdsByRole ({ userProfile } as model) =
    case userProfile of
        Just profile ->
            case profile.roleName of
                "administrator" ->
                    let
                        qry1 =
                            SelectQuery User Nothing Nothing Nothing

                        qry2 =
                            SelectQuery Role Nothing Nothing Nothing

                        qry3 =
                            SelectQuery KeyValue Nothing Nothing Nothing
                    in
                        [ Task.succeed [ qry1, qry2, qry3 ] |> Task.perform SelectQueryMsg ]

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
