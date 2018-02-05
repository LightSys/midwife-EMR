module Data.MembranesResus
    exposing
        ( Amniotic(..)
        , amnioticToString
        , isMembranesResusRecordComplete
        , maybeAmnioticToString
        , maybeRuptureToString
        , maybeStringToAmniotic
        , maybeStringToRupture
        , MembranesResusId(..)
        , MembranesResusRecord
        , MembranesResusRecordNew
        , membranesResusRecord
        , membranesResusRecordNewToMembranesResusRecord
        , membranesResusRecordNewToValue
        , membranesResusRecordToValue
        , Rupture(..)
        , ruptureToString
        )

import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE


-- LOCAL IMPORTS --

import Util as U


type MembranesResusId
    = MembranesResusId Int


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


type alias MembranesResusRecord =
    { id : Int
    , ruptureDatetime : Maybe Date
    , rupture : Maybe Rupture
    , ruptureComment : Maybe String
    , amniotic : Maybe Amniotic
    , amnioticComment : Maybe String
    , bulb : Maybe Bool
    , machine : Maybe Bool
    , freeFlowO2 : Maybe Bool
    , chestCompressions : Maybe Bool
    , ppv : Maybe Bool
    , comments : Maybe String
    , baby_id : Int
    }


type alias MembranesResusRecordNew =
    { ruptureDatetime : Maybe Date
    , rupture : Maybe Rupture
    , ruptureComment : Maybe String
    , amniotic : Maybe Amniotic
    , amnioticComment : Maybe String
    , bulb : Maybe Bool
    , machine : Maybe Bool
    , freeFlowO2 : Maybe Bool
    , chestCompressions : Maybe Bool
    , ppv : Maybe Bool
    , comments : Maybe String
    , baby_id : Int
    }


membranesResusRecord : JD.Decoder MembranesResusRecord
membranesResusRecord =
    JDP.decode MembranesResusRecord
        |> JDP.required "id" JD.int
        |> JDP.optional "ruptureDatetime" (JD.maybe JDE.date) Nothing
        |> JDP.required "rupture" (JD.maybe JD.string |> JD.map maybeStringToRupture)
        |> JDP.required "ruptureComment" (JD.maybe JD.string)
        |> JDP.required "amniotic" (JD.maybe JD.string |> JD.map maybeStringToAmniotic)
        |> JDP.required "amnioticComment" (JD.maybe JD.string)
        |> JDP.required "bulb" U.maybeIntToMaybeBool
        |> JDP.required "machine" U.maybeIntToMaybeBool
        |> JDP.required "freeFlowO2" U.maybeIntToMaybeBool
        |> JDP.required "chestCompressions" U.maybeIntToMaybeBool
        |> JDP.required "ppv" U.maybeIntToMaybeBool
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "baby_id" JD.int


membranesResusRecordToValue : MembranesResusRecord -> JE.Value
membranesResusRecordToValue rec =
    JE.object
        [ ( "table", (JE.string "membranesResus") )
        , ( "data"
          , JE.object
                [ ( "id", (JE.int rec.id) )
                , ( "ruptureDatetime", (JEE.maybe U.dateToStringValue rec.ruptureDatetime) )
                , ( "rupture", (JEE.maybe (\r -> (JE.string (ruptureToString r))) rec.rupture) )
                , ( "ruptureComment", (JEE.maybe JE.string rec.ruptureComment) )
                , ( "amniotic", (JEE.maybe (\a -> (JE.string (amnioticToString a))) rec.amniotic) )
                , ( "amnioticComment", (JEE.maybe JE.string rec.amnioticComment) )
                , ( "bulb", (U.maybeBoolToMaybeInt rec.bulb) )
                , ( "machine", (U.maybeBoolToMaybeInt rec.machine) )
                , ( "freeFlowO2", (U.maybeBoolToMaybeInt rec.freeFlowO2) )
                , ( "chestCompressions", (U.maybeBoolToMaybeInt rec.chestCompressions) )
                , ( "ppv", (U.maybeBoolToMaybeInt rec.ppv) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "baby_id", (JE.int rec.baby_id) )
                ]
          )
        ]


membranesResusRecordNewToValue : MembranesResusRecordNew -> JE.Value
membranesResusRecordNewToValue rec =
    JE.object
        [ ( "table", (JE.string "membranesResus") )
        , ( "data"
          , JE.object
                [ ( "ruptureDatetime", (JEE.maybe U.dateToStringValue rec.ruptureDatetime) )
                , ( "rupture", (JEE.maybe (\r -> (JE.string (ruptureToString r))) rec.rupture) )
                , ( "ruptureComment", (JEE.maybe JE.string rec.ruptureComment) )
                , ( "amniotic", (JEE.maybe (\a -> (JE.string (amnioticToString a))) rec.amniotic) )
                , ( "amnioticComment", (JEE.maybe JE.string rec.amnioticComment) )
                , ( "bulb", (U.maybeBoolToMaybeInt rec.bulb) )
                , ( "machine", (U.maybeBoolToMaybeInt rec.machine) )
                , ( "freeFlowO2", (U.maybeBoolToMaybeInt rec.freeFlowO2) )
                , ( "chestCompressions", (U.maybeBoolToMaybeInt rec.chestCompressions) )
                , ( "ppv", (U.maybeBoolToMaybeInt rec.ppv) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "baby_id", (JE.int rec.baby_id) )
                ]
          )
        ]


membranesResusRecordNewToMembranesResusRecord : MembranesResusId -> MembranesResusRecordNew -> MembranesResusRecord
membranesResusRecordNewToMembranesResusRecord (MembranesResusId id) newRec =
    MembranesResusRecord id
        newRec.ruptureDatetime
        newRec.rupture
        newRec.ruptureComment
        newRec.amniotic
        newRec.amnioticComment
        newRec.bulb
        newRec.machine
        newRec.freeFlowO2
        newRec.chestCompressions
        newRec.ppv
        newRec.comments
        newRec.baby_id


isMembranesResusRecordComplete : MembranesResusRecord -> Bool
isMembranesResusRecordComplete rec =
    not <|
        ((U.validateDate rec.ruptureDatetime)
            || (rec.rupture == Nothing)
            || (rec.amniotic == Nothing)
        )
