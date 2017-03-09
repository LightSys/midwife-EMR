module Models.MedicationType exposing (..)

import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)
import ModelUtils as MU


-- MODEL


type alias MedicationTypeModel =
    TableModel MedicationTypeRecord MedicationTypeForm


initialMedicationTypeModel : MedicationTypeModel
initialMedicationTypeModel =
    { records = NotAsked
    , form = Form.initial [] medicationTypeValidate
    , selectedRecordId = Nothing
    , editMode = EditModeTable
    , nextPendingId = -1
    , selectQuery = Nothing
    }



-- VALIDATION


medicationTypeInitialForm : MedicationTypeRecord -> Form () MedicationTypeForm
medicationTypeInitialForm table =
    Form.initial
        [ ( "id", Fld.string <| toString table.id )
        , ( "name", Fld.string table.name )
        , ( "description", Fld.string table.description )
        , ( "sortOrder", Fld.string <| toString table.sortOrder )
        ]
        medicationTypeValidate


medicationTypeValidate : V.Validation () MedicationTypeForm
medicationTypeValidate =
    V.map4 MedicationTypeForm
        (V.field "id" V.int)
        (V.field "name" V.string |> V.andThen V.nonEmpty)
        (V.field "description" V.string |> V.andThen V.nonEmpty)
        (V.field "sortOrder" V.int)



-- FIELD UPDATES


firstRecord : MedicationTypeModel -> MedicationTypeModel
firstRecord mtModel =
    moveToRecord (\_ list -> list) List.head mtModel


prevRecord : MedicationTypeModel -> MedicationTypeModel
prevRecord mtModel =
    moveToRecord (\rid list -> LE.takeWhile (\r -> r.id < rid) list) LE.last mtModel


nextRecord : MedicationTypeModel -> MedicationTypeModel
nextRecord mtModel =
    moveToRecord (\rid list -> LE.dropWhile (\r -> r.id <= rid) list) List.head mtModel


lastRecord : MedicationTypeModel -> MedicationTypeModel
lastRecord mtModel =
    moveToRecord (\_ list -> list) LE.last mtModel


moveToRecord :
    (Int -> List MedicationTypeRecord -> List MedicationTypeRecord)
    -> (List MedicationTypeRecord -> Maybe MedicationTypeRecord)
    -> MedicationTypeModel
    -> MedicationTypeModel
moveToRecord func1 func2 ({ records, selectedRecordId } as mtModel) =
    let
        newId =
            case ( RD.toMaybe records, selectedRecordId ) of
                ( Just recs, Just recId ) ->
                    case
                        List.sortBy .id recs
                            |> func1 recId
                            |> func2
                    of
                        Just rec ->
                            Just rec.id

                        _ ->
                            -- If we came up with an empty list, default to
                            -- the starting record.
                            Just recId

                _ ->
                    Nothing
    in
        MU.setSelectedRecordId newId mtModel
            |> populateSelectedTableForm


populateSelectedTableForm : MedicationTypeModel -> MedicationTypeModel
populateSelectedTableForm mtModel =
    case mtModel.records of
        Success data ->
            case mtModel.editMode of
                EditModeAdd ->
                    let
                        sortOrderFldVal =
                            MU.getRecNextMax (\r -> r.sortOrder) data
                    in
                        mtModel
                            |> MU.setForm
                                (medicationTypeInitialForm
                                    (MedicationTypeRecord mtModel.nextPendingId
                                        ""
                                        ""
                                        sortOrderFldVal
                                        Nothing
                                    )
                                )
                            |> MU.setNextPendingId (mtModel.nextPendingId - 1)

                _ ->
                    case LE.find (\r -> r.id == (Maybe.withDefault 0 mtModel.selectedRecordId)) data of
                        Just rec ->
                            mtModel
                                |> MU.setForm (medicationTypeInitialForm rec)

                        Nothing ->
                            mtModel

        _ ->
            mtModel
