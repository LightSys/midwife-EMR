module Updates.SelectData exposing (selectDataUpdate)

import Form exposing (Form)
import Json.Encode as JE
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Models.SelectData as SelectData
import Models.Utils as MU
import Msg exposing (..)
import Ports
import Transactions as Trans
import Types exposing (..)
import Utils as U


{-| Handle certain error responses from the server here.
Let the update detail function do all of the heavy lifting.
-}
selectDataUpdate : SelectDataMsg -> Model -> ( Model, Cmd Msg )
selectDataUpdate msg model =
    let
        ( newModel, newCmd ) =
            selectDataUpdateDetail msg model

        newCmd2 =
            case msg of
                CreateResponseSelectData response ->
                    U.handleSessionExpired response.errorCode

                DeleteResponseSelectData response ->
                    U.handleSessionExpired response.errorCode

                UpdateResponseSelectData response ->
                    U.handleSessionExpired response.errorCode

                _ ->
                    Cmd.none
    in
        ( newModel, Cmd.batch [ newCmd, newCmd2 ] )


selectDataUpdateDetail : SelectDataMsg -> Model -> ( Model, Cmd Msg )
selectDataUpdateDetail msg ({ selectDataModel } as model) =
    case msg of
        CancelEditSelectData ->
            -- User canceled, so reset data back to what we had before.
            ( SelectData.populateSelectedTableForm selectDataModel
                |> MU.setEditMode EditModeTable
                |> asSelectDataModelIn model
            , Cmd.none
            )

        CreateSelectData ->
            let
                -- Get the table record from the form.
                --
                selectDataRecord =
                    selectDataFormToRecord selectDataModel.form Nothing

                -- Optimistic add of the record to the model with a pending id
                -- and create the Cmd to send data to the server. Or give a message
                -- to the user to effect that the sort order is wrong.
                ( newModel, newCmd ) =
                    ( MU.addRecord selectDataRecord selectDataModel
                        |> asSelectDataModelIn model
                    , Ports.selectDataCreate <| E.selectDataToValue selectDataRecord
                    )
            in
                newModel ! [ newCmd ]

        CreateResponseSelectData { id, pendingId, success, msg } ->
            let
                -- Update the model with the server assigned id for the record.
                --
                -- Note: if the record creation was successful, we request to
                -- get all records back from the server again because the server
                -- has final authority about which records can have the select
                -- field set to true for each group of records by name.
                ( updatedRecords, ( newModel, newCmd ) ) =
                    case success of
                        True ->
                            ( MU.updateById pendingId
                                (\r -> { r | id = id })
                                selectDataModel.records
                            , ( model
                              , Ports.selectQuery
                                    (E.selectQueryToValue <|
                                        SelectQuery SelectData Nothing Nothing Nothing
                                    )
                              )
                            )

                        False ->
                            -- Give a message to the user upon failure.
                            ( selectDataModel.records
                            , (if String.length msg == 0 then
                                "Sorry, the server rejected that addition."
                               else
                                msg
                              )
                                |> flip U.addWarning model
                            )

                -- Update the form and remove stored state from transaction manager.
                newModel2 =
                    MU.setRecords updatedRecords selectDataModel
                        |> MU.setEditMode EditModeView
                        |> MU.setSelectedRecordId (Just id)
                        |> SelectData.populateSelectedTableForm
                        |> asSelectDataModelIn newModel
            in
                newModel2 ! [ newCmd ]

        DeleteSelectData id ->
            -- This is an optimistic workflow.
            -- NOTE: this assumes that a delete was performed with the correct record
            -- loaded in the form.
            case id of
                Just recId ->
                    let
                        -- Save current rec as a transaction.
                        ( newModel, stateId ) =
                            case MU.getSelectedRecordAsString selectDataModel E.selectDataToValue of
                                Just s ->
                                    Trans.setState s Nothing model

                                Nothing ->
                                    ( model, Nothing )

                        -- Create command to send record to delete to the server.
                        newCmd2 =
                            selectDataFormToRecord newModel.selectDataModel.form stateId
                                |> E.selectDataToValue
                                |> Ports.selectDataDelete

                        -- Delete the record from the client and return to table view.
                        newModel2 =
                            newModel.selectDataModel
                                |> MU.delSelectedRecord
                                |> MU.setSelectedRecordId Nothing
                                |> MU.setEditMode EditModeTable
                                |> asSelectDataModelIn newModel
                    in
                        newModel2 ! [ newCmd2 ]

                Nothing ->
                    model ! []

        DeleteResponseSelectData response ->
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
                                    |> Decoders.decodeSelectDataRecord
                            of
                                Just r ->
                                    MU.addRecord r selectDataModel
                                        |> MU.setSelectedRecordId (Just response.id)
                                        |> SelectData.populateSelectedTableForm
                                        |> MU.setEditMode EditModeView
                                        |> asSelectDataModelIn model
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

        FormMsgSelectData formMsg ->
            case ( formMsg, Form.getOutput selectDataModel.form ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation.
                    if selectDataModel.editMode == EditModeAdd then
                        selectDataUpdate CreateSelectData model
                    else
                        selectDataUpdate UpdateSelectData model

                _ ->
                    -- Otherwise, pass it through validation again.
                    (selectDataModel
                        |> MU.setForm
                            (Form.update SelectData.selectDataValidate
                                formMsg
                                selectDataModel.form
                            )
                        |> asSelectDataModelIn model
                    )
                        ! []

        ReadResponseSelectData selectDataTbl sq ->
            -- Merge records from the server into our model, update
            -- our form as necessary, and make sure we are subscribed
            -- to changes from the server.
            let
                subscription =
                    NotificationSubscription SelectData NotifySubQualifierNone
            in
                ( MU.mergeById selectDataTbl selectDataModel.records
                    |> (\recs -> { selectDataModel | records = recs })
                    |> MU.setSelectQuery sq
                    |> SelectData.populateSelectedTableForm
                    |> asSelectDataModelIn model
                    |> Model.addNotificationSubscription subscription
                , Cmd.none
                )

        SelectedRecordEditModeSelectData mode id name ->
            (selectDataModel
                |> MU.setSelectedRecordId id
                |> MU.setEditMode mode
                |> (\tblModel ->
                        if mode == EditModeAdd then
                            case name of
                                Just n ->
                                    SelectData.populateSelectedTableFormWithName n tblModel

                                Nothing ->
                                    SelectData.populateSelectedTableForm tblModel
                        else if mode /= EditModeTable && id /= Nothing then
                            SelectData.populateSelectedTableForm tblModel
                        else
                            tblModel
                   )
                |> asSelectDataModelIn model
            )
                ! []

        SelectedRecordSelectData id ->
            { model | selectDataModel = MU.setSelectedRecordId id selectDataModel } ! []

        UpdateSelectData ->
            -- User saved on selectData form. This is an optimistic workflow.
            let
                -- 1. Encode original entity record to a string and save the
                --    original rec to transactions in exchange for a transaction id.
                -- 2. Convert the form values which user just created into a table record.
                ( newModel, stateId, sdTable ) =
                    (case MU.getSelectedRecordAsString selectDataModel E.selectDataToValue of
                        Just s ->
                            Trans.setState s Nothing model

                        Nothing ->
                            ( model, Nothing )
                    )
                        |> (\( nm, sid ) ->
                                ( nm
                                , sid
                                , selectDataFormToRecord nm.selectDataModel.form sid
                                )
                           )

                -- 3. Optimistic update of the record in the list of records.
                updatedRecords =
                    case selectDataModel.selectedRecordId of
                        Just id ->
                            MU.updateById id
                                (\r ->
                                    { r
                                        | stateId = stateId
                                        , name = sdTable.name
                                        , selectKey = sdTable.selectKey
                                        , label = sdTable.label
                                        , selected = sdTable.selected
                                    }
                                )
                                newModel.selectDataModel.records

                        Nothing ->
                            newModel.selectDataModel.records

                -- 4. Create the Cmd to send data to the server.
                newCmd =
                    Ports.selectDataUpdate <| E.selectDataToValue sdTable
            in
                ( newModel.selectDataModel
                    |> MU.setRecords updatedRecords
                    |> MU.setEditMode EditModeView
                    |> asSelectDataModelIn newModel
                    |> (\m -> { m | selectedTableEditMode = EditModeView })
                , newCmd
                )

        UpdateResponseSelectData change ->
            let
                -- TODO: after successful response, get all records from server
                -- again because server has final authority regarding which
                -- records are allowed to have the selected field set to true
                -- within a group by name.

                -- Remove the state id no matter what.
                noStateIdSelectDataRecords =
                    MU.updateById change.id
                        (\r -> { r | stateId = Nothing })
                        selectDataModel.records

                updatedRecords =
                    case change.success of
                        True ->
                            noStateIdSelectDataRecords

                        False ->
                            -- Server rejected change. Reset record back to original.
                            case
                                Trans.getState change.stateId model
                                    |> Decoders.decodeSelectDataRecord
                            of
                                Just r ->
                                    MU.updateById change.id
                                        (\rec ->
                                            { rec
                                                | name = r.name
                                                , selectKey = r.selectKey
                                                , label = r.label
                                                , selected = r.selected
                                            }
                                        )
                                        selectDataModel.records

                                Nothing ->
                                    -- TODO: if we get here, something is really messed
                                    -- up because we can't find our original record in
                                    -- the transaction manager.
                                    noStateIdSelectDataRecords

                -- Save the records to the model, update the form,
                -- and remove stored state from transaction manager.
                ( newModel, _ ) =
                    selectDataModel
                        |> MU.setRecords updatedRecords
                        |> SelectData.populateSelectedTableForm
                        |> asSelectDataModelIn model
                        |> Trans.delState change.stateId

                -- Give a message to the user upon failure.
                -- Retrieve all of the selectData records again upon success.
                -- We do this because the server can change multiple records
                -- according to it's own business logic and we want to sync
                -- those changes as well.
                ( newModel2, newCmd2 ) =
                    if not change.success then
                        (if String.length change.msg == 0 then
                            "Sorry, the server rejected that change."
                         else
                            change.msg
                        )
                            |> flip U.addWarning newModel
                    else
                        ( newModel
                        , Ports.selectQuery
                            (E.selectQueryToValue <|
                                SelectQuery SelectData Nothing Nothing Nothing
                            )
                        )
            in
                newModel2 ! [ newCmd2, newCmd2 ]


{-| Note: We have a simplified user edit form that only shows and allows the
user to edit the label field. We make the assumption that the label field is
the same value as the selectKey field for the sake of simplicity, therefore
we need to make that happen here.
-}
selectDataFormToRecord : Form () SelectDataForm -> Maybe Int -> SelectDataRecord
selectDataFormToRecord sd transId =
    let
        ( f_id, f_name, f_label, f_selected ) =
            ( Form.getFieldAsString "id" sd
                |> .value
                |> U.maybeStringToInt -1
            , Form.getFieldAsString "name" sd
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "label" sd
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsBool "selected" sd
                |> .value
                |> Maybe.withDefault False
            )
    in
        -- We pass the f_label field twice because the selectKey field
        -- is the same as the label.
        SelectDataRecord f_id f_name f_label f_label f_selected transId
