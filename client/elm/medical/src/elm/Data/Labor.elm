module Data.Labor
    exposing
        ( getLaborId
        , LaborId(..)
        , LaborRecord
        , laborRecord
        , LaborRecordNew
        , laborRecordNewToLaborRecord
        , laborRecordNewToValue
        , laborRecordToValue
        )

import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE


-- LOCAL IMPORTS --

import Util as U


type LaborId
    = LaborId Int


type alias LaborRecord =
    { id : Int
    , admittanceDate : Date
    , startLaborDate : Date
    , dischargeDate : Maybe Date
    , falseLabor : Bool
    , pos : String
    , fh : Int
    , fht : Int
    , systolic : Int
    , diastolic : Int
    , cr : Int
    , temp : Float
    , comments : Maybe String
    , pregnancy_id : Int
    }


{-| For creating new records hence the lack of certain fields
such as id, dischargeDate, and falseLabor.
-}
type alias LaborRecordNew =
    { admittanceDate : Date
    , startLaborDate : Date
    , pos : String
    , fh : Int
    , fht : Int
    , systolic : Int
    , diastolic : Int
    , cr : Int
    , temp : Float
    , comments : Maybe String
    , pregnancy_id : Int
    }


{-| Decode a LaborRecord from the server.

partof: #SPC-dates-client-decode
-}
laborRecord : JD.Decoder LaborRecord
laborRecord =
    let
        handleBool id ad ld ed fl pos fh fht sys dias cr temp comm pregId =
            let
                falseLabor =
                    fl == 1
            in
                LaborRecord id ad ld ed falseLabor pos fh fht sys dias cr temp comm pregId
    in
        JDP.decode handleBool
            |> JDP.required "id" JD.int
            |> JDP.required "admittanceDate" JDE.date
            |> JDP.required "startLaborDate" JDE.date
            |> JDP.optional "dischargeDate" (JD.maybe JDE.date) Nothing
            |> JDP.required "falseLabor" JD.int
            |> JDP.required "pos" JD.string
            |> JDP.required "fh" JD.int
            |> JDP.required "fht" JD.int
            |> JDP.required "systolic" JD.int
            |> JDP.required "diastolic" JD.int
            |> JDP.required "cr" JD.int
            |> JDP.required "temp" JD.float
            |> JDP.required "comments" (JD.maybe JD.string)
            |> JDP.required "pregnancy_id" JD.int


{-| Encode LaborRecordNew for sending to the server as
a payload object that is ready to be wrapped with wrapPayload.
-}
laborRecordNewToValue : LaborRecordNew -> JE.Value
laborRecordNewToValue rec =
    JE.object
        [ ( "table", (JE.string "labor") )
        , ( "data"
          , JE.object
                [ ( "admittanceDate", (U.dateToStringValue rec.admittanceDate) )
                , ( "startLaborDate", (U.dateToStringValue rec.startLaborDate) )
                , ( "pos", (JE.string rec.pos) )
                , ( "fh", (JE.int rec.fh) )
                , ( "fht", (JE.int rec.fht) )
                , ( "systolic", (JE.int rec.systolic) )
                , ( "diastolic", (JE.int rec.diastolic) )
                , ( "cr", (JE.int rec.cr) )
                , ( "temp", (JE.float rec.temp) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "pregnancy_id", (JE.int rec.pregnancy_id) )
                ]
          )
        ]

{-| Encode LaborRecord for sending to the server as
a payload object that is ready to be wrapped with wrapPayload.
-}
laborRecordToValue : LaborRecord -> JE.Value
laborRecordToValue rec =
    JE.object
        [ ( "table", (JE.string "labor") )
        , ( "data"
          , JE.object
                [ ( "id", (JE.int rec.id) )
                , ( "admittanceDate", (U.dateToStringValue rec.admittanceDate) )
                , ( "startLaborDate", (U.dateToStringValue rec.startLaborDate) )
                , ( "dischargeDate", (U.maybeDateToValue rec.dischargeDate) )
                , ( "falseLabor", (U.boolToInt rec.falseLabor |> JE.int) )
                , ( "pos", (JE.string rec.pos) )
                , ( "fh", (JE.int rec.fh) )
                , ( "fht", (JE.int rec.fht) )
                , ( "systolic", (JE.int rec.systolic) )
                , ( "diastolic", (JE.int rec.diastolic) )
                , ( "cr", (JE.int rec.cr) )
                , ( "temp", (JE.float rec.temp) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "pregnancy_id", (JE.int rec.pregnancy_id) )
                ]
          )
        ]


getLaborId : LaborId -> Int
getLaborId (LaborId id) =
    id


laborRecordNewToLaborRecord : LaborId -> LaborRecordNew -> LaborRecord
laborRecordNewToLaborRecord (LaborId id) lrn =
    LaborRecord id
        lrn.admittanceDate
        lrn.startLaborDate
        Nothing
        False
        lrn.pos
        lrn.fh
        lrn.fht
        lrn.systolic
        lrn.diastolic
        lrn.cr
        lrn.temp
        lrn.comments
        lrn.pregnancy_id
