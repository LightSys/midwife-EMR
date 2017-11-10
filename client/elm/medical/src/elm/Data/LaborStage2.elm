module Data.LaborStage2
    exposing
        ( getLaborStage2Id
        , isLaborStage2RecordComplete
        , LaborStage2Id(..)
        , LaborStage2Record
        , LaborStage2RecordNew
        , laborStage2Record
        , laborStage2RecordNewToValue
        , laborStage2RecordNewToLaborStage2Record
        , laborStage2RecordToValue
        )

import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE


-- LOCAL IMPORTS --

import Util as U


type LaborStage2Id
    = LaborStage2Id Int


type alias LaborStage2Record =
    { id : Int
    , birthDatetime : Maybe Date
    , birthType : Maybe String
    , birthPosition : Maybe String
    , durationPushing : Maybe Int
    , birthPresentation : Maybe String
    , cordWrap : Maybe Bool
    , cordWrapType : Maybe String
    , deliveryType : Maybe String
    , shoulderDystocia : Maybe Bool
    , shoulderDystociaMinutes : Maybe Int
    , laceration : Maybe Bool
    , episiotomy : Maybe Bool
    , repair : Maybe Bool
    , degree : Maybe String
    , lacerationRepairedBy : Maybe String
    , birthEBL : Maybe Int
    , meconium : Maybe String
    , comments : Maybe String
    , labor_id : Int
    }


isLaborStage2RecordComplete : LaborStage2Record -> Bool
isLaborStage2RecordComplete rec =
    not <|
        ((rec.birthDatetime == Nothing)
            || (rec.birthType == Nothing)
            || (rec.birthPosition == Nothing)
            || (rec.durationPushing == Nothing)
            || (rec.birthPresentation == Nothing)
            || (rec.cordWrap == Just True && rec.cordWrapType == Nothing)
            || (rec.deliveryType == Nothing)
            || (rec.shoulderDystocia == Just True && rec.shoulderDystociaMinutes == Nothing)
            || (rec.laceration == Just True && rec.episiotomy == Nothing)
            || (rec.laceration == Just True && rec.repair == Nothing)
            || (rec.laceration == Just True && rec.degree == Nothing)
            || (rec.laceration == Just True && rec.lacerationRepairedBy == Nothing)
            || (rec.birthEBL == Nothing)
            || (rec.meconium == Nothing)
        )


type alias LaborStage2RecordNew =
    { birthDatetime : Maybe Date
    , birthType : Maybe String
    , birthPosition : Maybe String
    , durationPushing : Maybe Int
    , birthPresentation : Maybe String
    , cordWrap : Maybe Bool
    , cordWrapType : Maybe String
    , deliveryType : Maybe String
    , shoulderDystocia : Maybe Bool
    , shoulderDystociaMinutes : Maybe Int
    , laceration : Maybe Bool
    , episiotomy : Maybe Bool
    , repair : Maybe Bool
    , degree : Maybe String
    , lacerationRepairedBy : Maybe String
    , birthEBL : Maybe Int
    , meconium : Maybe String
    , comments : Maybe String
    , labor_id : Int
    }


laborStage2Record : JD.Decoder LaborStage2Record
laborStage2Record =
    JDP.decode LaborStage2Record
        |> JDP.required "id" JD.int
        |> JDP.required "birthDatetime" (JD.maybe JDE.date)
        |> JDP.required "birthType" (JD.maybe JD.string)
        |> JDP.required "birthPosition" (JD.maybe JD.string)
        |> JDP.required "durationPushing" (JD.maybe JD.int)
        |> JDP.required "birthPresentation" (JD.maybe JD.string)
        |> JDP.required "cordWrap" U.maybeIntToMaybeBool
        |> JDP.required "cordWrapType" (JD.maybe JD.string)
        |> JDP.required "deliveryType" (JD.maybe JD.string)
        |> JDP.required "shoulderDystocia" U.maybeIntToMaybeBool
        |> JDP.required "shoulderDystociaMinutes" (JD.maybe JD.int)
        |> JDP.required "laceration" U.maybeIntToMaybeBool
        |> JDP.required "episiotomy" U.maybeIntToMaybeBool
        |> JDP.required "repair" U.maybeIntToMaybeBool
        |> JDP.required "degree" (JD.maybe JD.string)
        |> JDP.required "lacerationRepairedBy" (JD.maybe JD.string)
        |> JDP.required "birthEBL" (JD.maybe JD.int)
        |> JDP.required "meconium" (JD.maybe JD.string)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "labor_id" JD.int


laborStage2RecordToValue : LaborStage2Record -> JE.Value
laborStage2RecordToValue rec =
    JE.object
        [ ( "table", (JE.string "laborStage2") )
        , ( "data"
          , JE.object
                [ ( "id", (JE.int rec.id) )
                , ( "birthDatetime", (JEE.maybe U.dateToStringValue rec.birthDatetime) )
                , ( "birthType", (JEE.maybe JE.string rec.birthType) )
                , ( "birthPosition", (JEE.maybe JE.string rec.birthPosition) )
                , ( "durationPushing", (JEE.maybe JE.int rec.durationPushing) )
                , ( "birthPresentation", (JEE.maybe JE.string rec.birthPresentation) )
                , ( "cordWrap", (U.maybeBoolToMaybeInt rec.cordWrap) )
                , ( "cordWrapType", (JEE.maybe JE.string rec.cordWrapType) )
                , ( "deliveryType", (JEE.maybe JE.string rec.deliveryType) )
                , ( "shouldDystocia", (U.maybeBoolToMaybeInt rec.shoulderDystocia) )
                , ( "shoulderDystociaMinutes", (JEE.maybe JE.int rec.shoulderDystociaMinutes) )
                , ( "laceration", (U.maybeBoolToMaybeInt rec.laceration) )
                , ( "episiotomy", (U.maybeBoolToMaybeInt rec.episiotomy) )
                , ( "repair", (U.maybeBoolToMaybeInt rec.repair) )
                , ( "degree", (JEE.maybe JE.string rec.degree) )
                , ( "lacerationRepairedBy", (JEE.maybe JE.string rec.lacerationRepairedBy) )
                , ( "birthEBL", (JEE.maybe JE.int rec.birthEBL) )
                , ( "meconium", (JEE.maybe JE.string rec.meconium) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "labor_id", (JE.int rec.labor_id) )
                ]
          )
        ]


laborStage2RecordNewToValue : LaborStage2RecordNew -> JE.Value
laborStage2RecordNewToValue rec =
    JE.object
        [ ( "table", (JE.string "laborStage2") )
        , ( "data"
          , JE.object
                [ ( "birthDatetime", (JEE.maybe U.dateToStringValue rec.birthDatetime) )
                , ( "birthType", (JEE.maybe JE.string rec.birthType) )
                , ( "birthPosition", (JEE.maybe JE.string rec.birthPosition) )
                , ( "durationPushing", (JEE.maybe JE.int rec.durationPushing) )
                , ( "birthPresentation", (JEE.maybe JE.string rec.birthPresentation) )
                , ( "cordWrap", (U.maybeBoolToMaybeInt rec.cordWrap) )
                , ( "cordWrapType", (JEE.maybe JE.string rec.cordWrapType) )
                , ( "deliveryType", (JEE.maybe JE.string rec.deliveryType) )
                , ( "shouldDystocia", (U.maybeBoolToMaybeInt rec.shoulderDystocia) )
                , ( "shoulderDystociaMinutes", (JEE.maybe JE.int rec.shoulderDystociaMinutes) )
                , ( "laceration", (U.maybeBoolToMaybeInt rec.laceration) )
                , ( "episiotomy", (U.maybeBoolToMaybeInt rec.episiotomy) )
                , ( "repair", (U.maybeBoolToMaybeInt rec.repair) )
                , ( "degree", (JEE.maybe JE.string rec.degree) )
                , ( "lacerationRepairedBy", (JEE.maybe JE.string rec.lacerationRepairedBy) )
                , ( "birthEBL", (JEE.maybe JE.int rec.birthEBL) )
                , ( "meconium", (JEE.maybe JE.string rec.meconium) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "labor_id", (JE.int rec.labor_id) )
                ]
          )
        ]


laborStage2RecordNewToLaborStage2Record : LaborStage2Id -> LaborStage2RecordNew -> LaborStage2Record
laborStage2RecordNewToLaborStage2Record (LaborStage2Id id) ls2new =
    LaborStage2Record id
        ls2new.birthDatetime
        ls2new.birthType
        ls2new.birthPosition
        ls2new.durationPushing
        ls2new.birthPresentation
        ls2new.cordWrap
        ls2new.cordWrapType
        ls2new.deliveryType
        ls2new.shoulderDystocia
        ls2new.shoulderDystociaMinutes
        ls2new.laceration
        ls2new.episiotomy
        ls2new.repair
        ls2new.degree
        ls2new.lacerationRepairedBy
        ls2new.birthEBL
        ls2new.meconium
        ls2new.comments
        ls2new.labor_id


getLaborStage2Id : LaborStage2Id -> Int
getLaborStage2Id (LaborStage2Id id) =
    id
