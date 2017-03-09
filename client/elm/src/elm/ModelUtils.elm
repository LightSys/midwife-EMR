module ModelUtils
    exposing
        ( delSelectedRecord
        , getRecNextMax
        , getSelectedRecordAsString
        , selectQueryResponseToSelectQuery
        , setEditMode
        , setForm
        , setNextPendingId
        , setRecords
        , setSelectedRecordId
        , setSelectQuery
        )

import Form exposing (Form)
import Json.Encode as JE
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)


{-| TODO: deletion is done here, but addition is done in Updates.MedicationType.
Fix this. Also, this one only deals with medicationTypeModel, while other
also includes Model.
-}
delSelectedRecord : TableModel { a | id : Int } b -> TableModel { a | id : Int } b
delSelectedRecord ({ records, selectedRecordId } as tableModel) =
    case ( records, selectedRecordId ) of
        ( Success data, Just id ) ->
            RD.map (\list -> List.filter (\rec -> rec.id /= id) list) records
                |> flip setRecords tableModel

        _ ->
            tableModel


getRecNextMax : (a -> Int) -> List a -> Int
getRecNextMax func list =
    case LE.maximumBy func list of
        Just a ->
            func a |> (+) 1

        Nothing ->
            0


getSelectedRecordAsString : TableModel { a | id : Int } b -> ({ a | id : Int } -> JE.Value) -> Maybe String
getSelectedRecordAsString { records, selectedRecordId } encoderFunc =
    case ( records, selectedRecordId ) of
        ( Success data, Just id ) ->
            case LE.find (\r -> r.id == id) data of
                Just rec ->
                    JE.encode 0 (encoderFunc rec) |> Just

                Nothing ->
                    Nothing

        _ ->
            Nothing


{-| Extract the SelectQuery portion from a SelectQueryResponse
and return it.
-}
selectQueryResponseToSelectQuery : SelectQueryResponse -> SelectQuery
selectQueryResponseToSelectQuery =
    (\sqr -> SelectQuery sqr.table sqr.id sqr.patient_id sqr.pregnancy_id)


setEditMode : EditMode -> TableModel a b -> TableModel a b
setEditMode mode tableModel =
    (\tm -> { tm | editMode = mode }) tableModel


setForm : Form () a -> TableModel b a -> TableModel b a
setForm theForm tableModel =
    (\tm -> { tm | form = theForm }) tableModel


setNextPendingId : Int -> TableModel a b -> TableModel a b
setNextPendingId id tableModel =
    (\tm -> { tm | nextPendingId = id }) tableModel


setRecords : RemoteData String (List a) -> TableModel a b -> TableModel a b
setRecords recs tableModel =
    (\tm -> { tm | records = recs }) tableModel


setSelectedRecordId : Maybe Int -> TableModel a b -> TableModel a b
setSelectedRecordId id tableModel =
    (\tm -> { tm | selectedRecordId = id }) tableModel


setSelectQuery : Maybe SelectQuery -> TableModel a b -> TableModel a b
setSelectQuery sq tableModel =
    (\tm -> { tm | selectQuery = sq }) tableModel
