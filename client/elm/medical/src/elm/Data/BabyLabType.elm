module Data.BabyLabType
    exposing
        ( BabyLabFields
        , BabyLabFieldType(..)
        , BabyLabTypeId(..)
        , BabyLabTypeRecord
        , babyLabTypeRecord
        , getBabyLabFields
        , getName
        , getType
        )

import Data.Table exposing (Table(..), tableToString)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import List.Extra as LE
import Util as U


type BabyLabTypeId
    = BabyLabTypeId Int


type BabyLabFieldType
    = StringBabyLabFT
    | IntegerBabyLabFT
    | FloatBabyLabFT
    | BoolBabyLabFT
    | InvalidBabyLabFT


type alias BabyLabFields =
    { num : Int
    , name : Maybe String
    , type_ : Maybe BabyLabFieldType
    }

maybeStringToMaybeBabyLabFieldType : Maybe String -> Maybe BabyLabFieldType
maybeStringToMaybeBabyLabFieldType str =
    case str of
        Nothing ->
            Just InvalidBabyLabFT

        Just s ->
            stringToBabyLabFieldType s
                |> Just


stringToBabyLabFieldType : String -> BabyLabFieldType
stringToBabyLabFieldType str =
    case str of
        "String" ->
            StringBabyLabFT

        "Integer" ->
            IntegerBabyLabFT

        "Float" ->
            FloatBabyLabFT

        "Bool" ->
            BoolBabyLabFT

        _ ->
            InvalidBabyLabFT


type alias BabyLabTypeRecord =
    { id : Int
    , name : String
    , description : Maybe String
    , fld1Name : String
    , fld1Type : BabyLabFieldType
    , fld2Name : Maybe String
    , fld2Type : Maybe BabyLabFieldType
    , fld3Name : Maybe String
    , fld3Type : Maybe BabyLabFieldType
    , fld4Name : Maybe String
    , fld4Type : Maybe BabyLabFieldType
    , active : Bool
    }


babyLabTypeRecord : JD.Decoder BabyLabTypeRecord
babyLabTypeRecord =
    JDP.decode BabyLabTypeRecord
        |> JDP.required "id" JD.int
        |> JDP.required "name" JD.string
        |> JDP.required "description" (JD.maybe JD.string)
        |> JDP.required "fld1Name" JD.string
        |> JDP.required "fld1Type" (JD.string |> JD.map stringToBabyLabFieldType)
        |> JDP.required "fld2Name" (JD.maybe JD.string)
        |> JDP.required "fld2Type" (JD.maybe JD.string |> JD.map maybeStringToMaybeBabyLabFieldType)
        |> JDP.required "fld3Name" (JD.maybe JD.string)
        |> JDP.required "fld3Type" (JD.maybe JD.string |> JD.map maybeStringToMaybeBabyLabFieldType)
        |> JDP.required "fld4Name" (JD.maybe JD.string)
        |> JDP.required "fld4Type" (JD.maybe JD.string |> JD.map maybeStringToMaybeBabyLabFieldType)
        |> JDP.required "active" (JD.map (\a -> a == 1) JD.int)


getName : Int -> List BabyLabTypeRecord -> Maybe String
getName id recsList =
    case LE.find (\r -> r.id == id) recsList of
        Just rec ->
            Just rec.name

        Nothing ->
            Nothing

getBabyLabFields : Int -> List BabyLabTypeRecord -> List BabyLabFields
getBabyLabFields id recsList =
    case LE.find (\r -> r.id == id) recsList of
        Just rec ->
            [ BabyLabFields 1 (Just rec.fld1Name) (Just rec.fld1Type)
            , BabyLabFields 2 rec.fld2Name rec.fld2Type
            , BabyLabFields 3 rec.fld3Name rec.fld3Type
            , BabyLabFields 4 rec.fld4Name rec.fld4Type
            ]

        Nothing ->
            []

getType : Int -> Int -> List BabyLabTypeRecord -> Maybe BabyLabFieldType
getType id fldNum recsList =
    case LE.find (\r -> r.id == id) recsList of
        Just rec ->
            case fldNum of
                1 ->
                    Just rec.fld1Type

                2 ->
                    rec.fld2Type

                3 ->
                    rec.fld3Type

                4 ->
                    rec.fld4Type

                _ ->
                    Nothing

        Nothing ->
            Nothing
