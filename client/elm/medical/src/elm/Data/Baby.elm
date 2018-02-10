module Data.Baby
    exposing
        ( apgarScoreDictToApgarRecordList
        , apgarRecordListToApgarScoreDict
        , apgarRecordToApgarScore
        , apgarScoreToApgarRecord
        , ApgarScore(..)
        , BabyId(..)
        , BabyRecord
        , BabyRecordNew
        , babyRecord
        , babyRecordNewToBabyRecord
        , babyRecordNewToValue
        , babyRecordToValue
        , getBabyId
        , getCustomScoresAsList
        , getScoresAsList
        , getScoreAsStringByMinute
        , isBabyRecordFullyComplete
        , MaleFemale(..)
        , maleFemaleToFullString
        , maleFemaleToString
        , maybeMaleFemaleToString
        , stringToMaleFemale
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


type ApgarScore
    = ApgarScore (Maybe Int) (Maybe Int)


type alias ApgarRecord =
    { minute : Int
    , score : Int
    }


type BabyId
    = BabyId Int


getBabyId : BabyId -> Int
getBabyId (BabyId id) =
    id


type MaleFemale
    = Male
    | Female


maleFemale : JD.Decoder String -> JD.Decoder MaleFemale
maleFemale =
    JD.map stringToMaleFemale


stringToMaleFemale : String -> MaleFemale
stringToMaleFemale str =
    case String.toUpper str of
        "M" ->
            Male

        "MALE" ->
            Male

        "F" ->
            Female

        "FEMALE" ->
            Female

        _ ->
            let
                _ =
                    Debug.log "Data.Baby.stringToMaleFemale" "Error: unknown str of '" ++ str ++ "' encountered."
            in
                Female


maybeMaleFemaleToString : Bool -> Maybe MaleFemale -> String
maybeMaleFemaleToString fullString maleFemale =
    case maleFemale of
        Just mf ->
            if fullString then
                maleFemaleToFullString mf
            else
                maleFemaleToString mf

        Nothing ->
            ""


maleFemaleToFullString : MaleFemale -> String
maleFemaleToFullString mf =
    case mf of
        Male ->
            "Male"

        Female ->
            "Female"


maleFemaleToString : MaleFemale -> String
maleFemaleToString mf =
    case mf of
        Male ->
            "M"

        Female ->
            "F"


type alias BabyRecord =
    { id : Int
    , birthNbr : Int
    , lastname : Maybe String
    , firstname : Maybe String
    , middlename : Maybe String
    , sex : MaleFemale
    , birthWeight : Maybe Int
    , bFedEstablished : Maybe Date
    , nbsDate : Maybe Date
    , nbsResult : Maybe String
    , bcgDate : Maybe Date
    , bulb : Maybe Bool
    , machine : Maybe Bool
    , freeFlowO2 : Maybe Bool
    , chestCompressions : Maybe Bool
    , ppv : Maybe Bool
    , comments : Maybe String
    , labor_id : Int
    , apgarScores : List ApgarRecord
    }


type alias BabyRecordNew =
    { birthNbr : Int
    , lastname : Maybe String
    , firstname : Maybe String
    , middlename : Maybe String
    , sex : MaleFemale
    , birthWeight : Maybe Int
    , bFedEstablished : Maybe Date
    , nbsDate : Maybe Date
    , nbsResult : Maybe String
    , bcgDate : Maybe Date
    , bulb : Maybe Bool
    , machine : Maybe Bool
    , freeFlowO2 : Maybe Bool
    , chestCompressions : Maybe Bool
    , ppv : Maybe Bool
    , comments : Maybe String
    , labor_id : Int
    , apgarScores : List ApgarRecord
    }


babyRecordNewToBabyRecord : BabyId -> BabyRecordNew -> BabyRecord
babyRecordNewToBabyRecord (BabyId id) babyNew =
    BabyRecord id
        babyNew.birthNbr
        babyNew.lastname
        babyNew.firstname
        babyNew.middlename
        babyNew.sex
        babyNew.birthWeight
        babyNew.bFedEstablished
        babyNew.nbsDate
        babyNew.nbsResult
        babyNew.bcgDate
        babyNew.bulb
        babyNew.machine
        babyNew.freeFlowO2
        babyNew.chestCompressions
        babyNew.ppv
        babyNew.comments
        babyNew.labor_id
        babyNew.apgarScores


apgarRecordToValue : ApgarRecord -> JE.Value
apgarRecordToValue rec =
    JE.object
        [ ( "minute", (JE.int rec.minute) )
        , ( "score", (JE.int rec.score) )
        ]


{-| Encode BabyRecordNew for sending to the server as
a payload object that is ready to be wrapped with wrapPayload.

NOTE: we are hard-coding birthNbr to one until we implement the
ability to handle multiple births in this client.
-}
babyRecordNewToValue : BabyRecordNew -> JE.Value
babyRecordNewToValue rec =
    JE.object
        [ ( "table", (JE.string "baby") )
        , ( "data"
          , JE.object
                [ ( "birthNbr", (JE.int 1) )
                , ( "lastname", (JEE.maybe JE.string rec.lastname) )
                , ( "firstname", (JEE.maybe JE.string rec.firstname) )
                , ( "middlename", (JEE.maybe JE.string rec.middlename) )
                , ( "sex", (maleFemaleToString rec.sex |> JE.string) )
                , ( "birthWeight", (JEE.maybe JE.int rec.birthWeight) )
                , ( "bFedEstablished", (JEE.maybe U.dateToStringValue rec.bFedEstablished) )
                , ( "nbsDate", (JEE.maybe U.dateToStringValue rec.nbsDate) )
                , ( "nbsResult", (JEE.maybe JE.string rec.nbsResult) )
                , ( "bcgDate", (JEE.maybe U.dateToStringValue rec.bcgDate) )
                , ( "bulb", (U.maybeBoolToMaybeInt rec.bulb) )
                , ( "machine", (U.maybeBoolToMaybeInt rec.machine) )
                , ( "freeFlowO2", (U.maybeBoolToMaybeInt rec.freeFlowO2) )
                , ( "chestCompressions", (U.maybeBoolToMaybeInt rec.chestCompressions) )
                , ( "ppv", (U.maybeBoolToMaybeInt rec.ppv) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "labor_id", (JE.int rec.labor_id) )
                , ( "apgarScores", (JE.list <| List.map apgarRecordToValue rec.apgarScores) )
                ]
          )
        ]


babyRecordToValue : BabyRecord -> JE.Value
babyRecordToValue rec =
    JE.object
        [ ( "table", (JE.string "baby") )
        , ( "data"
          , JE.object
                [ ( "id", (JE.int rec.id) )
                , ( "birthNbr", (JE.int 1) )
                , ( "lastname", (JEE.maybe JE.string rec.lastname) )
                , ( "firstname", (JEE.maybe JE.string rec.firstname) )
                , ( "middlename", (JEE.maybe JE.string rec.middlename) )
                , ( "sex", (maleFemaleToString rec.sex |> JE.string) )
                , ( "birthWeight", (JEE.maybe JE.int rec.birthWeight) )
                , ( "bFedEstablished", (JEE.maybe U.dateToStringValue rec.bFedEstablished) )
                , ( "nbsDate", (JEE.maybe U.dateToStringValue rec.nbsDate) )
                , ( "nbsResult", (JEE.maybe JE.string rec.nbsResult) )
                , ( "bcgDate", (JEE.maybe U.dateToStringValue rec.bcgDate) )
                , ( "bulb", (U.maybeBoolToMaybeInt rec.bulb) )
                , ( "machine", (U.maybeBoolToMaybeInt rec.machine) )
                , ( "freeFlowO2", (U.maybeBoolToMaybeInt rec.freeFlowO2) )
                , ( "chestCompressions", (U.maybeBoolToMaybeInt rec.chestCompressions) )
                , ( "ppv", (U.maybeBoolToMaybeInt rec.ppv) )
                , ( "comments", (JEE.maybe JE.string rec.comments) )
                , ( "labor_id", (JE.int rec.labor_id) )
                , ( "apgarScores", (JE.list <| List.map apgarRecordToValue rec.apgarScores) )
                ]
          )
        ]


apgarRecord : JD.Decoder ApgarRecord
apgarRecord =
    JDP.decode ApgarRecord
        |> JDP.required "minute" JD.int
        |> JDP.required "score" JD.int


babyRecord : JD.Decoder BabyRecord
babyRecord =
    JDP.decode BabyRecord
        |> JDP.required "id" JD.int
        |> JDP.required "birthNbr" JD.int
        |> JDP.required "lastname" (JD.maybe JD.string)
        |> JDP.required "firstname" (JD.maybe JD.string)
        |> JDP.required "middlename" (JD.maybe JD.string)
        |> JDP.required "sex" (JD.string |> maleFemale)
        |> JDP.required "birthWeight" (JD.maybe JD.int)
        |> JDP.required "bFedEstablished" (JD.maybe JDE.date)
        |> JDP.required "nbsDate" (JD.maybe JDE.date)
        |> JDP.required "nbsResult" (JD.maybe JD.string)
        |> JDP.required "bcgDate" (JD.maybe JDE.date)
        |> JDP.required "bulb" U.maybeIntToMaybeBool
        |> JDP.required "machine" U.maybeIntToMaybeBool
        |> JDP.required "freeFlowO2" U.maybeIntToMaybeBool
        |> JDP.required "chestCompressions" U.maybeIntToMaybeBool
        |> JDP.required "ppv" U.maybeIntToMaybeBool
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "labor_id" JD.int
        |> JDP.required "apgarScores" (JD.list apgarRecord)


{-| Answers the question, is this record complete so that all expected
fields are answered? Rather than looking at the minimal requirements
to be submitted to the server, this is looking at the real completion
of the record when all of the data has been input.
-}
isBabyRecordFullyComplete : BabyRecord -> Bool
isBabyRecordFullyComplete rec =
    not <|
        ((rec.birthNbr <= 0)
            || (U.validatePopulatedString rec.lastname)
            || (U.validatePopulatedString rec.firstname)
            || ((Maybe.withDefault 0 rec.birthWeight) <= 0)
            || (U.validateDate rec.bFedEstablished)
            || (U.validateDate rec.nbsDate)
            || (U.validateDate rec.bcgDate)
        )


apgarScoreDictToApgarRecordList : Dict Int ApgarScore -> List ApgarRecord
apgarScoreDictToApgarRecordList scores =
    Dict.map (\_ s -> apgarScoreToApgarRecord s) scores
        |> Dict.values
        |> List.filterMap (\rec -> rec)


apgarRecordListToApgarScoreDict : List ApgarRecord -> Dict Int ApgarScore
apgarRecordListToApgarScoreDict scores =
    List.map (\rec -> ( rec.minute, apgarRecordToApgarScore rec )) scores
        |> Dict.fromList


apgarRecordToApgarScore : ApgarRecord -> ApgarScore
apgarRecordToApgarScore rec =
    ApgarScore (Just rec.minute) (Just rec.score)


apgarScoreToApgarRecord : ApgarScore -> Maybe ApgarRecord
apgarScoreToApgarRecord (ApgarScore min score) =
    case ( min, score ) of
        ( Just m, Just s ) ->
            if s >= 0 && s <= 10 then
                Just <| ApgarRecord m s
            else
                Nothing

        ( _, _ ) ->
            Nothing


getScoreAsStringByMinute : Int -> Dict Int ApgarScore -> Maybe String
getScoreAsStringByMinute minute scores =
    case Dict.get minute scores of
        Just (ApgarScore min score) ->
            case score of
                Just s ->
                    Just <| toString s

                Nothing ->
                    Just ""

        Nothing ->
            Just ""


getScoresAsList : Dict Int ApgarScore -> List ApgarScore
getScoresAsList scores =
    Dict.values scores


getCustomScoresAsList : Dict Int ApgarScore -> List ApgarScore
getCustomScoresAsList scores =
    Dict.filter (\min _ -> not <| List.member min [ 1, 5, 10 ]) scores
        |> Dict.values
