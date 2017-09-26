module Data.Message
    exposing
        ( decodeIncoming
        , IncomingMessage(..)
        , MsgType(..)
        , wrapPayload
        )

import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Json.Encode as JE


-- LOCAL IMPORTS --

import Data.Processing exposing (ProcessId(..))
import Data.SiteMessage exposing (SiteKeyValue(..), SiteMsg, siteMsg)
import Data.Table exposing (decodeTable, Table(..))
import Data.TableRecord as DTR exposing (TableRecord(..), tableRecord)


type MsgType
    = AddMsgType
    | DelMsgType
    | SelectMsgType
    | ChgMsgType


type Namespace
    = DataNamespace
    | SiteNamespace
    | SystemNamespace


{-| Version of the "sub-protocol" that we are using
to exchange messages with the server.
-}
version : Int
version =
    2


msgTypeToString : MsgType -> String
msgTypeToString mt =
    case mt of
        AddMsgType ->
            "ADD"

        DelMsgType ->
            "DEL"

        SelectMsgType ->
            "SELECT"

        ChgMsgType ->
            "CHG"


{-| Wrap a JSON Value in an outer message wrapper
along with the process id and message type associated
with it.
-}
wrapPayload : ProcessId -> MsgType -> JE.Value -> JE.Value
wrapPayload (ProcessId id) msgType payload =
    JE.object
        [ ( "messageId", JE.int id )
        , ( "namespace", JE.string "DATA" )
        , ( "msgType", JE.string <| msgTypeToString msgType )
        , ( "version", JE.int version )
        , ( "payload", payload )
        ]



-- Incoming Select Data Messages --


type alias DataSelectMsg =
    { messageId : Int
    , namespace : String
    , msgType : String
    , version : Int
    , response : DataSelectMsgResponse
    }


type alias DataSelectMsgResponse =
    { success : Bool
    , errorCode : String
    , msg : String
    , data : List TableRecord
    }


dataMsg : JD.Decoder DataSelectMsg
dataMsg =
    JDP.decode DataSelectMsg
        |> JDP.required "messageId" JD.int
        |> JDP.required "namespace" JD.string
        |> JDP.required "msgType" JD.string
        |> JDP.required "version" JD.int
        |> JDP.required "response" dataMsgResponse


dataMsgResponse : JD.Decoder DataSelectMsgResponse
dataMsgResponse =
    JDP.decode DataSelectMsgResponse
        |> JDP.required "success" JD.bool
        |> JDP.required "errorCode" JD.string
        |> JDP.required "msg" JD.string
        |> JDP.required "data" (JD.list tableRecord)


tableRecord : JD.Decoder TableRecord
tableRecord =
    JD.field "table" decodeTable
        |> JD.andThen (\tableName -> JD.field "records" <| DTR.tableRecord tableName)



-- Incoming Add Data Messages --


type alias DataAddMsg =
    { messageId : Int
    , namespace : String
    , msgType : String
    , version : Int
    , response : DataAddMsgResponse
    }


type alias DataAddMsgResponse =
    { table : Table
    , id : Int
    , success : Bool
    , errorCode : String
    , msg : String
    }


dataAddMsg : JD.Decoder DataAddMsg
dataAddMsg =
    JDP.decode DataAddMsg
        |> JDP.required "messageId" JD.int
        |> JDP.required "namespace" JD.string
        |> JDP.required "msgType" JD.string
        |> JDP.required "version" JD.int
        |> JDP.required "response" dataAddMsgResponse


dataAddMsgResponse : JD.Decoder DataAddMsgResponse
dataAddMsgResponse =
    JDP.decode DataAddMsgResponse
        |> JDP.required "table" decodeTable
        |> JDP.required "id" JD.int
        |> JDP.required "success" JD.bool
        |> JDP.required "errorCode" JD.string
        |> JDP.required "msg" JD.string



-- Incoming Change Data Messages --


type alias DataChgMsg =
    { messageId : Int
    , namespace : String
    , msgType : String
    , version : Int
    , response : DataChgMsgResponse
    }


type alias DataChgMsgResponse =
    { table : Table
    , id : Int
    , success : Bool
    , errorCode : String
    , msg : String
    }


dataChgMsg : JD.Decoder DataChgMsg
dataChgMsg =
    JDP.decode DataChgMsg
        |> JDP.required "messageId" JD.int
        |> JDP.required "namespace" JD.string
        |> JDP.required "msgType" JD.string
        |> JDP.required "version" JD.int
        |> JDP.required "response" dataAddMsgResponse


dataChgMsgResponse : JD.Decoder DataChgMsgResponse
dataChgMsgResponse =
    JDP.decode DataChgMsgResponse
        |> JDP.required "table" decodeTable
        |> JDP.required "id" JD.int
        |> JDP.required "success" JD.bool
        |> JDP.required "errorCode" JD.string
        |> JDP.required "msg" JD.string



-- All Incoming Messages --


type IncomingMessage
    = UnknownMessage String
    | SiteMessage SiteMsg
    | DataSelectMessage DataSelectMsg
    | DataAddMessage DataAddMsg
    | DataChgMessage DataChgMsg


decodeIncoming : JE.Value -> IncomingMessage
decodeIncoming payload =
    case JD.decodeValue incomingMessage payload of
        Ok val ->
            val

        Err message ->
            let
                _ =
                    Debug.log "decodeIncoming decoding error" message
            in
                UnknownMessage message


{-| Parse incoming messages.
-}
incomingMessage : JD.Decoder IncomingMessage
incomingMessage =
    JD.field "namespace" JD.string
        |> JD.andThen namespaceHelper


{-| First level, discern the namespace.
-}
namespaceHelper : String -> JD.Decoder IncomingMessage
namespaceHelper namespace =
    case namespace of
        "SITE" ->
            JD.map SiteMessage siteMsg

        "DATA" ->
            JD.field "msgType" JD.string
                |> JD.andThen msgTypeHelper

        _ ->
            JD.map (\_ -> UnknownMessage <| "Unknown namespace: " ++ namespace) JD.value


{-| Second level, discern the msgType.
-}
msgTypeHelper : String -> JD.Decoder IncomingMessage
msgTypeHelper msgType =
    case msgType of
        "SELECT" ->
            JD.map DataSelectMessage dataMsg

        "ADD" ->
            JD.map DataAddMessage dataAddMsg

        "CHG" ->
            JD.map DataChgMessage dataChgMsg

        _ ->
            JD.map DataSelectMessage dataMsg
