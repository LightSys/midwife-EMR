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


medicationTypeToValue : MedicationTypeRecord -> JE.Value
medicationTypeToValue mt =
    JE.object
        [ ( "id", JE.int mt.id )
        , ( "name", JE.string mt.name )
        , ( "description", JE.string mt.description )
        , ( "sortOrder", JE.int mt.sortOrder )
        , case mt.stateId of
            Just num ->
                ( "stateId", JE.int num )

            Nothing ->
                ( "stateId", JE.null )
        ]
