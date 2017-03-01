module Models.MedicationType exposing (..)

import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)


-- MODEL


type alias MedicationTypeModel =
    { medicationType : RemoteData String (List MedicationTypeTable)
    , medicationTypeForm : Form () MedicationTypeForm
    , selectedRecordId : Maybe Int
    , editMode : EditMode
    , nextPendingId : Int
    }


initialMedicationTypeModel : MedicationTypeModel
initialMedicationTypeModel =
    { medicationType = NotAsked
    , medicationTypeForm = Form.initial [] medicationTypeValidate
    , selectedRecordId = Nothing
    , editMode = EditModeTable
    , nextPendingId = -1
    }


type alias MedicationTypeForm =
    { id : Int
    , name : String
    , description : String
    , sortOrder : Int
    }



-- VALIDATION


medicationTypeInitialForm : MedicationTypeTable -> Form () MedicationTypeForm
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


setMedicationType : RemoteData String (List MedicationTypeTable) -> MedicationTypeModel -> MedicationTypeModel
setMedicationType mt mtModel =
    (\mtModel -> { mtModel | medicationType = mt }) mtModel


setMedicationTypeForm : Form () MedicationTypeForm -> MedicationTypeModel -> MedicationTypeModel
setMedicationTypeForm mtf mtModel =
    (\mtModel -> { mtModel | medicationTypeForm = mtf }) mtModel


setSelectedRecordId : Maybe Int -> MedicationTypeModel -> MedicationTypeModel
setSelectedRecordId id mtModel =
    (\mtModel -> { mtModel | selectedRecordId = id }) mtModel


setEditMode : EditMode -> MedicationTypeModel -> MedicationTypeModel
setEditMode mode mtModel =
    (\mtModel -> { mtModel | editMode = mode }) mtModel


setNextPendingId : Int -> MedicationTypeModel -> MedicationTypeModel
setNextPendingId id mtModel =
    (\mtModel -> { mtModel | nextPendingId = id }) mtModel


{-| TODO: deletion is done here, but addition is done in Updates.MedicationType.
Fix this. Also, this one only deals with medicationTypeModel, while other
also includes Model.
-}
delSelectedRecord : MedicationTypeModel -> MedicationTypeModel
delSelectedRecord ({ medicationType, selectedRecordId } as mtModel) =
    case ( medicationType, selectedRecordId ) of
        ( Success data, Just id ) ->
            RD.map (\list -> List.filter (\rec -> rec.id /= id) list) medicationType
                |> flip setMedicationType mtModel

        _ ->
            mtModel


getRecNextMax : (a -> Int) -> List a -> Int
getRecNextMax func list =
    case LE.maximumBy func list of
        Just a ->
            func a |> (+) 1

        Nothing ->
            0


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
    (Int -> List MedicationTypeTable -> List MedicationTypeTable)
    -> (List MedicationTypeTable -> Maybe MedicationTypeTable)
    -> MedicationTypeModel
    -> MedicationTypeModel
moveToRecord func1 func2 ({ medicationType, selectedRecordId } as mtModel) =
    let
        newId =
            case ( RD.toMaybe medicationType, selectedRecordId ) of
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
        setSelectedRecordId newId mtModel
            |> populateSelectedTableForm


populateSelectedTableForm : MedicationTypeModel -> MedicationTypeModel
populateSelectedTableForm mtModel =
    case mtModel.medicationType of
        Success data ->
            case mtModel.editMode of
                EditModeAdd ->
                    let
                        nextSortOrder =
                            getRecNextMax (\r -> r.sortOrder) data
                    in
                        mtModel
                            |> setMedicationTypeForm
                                (medicationTypeInitialForm
                                    (MedicationTypeTable mtModel.nextPendingId
                                        ""
                                        ""
                                        nextSortOrder
                                        Nothing
                                    )
                                )
                            |> setNextPendingId (mtModel.nextPendingId + 1)

                _ ->
                    case LE.find (\r -> r.id == (Maybe.withDefault 0 mtModel.selectedRecordId)) data of
                        Just rec ->
                            mtModel
                                |> setMedicationTypeForm (medicationTypeInitialForm rec)

                        Nothing ->
                            mtModel

        _ ->
            mtModel
