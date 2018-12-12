module Data.TableMeta
    exposing
        ( TableMeta
        , TableMetaCollection
        , updateTableMetaByParts
        , getTableMeta
        , initializeTableMetaCollection
        , removeTableMeta
        , tableMetaForTable
        , toggleTableMetaVisible
        , updateTableMetaCollectionByList
        )

import Data.Table exposing (Table(..), decodeTable, tableToString)
import Data.User as DU
import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP


type alias TableMeta =
    { table : Table
    , id : Int
    , updatedBy : Int
    , username : Maybe String
    , updatedAt : Date
    , supervisor : Maybe Int
    , isVisible : Bool
    }


tableMetaForTable : Table -> JD.Decoder TableMeta
tableMetaForTable tbl =
    JDP.decode TableMeta
        |> JDP.hardcoded tbl
        |> JDP.required "id" JD.int
        |> JDP.required "updatedBy" JD.int
        |> JDP.hardcoded Nothing
        |> JDP.required "updatedAt" JDE.date
        |> JDP.required "supervisor" (JD.maybe JD.int)
        |> JDP.hardcoded False


type alias TableMetaCollection =
    Dict String (Dict Int TableMeta)


initializeTableMetaCollection : TableMetaCollection
initializeTableMetaCollection =
    Dict.empty


{-| Toggle the isVisible field of the TableMeta record
corresponding to the Table and id passed.
-}
toggleTableMetaVisible : Table -> Int -> TableMetaCollection -> TableMetaCollection
toggleTableMetaVisible tbl id tmColl =
    Dict.update (tableToString tbl)
        (\outer ->
            case outer of
                Just inner ->
                    Just <|
                        Dict.update id
                            (\innerVal ->
                                case innerVal of
                                    Just tm ->
                                        Just { tm | isVisible = not tm.isVisible }

                                    Nothing ->
                                        Nothing
                            )
                            inner

                Nothing ->
                    Nothing
        )
        tmColl


{-| Update or insert a TableMeta record with the user and date information. This is used when the
user updates/inserts a record and since the server does not return meta data in that case.
-}
updateTableMetaByParts : Table -> Int -> Int -> Maybe Int -> Date -> Dict Int DU.User -> TableMetaCollection -> TableMetaCollection
updateTableMetaByParts tbl key userId supervisorId theDate users tmColl =
    case getTableMeta tbl key tmColl of
        Just tm ->
            updateTableMeta
                { tm | updatedAt = theDate }
                (DU.getUser userId users)
                supervisorId
                tmColl

        Nothing ->
            -- We insert a record as necessary.
            updateTableMeta
                (TableMeta tbl key userId Nothing theDate Nothing False)
                (DU.getUser userId users)
                supervisorId
                tmColl


{-| Insert or update a TableMeta record into the collection.
-}
updateTableMeta : TableMeta -> Maybe DU.User -> Maybe Int -> TableMetaCollection -> TableMetaCollection
updateTableMeta tm user supervisorId tmColl =
    let
        ( tbl, id ) =
            ( tm.table, tm.id )

        tm2 =
            case user of
                Just u ->
                    { tm
                        | username = Just u.username
                        , supervisor = supervisorId
                    }

                Nothing ->
                    tm
    in
    case Dict.get (tableToString tbl) tmColl of
        Just tblCollection ->
            Dict.insert (tableToString tbl) (Dict.insert id tm2 tblCollection) tmColl

        Nothing ->
            Dict.insert (tableToString tbl) (Dict.singleton id tm2) tmColl


{-| Insert or update a list of TableMeta records into the collection.
-}
updateTableMetaCollectionByList : List TableMeta -> Dict Int DU.User -> TableMetaCollection -> TableMetaCollection
updateTableMetaCollectionByList tableMeta users tmColl =
    List.foldl (\tm coll -> updateTableMeta tm (Dict.get tm.updatedBy users) tm.supervisor coll) tmColl tableMeta


{-| Remove the TableMeta record corresponding to the Table and id passed.
-}
removeTableMeta : Table -> Int -> TableMetaCollection -> TableMetaCollection
removeTableMeta tbl id tmColl =
    case Dict.get (tableToString tbl) tmColl of
        Just tblCollection ->
            Dict.insert (tableToString tbl) (Dict.remove id tblCollection) tmColl

        Nothing ->
            tmColl


{-| Return the TableMeta record, if any, corresponding to the Table
and id passed.
-}
getTableMeta : Table -> Int -> TableMetaCollection -> Maybe TableMeta
getTableMeta tbl id tmColl =
    case Dict.get (tableToString tbl) tmColl of
        Just tblCollection ->
            Dict.get id tblCollection

        Nothing ->
            Nothing
