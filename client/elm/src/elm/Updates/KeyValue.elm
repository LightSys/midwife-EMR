module Updates.KeyValue exposing (keyValueUpdate)

import Form exposing (Form)
import Json.Encode as JE
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Models.KeyValue as KeyValue
import Models.Utils as MU
import Msg exposing (..)
import Ports
import Transactions as Trans
import Types exposing (..)
import Utils as U


{-| Handle certain error responses from the server here.
Let the update detail function do all of the heavy lifting.
-}
keyValueUpdate : KeyValueMsg -> Model -> ( Model, Cmd Msg )
keyValueUpdate msg model =
    let
        ( newModel, newCmd ) =
            keyValueUpdateDetail msg model

        newCmd2 =
            case msg of
                UpdateResponseKeyValue response ->
                    U.handleSessionExpired response.errorCode

                _ ->
                    Cmd.none
    in
        ( newModel, Cmd.batch [ newCmd, newCmd2 ] )


keyValueUpdateDetail : KeyValueMsg -> Model -> ( Model, Cmd Msg )
keyValueUpdateDetail msg ({ keyValueModel } as model) =
    case msg of
        CancelEditKeyValue ->
            let
                editMode =
                    if keyValueModel.selectedRecordId == Nothing then
                        EditModeTable
                    else
                        EditModeView
            in
                -- User canceled, so reset data back to what we had before.
                ( KeyValue.populateSelectedTableForm keyValueModel
                    |> MU.setEditMode editMode
                    |> asKeyValueModelIn model
                , Cmd.none
                )

        FormMsgKeyValue formMsg ->
            case ( formMsg, Form.getOutput keyValueModel.form ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation.
                    keyValueUpdate UpdateKeyValue model

                _ ->
                    -- Otherwise, pass it through validation again.
                    (keyValueModel
                        |> MU.setForm
                            (Form.update (KeyValue.keyValueValidateWithForm keyValueModel.form)
                                formMsg
                                keyValueModel.form
                            )
                        |> asKeyValueModelIn model
                    )
                        ! []

        ReadResponseKeyValue keyValueTbl sq ->
            -- Merge records from the server into our model, update
            -- our form as necessary, and make sure we are subscribed
            -- to changes from the server.
            let
                subscription =
                    NotificationSubscription KeyValue NotifySubQualifierNone
            in
                ( MU.mergeById keyValueTbl keyValueModel.records
                    |> (\recs -> { keyValueModel | records = recs })
                    |> MU.setSelectQuery sq
                    |> KeyValue.populateSelectedTableForm
                    |> asKeyValueModelIn model
                    |> Model.addNotificationSubscription subscription
                , Cmd.none
                )

        SelectedRecordEditModeKeyValue mode id ->
            (keyValueModel
                |> MU.setSelectedRecordId id
                |> MU.setEditMode mode
                |> (\tblModel ->
                        case ( mode, id ) of
                            ( EditModeEdit, Just _ ) ->
                                KeyValue.populateSelectedTableForm tblModel

                            ( EditModeView, Just _ ) ->
                                KeyValue.populateSelectedTableForm tblModel

                            ( _, _ ) ->
                                tblModel
                   )
                |> asKeyValueModelIn model
            )
                ! []

        SelectedRecordKeyValue id ->
            { model | keyValueModel = MU.setSelectedRecordId id keyValueModel } ! []

        UpdateKeyValue ->
            -- User saved on keyValue form. This is an optimistic workflow.
            let
                -- 1. Encode original entity record to a string and save the
                --    original rec to transactions in exchange for a transaction id.
                -- 2. Convert the form values which user just created into a table record.
                ( newModel, stateId, tblModel ) =
                    (case MU.getSelectedRecordAsString keyValueModel E.keyValueToValue of
                        Just s ->
                            Trans.setState s Nothing model

                        Nothing ->
                            ( model, Nothing )
                    )
                        |> (\( nm, sid ) ->
                                ( nm
                                , sid
                                , keyValueFormToRecord nm.keyValueModel.form sid
                                )
                           )

                -- 3. Optimistic update of the record in the list of records.
                -- Note that only the kvValue field can be changed by the user.
                updatedRecords =
                    case keyValueModel.selectedRecordId of
                        Just id ->
                            MU.updateById id
                                (\r ->
                                    { r
                                        | stateId = stateId
                                        , kvValue = tblModel.kvValue
                                    }
                                )
                                newModel.keyValueModel.records

                        Nothing ->
                            newModel.keyValueModel.records

                -- 4. Create the Cmd to send data to the server.
                newCmd =
                    Ports.keyValueUpdate <| E.keyValueToValue tblModel
            in
                ( newModel.keyValueModel
                    |> MU.setRecords updatedRecords
                    |> MU.setEditMode EditModeView
                    |> asKeyValueModelIn newModel
                    |> (\m -> { m | selectedTableEditMode = EditModeView })
                , newCmd
                )

        UpdateResponseKeyValue change ->
            let
                -- Remove the state id no matter what.
                noStateIdKeyValueRecords =
                    MU.updateById change.id
                        (\r -> { r | stateId = Nothing })
                        keyValueModel.records

                updatedRecords =
                    case change.success of
                        True ->
                            noStateIdKeyValueRecords

                        False ->
                            -- Server rejected change. Reset record back to original.
                            -- Note that only the kvValue field can be changed by the user.
                            case
                                Trans.getState change.stateId model
                                    |> Decoders.decodeKeyValueRecord
                            of
                                Just r ->
                                    MU.updateById change.id
                                        (\rec ->
                                            { rec
                                                | kvValue = r.kvValue
                                            }
                                        )
                                        keyValueModel.records

                                Nothing ->
                                    -- TODO: if we get here, something is really messed
                                    -- up because we can't find our original record in
                                    -- the transaction manager.
                                    noStateIdKeyValueRecords

                -- Save the records to the model, update the form,
                -- and remove stored state from transaction manager.
                ( newModel, _ ) =
                    keyValueModel
                        |> MU.setRecords updatedRecords
                        |> KeyValue.populateSelectedTableForm
                        |> asKeyValueModelIn model
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


keyValueFormToRecord : Form () KeyValueForm -> Maybe Int -> KeyValueRecord
keyValueFormToRecord rec transId =
    let
        ( f_id, f_kvKey, f_kvValue, f_description
        , f_valueType, f_acceptableValues, f_systemOnly ) =
            ( Form.getFieldAsString "id" rec
                |> .value
                |> U.maybeStringToInt -1
            , Form.getFieldAsString "kvKey" rec
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "kvValue" rec
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "description" rec
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsString "valueType" rec
                |> .value
                |> Maybe.withDefault ""
                |> MU.stringToKeyValueType
            , Form.getFieldAsString "acceptableValues" rec
                |> .value
                |> Maybe.withDefault ""
            , Form.getFieldAsBool "systemOnly" rec
                |> .value
                |> Maybe.withDefault False
            )
    in
        KeyValueRecord f_id
            f_kvKey
            f_kvValue
            f_description
            f_valueType
            f_acceptableValues
            f_systemOnly
            transId
