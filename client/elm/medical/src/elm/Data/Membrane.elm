module Data.Membrane
    exposing
        ( isMembraneRecordComplete
        , maybeAmnioticToString
        , maybeRuptureToString
        , maybeStringToAmniotic
        , maybeStringToRupture
        , MembraneId(..)
        , MembraneRecord
        , membraneRecord
        , MembraneRecordNew
        , membraneRecordNewToMembraneRecord
        , membraneRecordNewToValue
        , membraneRecordToValue
        )

import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE


-- LOCAL IMPORTS --

import Data.Table exposing (Table(..), tableToString)
import Util as U


type MembraneId
    = MembraneId Int

type Rupture
    = AROMRupture
    | SROMRupture
    | OtherRupture


ruptureToString : Rupture -> String
ruptureToString rupture =
    case rupture of
        AROMRupture ->
            "AROM"

        SROMRupture ->
            "SROM"

        OtherRupture ->
            "Other"


maybeRuptureToString : Maybe Rupture -> String
maybeRuptureToString rupture =
    case rupture of
        Just AROMRupture ->
            "AROM"

        Just SROMRupture ->
            "SROM"

        Just OtherRupture ->
            "Other"

        Nothing ->
            ""


stringToRupture : String -> Maybe Rupture
stringToRupture str =
    case str of
        "AROM" ->
            Just AROMRupture

        "SROM" ->
            Just SROMRupture

        "Other" ->
            Just OtherRupture

        _ ->
            Nothing


maybeStringToRupture : Maybe String -> Maybe Rupture
maybeStringToRupture str =
    case str of
        Just val ->
            stringToRupture val

        Nothing ->
            Nothing


type Amniotic
    = ClearAmniotic
    | LtStainAmniotic
    | ModStainAmniotic
    | ThickStainAmniotic
    | OtherAmniotic


amnioticToString : Amniotic -> String
amnioticToString amniotic =
    case amniotic of
        ClearAmniotic ->
            "Clear"

        LtStainAmniotic ->
            "Lt Stain"

        ModStainAmniotic ->
            "Mod Stain"

        ThickStainAmniotic ->
            "Thick Stain"

        OtherAmniotic ->
            "Other"


maybeAmnioticToString : Maybe Amniotic -> String
maybeAmnioticToString amniotic =
    case amniotic of
        Just ClearAmniotic ->
            "Clear"

        Just LtStainAmniotic ->
            "Lt Stain"

        Just ModStainAmniotic ->
            "Mod Stain"

        Just ThickStainAmniotic ->
            "Thick Stain"

        Just OtherAmniotic ->
            "Other"

        Nothing ->
            ""


stringToAmniotic : String -> Maybe Amniotic
stringToAmniotic str =
    case str of
        "Clear" ->
            Just ClearAmniotic

        "Lt Stain" ->
            Just LtStainAmniotic

        "Mod Stain" ->
            Just ModStainAmniotic

        "Thick Stain" ->
            Just ThickStainAmniotic

        "Other" ->
            Just OtherAmniotic

        _ ->
            Nothing


maybeStringToAmniotic : Maybe String -> Maybe Amniotic
maybeStringToAmniotic str =
    case str of
        Just val ->
            stringToAmniotic val

        Nothing ->
            Nothing


type alias MembraneRecord =
    { id : Int
    , ruptureDatetime : Maybe Date
    , rupture : Maybe Rupture
    , ruptureComment : Maybe String
    , amniotic : Maybe Amniotic
    , amnioticComment : Maybe String
    , comments : Maybe String
    , labor_id : Int
    }


type alias MembraneRecordNew =
    { ruptureDatetime : Maybe Date
    , rupture : Maybe Rupture
    , ruptureComment : Maybe String
    , amniotic : Maybe Amniotic
    , amnioticComment : Maybe String
    , comments : Maybe String
    , labor_id : Int
    }


membraneRecord : JD.Decoder MembraneRecord
membraneRecord =
    JDP.decode MembraneRecord
        |> JDP.required "id" JD.int
        |> JDP.optional "ruptureDatetime" (JD.maybe JDE.date) Nothing
        |> JDP.required "rupture" (JD.maybe JD.string |> JD.map maybeStringToRupture)
        |> JDP.required "ruptureComment" (JD.maybe JD.string)
        |> JDP.required "amniotic" (JD.maybe JD.string |> JD.map maybeStringToAmniotic)
        |> JDP.required "amnioticComment" (JD.maybe JD.string)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "labor_id" JD.int


membraneRecordToValue : MembraneRecord -> JE.Value
membraneRecordToValue rec =
    JE.object
        [ ( "table", (JE.string (tableToString Membrane)) )
        , ( "data"
          , JE.object
                [ ( "id", (JE.int rec.id) )
                , ( "ruptureDatetime", (JEE.maybe U.dateToStringValue rec.ruptureDatetime) )
                , ( "rupture", (JEE.maybe (\r -> (JE.string (ruptureToString r))) rec.rupture) )
                , ( "ruptureComment", (JEE.maybe JE.string rec.ruptureComment) )
                , ( "amniotic", (JEE.maybe (\a -> (JE.string (amnioticToString a))) rec.amniotic) )
                , ( "amnioticComment", (JEE.maybe JE.string rec.amnioticComment) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "labor_id", (JE.int rec.labor_id) )
                ]
          )
        ]


membraneRecordNewToValue : MembraneRecordNew -> JE.Value
membraneRecordNewToValue rec =
    JE.object
        [ ( "table", (JE.string "membrane") )
        , ( "data"
          , JE.object
                [ ( "ruptureDatetime", (JEE.maybe U.dateToStringValue rec.ruptureDatetime) )
                , ( "rupture", (JEE.maybe (\r -> (JE.string (ruptureToString r))) rec.rupture) )
                , ( "ruptureComment", (JEE.maybe JE.string rec.ruptureComment) )
                , ( "amniotic", (JEE.maybe (\a -> (JE.string (amnioticToString a))) rec.amniotic) )
                , ( "amnioticComment", (JEE.maybe JE.string rec.amnioticComment) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "labor_id", (JE.int rec.labor_id) )
                ]
          )
        ]


membraneRecordNewToMembraneRecord : MembraneId -> MembraneRecordNew -> MembraneRecord
membraneRecordNewToMembraneRecord (MembraneId id) newRec =
    MembraneRecord id
        newRec.ruptureDatetime
        newRec.rupture
        newRec.ruptureComment
        newRec.amniotic
        newRec.amnioticComment
        newRec.comments
        newRec.labor_id


isMembraneRecordComplete : MembraneRecord -> Bool
isMembraneRecordComplete rec =
    not <|
        ((U.validateReasonableDate True rec.ruptureDatetime)
            || (rec.rupture == Nothing)
            || (rec.amniotic == Nothing)
        )
