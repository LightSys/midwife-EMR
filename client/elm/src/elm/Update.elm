module Update
    exposing
        ( update
        , getSelectedTableRecordAsString
        , updateMedicationType
        )

import Form exposing (Form)
import Form.Field as Fld
import Json.Decode as JD
import Json.Encode as JE
import List.Extra as LE
import Material
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Msg exposing (..)
import Ports
import Transactions as Trans
import Types exposing (..)
import Utils as U


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl matMsg ->
            Material.update matMsg model

        SelectTab tab ->
            { model | selectedTab = tab } ! []

        NewSystemMessage sysMsg ->
            -- We only keep the most recent 1000 messages.
            let
                newSysMessages =
                    if sysMsg.id /= "ERROR" then
                        sysMsg
                            :: model.systemMessages
                            |> List.take 1000
                    else
                        model.systemMessages
            in
                { model | systemMessages = newSysMessages } ! []

        NoOp ->
            let
                _ =
                    Debug.log "NoOp" "was called"
            in
                model ! []

        SelectQuerySelectTable query ->
            -- Perform a SelectQuery and set the selectTable field.
            { model | selectedTable = Just query.table, selectedTableRecord = 0 }
                ! [ Ports.selectQuery (E.selectQueryToValue query) ]

        SelectTableRecord rec ->
            let
                newModel =
                    { model | selectedTableRecord = rec }
                        |> populateSelectedTableForm
            in
                newModel ! []

        EditSelectedTable ->
            { model | selectedTableEditMode = True } ! []

        CancelSelectedTable ->
            let
                -- User canceled, so reset data back to what we had before.
                newModel =
                    populateSelectedTableForm model
            in
                { newModel | selectedTableEditMode = False } ! []

        SaveSelectedTable ->
            -- Note: the real save is done with other messages like MedicationTypeMessages
            { model | selectedTableEditMode = False } ! []

        FirstRecord ->
            let
                newModel =
                    { model | selectedTableRecord = 0 }
                        |> populateSelectedTableForm
            in
                newModel ! []

        PreviousRecord ->
            let
                newModel =
                    { model | selectedTableRecord = max 0 (model.selectedTableRecord - 1) }
                        |> populateSelectedTableForm
            in
                newModel ! []

        NextRecord ->
            let
                newModel =
                    { model
                        | selectedTableRecord = min ((numRecsSelectedTable model) - 1) (model.selectedTableRecord + 1)
                    }
                        |> populateSelectedTableForm
            in
                newModel ! []

        LastRecord ->
            let
                newModel =
                    { model
                        | selectedTableRecord = ((numRecsSelectedTable model) - 1)
                    }
                        |> populateSelectedTableForm
            in
                newModel ! []

        MedicationTypeMessages mtMsg ->
            updateMedicationType mtMsg model

        EventTypeResponse eventTypeTbl ->
            { model | eventType = eventTypeTbl } ! []

        LabSuiteResponse labSuiteTbl ->
            { model | labSuite = labSuiteTbl } ! []

        LabTestResponse labTestTbl ->
            { model | labTest = labTestTbl } ! []

        LabTestValueResponse labTestValueTbl ->
            { model | labTestValue = labTestValueTbl } ! []

        PregnoteTypeResponse pregnoteTypeTbl ->
            { model | pregnoteType = pregnoteTypeTbl } ! []

        RiskCodeResponse riskCodeTbl ->
            { model | riskCode = riskCodeTbl } ! []

        VaccinationTypeResponse vaccinationTypeTbl ->
            { model | vaccinationType = vaccinationTypeTbl } ! []

        ChangeConfirmationMsg change ->
            case change of
                Just c ->
                    case c.table of
                        "medicationType" ->
                            updateMedicationType (MedicationTypeSaveResponse c) model

                        _ ->
                            model ! []

                Nothing ->
                    model ! []


updateMedicationType : MedicationTypeMsg -> Model -> ( Model, Cmd Msg )
updateMedicationType msg model =
    case msg of
        FormMsg formMsg ->
            { model | medicationTypeForm = Form.update formMsg model.medicationTypeForm } ! []

        MedicationTypeResponse medicationTypeTbl ->
            let
                -- Load the form as well.
                ( newModel, newCmd ) =
                    { model | medicationType = medicationTypeTbl }
                        |> update (SelectTableRecord 0)
            in
                newModel ! [ newCmd ]

        MedicationTypeSave ->
            -- User saved on medicationType form.
            --
            -- This is an optimistic workflow:
            --    1 - 5 - see below
            --
            let
                -- 1. Encode original entity record to a string.
                recordStr =
                    getSelectedTableRecordAsString model

                -- 2. Save the original rec to transactions in exchange for a transaction id.
                ( newModel, stateId ) =
                    case recordStr of
                        Just s ->
                            Trans.setState s Nothing model

                        Nothing ->
                            ( model, Nothing )

                -- 3. Get the form values which user just created.
                ( f_id, f_name, f_description, f_sortOrder ) =
                    ( Form.getFieldAsString "id" newModel.medicationTypeForm
                        |> .value
                        |> U.maybeStringToInt -1
                    , Form.getFieldAsString "name" newModel.medicationTypeForm
                        |> .value
                        |> Maybe.withDefault ""
                    , Form.getFieldAsString "description" newModel.medicationTypeForm
                        |> .value
                        |> Maybe.withDefault ""
                    , Form.getFieldAsString "sortOrder" newModel.medicationTypeForm
                        |> .value
                        |> U.maybeStringToInt -1
                    )

                -- 4. Save form values to entity record which is the optimistic update.
                -- NOTE: assuming that the id does not need changing and is correct.
                updatedMedicationTypeRecords =
                    updateMedicationTypeByIndex newModel.selectedTableRecord
                        (\r ->
                            { r
                                | pendingTransaction = stateId
                                , name = f_name
                                , description = f_description
                                , sortOrder = f_sortOrder
                            }
                        )
                        newModel.medicationType

                _ =
                    Debug.log "updatedMedicationTypeRecords" <| toString updatedMedicationTypeRecords

                -- 5. Create the Cmd to send data to the server.
                newCmd =
                    MedicationTypeTable f_id f_name f_description f_sortOrder stateId
                        |> E.medicationTypeToValue
                        |> Ports.medicationTypeUpdate
            in
                { newModel
                    | medicationType = updatedMedicationTypeRecords
                    , selectedTableEditMode = False
                }
                    ! [ newCmd ]

        MedicationTypeCancel ->
            let
                -- User canceled, so reset data back to what we had before.
                newModel =
                    populateSelectedTableForm model
            in
                { newModel | selectedTableEditMode = False } ! []

        MedicationTypeSaveResponse change ->
            --    6. get response back
            --    8. server Timeout:
            --      a. display error message to user
            --      b. get state based on pending field
            --      c. set state into entity record and set pending to Nothing.
            --      d. remove state from transactions.
            let
                updatedMedicationTypeRecords =
                    case change.success of
                        True ->
                            -- 7. server OK:
                            -- set pending fld in entity record to Nothing.
                            updateMedicationTypeById change.id
                                (\r -> { r | pendingTransaction = Nothing })
                                model.medicationType

                        False ->
                            -- 7. server Reject:
                            -- a. TODO: display error message to user
                            -- b. get state based on pending field
                            -- c. set state into entity record and set pending to Nothing.
                            -- d. update the form in case it is current
                            let
                                _ =
                                    Debug.log "Server fail" "for updating medicationType"

                                oldState =
                                    Trans.getState change.pendingTransaction model

                                record =
                                    Decoders.decodeMedicationTypeRecord oldState
                            in
                                case record of
                                    Just r ->
                                        updateMedicationTypeById change.id
                                            (\rec ->
                                                { rec
                                                    | pendingTransaction = Nothing
                                                    , name = r.name
                                                    , description = r.description
                                                    , sortOrder = r.sortOrder
                                                }
                                            )
                                            model.medicationType

                                    Nothing ->
                                        -- TODO: handle this wrong case better.
                                        updateMedicationTypeById change.id
                                            (\r -> { r | pendingTransaction = Nothing })
                                            model.medicationType

                -- Update the form and
                -- remove the stored state from the transaction manager.
                ( newModel, _ ) =
                    populateSelectedTableForm model
                        |> Trans.delState change.pendingTransaction
            in
                { newModel | medicationType = updatedMedicationTypeRecords } ! []


{-| Alias for updating medicationType functions.
-}
type alias UpdateMedicationType =
    Int
    -> (MedicationTypeTable -> MedicationTypeTable)
    -> RemoteData String (List MedicationTypeTable)
    -> RemoteData String (List MedicationTypeTable)


updateMedicationTypeById : UpdateMedicationType
updateMedicationTypeById id func records =
    case records of
        Success recs ->
            case LE.findIndex (\r -> r.id == id) recs of
                Just idx ->
                    updateMedicationTypeByIndex idx func records

                Nothing ->
                    records

        _ ->
            records


updateMedicationTypeByIndex : UpdateMedicationType
updateMedicationTypeByIndex idx func records =
    case records of
        Success recs ->
            case LE.updateAt idx func recs of
                Just updatedRecs ->
                    RD.succeed updatedRecs

                Nothing ->
                    records

        _ ->
            records


populateSelectedTableForm : Model -> Model
populateSelectedTableForm model =
    -- Is there a selected table?
    case model.selectedTable of
        Just t ->
            -- Is this a table that we can handle?
            case t of
                MedicationType ->
                    -- Is there data for that table?
                    case model.medicationType of
                        Success data ->
                            let
                                -- Populate the form with the record we need.
                                form =
                                    case LE.getAt model.selectedTableRecord data of
                                        Just rec ->
                                            medicationTypeInitialForm rec

                                        Nothing ->
                                            model.medicationTypeForm
                            in
                                { model | medicationTypeForm = form }

                        _ ->
                            model

                _ ->
                    model

        Nothing ->
            model


getSelectedTableRecordAsString : Model -> Maybe String
getSelectedTableRecordAsString model =
    -- Is there a selected table?
    case model.selectedTable of
        Just t ->
            -- Is this a table that we can handle?
            case t of
                MedicationType ->
                    -- Is there data for that table?
                    case model.medicationType of
                        Success data ->
                            let
                                -- Get the record as a string.
                                string =
                                    case LE.getAt model.selectedTableRecord data of
                                        Just rec ->
                                            JE.encode 0 (E.medicationTypeToValue rec)
                                                |> Just

                                        Nothing ->
                                            Nothing
                            in
                                string

                        _ ->
                            Nothing

                _ ->
                    Nothing

        Nothing ->
            Nothing


{-| Returns the number of records in the selected table
or zero if anything goes wrong.
-}
numRecsSelectedTable : Model -> Int
numRecsSelectedTable model =
    case model.selectedTable of
        Just t ->
            case t of
                MedicationType ->
                    case model.medicationType of
                        Success val ->
                            (List.length val)

                        _ ->
                            0

                VaccinationType ->
                    case model.vaccinationType of
                        Success val ->
                            (List.length val)

                        _ ->
                            0

                -- TODO: add more tables.
                _ ->
                    0

        Nothing ->
            0
