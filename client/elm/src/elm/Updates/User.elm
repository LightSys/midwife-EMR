module Updates.User exposing (userUpdate)

import Form exposing (Form)
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Msg exposing (..)
import Model exposing (..)
import Models.User as User
import Models.Utils as MU
import Ports
import Task
import Transactions as Trans
import Types exposing (..)
import Utils as U


userUpdate : UserMsg -> Model -> ( Model, Cmd Msg )
userUpdate msg ({ userSearchForm, userModel } as model) =
    case msg of
        CancelEditUser ->
            -- User canceled, so reset data back to what we had before.
            ( User.populateSelectedTableForm userModel
                |> MU.setEditMode EditModeView
                |> asUserModelIn model
            , Cmd.none
            )

        CreateResponseUser { id, pendingId, success, msg } ->
            let
                -- Update the model with the server assigned id for the record.
                ( updatedRecords, ( newModel, newCmd ) ) =
                    case success of
                        True ->
                            ( MU.updateById pendingId
                                (\r -> { r | id = id })
                                userModel.records
                            , ( model, Cmd.none )
                            )

                        False ->
                            -- Give a message to the user upon failure.
                            ( userModel.records
                            , (if String.length msg == 0 then
                                "Sorry, the server rejected that addition."
                               else
                                msg
                              )
                                |> flip U.addWarning model
                            )

                -- Update the form and remove stored state from transaction manager.
                newModel2 =
                    MU.setRecords updatedRecords userModel
                        |> MU.setEditMode
                            (if success then
                                EditModeTable
                             else
                                EditModeEdit
                            )
                        |> MU.setSelectedRecordId (Just id)
                        |> User.populateSelectedTableForm
                        |> asUserModelIn newModel
            in
                newModel2 ! [ newCmd ]

        CreateUser ->
            let
                -- Get the table record from the form.
                userRecord =
                    userFormToRecord userModel.form Nothing

                -- Optimistic add of the record to the model with a pending id
                -- and create the Cmd to send data to the server.
                ( newModel, newCmd ) =
                    ( MU.addRecord userRecord userModel
                        |> asUserModelIn model
                    , Ports.userCreate <| E.userToValue userRecord
                    )
            in
                newModel ! [ newCmd ]

        CreateUserForm ->
            ( MU.setEditMode EditModeAdd userModel
                |> User.populateSelectedTableForm
                |> asUserModelIn model
            , Cmd.none
            )

        DeleteResponseUser response ->
            let
                -- 1. Update the model according to success or failure.
                ( newModel1, _ ) =
                    case response.success of
                        True ->
                            -- Optimistic update, so nothing to do.
                            ( model, Nothing )

                        False ->
                            -- Server rejected change. Insert record back,
                            -- select the record and populate the form.
                            -- Finally, remove transaction record.
                            case
                                Trans.getState response.stateId model
                                    |> Decoders.decodeUserRecord
                            of
                                Just r ->
                                    MU.addRecord r userModel
                                        |> MU.setSelectedRecordId (Just response.id)
                                        |> User.populateSelectedTableForm
                                        |> MU.setEditMode EditModeTable
                                        |> asUserModelIn model
                                        |> Trans.delState response.stateId

                                Nothing ->
                                    -- TODO: if we get here, something is really messed
                                    -- up because we can't find our original record in
                                    -- the transaction manager.
                                    ( model, Nothing )

                -- Give a message to the user upon failure.
                ( newModel2, newCmd2 ) =
                    if not response.success then
                        (if String.length response.msg == 0 then
                            "Sorry, the server rejected that deletion."
                         else
                            response.msg
                        )
                            |> flip U.addWarning newModel1
                    else
                        ( newModel1, Cmd.none )
            in
                newModel2 ! [ newCmd2 ]

        DeleteUser id ->
            -- This is an optimistic workflow.
            -- NOTE: this assumes that a delete was performed with the correct record
            -- loaded in the form.
            case id of
                Just recId ->
                    let
                        -- Save current rec as a transaction.
                        ( newModel, stateId ) =
                            case MU.getSelectedRecordAsString userModel E.userToValue of
                                Just s ->
                                    Trans.setState s Nothing model

                                Nothing ->
                                    ( model, Nothing )

                        -- Create command to send record to delete to the server.
                        newCmd2 =
                            userFormToRecord newModel.userModel.form stateId
                                |> E.userToValue
                                |> Ports.userDelete

                        -- Delete the record from the client and return to table view.
                        newModel2 =
                            newModel.userModel
                                |> MU.delSelectedRecord
                                |> MU.setSelectedRecordId Nothing
                                |> MU.setEditMode EditModeTable
                                |> asUserModelIn newModel
                    in
                        newModel2 ! [ newCmd2 ]

                Nothing ->
                    model ! []

        FormMsgUser formMsg ->
            case ( formMsg, Form.getOutput userModel.form ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation.
                    if userModel.editMode == EditModeAdd then
                        userUpdate CreateUser model
                    else
                        userUpdate UpdateUser model

                _ ->
                    -- Otherwise, pass it through validation again.
                    (userModel
                        |> MU.setForm
                            (Form.update User.userValidate
                                formMsg
                                userModel.form
                            )
                        |> asUserModelIn model
                    )
                        ! []

        FormMsgUserSearch formMsg ->
            case ( formMsg, Form.getOutput userSearchForm ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation.
                    model ! []

                _ ->
                    -- Otherwise, pass it through validation again.
                    { model
                        | userSearchForm = (Form.update userSearchFormValidate formMsg userSearchForm)
                    }
                        ! []

        FirstUser ->
            ( User.firstRecord userModel
                |> asUserModelIn model
            , Cmd.none
            )

        LastUser ->
            ( User.lastRecord userModel
                |> asUserModelIn model
            , Cmd.none
            )

        NextUser ->
            ( User.nextRecord userModel
                |> asUserModelIn model
            , Cmd.none
            )

        PrevUser ->
            ( User.prevRecord userModel
                |> asUserModelIn model
            , Cmd.none
            )

        ReadResponseUser userTbl sq ->
            -- Getting either all of the user records back or maybe just a subset.
            -- We merge what comes back with what we already have.
            let
                -- Subscribe to all changes from the user table.
                subscription =
                    NotificationSubscription User NotifySubQualifierNone

                -- If we are receiving a subset per the SelectQuery and the
                -- user id is this user's id, we also request the user profile
                -- again in order to keep the user's profile in sync.
                newCmd =
                    case sq of
                        Just query ->
                            case ( query.id, model.userProfile ) of
                                ( Just id, Just profile ) ->
                                    if id == profile.userId then
                                        Task.perform (always RequestUserProfile) (Task.succeed True)
                                    else
                                        Cmd.none

                                ( _, _ ) ->
                                    Cmd.none

                        Nothing ->
                            Cmd.none
            in
                ( MU.mergeById userTbl userModel.records
                    |> (\recs -> { userModel | records = recs })
                    |>
                        MU.setSelectQuery sq
                    |> asUserModelIn model
                    |> Model.addNotificationSubscription subscription
                , newCmd
                )

        SelectedRecordEditModeUser mode id ->
            (userModel
                |> MU.setSelectedRecordId id
                |> MU.setEditMode mode
                |> (\um ->
                        if mode /= EditModeTable && id /= Nothing then
                            User.populateSelectedTableForm um
                        else
                            um
                   )
                |> asUserModelIn model
            )
                ! []

        UpdateResponseUser change ->
            let
                -- Remove the state id no matter what.
                noStateIdUserRecords =
                    MU.updateById change.id
                        (\r -> { r | stateId = Nothing })
                        userModel.records

                updatedRecords =
                    case change.success of
                        True ->
                            noStateIdUserRecords

                        False ->
                            -- Server rejected change. Reset record back to original.
                            case
                                Trans.getState change.stateId model
                                    |> Decoders.decodeUserRecord
                            of
                                Just r ->
                                    MU.updateById change.id
                                        (\rec ->
                                            { rec
                                                | id = r.id
                                                , username = r.username
                                                , firstname = r.firstname
                                                , lastname = r.lastname
                                                , password = r.password
                                                , email = r.email
                                                , lang = r.lang
                                                , shortName = r.shortName
                                                , displayName = r.displayName
                                                , status = r.status
                                                , note = r.note
                                                , isCurrentTeacher = r.isCurrentTeacher
                                                , role_id = r.role_id
                                            }
                                        )
                                        userModel.records

                                Nothing ->
                                    -- Probably something is not right in encoding/decoding.
                                    let
                                        _ =
                                            Debug.log "UpdateResponseUser" "Cannot find state in transaction manager."
                                    in
                                        noStateIdUserRecords

                -- Save the records to the model, update the form,
                -- and remove stored state from transaction manager.
                ( newModel, _ ) =
                    userModel
                        |> MU.setRecords updatedRecords
                        |> User.populateSelectedTableForm
                        |> asUserModelIn model
                        |> Trans.delState change.stateId

                -- Give a message to the user upon failure.
                ( newModel2, newCmd2 ) =
                    if not change.success then
                        (if String.length change.msg == 0 then
                            "Sorry, the server rejected that change."
                         else
                            change.msg
                        )
                            |> flip U.addWarning newModel
                    else
                        ( newModel, Cmd.none )

                newCmd3 =
                    if change.errorCode == SessionExpiredErrorCode then
                        Task.perform (always SessionExpired) (Task.succeed True)
                    else
                        Cmd.none
            in
                newModel2 ! [ newCmd2, newCmd3 ]

        UpdateUser ->
            -- User saved on user form. This is an optimistic workflow.
            let
                -- 1. Encode original entity record to a string and save the
                --    original rec to transactions in exchange for a transaction id.
                -- 2. Convert the form values which user just created into a table record.
                ( newModel, stateId, userTable ) =
                    (case MU.getSelectedRecordAsString userModel E.userToValue of
                        Just s ->
                            Trans.setState s Nothing model

                        Nothing ->
                            let
                                _ =
                                    Debug.log "Oops, couldn't save state" "bug"
                            in
                                ( model, Nothing )
                    )
                        |> (\( nm, sid ) ->
                                ( nm
                                , sid
                                , userFormToRecord nm.userModel.form sid
                                )
                           )

                -- 3. Optimistic update of the record in the list of records.
                updatedRecords =
                    case userModel.selectedRecordId of
                        Just id ->
                            MU.updateById id
                                (\r ->
                                    { r
                                        | stateId = stateId
                                        , id = userTable.id
                                        , username = userTable.username
                                        , firstname = userTable.firstname
                                        , lastname = userTable.lastname
                                        , password = userTable.password
                                        , email = userTable.email
                                        , lang = userTable.lang
                                        , shortName = userTable.shortName
                                        , displayName = userTable.displayName
                                        , status = userTable.status
                                        , note = userTable.note
                                        , isCurrentTeacher = userTable.isCurrentTeacher
                                        , role_id = userTable.role_id
                                    }
                                )
                                newModel.userModel.records

                        Nothing ->
                            newModel.userModel.records

                -- 4. Create the Cmd to send data to the server.
                newCmd =
                    Ports.userUpdate <| E.userToValue userTable
            in
                ( newModel.userModel
                    |> MU.setRecords updatedRecords
                    |> MU.setEditMode EditModeView
                    |> asUserModelIn newModel
                    |> (\u -> { u | selectedTableEditMode = EditModeView })
                , newCmd
                )


userFormToRecord : Form () UserForm -> Maybe Int -> UserRecord
userFormToRecord user transId =
    let
        ( f_id, f_username, f_firstname, f_lastname, f_password, f_email, f_lang ) =
            ( Form.getFieldAsString "id" user
                |> .value
                |> U.maybeStringToInt -1
            , Form.getFieldAsString "username" user
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "firstname" user
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "lastname" user
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "password" user
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "email" user
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "lang" user
                |> .value
                |> Maybe.withDefault ""
            )

        ( f_shortName, f_displayName, f_status, f_note, f_isCurrentTeacher, f_role_id ) =
            ( Form.getFieldAsString "shortName" user
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "displayName" user
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsBool "status" user
                |> .value
                |> Maybe.withDefault False
            , Form.getFieldAsString "note" user
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsBool "isCurrentTeacher" user
                |> .value
                |> Maybe.withDefault False
            , Form.getFieldAsString "role_id" user
                |> .value
                |> U.maybeStringToInt 2
            )
    in
        UserRecord f_id
            f_username
            f_firstname
            f_lastname
            f_password
            f_email
            f_lang
            f_shortName
            f_displayName
            f_status
            f_note
            f_isCurrentTeacher
            f_role_id
            transId
