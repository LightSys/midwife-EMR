module Updates.LabSuite exposing (labSuiteUpdate)

import Form exposing (Form)
import Json.Encode as JE
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Models.LabSuite as LabSuite
import Models.Utils as MU
import Msg exposing (..)
import Ports
import Transactions as Trans
import Types exposing (..)
import Utils as U

{-| Handle certain error responses from the server here.
Let the update detail function do all of the heavy lifting.
-}
labSuiteUpdate : LabSuiteMsg -> Model -> ( Model, Cmd Msg )
labSuiteUpdate msg model =
    let
        ( newModel, newCmd ) =
            labSuiteUpdateDetail msg model

        newCmd2 =
            case msg of
                CreateResponseLabSuite response ->
                    U.handleSessionExpired response.errorCode

                DeleteResponseLabSuite response ->
                    U.handleSessionExpired response.errorCode

                UpdateResponseLabSuite response ->
                    U.handleSessionExpired response.errorCode

                _ ->
                    Cmd.none
    in
        ( newModel, Cmd.batch [ newCmd, newCmd2 ] )


labSuiteUpdateDetail : LabSuiteMsg -> Model -> ( Model, Cmd Msg )
labSuiteUpdateDetail msg ({ labSuiteModel } as model) =
    case msg of
        CancelEditLabSuite ->
            let
                editMode =
                    if labSuiteModel.selectedRecordId == Nothing then
                        EditModeTable
                    else
                        EditModeView
            in
                -- User canceled, so reset data back to what we had before.
                ( LabSuite.populateSelectedTableForm labSuiteModel
                    |> MU.setEditMode editMode
                    |> asLabSuiteModelIn model
                , Cmd.none
                )

        CreateLabSuite ->
            let
                -- Get the table record from the form.
                labSuiteRecord =
                    labSuiteFormToRecord labSuiteModel.form Nothing

                -- Optimistic add of the record to the model with a pending id
                -- and create the Cmd to send data to the server. Or give a message
                -- to the user to effect that the sort order is wrong.
                ( newModel, newCmd ) =
                    ( MU.addRecord labSuiteRecord labSuiteModel
                        |> asLabSuiteModelIn model
                    , Ports.labSuiteCreate <| E.labSuiteToValue labSuiteRecord
                    )
            in
                newModel ! [ newCmd ]

        CreateResponseLabSuite { id, pendingId, success, msg } ->
            let
                -- Update the model with the server assigned id for the record.
                ( updatedRecords, ( newModel, newCmd ) ) =
                    case success of
                        True ->
                            ( MU.updateById pendingId
                                (\r -> { r | id = id })
                                labSuiteModel.records
                            , ( model, Cmd.none )
                            )

                        False ->
                            -- Give a message to the user upon failure.
                            ( labSuiteModel.records
                            , (if String.length msg == 0 then
                                "Sorry, the server rejected that addition."
                               else
                                msg
                              )
                                |> flip U.addWarning model
                            )

                -- Update the form and remove stored state from transaction manager.
                newModel2 =
                    MU.setRecords updatedRecords labSuiteModel
                        |> MU.setEditMode EditModeView
                        |> MU.setSelectedRecordId (Just id)
                        |> LabSuite.populateSelectedTableForm
                        |> asLabSuiteModelIn newModel
            in
                newModel2 ! [ newCmd ]

        DeleteLabSuite id ->
            -- This is an optimistic workflow.
            -- NOTE: this assumes that a delete was performed with the correct record
            -- loaded in the form.
            case id of
                Just recId ->
                    let
                        -- Save current rec as a transaction.
                        ( newModel, stateId ) =
                            case MU.getSelectedRecordAsString labSuiteModel E.labSuiteToValue of
                                Just s ->
                                    Trans.setState s Nothing model

                                Nothing ->
                                    ( model, Nothing )

                        -- Create command to send record to delete to the server.
                        newCmd2 =
                            labSuiteFormToRecord newModel.labSuiteModel.form stateId
                                |> E.labSuiteToValue
                                |> Ports.labSuiteDelete

                        -- Delete the record from the client and return to table view.
                        newModel2 =
                            newModel.labSuiteModel
                                |> MU.delSelectedRecord
                                |> MU.setSelectedRecordId Nothing
                                |> MU.setEditMode EditModeTable
                                |> asLabSuiteModelIn newModel
                    in
                        newModel2 ! [ newCmd2 ]

                Nothing ->
                    model ! []

        DeleteResponseLabSuite response ->
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
                                    |> Decoders.decodeLabSuiteRecord
                            of
                                Just r ->
                                    MU.addRecord r labSuiteModel
                                        |> MU.setSelectedRecordId (Just response.id)
                                        |> LabSuite.populateSelectedTableForm
                                        |> MU.setEditMode EditModeView
                                        |> asLabSuiteModelIn model
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

        FormMsgLabSuite formMsg ->
            case ( formMsg, Form.getOutput labSuiteModel.form ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation.
                    if labSuiteModel.editMode == EditModeAdd then
                        labSuiteUpdate CreateLabSuite model
                    else
                        labSuiteUpdate UpdateLabSuite model

                _ ->
                    -- Otherwise, pass it through validation again.
                    (labSuiteModel
                        |> MU.setForm
                            (Form.update LabSuite.labSuiteValidate
                                formMsg
                                labSuiteModel.form
                            )
                        |> asLabSuiteModelIn model
                    )
                        ! []

        ReadResponseLabSuite labSuiteTbl sq ->
            -- Merge records from the server into our model, update
            -- our form as necessary, and make sure we are subscribed
            -- to changes from the server.
            let
                subscription =
                    NotificationSubscription LabSuite NotifySubQualifierNone
            in
                ( MU.mergeById labSuiteTbl labSuiteModel.records
                    |> (\recs -> { labSuiteModel | records = recs })
                    |> MU.setSelectQuery sq
                    |> LabSuite.populateSelectedTableForm
                    |> asLabSuiteModelIn model
                    |> Model.addNotificationSubscription subscription
                , Cmd.none
                )

        SelectedRecordEditModeLabSuite mode id ->
            (labSuiteModel
                |> MU.setSelectedRecordId id
                |> MU.setEditMode mode
                |> (\tableModel ->
                        case (mode, id) of
                            (EditModeAdd, _) ->
                                LabSuite.populateSelectedTableForm tableModel

                            (EditModeView, _) ->
                                LabSuite.populateSelectedTableForm tableModel
                            (EditModeEdit, _) ->
                                LabSuite.populateSelectedTableForm tableModel

                            (_, _) ->
                                tableModel
                   )
                |> asLabSuiteModelIn model
            )
                ! []

        UpdateLabSuite ->
            -- User saved on labSuite form. This is an optimistic workflow.
            let
                -- 1. Encode original entity record to a string and save the
                --    original rec to transactions in exchange for a transaction id.
                -- 2. Convert the form values which user just created into a table record.
                ( newModel, stateId, mtTable ) =
                    (case MU.getSelectedRecordAsString labSuiteModel E.labSuiteToValue of
                        Just s ->
                            Trans.setState s Nothing model

                        Nothing ->
                            ( model, Nothing )
                    )
                        |> (\( nm, sid ) ->
                                ( nm
                                , sid
                                , labSuiteFormToRecord nm.labSuiteModel.form sid
                                )
                           )

                -- 3. Optimistic update of the record in the list of records.
                updatedRecords =
                    case labSuiteModel.selectedRecordId of
                        Just id ->
                            MU.updateById id
                                (\r ->
                                    { r
                                        | stateId = stateId
                                        , name = mtTable.name
                                        , description = mtTable.description
                                        , category = mtTable.category
                                    }
                                )
                                newModel.labSuiteModel.records

                        Nothing ->
                            newModel.labSuiteModel.records

                -- 4. Create the Cmd to send data to the server.
                newCmd =
                    Ports.labSuiteUpdate <| E.labSuiteToValue mtTable
            in
                ( newModel.labSuiteModel
                    |> MU.setRecords updatedRecords
                    |> MU.setEditMode EditModeView
                    |> asLabSuiteModelIn newModel
                    |> (\m -> { m | selectedTableEditMode = EditModeView })
                , newCmd
                )

        UpdateResponseLabSuite change ->
            let
                -- Remove the state id no matter what.
                noStateIdLabSuiteRecords =
                    MU.updateById change.id
                        (\r -> { r | stateId = Nothing })
                        labSuiteModel.records

                updatedRecords =
                    case change.success of
                        True ->
                            noStateIdLabSuiteRecords

                        False ->
                            -- Server rejected change. Reset record back to original.
                            case
                                Trans.getState change.stateId model
                                    |> Decoders.decodeLabSuiteRecord
                            of
                                Just r ->
                                    MU.updateById change.id
                                        (\rec ->
                                            { rec
                                                | name = r.name
                                                , description = r.description
                                                , category = r.category
                                            }
                                        )
                                        labSuiteModel.records

                                Nothing ->
                                    -- TODO: if we get here, something is really messed
                                    -- up because we can't find our original record in
                                    -- the transaction manager.
                                    noStateIdLabSuiteRecords

                -- Save the records to the model, update the form,
                -- and remove stored state from transaction manager.
                ( newModel, _ ) =
                    labSuiteModel
                        |> MU.setRecords updatedRecords
                        |> LabSuite.populateSelectedTableForm
                        |> asLabSuiteModelIn model
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


labSuiteFormToRecord : Form () LabSuiteForm -> Maybe Int -> LabSuiteRecord
labSuiteFormToRecord form transId =
    let
        ( f_id, f_name, f_description ) =
            ( Form.getFieldAsString "id" form
                |> .value
                |> U.maybeStringToInt -1
            , Form.getFieldAsString "name" form
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "description" form
                |> .value
                |> Maybe.withDefault ""
            )
    in
        -- We pass the f_name field twice because the category field
        -- is the same as the name field.
        LabSuiteRecord f_id f_name f_description f_name transId
