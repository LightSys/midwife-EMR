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
    | Baby
    | Labor
    | LaborStage1
    | LaborStage2
    | LaborStage3
    | Membrane
    | NewbornExam
    | Patient
    | Pregnancy
    | SelectData


-- HELPERS --


tableToValue : Table -> JE.Value
tableToValue table =
    JE.string <| tableToString table


tableToString : Table -> String
tableToString tbl =
    case tbl of
        Unknown ->
            "unknown"

        Baby ->
            "baby"

        Labor ->
            "labor"

        LaborStage1 ->
            "laborStage1"

        LaborStage2 ->
            "laborStage2"

        LaborStage3 ->
            "laborStage3"

        Membrane ->
            "membrane"

        NewbornExam ->
            "newbornExam"

        Patient ->
            "patient"

        Pregnancy ->
            "pregnancy"

        SelectData ->
            "selectData"


stringToTable : String -> Table
stringToTable tbl =
    case tbl of
        "baby" ->
            Baby

        "labor" ->
            Labor

        "laborStage1" ->
            LaborStage1

        "laborStage2" ->
            LaborStage2

        "laborStage3" ->
            LaborStage3

        "membrane" ->
            Membrane

        "newbornExam" ->
            NewbornExam

        "patient" ->
            Patient

        "pregnancy" ->
            Pregnancy

        "selectData" ->
            SelectData

        _ ->
            Unknown


decodeTable : JD.Decoder Table
decodeTable =
    JD.string |> JD.map stringToTable

