module Update
    exposing
        ( update
        )

import Form exposing (Form)
import Form.Field as Fld
import Json.Decode as JD
import Json.Encode as JE
import List.Extra as LE
import Material
import Material.Snackbar as Snackbar
import RemoteData as RD exposing (RemoteData(..))
import Form.Validate as V


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Msg exposing (..)
import Ports
import Transactions as Trans
import Types exposing (..)
import Models.MedicationType as MedType
import Updates.MedicationType as Updates
import Utils as U


type alias Mdl =
    Material.Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddResponseMsg add ->
            case add of
                Just a ->
                    case a.table of
                        MedicationType ->
                            Updates.updateMedicationType (MedicationTypeAddResponse a) model

                        _ ->
                            model ! []

                Nothing ->
                    model ! []

        AddSelectedTable ->
            let
                newModel =
                    { model | selectedTableEditMode = EditModeAdd }
                        |> populateSelectedTableForm
            in
                newModel ! []

        CancelSelectedTable ->
            let
                -- User canceled, so reset data back to what we had before.
                newModel =
                    populateSelectedTableForm model
            in
                { newModel | selectedTableEditMode = EditModeView } ! []

        ChangeResponseMsg change ->
            case change of
                Just c ->
                    case c.table of
                        MedicationType ->
                            Updates.updateMedicationType (MedicationTypeChgResponse c) model

                        _ ->
                            model ! []

                Nothing ->
                    model ! []

        DelResponseMsg del ->
            case del of
                Just d ->
                    case d.table of
                        MedicationType ->
                            Updates.updateMedicationType (MedicationTypeDelResponse d) model

                        _ ->
                            model ! []

                Nothing ->
                    model ! []

        EditSelectedTable ->
            { model | selectedTableEditMode = EditModeEdit } ! []

        EventTypeResponse eventTypeTbl ->
            { model | eventType = eventTypeTbl } ! []

        FirstRecord ->
            let
                newModel =
                    { model | selectedTableRecord = 0 }
                        |> populateSelectedTableForm
            in
                newModel ! []

        LabSuiteResponse labSuiteTbl ->
            { model | labSuite = labSuiteTbl } ! []

        LabTestResponse labTestTbl ->
            { model | labTest = labTestTbl } ! []

        LabTestValueResponse labTestValueTbl ->
            { model | labTestValue = labTestValueTbl } ! []

        LastRecord ->
            let
                newModel =
                    { model
                        | selectedTableRecord = ((numRecsSelectedTable model) - 1)
                    }
                        |> populateSelectedTableForm
            in
                newModel ! []

        Mdl matMsg ->
            Material.update Mdl matMsg model

        MedicationTypeMessages mtMsg ->
            Updates.updateMedicationType mtMsg model

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

        NextRecord ->
            let
                newModel =
                    { model
                        | selectedTableRecord = min ((numRecsSelectedTable model) - 1) (model.selectedTableRecord + 1)
                    }
                        |> populateSelectedTableForm
            in
                newModel ! []

        NoOp ->
            let
                _ =
                    Debug.log "NoOp" "was called"
            in
                model ! []

        PregnoteTypeResponse pregnoteTypeTbl ->
            { model | pregnoteType = pregnoteTypeTbl } ! []

        PreviousRecord ->
            let
                newModel =
                    { model | selectedTableRecord = max 0 (model.selectedTableRecord - 1) }
                        |> populateSelectedTableForm
            in
                newModel ! []

        RiskCodeResponse riskCodeTbl ->
            { model | riskCode = riskCodeTbl } ! []

        SaveSelectedTable ->
            -- Note: the real save is done with other messages like MedicationTypeMessages
            { model | selectedTableEditMode = EditModeView } ! []

        SelectedTableEditMode mode id ->
            let
                -- TODO: fix this because it is passed record id but
                -- selectedTableRecord required index.
                newModel =
                    { model
                        | selectedTableEditMode = mode
                        , selectedTableRecord = Maybe.withDefault 0 id
                    }

                newModel2 =
                    if mode /= EditModeTable && id /= Nothing then
                        populateSelectedTableForm newModel
                    else
                        newModel
            in
                newModel2 ! []

        SelectQueryResponseMsg sqr ->
            let
                _ =
                    Debug.log "SelectQueryResponseMsg" <| toString sqr

                ( newModel, newCmd ) =
                    -- Unwrap sqr from the RemoteData wrapper.
                    case sqr of
                        Success selQryResp ->
                            let
                                selQry =
                                    U.selectQueryResponseToSelectQuery selQryResp
                            in
                                case selQryResp.data of
                                    MedicationTypeResp list ->
                                        -- Put the records into RemoteData format as expected and
                                        -- pass to update function for processing.
                                        Updates.updateMedicationType
                                            (MedicationTypeResponse
                                                (RD.succeed list)
                                                (Just selQry)
                                            )
                                            model

                                    LabSuiteResp list ->
                                        update (LabSuiteResponse (RD.succeed list)) model

                                    LabTestResp list ->
                                        update (LabTestResponse (RD.succeed list)) model

                        Failure err ->
                            let
                                _ =
                                    Debug.log "SelectQueryResponseMsg" <| toString err
                            in
                                ( model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )
            in
                ( newModel, newCmd )

        SelectQuerySelectTable query ->
            -- Perform a SelectQuery and set the selectTable field.
            { model
                | selectedTable = Just query.table
                , selectedTableRecord = 0
                , selectedTableEditMode = EditModeTable
            }
                ! [ Ports.selectQuery (E.selectQueryToValue query) ]

        SelectTab tab ->
            { model | selectedTab = tab } ! []

        SelectTableRecord rec ->
            let
                newModel =
                    { model | selectedTableRecord = rec }
                        |> populateSelectedTableForm
            in
                newModel ! []

        SessionExpired ->
            -- TODO: do something great here.
            let
                _ =
                    Debug.log "SessionExpired" "We just received the news..."
            in
                model ! []

        Snackbar msg ->
            let
                ( snackbar, newCmd ) =
                    Snackbar.update msg model.snackbar
            in
                { model | snackbar = snackbar } ! [ Cmd.map Snackbar newCmd ]

        VaccinationTypeResponse vaccinationTypeTbl ->
            { model | vaccinationType = vaccinationTypeTbl } ! []


populateSelectedTableForm : Model -> Model
populateSelectedTableForm model =
    -- Is there a selected table?
    case model.selectedTable of
        Just t ->
            -- Is this a table that we can handle?
            case t of
                MedicationType ->
                    -- Is there data for that table?
                    case model.medicationTypeModel.medicationType of
                        Success data ->
                            let
                                -- Populate the form with the record we need.
                                ( form, newModel ) =
                                    case model.medicationTypeModel.editMode of
                                        EditModeAdd ->
                                            let
                                                -- Get an unique sorting id as default value.
                                                nextSortOrder =
                                                    getRecNextMax (\r -> r.sortOrder) data
                                            in
                                                ( MedicationTypeTable model.nextPendingId "" "" nextSortOrder Nothing
                                                    |> MedType.medicationTypeInitialForm
                                                , { model | nextPendingId = model.nextPendingId - 1 }
                                                )

                                        _ ->
                                            case LE.getAt (Maybe.withDefault 0 model.medicationTypeModel.selectedRecordId) data of
                                                Just rec ->
                                                    ( MedType.medicationTypeInitialForm rec, model )

                                                Nothing ->
                                                    ( model.medicationTypeModel.medicationTypeForm, model )
                            in
                                newModel.medicationTypeModel
                                    |> MedType.setMedicationTypeForm form
                                    |> asMedicationTypeModelIn newModel

                        _ ->
                            model

                _ ->
                    model

        Nothing ->
            model


getRecNextMax : (a -> Int) -> List a -> Int
getRecNextMax func list =
    case LE.maximumBy func list of
        Just a ->
            func a |> (+) 1

        Nothing ->
            0


{-| Returns the number of records in the selected table
or zero if anything goes wrong.
-}
numRecsSelectedTable : Model -> Int
numRecsSelectedTable model =
    case model.selectedTable of
        Just t ->
            case t of
                MedicationType ->
                    case model.medicationTypeModel.medicationType of
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
