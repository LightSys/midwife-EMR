module Models.LabTest exposing (..)

import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)
import Models.Utils as MU


-- MODEL


type alias LabTestModel =
    TableModel LabTestRecord LabTestForm


initialLabTestModel : LabTestModel
initialLabTestModel =
    { records = NotAsked
    , form = Form.initial [] labTestValidate
    , selectedRecordId = Nothing
    , editMode = EditModeOther
    , nextPendingId = -1
    , selectQuery = Nothing
    }



-- VALIDATION


labTestInitialForm : LabTestRecord -> Form () LabTestForm
labTestInitialForm rec =
    Form.initial
        [ ( "id", Fld.string <| toString rec.id )
        , ( "name", Fld.string rec.name )
        , ( "abbrev", Fld.string rec.abbrev )
        , ( "normal", Fld.string rec.normal )
        , ( "unit", Fld.string rec.unit )
        , ( "minRangeDecimal", Fld.string <| MU.maybeFloatToString "" rec.minRangeDecimal )
        , ( "maxRangeDecimal", Fld.string <| MU.maybeFloatToString "" rec.maxRangeDecimal )
        , ( "minRangeInteger", Fld.string <| MU.maybeIntToString "" rec.minRangeInteger )
        , ( "maxRangeInteger", Fld.string <| MU.maybeIntToString "" rec.maxRangeInteger )
        , ( "isRange", Fld.bool rec.isRange )
        , ( "isText", Fld.bool rec.isText )
        , ( "labSuite_id", Fld.string <| toString rec.labSuite_id )
        ]
        labTestValidate


labTestValidate : V.Validation () LabTestForm
labTestValidate =
    V.succeed LabTestForm
        |> V.andMap (V.field "id" V.int)
        |> V.andMap (V.field "name" V.string |> V.andThen V.nonEmpty)
        |> V.andMap (V.field "abbrev" (V.string |> V.defaultValue ""))
        |> V.andMap (V.field "normal" (V.string |> V.defaultValue ""))
        |> V.andMap (V.field "unit" (V.string |> V.defaultValue ""))
        |> V.andMap (V.field "minRangeDecimal" (V.string |> V.defaultValue ""))
        |> V.andMap (V.field "maxRangeDecimal" (V.string |> V.defaultValue ""))
        |> V.andMap (V.field "minRangeInteger" (V.string |> V.defaultValue ""))
        |> V.andMap (V.field "minRangeInteger" (V.string |> V.defaultValue ""))
        |> V.andMap (V.field "isRange" V.bool)
        |> V.andMap (V.field "maxRangeInteger" V.bool)
        |> V.andMap (V.field "labSuite_id" V.int)



-- FIELD UPDATES


populateSelectedTableForm : LabTestModel -> LabTestModel
populateSelectedTableForm lsModel =
    case lsModel.records of
        Success data ->
            case lsModel.editMode of
                EditModeAdd ->
                    let
                        _ =
                            Debug.log "populateSelectedTableForm for labTest" "Warning: should call populateSelectedTableFormWithSuiteId for EditModeAdd."
                    in
                        lsModel

                _ ->
                    case LE.find (\r -> r.id == (Maybe.withDefault 0 lsModel.selectedRecordId)) data of
                        Just rec ->
                            lsModel
                                |> MU.setForm (labTestInitialForm rec)

                        Nothing ->
                            lsModel

        _ ->
            lsModel


populateSelectedTableFormWithSuiteId : Int -> LabTestModel -> LabTestModel
populateSelectedTableFormWithSuiteId suiteId lsModel =
    case lsModel.records of
        Success data ->
            case lsModel.editMode of
                EditModeAdd ->
                    lsModel
                        |> MU.setForm
                            (labTestInitialForm
                                (LabTestRecord lsModel.nextPendingId
                                    ""
                                    ""
                                    ""
                                    ""
                                    Nothing
                                    Nothing
                                    Nothing
                                    Nothing
                                    False
                                    False
                                    suiteId
                                    Nothing
                                )
                            )
                        |> MU.setNextPendingId (lsModel.nextPendingId - 1)

                _ ->
                    let
                        _ =
                            Debug.log "populateSelectedTableFormWithSuiteId" "Warning: should only call this function for EditModeAdd."
                    in
                        lsModel

        _ ->
            lsModel
