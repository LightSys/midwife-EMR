module Data.Table
    exposing
        ( decodeTable
        , Table(..)
        , stringToTable
        , tableToString
        , tableToValue
        )

import Json.Decode as JD
import Json.Encode as JE


type Table
    = Unknown
    | Patient
    | Pregnancy
    | Labor



-- HELPERS --


tableToValue : Table -> JE.Value
tableToValue table =
    JE.string <| tableToString table


tableToString : Table -> String
tableToString tbl =
    case tbl of
        Unknown ->
            "unknown"

        Labor ->
            "labor"

        Patient ->
            "patient"

        Pregnancy ->
            "pregnancy"


stringToTable : String -> Table
stringToTable tbl =
    case tbl of
        "labor" ->
            Labor

        "patient" ->
            Patient

        "pregnancy" ->
            Pregnancy

        _ ->
            Unknown


decodeTable : JD.Decoder Table
decodeTable =
    JD.string |> JD.map stringToTable

