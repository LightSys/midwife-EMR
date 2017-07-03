module Updates.Profile exposing (userProfileUpdate)

import Form exposing (Form)


-- LOCAL IMPORTS

import Encoders as E
import Model exposing (..)
import Msg exposing (..)
import Ports


{-| Note that the user's profile is loaded on startup using
the adhoc mechanism.
-}
userProfileUpdate : UserProfileMsg -> Model -> ( Model, Cmd Msg )
userProfileUpdate msg ({ userProfile, userProfileForm } as model) =
    case msg of
        FormMsgUserProfile formMsg ->
            case ( formMsg, Form.getOutput userProfileForm ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation.
                    userProfileUpdate UpdateUserProfile model

                _ ->
                    -- Otherwise, pass it through validation again.
                    { model
                        | userProfileForm =
                            Form.update userProfileFormValidate formMsg model.userProfileForm
                    }
                        ! []

        UpdateUserProfile ->
            -- Initiate the update of the user's profile.
            -- This is NOT an optimistic update. Stay on the user profile editing
            -- page until the server confirms the change. The response will come
            -- back as (AdhocResponseMessages AdhocUserProfileUpdateResponseMsg).
            let
                newCmd =
                    case Form.getOutput model.userProfileForm of
                        Just upForm ->
                            Ports.userProfileUpdate <| E.userProfileFormToValue upForm

                        Nothing ->
                            Cmd.none
            in
                model ! [ newCmd ]
