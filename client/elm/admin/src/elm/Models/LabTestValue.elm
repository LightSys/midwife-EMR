module Models.LabTestValue exposing (..)

import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)
import Models.Utils as MU


-- MODEL


type alias LabTestValueModel =
    TableModel LabTestValueRecord LabTestValueForm


initialLabTestValueModel : LabTestValueModel
initialLabTestValueModel =
    { records = NotAsked
    , form = Form.initial [] labTestValueValidate
    , selectedRecordId = Nothing
    , editMode = EditModeOther
    , nextPendingId = -1
    , selectQuery = Nothing
    }



-- VALIDATION


labTestValueInitialForm : LabTestValueRecord -> Form () LabTestValueForm
labTestValueInitialForm rec =
    Form.initial
        [ ( "id", Fld.string <| toString rec.id )
        , ( "value", Fld.string rec.value )
        , ( "labTest_id", Fld.string <| toString rec.labTest_id )
        ]
        labTestValueValidate


labTestValueValidate : V.Validation () LabTestValueForm
labTestValueValidate =
    V.succeed LabTestValueForm
        |> V.andMap (V.field "id" V.int)
        |> V.andMap (V.field "value" V.string |> V.andThen V.nonEmpty)
        |> V.andMap (V.field "labTest_id" V.int)



-- FIELD UPDATES


populateSelectedTableForm : LabTestValueModel -> LabTestValueModel
populateSelectedTableForm lsModel =
    case lsModel.records of
        Success data ->
            case lsModel.editMode of
                EditModeAdd ->
                    let
                        _ =
                            Debug.log "populateSelectedTableForm for labTestValue" "Warning: probably should use populateSelectedTableFormWithTestId instead."
                    in
                        lsModel

                _ ->
                    case LE.find (\r -> r.id == (Maybe.withDefault 0 lsModel.selectedRecordId)) data of
                        Just rec ->
                            lsModel
                                |> MU.setForm (labTestValueInitialForm rec)

                        Nothing ->
                            lsModel

        _ ->
            lsModel


populateSelectedTableFormWithTestId : Int -> LabTestValueModel -> LabTestValueModel
populateSelectedTableFormWithTestId testId lsModel =
    case lsModel.records of
        Success data ->
            case lsModel.editMode of
                EditModeAdd ->
                    lsModel
                        |> MU.setForm
                            (labTestValueInitialForm
                                (LabTestValueRecord lsModel.nextPendingId
                                    ""
                                    testId
                                    Nothing
                                )
                            )
                        |> MU.setNextPendingId (lsModel.nextPendingId - 1)

                _ ->
                    let
                        _ =
                            Debug.log "populateSelectedTableFormWithTestId" "Warning: probably should use populateSelectedTableForm instead."
                    in
                        lsModel

        _ ->
            lsModel
