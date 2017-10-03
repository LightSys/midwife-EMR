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
    | LaborStage1



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

        LaborStage1 ->
            "laborStage1"

        Patient ->
            "patient"

        Pregnancy ->
            "pregnancy"


stringToTable : String -> Table
stringToTable tbl =
    case tbl of
        "labor" ->
            Labor

        "laborStage1" ->
            LaborStage1

        "patient" ->
            Patient

        "pregnancy" ->
            Pregnancy

        _ ->
            Unknown


decodeTable : JD.Decoder Table
decodeTable =
    JD.string |> JD.map stringToTable
