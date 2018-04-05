module Data.LaborStage3
    exposing
        ( LaborStage3Id(..)
        , LaborStage3Record
        , LaborStage3RecordNew
        , isLaborStage3RecordComplete
        , laborStage3Record
        , laborStage3RecordNewToValue
        , laborStage3RecordNewToLaborStage3Record
        , laborStage3RecordToValue
        , schultzDuncan2String
        , string2SchultzDuncan
        )

import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE


-- LOCAL IMPORTS --

import Util as U


type LaborStage3Id
    = LaborStage3Id Int


type SchultzDuncan
    = Schultz
    | Duncan


schultzDuncan2String : SchultzDuncan -> String
schultzDuncan2String sd =
    case sd of
        Schultz ->
            "Schultz"

        Duncan ->
            "Duncan"


string2SchultzDuncan : String -> Maybe SchultzDuncan
string2SchultzDuncan str =
    case str of
        "Schultz" ->
            Just Schultz

        "Duncan" ->
            Just Duncan

        _ ->
            Nothing


maybeString2SchultzDuncan : Maybe String -> Maybe SchultzDuncan
maybeString2SchultzDuncan str =
    case str of
        Just val ->
            string2SchultzDuncan val

        Nothing ->
            Nothing


{-| Answers the question, is the LaborStage3Record
complete enough to submit to the server? Assumes that
the record was already submitted when the date/time of
the placenta delivery was set, so this pertains to the
remainder of the fields.
-}
isLaborStage3RecordComplete : LaborStage3Record -> Bool
isLaborStage3RecordComplete rec =
    not <|
        ((U.validateDate rec.placentaDatetime)
            || ((not <| Maybe.withDefault False rec.placentaDeliverySpontaneous)
                    && (not <| Maybe.withDefault False rec.placentaDeliveryAMTSL)
                    && (not <| Maybe.withDefault False rec.placentaDeliveryCCT)
                    && (not <| Maybe.withDefault False rec.placentaDeliveryManual)
               )
            || (U.validatePopulatedString rec.maternalPosition)
            || (U.validatePopulatedString rec.placentaShape)
            || (U.validatePopulatedString rec.placentaInsertion)
            || (rec.placentaNumVessels == Nothing)
            || (rec.schultzDuncan == Nothing)
            || (U.validatePopulatedString rec.cotyledons)
            || (U.validatePopulatedString rec.membranes)
        )


type alias LaborStage3Record =
    { id : Int
    , placentaDatetime : Maybe Date
    , placentaDeliverySpontaneous : Maybe Bool
    , placentaDeliveryAMTSL : Maybe Bool
    , placentaDeliveryCCT : Maybe Bool
    , placentaDeliveryManual : Maybe Bool
    , maternalPosition : Maybe String
    , txBloodLoss1 : Maybe String
    , txBloodLoss2 : Maybe String
    , txBloodLoss3 : Maybe String
    , txBloodLoss4 : Maybe String
    , txBloodLoss5 : Maybe String
    , placentaShape : Maybe String
    , placentaInsertion : Maybe String
    , placentaNumVessels : Maybe Int
    , schultzDuncan : Maybe SchultzDuncan
    , cotyledons : Maybe String
    , membranes : Maybe String
    , comments : Maybe String
    , labor_id : Int
    }


type alias LaborStage3RecordNew =
    { placentaDatetime : Maybe Date
    , placentaDeliverySpontaneous : Maybe Bool
    , placentaDeliveryAMTSL : Maybe Bool
    , placentaDeliveryCCT : Maybe Bool
    , placentaDeliveryManual : Maybe Bool
    , maternalPosition : Maybe String
    , txBloodLoss1 : Maybe String
    , txBloodLoss2 : Maybe String
    , txBloodLoss3 : Maybe String
    , txBloodLoss4 : Maybe String
    , txBloodLoss5 : Maybe String
    , placentaShape : Maybe String
    , placentaInsertion : Maybe String
    , placentaNumVessels : Maybe Int
    , schultzDuncan : Maybe SchultzDuncan
    , cotyledons : Maybe String
    , membranes : Maybe String
    , comments : Maybe String
    , labor_id : Int
    }


laborStage3Record : JD.Decoder LaborStage3Record
laborStage3Record =
    JDP.decode LaborStage3Record
        |> JDP.required "id" JD.int
        |> JDP.required "placentaDatetime" (JD.maybe JDE.date)
        |> JDP.required "placentaDeliverySpontaneous" U.maybeIntToMaybeBool
        |> JDP.required "placentaDeliveryAMTSL" U.maybeIntToMaybeBool
        |> JDP.required "placentaDeliveryCCT" U.maybeIntToMaybeBool
        |> JDP.required "placentaDeliveryManual" U.maybeIntToMaybeBool
        |> JDP.required "maternalPosition" (JD.maybe JD.string)
        |> JDP.required "txBloodLoss1" (JD.maybe JD.string)
        |> JDP.required "txBloodLoss2" (JD.maybe JD.string)
        |> JDP.required "txBloodLoss3" (JD.maybe JD.string)
        |> JDP.required "txBloodLoss4" (JD.maybe JD.string)
        |> JDP.required "txBloodLoss5" (JD.maybe JD.string)
        |> JDP.required "placentaShape" (JD.maybe JD.string)
        |> JDP.required "placentaInsertion" (JD.maybe JD.string)
        |> JDP.required "placentaNumVessels" (JD.maybe JD.int)
        |> JDP.required "schultzDuncan" (JD.maybe JD.string |> JD.map maybeString2SchultzDuncan)
        |> JDP.required "cotyledons" (JD.maybe JD.string)
        |> JDP.required "membranes" (JD.maybe JD.string)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "labor_id" JD.int


laborStage3RecordToValue : LaborStage3Record -> JE.Value
laborStage3RecordToValue rec =
    JE.object
        [ ( "table", (JE.string "laborStage3") )
        , ( "data"
          , JE.object
                [ ( "id", (JE.int rec.id) )
                , ( "placentaDatetime", (JEE.maybe U.dateToStringValue rec.placentaDatetime) )
                , ( "placentaDeliverySpontaneous", (U.maybeBoolToMaybeInt rec.placentaDeliverySpontaneous) )
                , ( "placentaDeliveryAMTSL", (U.maybeBoolToMaybeInt rec.placentaDeliveryAMTSL) )
                , ( "placentaDeliveryCCT", (U.maybeBoolToMaybeInt rec.placentaDeliveryCCT) )
                , ( "placentaDeliveryManual", (U.maybeBoolToMaybeInt rec.placentaDeliveryManual) )
                , ( "maternalPosition", (JEE.maybe JE.string rec.maternalPosition) )
                , ( "txBloodLoss1", (JEE.maybe JE.string rec.txBloodLoss1) )
                , ( "txBloodLoss2", (JEE.maybe JE.string rec.txBloodLoss2) )
                , ( "txBloodLoss3", (JEE.maybe JE.string rec.txBloodLoss3) )
                , ( "txBloodLoss4", (JEE.maybe JE.string rec.txBloodLoss4) )
                , ( "txBloodLoss5", (JEE.maybe JE.string rec.txBloodLoss5) )
                , ( "placentaShape", (JEE.maybe JE.string rec.placentaShape) )
                , ( "placentaInsertion", (JEE.maybe JE.string rec.placentaInsertion) )
                , ( "placentaNumVessels", (JEE.maybe JE.int rec.placentaNumVessels) )
                , ( "schultzDuncan", (JEE.maybe (schultzDuncan2String >> JE.string) rec.schultzDuncan) )
                , ( "cotyledons", (JEE.maybe JE.string rec.cotyledons) )
                , ( "membranes", (JEE.maybe JE.string rec.membranes) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "labor_id", (JE.int rec.labor_id) )
                ]
          )
        ]


laborStage3RecordNewToValue : LaborStage3RecordNew -> JE.Value
laborStage3RecordNewToValue rec =
    JE.object
        [ ( "table", (JE.string "laborStage3") )
        , ( "data"
          , JE.object
                [ ( "placentaDatetime", (JEE.maybe U.dateToStringValue rec.placentaDatetime) )
                , ( "placentaDeliverySpontaneous", (U.maybeBoolToMaybeInt rec.placentaDeliverySpontaneous) )
                , ( "placentaDeliveryAMTSL", (U.maybeBoolToMaybeInt rec.placentaDeliveryAMTSL) )
                , ( "placentaDeliveryCCT", (U.maybeBoolToMaybeInt rec.placentaDeliveryCCT) )
                , ( "placentaDeliveryManual", (U.maybeBoolToMaybeInt rec.placentaDeliveryManual) )
                , ( "maternalPosition", (JEE.maybe JE.string rec.maternalPosition) )
                , ( "txBloodLoss1", (JEE.maybe JE.string rec.txBloodLoss1) )
                , ( "txBloodLoss2", (JEE.maybe JE.string rec.txBloodLoss2) )
                , ( "txBloodLoss3", (JEE.maybe JE.string rec.txBloodLoss3) )
                , ( "txBloodLoss4", (JEE.maybe JE.string rec.txBloodLoss4) )
                , ( "txBloodLoss5", (JEE.maybe JE.string rec.txBloodLoss5) )
                , ( "placentaShape", (JEE.maybe JE.string rec.placentaShape) )
                , ( "placentaInsertion", (JEE.maybe JE.string rec.placentaInsertion) )
                , ( "placentaNumVessels", (JEE.maybe JE.int rec.placentaNumVessels) )
                , ( "schultzDuncan", (JEE.maybe (schultzDuncan2String >> JE.string) rec.schultzDuncan) )
                , ( "cotyledons", (JEE.maybe JE.string rec.cotyledons) )
                , ( "membranes", (JEE.maybe JE.string rec.membranes) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "labor_id", (JE.int rec.labor_id) )
                ]
          )
        ]


laborStage3RecordNewToLaborStage3Record : LaborStage3Id -> LaborStage3RecordNew -> LaborStage3Record
laborStage3RecordNewToLaborStage3Record (LaborStage3Id id) ls3new =
    LaborStage3Record id
        ls3new.placentaDatetime
        ls3new.placentaDeliverySpontaneous
        ls3new.placentaDeliveryAMTSL
        ls3new.placentaDeliveryCCT
        ls3new.placentaDeliveryManual
        ls3new.maternalPosition
        ls3new.txBloodLoss1
        ls3new.txBloodLoss2
        ls3new.txBloodLoss3
        ls3new.txBloodLoss4
        ls3new.txBloodLoss5
        ls3new.placentaShape
        ls3new.placentaInsertion
        ls3new.placentaNumVessels
        ls3new.schultzDuncan
        ls3new.cotyledons
        ls3new.membranes
        ls3new.comments
        ls3new.labor_id


