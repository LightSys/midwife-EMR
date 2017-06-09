module Updates.VaccinationType exposing (vaccinationTypeUpdate)

import Form exposing (Form)
import Json.Encode as JE
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Models.VaccinationType as VacType
import Models.Utils as MU
import Msg exposing (..)
import Ports
import Transactions as Trans
import Types exposing (..)
import Utils as U


{-| Handle certain error responses from the server here.
Let the update detail function do all of the heavy lifting.
-}
vaccinationTypeUpdate : VaccinationTypeMsg -> Model -> ( Model, Cmd Msg )
vaccinationTypeUpdate msg model =
    let
        ( newModel, newCmd ) =
            vaccinationTypeUpdateDetail msg model

        newCmd2 =
            case msg of
                CreateResponseVaccinationType response ->
                    U.handleSessionExpired response.errorCode

                DeleteResponseVaccinationType response ->
                    U.handleSessionExpired response.errorCode

                UpdateResponseVaccinationType response ->
                    U.handleSessionExpired response.errorCode

                _ ->
                    Cmd.none
    in
        ( newModel, Cmd.batch [ newCmd, newCmd2 ] )


vaccinationTypeUpdateDetail : VaccinationTypeMsg -> Model -> ( Model, Cmd Msg )
vaccinationTypeUpdateDetail msg ({ vaccinationTypeModel } as model) =
    case msg of
        CancelEditVaccinationType ->
            let
                editMode =
                    if vaccinationTypeModel.selectedRecordId == Nothing then
                        EditModeTable
                    else
                        EditModeView
            in
                -- User canceled, so reset data back to what we had before.
                ( VacType.populateSelectedTableForm vaccinationTypeModel
                    |> MU.setEditMode editMode
                    |> asVaccinationTypeModelIn model
                , Cmd.none
                )

        CreateVaccinationType ->
            let
                -- Get the table record from the form.
                vaccinationTypeRecord =
                    vaccinationTypeFormToRecord vaccinationTypeModel.form Nothing

                -- Determine if the sortOrder field is unique. It would be best to
                -- do this in validation instead of here if possible.
                failedSortOrder =
                    case RD.toMaybe vaccinationTypeModel.records of
                        Just recs ->
                            case
                                LE.find (\r -> r.sortOrder == vaccinationTypeRecord.sortOrder) recs
                            of
                                Just r ->
                                    True

                                Nothing ->
                                    False

                        Nothing ->
                            -- What should this be?
                            False

                -- Optimistic add of the record to the model with a pending id
                -- and create the Cmd to send data to the server. Or give a message
                -- to the user to effect that the sort order is wrong.
                ( newModel, newCmd ) =
                    if not failedSortOrder then
                        ( MU.addRecord vaccinationTypeRecord vaccinationTypeModel
                            |> asVaccinationTypeModelIn model
                        , Ports.vaccinationTypeCreate <| E.vaccinationTypeToValue vaccinationTypeRecord
                        )
                    else
                        U.addMessage "The sort order number is not unique." model
            in
                newModel ! [ newCmd ]

        CreateResponseVaccinationType { id, pendingId, success, msg } ->
            let
                -- Update the model with the server assigned id for the record.
                ( updatedRecords, ( newModel, newCmd ) ) =
                    case success of
                        True ->
                            ( MU.updateById pendingId
                                (\r -> { r | id = id })
                                vaccinationTypeModel.records
                            , ( model, Cmd.none )
                            )

                        False ->
                            -- Give a message to the user upon failure.
                            ( vaccinationTypeModel.records
                            , (if String.length msg == 0 then
                                "Sorry, the server rejected that addition."
                               else
                                msg
                              )
                                |> flip U.addWarning model
                            )

                -- Update the form and remove stored state from transaction manager.
                newModel2 =
                    MU.setRecords updatedRecords vaccinationTypeModel
                        |> MU.setEditMode EditModeView
                        |> MU.setSelectedRecordId (Just id)
                        |> VacType.populateSelectedTableForm
                        |> asVaccinationTypeModelIn newModel
            in
                newModel2 ! [ newCmd ]

        DeleteVaccinationType id ->
            -- This is an optimistic workflow.
            -- NOTE: this assumes that a delete was performed with the correct record
            -- loaded in the form.
            case id of
                Just recId ->
                    let
                        -- Save current rec as a transaction.
                        ( newModel, stateId ) =
                            case MU.getSelectedRecordAsString vaccinationTypeModel E.vaccinationTypeToValue of
                                Just s ->
                                    Trans.setState s Nothing model

                                Nothing ->
                                    ( model, Nothing )

                        -- Create command to send record to delete to the server.
                        newCmd2 =
                            vaccinationTypeFormToRecord newModel.vaccinationTypeModel.form stateId
                                |> E.vaccinationTypeToValue
                                |> Ports.vaccinationTypeDelete

                        -- Delete the record from the client and return to table view.
                        newModel2 =
                            newModel.vaccinationTypeModel
                                |> MU.delSelectedRecord
                                |> MU.setSelectedRecordId Nothing
                                |> MU.setEditMode EditModeTable
                                |> asVaccinationTypeModelIn newModel
                    in
                        newModel2 ! [ newCmd2 ]

                Nothing ->
                    model ! []

        DeleteResponseVaccinationType response ->
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
                                    |> Decoders.decodeVaccinationTypeRecord
                            of
                                Just r ->
                                    MU.addRecord r vaccinationTypeModel
                                        |> MU.setSelectedRecordId (Just response.id)
                                        |> VacType.populateSelectedTableForm
                                        |> MU.setEditMode EditModeView
                                        |> asVaccinationTypeModelIn model
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

        FirstVaccinationType ->
            ( VacType.firstRecord vaccinationTypeModel
                |> asVaccinationTypeModelIn model
            , Cmd.none
            )

        FormMsgVaccinationType formMsg ->
            case ( formMsg, Form.getOutput vaccinationTypeModel.form ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation.
                    if vaccinationTypeModel.editMode == EditModeAdd then
                        vaccinationTypeUpdate CreateVaccinationType model
                    else
                        vaccinationTypeUpdate UpdateVaccinationType model

                _ ->
                    -- Otherwise, pass it through validation again.
                    (vaccinationTypeModel
                        |> MU.setForm
                            (Form.update VacType.vaccinationTypeValidate
                                formMsg
                                vaccinationTypeModel.form
                            )
                        |> asVaccinationTypeModelIn model
                    )
                        ! []

        LastVaccinationType ->
            ( VacType.lastRecord vaccinationTypeModel
                |> asVaccinationTypeModelIn model
            , Cmd.none
            )

        NextVaccinationType ->
            ( VacType.nextRecord vaccinationTypeModel
                |> asVaccinationTypeModelIn model
            , Cmd.none
            )

        PrevVaccinationType ->
            ( VacType.prevRecord vaccinationTypeModel
                |> asVaccinationTypeModelIn model
            , Cmd.none
            )

        ReadResponseVaccinationType vaccinationTypeTbl sq ->
            -- Merge records from the server into our model, update
            -- our form as necessary, and make sure we are subscribed
            -- to changes from the server.
            let
                subscription =
                    NotificationSubscription VaccinationType NotifySubQualifierNone
            in
                ( MU.mergeById vaccinationTypeTbl vaccinationTypeModel.records
                    |> (\recs -> { vaccinationTypeModel | records = recs })
                    |> MU.setSelectQuery sq
                    |> VacType.populateSelectedTableForm
                    |> asVaccinationTypeModelIn model
                    |> Model.addNotificationSubscription subscription
                , Cmd.none
                )

        SelectedRecordEditModeVaccinationType mode id ->
            (vaccinationTypeModel
                |> MU.setSelectedRecordId id
                |> MU.setEditMode mode
                |> (\vtm ->
                        case ( mode, id ) of
                            ( EditModeAdd, _ ) ->
                                VacType.populateSelectedTableForm vtm

                            ( EditModeEdit, Just _ ) ->
                                VacType.populateSelectedTableForm vtm

                            ( EditModeView, Just _ ) ->
                                VacType.populateSelectedTableForm vtm

                            ( _, _ ) ->
                                vtm
                   )
                |> asVaccinationTypeModelIn model
            )
                ! []

        SelectedRecordVaccinationType id ->
            { model | vaccinationTypeModel = MU.setSelectedRecordId id vaccinationTypeModel } ! []

        UpdateVaccinationType ->
            -- User saved on vaccinationType form. This is an optimistic workflow.
            let
                -- 1. Encode original entity record to a string and save the
                --    original rec to transactions in exchange for a transaction id.
                -- 2. Convert the form values which user just created into a table record.
                ( newModel, stateId, mtTable ) =
                    (case MU.getSelectedRecordAsString vaccinationTypeModel E.vaccinationTypeToValue of
                        Just s ->
                            Trans.setState s Nothing model

                        Nothing ->
                            ( model, Nothing )
                    )
                        |> (\( nm, sid ) ->
                                ( nm
                                , sid
                                , vaccinationTypeFormToRecord nm.vaccinationTypeModel.form sid
                                )
                           )

                -- 3. Optimistic update of the record in the list of records.
                updatedRecords =
                    case vaccinationTypeModel.selectedRecordId of
                        Just id ->
                            MU.updateById id
                                (\r ->
                                    { r
                                        | stateId = stateId
                                        , name = mtTable.name
                                        , description = mtTable.description
                                        , sortOrder = mtTable.sortOrder
                                    }
                                )
                                newModel.vaccinationTypeModel.records

                        Nothing ->
                            newModel.vaccinationTypeModel.records

                -- 4. Create the Cmd to send data to the server.
                newCmd =
                    Ports.vaccinationTypeUpdate <| E.vaccinationTypeToValue mtTable
            in
                ( newModel.vaccinationTypeModel
                    |> MU.setRecords updatedRecords
                    |> MU.setEditMode EditModeView
                    |> asVaccinationTypeModelIn newModel
                    |> (\m -> { m | selectedTableEditMode = EditModeView })
                , newCmd
                )

        UpdateResponseVaccinationType change ->
            let
                -- Remove the state id no matter what.
                noStateIdVaccinationTypeRecords =
                    MU.updateById change.id
                        (\r -> { r | stateId = Nothing })
                        vaccinationTypeModel.records

                updatedRecords =
                    case change.success of
                        True ->
                            noStateIdVaccinationTypeRecords

                        False ->
                            -- Server rejected change. Reset record back to original.
                            case
                                Trans.getState change.stateId model
                                    |> Decoders.decodeVaccinationTypeRecord
                            of
                                Just r ->
                                    MU.updateById change.id
                                        (\rec ->
                                            { rec
                                                | name = r.name
                                                , description = r.description
                                                , sortOrder = r.sortOrder
                                            }
                                        )
                                        vaccinationTypeModel.records

                                Nothing ->
                                    -- TODO: if we get here, something is really messed
                                    -- up because we can't find our original record in
                                    -- the transaction manager.
                                    noStateIdVaccinationTypeRecords

                -- Save the records to the model, update the form,
                -- and remove stored state from transaction manager.
                ( newModel, _ ) =
                    vaccinationTypeModel
                        |> MU.setRecords updatedRecords
                        |> VacType.populateSelectedTableForm
                        |> asVaccinationTypeModelIn model
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
            in
                newModel2 ! [ newCmd2, newCmd2 ]


vaccinationTypeFormToRecord : Form () VaccinationTypeForm -> Maybe Int -> VaccinationTypeRecord
vaccinationTypeFormToRecord vt transId =
    let
        ( f_id, f_name, f_description, f_sortOrder ) =
            ( Form.getFieldAsString "id" vt
                |> .value
                |> U.maybeStringToInt -1
            , Form.getFieldAsString "name" vt
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "description" vt
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "sortOrder" vt
                |> .value
                |> U.maybeStringToInt -1
            )
    in
        VaccinationTypeRecord f_id f_name f_description f_sortOrder transId
