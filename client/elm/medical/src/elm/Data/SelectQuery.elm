module Data.SelectQuery exposing (SelectQuery, selectQueryToValue)

import Json.Encode as JE
import Json.Decode.Pipeline exposing (decode, required, requiredAt)


-- LOCAL IMPORTS --

import Data.Table exposing (Table, tableToValue)
import Util exposing (maybeIntToNegOne)


type alias SelectQuery =
    { table : Table
    , id : Maybe Int
    , related : List Table
    }


selectQueryToValue : SelectQuery -> JE.Value
selectQueryToValue sq =
    JE.object
        [ ( "table", tableToValue sq.table )
        , ( "id", maybeIntToNegOne sq.id )
        , ( "related", JE.list <| List.map tableToValue sq.related )
        ]
