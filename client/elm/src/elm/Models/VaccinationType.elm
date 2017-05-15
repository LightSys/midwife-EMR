module Models.VaccinationType exposing (..)

import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)
import Models.Utils as MU


-- MODEL


type alias VaccinationTypeModel =
    TableModel VaccinationTypeRecord VaccinationTypeForm


initialVaccinationTypeModel : VaccinationTypeModel
initialVaccinationTypeModel =
    { records = NotAsked
    , form = Form.initial [] vaccinationTypeValidate
    , selectedRecordId = Nothing
    , editMode = EditModeTable
    , nextPendingId = -1
    , selectQuery = Nothing
    }



-- VALIDATION

vaccinationTypeInitialForm : VaccinationTypeRecord -> Form () VaccinationTypeForm
vaccinationTypeInitialForm vtRecord =
    Form.initial
        [ ( "id", Fld.string <| toString vtRecord.id )
        , ( "name", Fld.string vtRecord.name )
        , ( "description", Fld.string vtRecord.description )
        , ( "sortOrder", Fld.string <| toString vtRecord.sortOrder )
        ]
        vaccinationTypeValidate


vaccinationTypeValidate : V.Validation () VaccinationTypeForm
vaccinationTypeValidate =
    V.map4 VaccinationTypeForm
        (V.field "id" V.int)
        (V.field "name" V.string |> V.andThen V.nonEmpty)
        (V.field "description" V.string |> V.andThen V.nonEmpty)
        (V.field "sortOrder" V.int)


-- FIELD UPDATES


firstRecord : VaccinationTypeModel -> VaccinationTypeModel
firstRecord vtModel =
    moveToRecord (\_ list -> list) List.head vtModel


prevRecord : VaccinationTypeModel -> VaccinationTypeModel
prevRecord vtModel =
    moveToRecord (\rid list -> LE.takeWhile (\r -> r.id < rid) list) LE.last vtModel


nextRecord : VaccinationTypeModel -> VaccinationTypeModel
nextRecord vtModel =
    moveToRecord (\rid list -> LE.dropWhile (\r -> r.id <= rid) list) List.head vtModel


lastRecord : VaccinationTypeModel -> VaccinationTypeModel
lastRecord vtModel =
    moveToRecord (\_ list -> list) LE.last vtModel


moveToRecord :
    (Int -> List VaccinationTypeRecord -> List VaccinationTypeRecord)
    -> (List VaccinationTypeRecord -> Maybe VaccinationTypeRecord)
    -> VaccinationTypeModel
    -> VaccinationTypeModel
moveToRecord func1 func2 ({ records, selectedRecordId } as vtModel) =
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
        MU.setSelectedRecordId newId vtModel
            |> populateSelectedTableForm


populateSelectedTableForm : VaccinationTypeModel -> VaccinationTypeModel
populateSelectedTableForm vtModel =
    case vtModel.records of
        Success data ->
            case vtModel.editMode of
                EditModeAdd ->
                    let
                        sortOrderFldVal =
                            MU.getRecNextMax (\r -> r.sortOrder) data
                    in
                        vtModel
                            |> MU.setForm
                                (vaccinationTypeInitialForm
                                    (VaccinationTypeRecord vtModel.nextPendingId
                                        ""
                                        ""
                                        sortOrderFldVal
                                        Nothing
                                    )
                                )
                            |> MU.setNextPendingId (vtModel.nextPendingId - 1)

                _ ->
                    case LE.find (\r -> r.id == (Maybe.withDefault 0 vtModel.selectedRecordId)) data of
                        Just rec ->
                            vtModel
                                |> MU.setForm (vaccinationTypeInitialForm rec)

                        Nothing ->
                            vtModel

        _ ->
            vtModel
