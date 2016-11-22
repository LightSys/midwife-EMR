module Encoders exposing (..)

import Json.Encode as JE
import Json.Decode.Pipeline exposing (decode, required, requiredAt)


-- LOCAL IMPORTS

import Types exposing (..)
import Utils as U


tableToValue : Table -> JE.Value
tableToValue table =
    JE.string <| U.tableToString table


maybeIntToNegOne : Maybe Int -> JE.Value
maybeIntToNegOne int =
    case int of
        Just i ->
            JE.int i

        Nothing ->
            JE.int -1


selectQueryToValue : SelectQuery -> JE.Value
selectQueryToValue sq =
    JE.object
        [ ( "table", tableToValue sq.table )
        , ( "id", maybeIntToNegOne sq.id )
        , ( "patient_id", maybeIntToNegOne sq.patient_id )
        , ( "pregnancy_id", maybeIntToNegOne sq.pregnancy_id )
        ]
