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



-- HELPERS --


tableToValue : Table -> JE.Value
tableToValue table =
    JE.string <| tableToString table


tableToString : Table -> String
tableToString tbl =
    case tbl of
        Unknown ->
            "unknown"

        Patient ->
            "patient"

        Pregnancy ->
            "pregnancy"


stringToTable : String -> Table
stringToTable tbl =
    case tbl of
        "patient" ->
            Patient

        "pregnancy" ->
            Pregnancy

        _ ->
            Unknown


decodeTable : JD.Decoder Table
decodeTable =
    JD.string |> JD.map stringToTable

