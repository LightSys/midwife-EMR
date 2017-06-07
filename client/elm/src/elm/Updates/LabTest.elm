module Updates.LabTest exposing (labTestUpdate)

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
import Models.LabTest as LabTest
import Models.Utils as MU
import Msg exposing (..)
import Ports
import Transactions as Trans
import Types exposing (..)
import Utils as U


{-| Handle certain error responses from the server here.
Let the update detail function do all of the heavy lifting.
-}
labTestUpdate : LabTestMsg -> Model -> ( Model, Cmd Msg )
labTestUpdate msg model =
    let
        ( newModel, newCmd ) =
            labTestUpdateDetail msg model

        newCmd2 =
            case msg of
                CreateResponseLabTest response ->
                    U.handleSessionExpired response.errorCode

                DeleteResponseLabTest response ->
                    U.handleSessionExpired response.errorCode

                UpdateResponseLabTest response ->
                    U.handleSessionExpired response.errorCode

                _ ->
                    Cmd.none
    in
        ( newModel, Cmd.batch [ newCmd, newCmd2 ] )


labTestUpdateDetail : LabTestMsg -> Model -> ( Model, Cmd Msg )
labTestUpdateDetail msg ({ labTestModel } as model) =
    case msg of
        CancelEditLabTest ->
            -- User canceled, so reset data back to what we had before.
            ( LabTest.populateSelectedTableForm labTestModel
                |> MU.setEditMode EditModeView
                |> asLabTestModelIn model
            , Cmd.none
            )

        CreateLabTest ->
            let
                -- Get the table record from the form.
                labTestRecord =
                    labTestFormToRecord labTestModel.form Nothing

                -- Optimistic add of the record to the model with a pending id
                -- and create the Cmd to send data to the server. Or give a message
                -- to the user to effect that the sort order is wrong.
                ( newModel, newCmd ) =
                    ( MU.addRecord labTestRecord labTestModel
                        |> asLabTestModelIn model
                    , Ports.labTestCreate <| E.labTestToValue labTestRecord
                    )
            in
                newModel ! [ newCmd ]

        CreateResponseLabTest ({ id, pendingId, success, msg } as response) ->
            let
                -- Update the model with the server assigned id for the record.
                ( updatedRecords, ( newModel, newCmd ) ) =
                    case success of
                        True ->
                            ( MU.updateById pendingId
                                (\r -> { r | id = id })
                                labTestModel.records
                            , ( model, Cmd.none )
                            )

                        False ->
                            -- Give a message to the user upon failure.
                            ( labTestModel.records
                            , (if String.length msg == 0 then
                                "Sorry, the server rejected that addition."
                               else
                                msg
                              )
                                |> flip U.addWarning model
                            )

                -- Update the form and remove stored state from transaction manager.
                newModel2 =
                    MU.setRecords updatedRecords labTestModel
                        |> MU.setEditMode EditModeView
                        |> MU.setSelectedRecordId (Just id)
                        |> LabTest.populateSelectedTableForm
                        |> asLabTestModelIn newModel
            in
                newModel2 ! [ newCmd ]

        DeleteLabTest id ->
            -- This is an optimistic workflow.
            -- NOTE: this assumes that a delete was performed with the correct record
            -- loaded in the form.
            case id of
                Just recId ->
                    let
                        -- Save current rec as a transaction.
                        ( newModel, stateId ) =
                            case MU.getSelectedRecordAsString labTestModel E.labTestToValue of
                                Just s ->
                                    Trans.setState s Nothing model

                                Nothing ->
                                    ( model, Nothing )

                        -- Create command to send record to delete to the server.
                        newCmd2 =
                            labTestFormToRecord newModel.labTestModel.form stateId
                                |> E.labTestToValue
                                |> Ports.labTestDelete

                        -- Delete the record from the client and return to table view.
                        newModel2 =
                            newModel.labTestModel
                                |> MU.delSelectedRecord
                                |> MU.setSelectedRecordId Nothing
                                |> MU.setEditMode EditModeTable
                                |> asLabTestModelIn newModel
                    in
                        newModel2 ! [ newCmd2 ]

                Nothing ->
                    model ! []

        DeleteResponseLabTest response ->
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
                                    |> Decoders.decodeLabTestRecord
                            of
                                Just r ->
                                    MU.addRecord r labTestModel
                                        |> MU.setSelectedRecordId (Just response.id)
                                        |> LabTest.populateSelectedTableForm
                                        |> MU.setEditMode EditModeView
                                        |> asLabTestModelIn model
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

        FormMsgLabTest formMsg ->
            case ( formMsg, Form.getOutput labTestModel.form ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation.
                    if labTestModel.editMode == EditModeAdd then
                        labTestUpdate CreateLabTest model
                    else
                        labTestUpdate UpdateLabTest model

                _ ->
                    -- Otherwise, pass it through validation again.
                    (labTestModel
                        |> MU.setForm
                            (Form.update LabTest.labTestValidate
                                formMsg
                                labTestModel.form
                            )
                        |> asLabTestModelIn model
                    )
                        ! []

        ReadResponseLabTest labTestTbl sq ->
            -- Merge records from the server into our model, update
            -- our form as necessary, and make sure we are subscribed
            -- to changes from the server.
            let
                subscription =
                    NotificationSubscription LabTest NotifySubQualifierNone
            in
                ( MU.mergeById labTestTbl labTestModel.records
                    |> (\recs -> { labTestModel | records = recs })
                    |> MU.setSelectQuery sq
                    |> LabTest.populateSelectedTableForm
                    |> asLabTestModelIn model
                    |> Model.addNotificationSubscription subscription
                , Cmd.none
                )

        SelectedRecordEditModeLabTest mode id ->
            -- Note: We do something a bit out of the norm in that we
            -- set selectedTable on the model here depending upon the
            -- edit mode. An edit mode of Other means go back up to
            -- the LabSuite records, otherwise assume we are working
            -- with the LabTest records.
            --
            -- Also, the model.userChoice field denotes the user selected
            -- labSuite_id, which we need to properly populate the form
            -- on an EditModeAdd below.
            let
                selectedLabSuiteId =
                    case Dict.get "labSuiteSelected" model.userChoice of
                        Just id ->
                            Result.withDefault -1 (String.toInt id)

                        Nothing ->
                            -1
            in
                (labTestModel
                    |> MU.setSelectedRecordId id
                    |> MU.setEditMode mode
                    |> (\tableModel ->
                            case ( mode, id ) of
                                ( EditModeAdd, _ ) ->
                                    LabTest.populateSelectedTableFormWithSuiteId selectedLabSuiteId tableModel

                                ( EditModeView, _ ) ->
                                    LabTest.populateSelectedTableForm tableModel

                                ( EditModeEdit, _ ) ->
                                    LabTest.populateSelectedTableForm tableModel

                                ( _, _ ) ->
                                    tableModel
                       )
                    |> asLabTestModelIn model
                    |> (\m ->
                            if mode == EditModeOther then
                                { m | selectedTable = Just LabSuite }
                            else
                                { m | selectedTable = Just LabTest }
                       )
                )
                    ! []

        UpdateLabTest ->
            -- User saved on labTest form. This is an optimistic workflow.
            let
                -- 1. Encode original entity record to a string and save the
                --    original rec to transactions in exchange for a transaction id.
                -- 2. Convert the form values which user just created into a table record.
                ( newModel, stateId, record ) =
                    (case MU.getSelectedRecordAsString labTestModel E.labTestToValue of
                        Just s ->
                            Trans.setState s Nothing model

                        Nothing ->
                            ( model, Nothing )
                    )
                        |> (\( nm, sid ) ->
                                ( nm
                                , sid
                                , labTestFormToRecord nm.labTestModel.form sid
                                )
                           )

                -- 3. Optimistic update of the record in the list of records.
                updatedRecords =
                    case labTestModel.selectedRecordId of
                        Just id ->
                            MU.updateById id
                                (\r ->
                                    { r
                                        | stateId = stateId
                                        , name = record.name
                                        , abbrev = record.abbrev
                                        , normal = record.normal
                                        , unit = record.unit
                                        , minRangeDecimal = record.minRangeDecimal
                                        , maxRangeDecimal = record.maxRangeDecimal
                                        , minRangeInteger = record.minRangeInteger
                                        , maxRangeInteger = record.maxRangeInteger
                                        , isRange = record.isRange
                                        , isText = record.isText
                                    }
                                )
                                newModel.labTestModel.records

                        Nothing ->
                            newModel.labTestModel.records

                -- 4. Create the Cmd to send data to the server.
                newCmd =
                    Ports.labTestUpdate <| E.labTestToValue record
            in
                ( newModel.labTestModel
                    |> MU.setRecords updatedRecords
                    |> MU.setEditMode EditModeView
                    |> asLabTestModelIn newModel
                    |> (\m -> { m | selectedTableEditMode = EditModeView })
                , newCmd
                )

        UpdateResponseLabTest response ->
            let
                -- Remove the state id no matter what.
                noStateIdLabTestRecords =
                    MU.updateById response.id
                        (\r -> { r | stateId = Nothing })
                        labTestModel.records

                updatedRecords =
                    case response.success of
                        True ->
                            noStateIdLabTestRecords

                        False ->
                            -- Server rejected change. Reset record back to original.
                            case
                                Trans.getState response.stateId model
                                    |> Decoders.decodeLabTestRecord
                            of
                                Just r ->
                                    MU.updateById response.id
                                        (\rec ->
                                            { rec
                                                | name = r.name
                                                , abbrev = r.abbrev
                                                , normal = r.normal
                                                , unit = r.unit
                                                , minRangeDecimal = r.minRangeDecimal
                                                , maxRangeDecimal = r.maxRangeDecimal
                                                , minRangeInteger = r.minRangeInteger
                                                , maxRangeInteger = r.maxRangeInteger
                                                , isRange = r.isRange
                                                , isText = r.isText
                                            }
                                        )
                                        labTestModel.records

                                Nothing ->
                                    -- TODO: if we get here, something is really messed
                                    -- up because we can't find our original record in
                                    -- the transaction manager.
                                    noStateIdLabTestRecords

                -- Save the records to the model, update the form,
                -- and remove stored state from transaction manager.
                ( newModel, _ ) =
                    labTestModel
                        |> MU.setRecords updatedRecords
                        |> LabTest.populateSelectedTableForm
                        |> asLabTestModelIn model
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


{-| The isRange field is computed programmatically depending
upon whether any of the four range fields were populated.

TODO: do the same with isText based somehow upon whether there
are corresponding labTestValue records.
-}
labTestFormToRecord : Form () LabTestForm -> Maybe Int -> LabTestRecord
labTestFormToRecord form transId =
    let
        ( f_id, f_name, f_abbrev, f_normal, f_unit, f_minRDec ) =
            ( Form.getFieldAsString "id" form
                |> .value
                |> U.maybeStringToInt -1
            , Form.getFieldAsString "name" form
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "abbrev" form
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "normal" form
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "unit" form
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "minRangeDecimal" form
                |> .value
                |> U.maybeStringToMaybeFloat
            )

        ( f_maxRDec, f_minRInt, f_maxRInt, f_isText, f_labSuite_id ) =
            ( Form.getFieldAsString "maxRangeDecimal" form
                |> .value
                |> U.maybeStringToMaybeFloat
            , Form.getFieldAsString "minRangeDecimal" form
                |> .value
                |> U.maybeStringToMaybeInt
            , Form.getFieldAsString "maxRangeInteger" form
                |> .value
                |> U.maybeStringToMaybeInt
            , Form.getFieldAsBool "istext" form
                |> .value
                |> Maybe.withDefault False
            , Form.getFieldAsString "labSuite_id" form
                |> .value
                |> U.maybeStringToInt -1
            )

        f_isRange =
            case ( f_minRDec, f_maxRDec, f_minRInt, f_maxRInt ) of
                ( Nothing, Nothing, Nothing, Nothing ) ->
                    False

                ( _, _, _, _ ) ->
                    True
    in
        LabTestRecord f_id
            f_name
            f_abbrev
            f_normal
            f_unit
            f_minRDec
            f_maxRDec
            f_minRInt
            f_maxRInt
            f_isRange
            f_isText
            f_labSuite_id
            transId
