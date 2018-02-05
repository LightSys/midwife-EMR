module Data.LaborStage1
    exposing
        ( getLaborStage1Id
        , LaborStage1Id(..)
        , LaborStage1Record
        , LaborStage1RecordNew
        , laborStage1Record
        , laborStage1RecordNewToLaborStage1Record
        , laborStage1RecordToValue
        , laborStage1RecordNewToValue
        )

import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE


-- LOCAL IMPORTS --

import Util as U


type LaborStage1Id
    = LaborStage1Id Int


type alias LaborStage1Record =
    { id : Int
    , fullDialation : Maybe Date
    , mobility : Maybe String
    , durationLatent : Maybe Int
    , durationActive : Maybe Int
    , comments : Maybe String
    , labor_id : Int
    }


{-| A new record is the same as the normal
record without the id field.
-}
type alias LaborStage1RecordNew =
    { fullDialation : Maybe Date
    , mobility : Maybe String
    , durationLatent : Maybe Int
    , durationActive : Maybe Int
    , comments : Maybe String
    , labor_id : Int
    }


laborStage1Record : JD.Decoder LaborStage1Record
laborStage1Record =
    JDP.decode LaborStage1Record
        |> JDP.required "id" JD.int
        |> JDP.required "fullDialation" (JD.maybe JDE.date)
        |> JDP.required "mobility" (JD.maybe JD.string)
        |> JDP.required "durationLatent" (JD.maybe JD.int)
        |> JDP.required "durationActive" (JD.maybe JD.int)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "labor_id" JD.int


laborStage1RecordToValue : LaborStage1Record -> JE.Value
laborStage1RecordToValue rec =
    JE.object
        [ ( "table", (JE.string "laborStage1") )
        , ( "data"
          , JE.object
                [ ( "id", (JE.int rec.id) )
                , ( "fullDialation", (JEE.maybe U.dateToStringValue rec.fullDialation) )
                , ( "mobility", (JEE.maybe JE.string rec.mobility) )
                , ( "durationLatent", (JEE.maybe JE.int rec.durationLatent) )
                , ( "durationActive", (JEE.maybe JE.int rec.durationActive) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "labor_id", (JE.int rec.labor_id) )
                ]
          )
        ]


laborStage1RecordNewToValue : LaborStage1RecordNew -> JE.Value
laborStage1RecordNewToValue rec =
    JE.object
        [ ( "table", (JE.string "laborStage1") )
        , ( "data"
          , JE.object
                [ ( "fullDialation", (JEE.maybe U.dateToStringValue rec.fullDialation) )
                , ( "mobility", (JEE.maybe JE.string rec.mobility) )
                , ( "durationLatent", (JEE.maybe JE.int rec.durationLatent) )
                , ( "durationActive", (JEE.maybe JE.int rec.durationActive) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "labor_id", (JE.int rec.labor_id) )
                ]
          )
        ]


laborStage1RecordNewToLaborStage1Record : LaborStage1Id -> LaborStage1RecordNew -> LaborStage1Record
laborStage1RecordNewToLaborStage1Record (LaborStage1Id id) ls1new =
    LaborStage1Record id
        ls1new.fullDialation
        ls1new.mobility
        ls1new.durationLatent
        ls1new.durationActive
        ls1new.comments
        ls1new.labor_id


getLaborStage1Id : LaborStage1Id -> Int
getLaborStage1Id (LaborStage1Id id) =
    id
