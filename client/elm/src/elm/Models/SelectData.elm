module Models.SelectData exposing (..)

import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)
import Models.Utils as MU


-- MODEL


type alias SelectDataModel =
    TableModel SelectDataRecord SelectDataForm


initialSelectDataModel : SelectDataModel
initialSelectDataModel =
    { records = NotAsked
    , form = Form.initial [] selectDataValidate
    , selectedRecordId = Nothing
    , editMode = EditModeTable
    , nextPendingId = -1
    , selectQuery = Nothing
    }



-- VALIDATION


selectDataInitialForm : SelectDataRecord -> Form () SelectDataForm
selectDataInitialForm sdRecord =
    Form.initial
        [ ( "id", Fld.string <| toString sdRecord.id )
        , ( "name", Fld.string sdRecord.name )
        , ( "label", Fld.string sdRecord.label )
        , ( "selected", Fld.bool sdRecord.selected )
        ]
        selectDataValidate


selectDataValidate : V.Validation () SelectDataForm
selectDataValidate =
    V.map4 SelectDataForm
        (V.field "id" V.int)
        (V.field "name" V.string |> V.andThen V.nonEmpty)
        (V.field "label" V.string )
        (V.field "selected" V.bool)



-- FIELD UPDATES


populateSelectedTableForm : SelectDataModel -> SelectDataModel
populateSelectedTableForm sdModel =
    case sdModel.records of
        Success data ->
            case sdModel.editMode of
                EditModeAdd ->
                    sdModel
                        |> MU.setForm
                            (selectDataInitialForm
                                (SelectDataRecord sdModel.nextPendingId
                                    ""
                                    ""
                                    ""
                                    False
                                    Nothing
                                )
                            )
                        |> MU.setNextPendingId (sdModel.nextPendingId - 1)

                _ ->
                    case LE.find (\r -> r.id == (Maybe.withDefault 0 sdModel.selectedRecordId)) data of
                        Just rec ->
                            sdModel
                                |> MU.setForm (selectDataInitialForm rec)

                        Nothing ->
                            sdModel

        _ ->
            sdModel


populateSelectedTableFormWithName : String -> SelectDataModel -> SelectDataModel
populateSelectedTableFormWithName name sdModel =
    case sdModel.records of
        Success data ->
            case sdModel.editMode of
                EditModeAdd ->
                    sdModel
                        |> MU.setForm
                            (selectDataInitialForm
                                (SelectDataRecord sdModel.nextPendingId
                                    name
                                    ""
                                    ""
                                    False
                                    Nothing
                                )
                            )
                        |> MU.setNextPendingId (sdModel.nextPendingId - 1)

                _ ->
                    case LE.find (\r -> r.id == (Maybe.withDefault 0 sdModel.selectedRecordId)) data of
                        Just rec ->
                            sdModel
                                |> MU.setForm (selectDataInitialForm rec)

                        Nothing ->
                            sdModel

        _ ->
            sdModel
