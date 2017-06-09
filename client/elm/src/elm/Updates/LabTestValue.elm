module Updates.LabTestValue exposing (labTestValueUpdate)

import Dict
import Form exposing (Form)
import Json.Encode as JE
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Models.LabTestValue as LabTestValue
import Models.Utils as MU
import Msg exposing (..)
import Ports
import Transactions as Trans
import Types exposing (..)
import Utils as U


{-| Handle certain error responses from the server here.
Let the update detail function do all of the heavy lifting.
-}
labTestValueUpdate : LabTestValueMsg -> Model -> ( Model, Cmd Msg )
labTestValueUpdate msg model =
    let
        ( newModel, newCmd ) =
            labTestValueUpdateDetail msg model

        newCmd2 =
            case msg of
                CreateResponseLabTestValue response ->
                    U.handleSessionExpired response.errorCode

                DeleteResponseLabTestValue response ->
                    U.handleSessionExpired response.errorCode

                UpdateResponseLabTestValue response ->
                    U.handleSessionExpired response.errorCode

                _ ->
                    Cmd.none
    in
        ( newModel, Cmd.batch [ newCmd, newCmd2 ] )


labTestValueUpdateDetail : LabTestValueMsg -> Model -> ( Model, Cmd Msg )
labTestValueUpdateDetail msg ({ labTestValueModel } as model) =
    case msg of
        CancelEditLabTestValue ->
            let
                editMode =
                    if labTestValueModel.selectedRecordId == Nothing then
                        EditModeTable
                    else
                        EditModeView
            in
                -- User canceled, so reset data back to what we had before.
                ( LabTestValue.populateSelectedTableForm labTestValueModel
                    |> MU.setEditMode editMode
                    |> asLabTestValueModelIn model
                , Cmd.none
                )

        CreateLabTestValue ->
            let
                -- Get the table record from the form.
                labTestValueRecord =
                    labTestValueFormToRecord labTestValueModel.form Nothing

                -- Optimistic add of the record to the model with a pending id
                -- and create the Cmd to send data to the server. Or give a message
                -- to the user to effect that the sort order is wrong.
                ( newModel, newCmd ) =
                    ( MU.addRecord labTestValueRecord labTestValueModel
                        |> asLabTestValueModelIn model
                    , Ports.labTestValueCreate <| E.labTestValueToValue labTestValueRecord
                    )
            in
                newModel ! [ newCmd ]

        CreateResponseLabTestValue ({ id, pendingId, success, msg } as response) ->
            let
                -- Update the model with the server assigned id for the record.
                ( updatedRecords, ( newModel, newCmd ) ) =
                    case success of
                        True ->
                            ( MU.updateById pendingId
                                (\r -> { r | id = id })
                                labTestValueModel.records
                            , ( model, Cmd.none )
                            )

                        False ->
                            -- Give a message to the user upon failure.
                            ( labTestValueModel.records
                            , (if String.length msg == 0 then
                                "Sorry, the server rejected that addition."
                               else
                                msg
                              )
                                |> flip U.addWarning model
                            )

                -- Update the form and remove stored state from transaction manager.
                newModel2 =
                    MU.setRecords updatedRecords labTestValueModel
                        |> MU.setEditMode EditModeView
                        |> MU.setSelectedRecordId (Just id)
                        |> LabTestValue.populateSelectedTableForm
                        |> asLabTestValueModelIn newModel
            in
                newModel2 ! [ newCmd ]

        DeleteLabTestValue id ->
            -- This is an optimistic workflow.
            -- NOTE: this assumes that a delete was performed with the correct record
            -- loaded in the form.
            case id of
                Just recId ->
                    let
                        -- Save current rec as a transaction.
                        ( newModel, stateId ) =
                            case MU.getSelectedRecordAsString labTestValueModel E.labTestValueToValue of
                                Just s ->
                                    Trans.setState s Nothing model

                                Nothing ->
                                    ( model, Nothing )

                        -- Create command to send record to delete to the server.
                        newCmd2 =
                            labTestValueFormToRecord newModel.labTestValueModel.form stateId
                                |> E.labTestValueToValue
                                |> Ports.labTestValueDelete

                        -- Delete the record from the client and return to table view.
                        newModel2 =
                            newModel.labTestValueModel
                                |> MU.delSelectedRecord
                                |> MU.setSelectedRecordId Nothing
                                |> MU.setEditMode EditModeTable
                                |> asLabTestValueModelIn newModel
                    in
                        newModel2 ! [ newCmd2 ]

                Nothing ->
                    model ! []

        DeleteResponseLabTestValue response ->
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
                                    |> Decoders.decodeLabTestValueRecord
                            of
                                Just r ->
                                    MU.addRecord r labTestValueModel
                                        |> MU.setSelectedRecordId (Just response.id)
                                        |> LabTestValue.populateSelectedTableForm
                                        |> MU.setEditMode EditModeView
                                        |> asLabTestValueModelIn model
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

        FormMsgLabTestValue formMsg ->
            case ( formMsg, Form.getOutput labTestValueModel.form ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation.
                    if labTestValueModel.editMode == EditModeAdd then
                        labTestValueUpdate CreateLabTestValue model
                    else
                        labTestValueUpdate UpdateLabTestValue model

                _ ->
                    -- Otherwise, pass it through validation again.
                    (labTestValueModel
                        |> MU.setForm
                            (Form.update LabTestValue.labTestValueValidate
                                formMsg
                                labTestValueModel.form
                            )
                        |> asLabTestValueModelIn model
                    )
                        ! []

        ReadResponseLabTestValue labTestValueTbl sq ->
            -- Merge records from the server into our model, update
            -- our form as necessary, and make sure we are subscribed
            -- to changes from the server.
            let
                subscription =
                    NotificationSubscription LabTestValue NotifySubQualifierNone
            in
                ( MU.mergeById labTestValueTbl labTestValueModel.records
                    |> (\recs -> { labTestValueModel | records = recs })
                    |> MU.setSelectQuery sq
                    |> LabTestValue.populateSelectedTableForm
                    |> asLabTestValueModelIn model
                    |> Model.addNotificationSubscription subscription
                , Cmd.none
                )

        SelectedRecordEditModeLabTestValue mode id ->
            let
                -- labTestValue is a known child table, so assume that
                -- EditModeTable means that the foreign key to use is
                -- the selected record of the labTestModel.
                selectedLabTestId =
                    case model.labTestModel.selectedRecordId of
                        Just id ->
                            id

                        Nothing ->
                            -- If we use this, it will fail, but we shouldn't get here.
                            -1
            in
                (labTestValueModel
                    |> MU.setSelectedRecordId id
                    |> MU.setEditMode mode
                    |> (\tableModel ->
                            case ( mode, id ) of
                                ( EditModeAdd, _ ) ->
                                    LabTestValue.populateSelectedTableFormWithTestId selectedLabTestId tableModel

                                ( EditModeView, _ ) ->
                                    LabTestValue.populateSelectedTableForm tableModel

                                ( EditModeEdit, _ ) ->
                                    LabTestValue.populateSelectedTableForm tableModel

                                ( _, _ ) ->
                                    tableModel
                       )
                    |> asLabTestValueModelIn model
                    |> (\m ->
                            if mode == EditModeOther then
                                { m | selectedTable = Just LabTest }
                            else
                                { m | selectedTable = Just LabTestValue }
                       )
                )
                    ! []

        UpdateLabTestValue ->
            -- User saved on labTestValue form. This is an optimistic workflow.
            let
                -- 1. Encode original entity record to a string and save the
                --    original rec to transactions in exchange for a transaction id.
                -- 2. Convert the form values which user just created into a table record.
                ( newModel, stateId, record ) =
                    (case MU.getSelectedRecordAsString labTestValueModel E.labTestValueToValue of
                        Just s ->
                            Trans.setState s Nothing model

                        Nothing ->
                            ( model, Nothing )
                    )
                        |> (\( nm, sid ) ->
                                ( nm
                                , sid
                                , labTestValueFormToRecord nm.labTestValueModel.form sid
                                )
                           )

                -- 3. Optimistic update of the record in the list of records.
                updatedRecords =
                    case labTestValueModel.selectedRecordId of
                        Just id ->
                            MU.updateById id
                                (\r ->
                                    { r
                                        | stateId = stateId
                                        , value = record.value
                                    }
                                )
                                newModel.labTestValueModel.records

                        Nothing ->
                            newModel.labTestValueModel.records

                -- 4. Create the Cmd to send data to the server.
                newCmd =
                    Ports.labTestValueUpdate <| E.labTestValueToValue record
            in
                ( newModel.labTestValueModel
                    |> MU.setRecords updatedRecords
                    |> MU.setEditMode EditModeView
                    |> asLabTestValueModelIn newModel
                    |> (\m -> { m | selectedTableEditMode = EditModeView })
                , newCmd
                )

        UpdateResponseLabTestValue response ->
            let
                -- Remove the state id no matter what.
                noStateIdLabTestValueRecords =
                    MU.updateById response.id
                        (\r -> { r | stateId = Nothing })
                        labTestValueModel.records

                updatedRecords =
                    case response.success of
                        True ->
                            noStateIdLabTestValueRecords

                        False ->
                            -- Server rejected change. Reset record back to original.
                            case
                                Trans.getState response.stateId model
                                    |> Decoders.decodeLabTestValueRecord
                            of
                                Just r ->
                                    MU.updateById response.id
                                        (\rec ->
                                            { rec | value = r.value }
                                        )
                                        labTestValueModel.records

                                Nothing ->
                                    -- TODO: if we get here, something is really messed
                                    -- up because we can't find our original record in
                                    -- the transaction manager.
                                    noStateIdLabTestValueRecords

                -- Save the records to the model, update the form,
                -- and remove stored state from transaction manager.
                ( newModel, _ ) =
                    labTestValueModel
                        |> MU.setRecords updatedRecords
                        |> LabTestValue.populateSelectedTableForm
                        |> asLabTestValueModelIn model
                        |> Trans.delState response.stateId

                -- Give a message to the user upon failure.
                ( newModel2, newCmd2 ) =
                    if not response.success then
                        (if String.length response.msg == 0 then
                            "Sorry, the server rejected that change."
                         else
                            response.msg
                        )
                            |> flip U.addWarning newModel
                    else
                        ( newModel, Cmd.none )
            in
                newModel2 ! [ newCmd2, newCmd2 ]


labTestValueFormToRecord : Form () LabTestValueForm -> Maybe Int -> LabTestValueRecord
labTestValueFormToRecord form transId =
    let
        ( f_id, f_value, f_labTest_id ) =
            ( Form.getFieldAsString "id" form
                |> .value
                |> U.maybeStringToInt -1
            , Form.getFieldAsString "value" form
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "labTest_id" form
                |> .value
                |> U.maybeStringToInt -1
            )
    in
        LabTestValueRecord f_id
            f_value
            f_labTest_id
            transId
