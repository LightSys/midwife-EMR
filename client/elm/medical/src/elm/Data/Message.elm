module Data.Message
    exposing
        ( DataNotificationMsg
        , IncomingMessage(..)
        , MsgType(..)
        , decodeIncoming
        , stringToMsgType
        , wrapPayload
        )

-- LOCAL IMPORTS --

import Data.Processing exposing (ProcessId(..))
import Data.SiteMessage exposing (SiteKeyValue(..), SiteMsg, siteMsg)
import Data.SystemMessage exposing (SystemMessageType, systemMessageType)
import Data.Table exposing (Table(..), decodeTable)
import Data.TableRecord as DTR exposing (TableRecord(..), tableRecord)
import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Json.Encode as JE


type MsgType
    = AddMsgType
    | DelMsgType
    | SelectMsgType
    | ChgMsgType
    | AddChgDelType
    | AdhocTouchType
    | AdhocClientConsole


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

        AddChgDelType ->
            "ADD_CHG_DELETE"

        AdhocTouchType ->
            "ADHOC_TOUCH_SESSION"

        AdhocClientConsole ->
            "ADHOC_CLIENT_CONSOLE"


stringToMsgType : String -> Maybe MsgType
stringToMsgType str =
    case str of
        "ADD" ->
            Just AddMsgType

        "DEL" ->
            Just DelMsgType

        "SELECT" ->
            Just SelectMsgType

        "CHG" ->
            Just ChgMsgType

        "ADD_CHG_DELETE" ->
            Just AddChgDelType

        "ADHOC_TOUCH_SESSION" ->
            Just AdhocTouchType

        "ADHOC_CLIENT_CONSOLE" ->
            Just AdhocClientConsole

        _ ->
            Nothing



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
        |> JD.andThen (\table -> JD.field "records" <| DTR.tableRecord table)



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


{-| The optional id allows an errorCode returned
from the server to propogate to be properly handled
downstream in the update.
-}
dataAddMsgResponse : JD.Decoder DataAddMsgResponse
dataAddMsgResponse =
    JDP.decode DataAddMsgResponse
        |> JDP.required "table" decodeTable
        |> JDP.optional "id" JD.int -2
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
        |> JDP.required "response" dataChgMsgResponse


-- Incoming Deletion Data Messages --

type alias DataDelMsg =
    { messageId : Int
    , namespace : String
    , msgType : String
    , version : Int
    , response : DataDelMsgResponse
    }

type alias DataDelMsgResponse =
    { table : Table
    , id : Int
    , success : Bool
    , errorCode : String
    , msg : String
    }

dataDelMsg : JD.Decoder DataDelMsg
dataDelMsg =
    JDP.decode DataDelMsg
        |> JDP.required "messageId" JD.int
        |> JDP.required "namespace" JD.string
        |> JDP.required "msgType" JD.string
        |> JDP.required "version" JD.int
        |> JDP.required "response" dataDelMsgResponse


-- Data Notification Messages --


type NotificationType
    = AddNotificationType
    | ChgNotificationType
    | DelNotificationType
    | UnknownNotificationType


type alias DataNotificationMsg =
    { namespace : String
    , msgType : String
    , payload : DataNotificationPayload
    }


type alias DataNotificationPayload =
    { table : Table
    , id : Int
    , notificationType : NotificationType
    , foreignKeys : List ForeignKeys
    }


type alias ForeignKeys =
    { table : Table
    , id : Int
    }


dataNotificationMsg : JD.Decoder DataNotificationMsg
dataNotificationMsg =
    JDP.decode DataNotificationMsg
        |> JDP.required "namespace" JD.string
        |> JDP.required "msgType" JD.string
        |> JDP.required "payload" dataNotificationPayload


dataNotificationPayload : JD.Decoder DataNotificationPayload
dataNotificationPayload =
    JDP.decode DataNotificationPayload
        |> JDP.required "table" decodeTable
        |> JDP.required "id" JD.int
        |> JDP.required "notificationType" (JD.string |> JD.map stringToNotificationType)
        |> JDP.required "foreignKeys" (JD.list foreignKeys)


foreignKeys : JD.Decoder ForeignKeys
foreignKeys =
    JDP.decode ForeignKeys
        |> JDP.required "table" decodeTable
        |> JDP.required "id" JD.int


stringToNotificationType : String -> NotificationType
stringToNotificationType str =
    case str of
        "DATA_ADD" ->
            AddNotificationType

        "DATA_CHANGE" ->
            ChgNotificationType

        "DATA_DELETE" ->
            DelNotificationType

        _ ->
            let
                _ =
                    Debug.log "Message.stringToNotificationType UnknownNotificationType" str
            in
            UnknownNotificationType


{-| The optional id allows an errorCode returned
from the server to propogate to be properly handled
downstream in the update.
-}
dataChgMsgResponse : JD.Decoder DataChgMsgResponse
dataChgMsgResponse =
    JDP.decode DataChgMsgResponse
        |> JDP.required "table" decodeTable
        |> JDP.optional "id" JD.int -1
        |> JDP.required "success" JD.bool
        |> JDP.required "errorCode" JD.string
        |> JDP.required "msg" JD.string


{-| The optional id allows an errorCode returned
from the server to propogate to be properly handled
downstream in the update.
-}
dataDelMsgResponse : JD.Decoder DataDelMsgResponse
dataDelMsgResponse =
    JDP.decode DataDelMsgResponse
        |> JDP.required "table" decodeTable
        |> JDP.optional "id" JD.int -1
        |> JDP.required "success" JD.bool
        |> JDP.required "errorCode" JD.string
        |> JDP.required "msg" JD.string



-- All Incoming Messages --


type IncomingMessage
    = UnknownMessage String
    | SiteMessage SiteMsg
    | SystemMessage SystemMessageType
    | DataSelectMessage DataSelectMsg
    | DataAddMessage DataAddMsg
    | DataChgMessage DataChgMsg
    | DataDelMessage DataDelMsg
    | DataNotificationMessage DataNotificationMsg


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

        "SYSTEM" ->
            JD.map SystemMessage systemMessageType

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

        "DEL" ->
            JD.map DataDelMessage dataDelMsg

        "ADD_CHG_DELETE" ->
            JD.map DataNotificationMessage dataNotificationMsg

        _ ->
            JD.map DataSelectMessage dataMsg
