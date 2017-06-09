module Updates.MedicationType exposing (medicationTypeUpdate)

import Form exposing (Form)
import Json.Encode as JE
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Models.MedicationType as MedType
import Models.Utils as MU
import Msg exposing (..)
import Ports
import Transactions as Trans
import Types exposing (..)
import Utils as U


{-| Handle certain error responses from the server here.
Let the update detail function do all of the heavy lifting.
-}
medicationTypeUpdate : MedicationTypeMsg -> Model -> ( Model, Cmd Msg )
medicationTypeUpdate msg model =
    let
        ( newModel, newCmd ) =
            medicationTypeUpdateDetail msg model

        newCmd2 =
            case msg of
                CreateResponseMedicationType response ->
                    U.handleSessionExpired response.errorCode

                DeleteResponseMedicationType response ->
                    U.handleSessionExpired response.errorCode

                UpdateResponseMedicationType response ->
                    U.handleSessionExpired response.errorCode

                _ ->
                    Cmd.none
    in
        ( newModel, Cmd.batch [ newCmd, newCmd2 ] )


medicationTypeUpdateDetail : MedicationTypeMsg -> Model -> ( Model, Cmd Msg )
medicationTypeUpdateDetail msg ({ medicationTypeModel } as model) =
    case msg of
        CancelEditMedicationType ->
            let
                editMode =
                    if medicationTypeModel.selectedRecordId == Nothing then
                        EditModeTable
                    else
                        EditModeView
            in
                -- User canceled, so reset data back to what we had before.
                ( MedType.populateSelectedTableForm medicationTypeModel
                    |> MU.setEditMode editMode
                    |> asMedicationTypeModelIn model
                , Cmd.none
                )

        CreateMedicationType ->
            let
                -- Get the table record from the form.
                medicationTypeRecord =
                    medicationTypeFormToRecord medicationTypeModel.form Nothing

                -- Determine if the sortOrder field is unique. It would be best to
                -- do this in validation instead of here if possible.
                failedSortOrder =
                    case RD.toMaybe medicationTypeModel.records of
                        Just recs ->
                            case
                                LE.find (\r -> r.sortOrder == medicationTypeRecord.sortOrder) recs
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
                        ( MU.addRecord medicationTypeRecord medicationTypeModel
                            |> asMedicationTypeModelIn model
                        , Ports.medicationTypeCreate <| E.medicationTypeToValue medicationTypeRecord
                        )
                    else
                        U.addMessage "The sort order number is not unique." model
            in
                newModel ! [ newCmd ]

        CreateResponseMedicationType { id, pendingId, success, msg } ->
            let
                -- Update the model with the server assigned id for the record.
                ( updatedRecords, ( newModel, newCmd ) ) =
                    case success of
                        True ->
                            ( MU.updateById pendingId
                                (\r -> { r | id = id })
                                medicationTypeModel.records
                            , ( model, Cmd.none )
                            )

                        False ->
                            -- Give a message to the user upon failure.
                            ( medicationTypeModel.records
                            , (if String.length msg == 0 then
                                "Sorry, the server rejected that addition."
                               else
                                msg
                              )
                                |> flip U.addWarning model
                            )

                -- Update the form and remove stored state from transaction manager.
                newModel2 =
                    MU.setRecords updatedRecords medicationTypeModel
                        |> MU.setEditMode EditModeView
                        |> MU.setSelectedRecordId (Just id)
                        |> MedType.populateSelectedTableForm
                        |> asMedicationTypeModelIn newModel
            in
                newModel2 ! [ newCmd ]

        DeleteMedicationType id ->
            -- This is an optimistic workflow.
            -- NOTE: this assumes that a delete was performed with the correct record
            -- loaded in the form.
            case id of
                Just recId ->
                    let
                        -- Save current rec as a transaction.
                        ( newModel, stateId ) =
                            case MU.getSelectedRecordAsString medicationTypeModel E.medicationTypeToValue of
                                Just s ->
                                    Trans.setState s Nothing model

                                Nothing ->
                                    ( model, Nothing )

                        -- Create command to send record to delete to the server.
                        newCmd2 =
                            medicationTypeFormToRecord newModel.medicationTypeModel.form stateId
                                |> E.medicationTypeToValue
                                |> Ports.medicationTypeDelete

                        -- Delete the record from the client and return to table view.
                        newModel2 =
                            newModel.medicationTypeModel
                                |> MU.delSelectedRecord
                                |> MU.setSelectedRecordId Nothing
                                |> MU.setEditMode EditModeTable
                                |> asMedicationTypeModelIn newModel
                    in
                        newModel2 ! [ newCmd2 ]

                Nothing ->
                    model ! []

        DeleteResponseMedicationType response ->
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
                                    |> Decoders.decodeMedicationTypeRecord
                            of
                                Just r ->
                                    MU.addRecord r medicationTypeModel
                                        |> MU.setSelectedRecordId (Just response.id)
                                        |> MedType.populateSelectedTableForm
                                        |> MU.setEditMode EditModeView
                                        |> asMedicationTypeModelIn model
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

        FirstMedicationType ->
            ( MedType.firstRecord medicationTypeModel
                |> asMedicationTypeModelIn model
            , Cmd.none
            )

        FormMsgMedicationType formMsg ->
            case ( formMsg, Form.getOutput medicationTypeModel.form ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation.
                    if medicationTypeModel.editMode == EditModeAdd then
                        medicationTypeUpdate CreateMedicationType model
                    else
                        medicationTypeUpdate UpdateMedicationType model

                _ ->
                    -- Otherwise, pass it through validation again.
                    (medicationTypeModel
                        |> MU.setForm
                            (Form.update MedType.medicationTypeValidate
                                formMsg
                                medicationTypeModel.form
                            )
                        |> asMedicationTypeModelIn model
                    )
                        ! []

        LastMedicationType ->
            ( MedType.lastRecord medicationTypeModel
                |> asMedicationTypeModelIn model
            , Cmd.none
            )

        NextMedicationType ->
            ( MedType.nextRecord medicationTypeModel
                |> asMedicationTypeModelIn model
            , Cmd.none
            )

        PrevMedicationType ->
            ( MedType.prevRecord medicationTypeModel
                |> asMedicationTypeModelIn model
            , Cmd.none
            )

        ReadResponseMedicationType medicationTypeTbl sq ->
            -- Merge records from the server into our model, update
            -- our form as necessary, and make sure we are subscribed
            -- to changes from the server.
            let
                subscription =
                    NotificationSubscription MedicationType NotifySubQualifierNone
            in
                ( MU.mergeById medicationTypeTbl medicationTypeModel.records
                    |> (\recs -> { medicationTypeModel | records = recs })
                    |> MU.setSelectQuery sq
                    |> MedType.populateSelectedTableForm
                    |> asMedicationTypeModelIn model
                    |> Model.addNotificationSubscription subscription
                , Cmd.none
                )

        SelectedRecordEditModeMedicationType mode id ->
            (medicationTypeModel
                |> MU.setSelectedRecordId id
                |> MU.setEditMode mode
                |> (\mtm ->
                        case ( mode, id ) of
                            ( EditModeAdd, _ ) ->
                                MedType.populateSelectedTableForm mtm

                            ( EditModeEdit, Just _ ) ->
                                MedType.populateSelectedTableForm mtm

                            ( EditModeView, Just _ ) ->
                                MedType.populateSelectedTableForm mtm

                            ( _, _ ) ->
                                mtm
                   )
                |> asMedicationTypeModelIn model
            )
                ! []

        SelectedRecordMedicationType id ->
            { model | medicationTypeModel = MU.setSelectedRecordId id medicationTypeModel } ! []

        UpdateMedicationType ->
            -- User saved on medicationType form. This is an optimistic workflow.
            let
                -- 1. Encode original entity record to a string and save the
                --    original rec to transactions in exchange for a transaction id.
                -- 2. Convert the form values which user just created into a table record.
                ( newModel, stateId, mtTable ) =
                    (case MU.getSelectedRecordAsString medicationTypeModel E.medicationTypeToValue of
                        Just s ->
                            Trans.setState s Nothing model

                        Nothing ->
                            ( model, Nothing )
                    )
                        |> (\( nm, sid ) ->
                                ( nm
                                , sid
                                , medicationTypeFormToRecord nm.medicationTypeModel.form sid
                                )
                           )

                -- 3. Optimistic update of the record in the list of records.
                updatedRecords =
                    case medicationTypeModel.selectedRecordId of
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
                                newModel.medicationTypeModel.records

                        Nothing ->
                            newModel.medicationTypeModel.records

                -- 4. Create the Cmd to send data to the server.
                newCmd =
                    Ports.medicationTypeUpdate <| E.medicationTypeToValue mtTable
            in
                ( newModel.medicationTypeModel
                    |> MU.setRecords updatedRecords
                    |> MU.setEditMode EditModeView
                    |> asMedicationTypeModelIn newModel
                    |> (\m -> { m | selectedTableEditMode = EditModeView })
                , newCmd
                )

        UpdateResponseMedicationType change ->
            let
                -- Remove the state id no matter what.
                noStateIdMedicationTypeRecords =
                    MU.updateById change.id
                        (\r -> { r | stateId = Nothing })
                        medicationTypeModel.records

                updatedRecords =
                    case change.success of
                        True ->
                            noStateIdMedicationTypeRecords

                        False ->
                            -- Server rejected change. Reset record back to original.
                            case
                                Trans.getState change.stateId model
                                    |> Decoders.decodeMedicationTypeRecord
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
                                        medicationTypeModel.records

                                Nothing ->
                                    -- TODO: if we get here, something is really messed
                                    -- up because we can't find our original record in
                                    -- the transaction manager.
                                    noStateIdMedicationTypeRecords

                -- Save the records to the model, update the form,
                -- and remove stored state from transaction manager.
                ( newModel, _ ) =
                    medicationTypeModel
                        |> MU.setRecords updatedRecords
                        |> MedType.populateSelectedTableForm
                        |> asMedicationTypeModelIn model
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


medicationTypeFormToRecord : Form () MedicationTypeForm -> Maybe Int -> MedicationTypeRecord
medicationTypeFormToRecord mt transId =
    let
        ( f_id, f_name, f_description, f_sortOrder ) =
            ( Form.getFieldAsString "id" mt
                |> .value
                |> U.maybeStringToInt -1
            , Form.getFieldAsString "name" mt
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "description" mt
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "sortOrder" mt
                |> .value
                |> U.maybeStringToInt -1
            )
    in
        MedicationTypeRecord f_id f_name f_description f_sortOrder transId
