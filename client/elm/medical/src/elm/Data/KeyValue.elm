module Data.KeyValue
    exposing
        ( getKeyValueRecordByKey
        , getKeyValueValueByKey
        , KeyValueRecord
        , keyValueRecord
        , KeyValueType(..)
        )


import Data.Table exposing (Table(..), tableToString)
import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import List.Extra as LE
import Util as U


type KeyValueType
    = TextKeyValueType
    | ListKeyValueType
    | IntegerKeyValueType
    | DecimalKeyValueType
    | DateKeyValueType
    | BoolKeyValueType


stringToKeyValueType : String -> KeyValueType
stringToKeyValueType str =
    case str of
        "text" ->
            TextKeyValueType

        "list" ->
            ListKeyValueType

        "integer" ->
            IntegerKeyValueType

        "decimal" ->
            DecimalKeyValueType

        "date" ->
            DateKeyValueType

        "boolean" ->
            BoolKeyValueType

        other ->
            let
                _ =
                    Debug.log "stringToKeyValueType error" <| "Encountered string of " ++ other
            in
            TextKeyValueType

keyValueTypeToString : KeyValueType -> String
keyValueTypeToString kvt =
    case kvt of
        TextKeyValueType ->
            "text"

        ListKeyValueType ->
            "list"

        IntegerKeyValueType ->
            "integer"

        DecimalKeyValueType ->
            "decimal"

        DateKeyValueType ->
            "date"

        BoolKeyValueType ->
            "boolean"

type alias KeyValueRecord =
    { id : Int
    , kvKey : String
    , kvValue : String
    , description : String
    , valueType : KeyValueType
    , acceptableValues : String
    , systemOnly : Bool
    }

keyValueRecord : JD.Decoder KeyValueRecord
keyValueRecord =
    JDP.decode KeyValueRecord
        |> JDP.required "id" JD.int
        |> JDP.required "kvKey" JD.string
        |> JDP.required "kvValue" JD.string
        |> JDP.required "description" JD.string
        |> JDP.required "valueType" (JD.string |> JD.map stringToKeyValueType)
        |> JDP.required "acceptableValues" JD.string
        |> JDP.required "systemOnly" (JD.map (\s -> s == 1) JD.int)


getKeyValueRecordByKey : String -> Dict String KeyValueRecord -> Maybe KeyValueRecord
getKeyValueRecordByKey key recs =
    Dict.get key recs


getKeyValueValueByKey : String -> Dict String KeyValueRecord -> Maybe String
getKeyValueValueByKey key recs =
    Maybe.map .kvValue <| getKeyValueRecordByKey key recs
