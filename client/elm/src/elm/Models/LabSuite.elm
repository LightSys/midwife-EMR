module Models.LabSuite exposing (..)

import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)
import Models.Utils as MU


-- MODEL


type alias LabSuiteModel =
    TableModel LabSuiteRecord LabSuiteForm


initialLabSuiteModel : LabSuiteModel
initialLabSuiteModel =
    { records = NotAsked
    , form = Form.initial [] labSuiteValidate
    , selectedRecordId = Nothing
    , editMode = EditModeOther
    , nextPendingId = -1
    , selectQuery = Nothing
    }



-- VALIDATION

labSuiteInitialForm : LabSuiteRecord -> Form () LabSuiteForm
labSuiteInitialForm lsRecord =
    Form.initial
        [ ( "id", Fld.string <| toString lsRecord.id )
        , ( "name", Fld.string lsRecord.name )
        , ( "description", Fld.string lsRecord.description )
        ]
        labSuiteValidate


labSuiteValidate : V.Validation () LabSuiteForm
labSuiteValidate =
    V.map3 LabSuiteForm
        (V.field "id" V.int)
        (V.field "name" V.string |> V.andThen V.nonEmpty)
        (V.succeed "description")


-- FIELD UPDATES


populateSelectedTableForm : LabSuiteModel -> LabSuiteModel
populateSelectedTableForm lsModel =
    case lsModel.records of
        Success data ->
            case lsModel.editMode of
                EditModeAdd ->
                    lsModel
                        |> MU.setForm
                            (labSuiteInitialForm
                                (LabSuiteRecord lsModel.nextPendingId
                                    ""
                                    ""
                                    ""
                                    Nothing
                                )
                            )
                        |> MU.setNextPendingId (lsModel.nextPendingId - 1)

                _ ->
                    case LE.find (\r -> r.id == (Maybe.withDefault 0 lsModel.selectedRecordId)) data of
                        Just rec ->
                            lsModel
                                |> MU.setForm (labSuiteInitialForm rec)

                        Nothing ->
                            lsModel

        _ ->
            lsModel
