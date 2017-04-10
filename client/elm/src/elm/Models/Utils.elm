module Models.Utils
    exposing
        ( addRecord
        , delSelectedRecord
        , getRecNextMax
        , getSelectedRecordAsString
        , selectQueryResponseToSelectQuery
        , setEditMode
        , setForm
        , setNextPendingId
        , setRecords
        , setSelectedRecordId
        , setSelectQuery
        , updateById
        , updateByIndex
        , validateOptionalEmail
        )

import Form exposing (Form)
import Form.Validate as V
import Json.Encode as JE
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)


validateOptionalEmail : V.Validation () String
validateOptionalEmail =
    V.oneOf
        [ V.emptyString |> V.map (\_ -> "")
        , V.email
        ]


addRecord : a -> TableModel a b -> TableModel a b
addRecord rec tableModel =
    setRecords (RD.map (\list -> list ++ [ rec ]) tableModel.records) tableModel


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


updateById :
    Int
    -> ({ a | id : Int } -> { a | id : Int })
    -> RemoteData String (List { a | id : Int })
    -> RemoteData String (List { a | id : Int })
updateById id func records =
    case records of
        Success recs ->
            case LE.findIndex (\r -> r.id == id) recs of
                Just idx ->
                    updateByIndex idx func records

                Nothing ->
                    records

        _ ->
            records


updateByIndex :
    Int
    -> ({ a | id : Int } -> { a | id : Int })
    -> RemoteData String (List { a | id : Int })
    -> RemoteData String (List { a | id : Int })
updateByIndex idx func records =
    case records of
        Success recs ->
            case LE.updateAt idx func recs of
                Just updatedRecs ->
                    RD.succeed updatedRecs

                Nothing ->
                    records

        _ ->
            records
