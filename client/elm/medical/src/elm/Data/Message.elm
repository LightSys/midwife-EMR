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
    = SelectMsgType


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
        SelectMsgType ->
            "SELECT"


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



-- Incoming Data Messages --


type alias DataMsg =
    { messageId : Int
    , namespace : String
    , msgType : String
    , version : Int
    , response : DataMsgResponse
    }


type alias DataMsgResponse =
    { success : Bool
    , errorCode : String
    , msg : String
    , data : List TableRecord
    }


dataMsg : JD.Decoder DataMsg
dataMsg =
    JDP.decode DataMsg
        |> JDP.required "messageId" JD.int
        |> JDP.required "namespace" JD.string
        |> JDP.required "msgType" JD.string
        |> JDP.required "version" JD.int
        |> JDP.required "response" dataMsgResponse


dataMsgResponse : JD.Decoder DataMsgResponse
dataMsgResponse =
    JDP.decode DataMsgResponse
        |> JDP.required "success" JD.bool
        |> JDP.required "errorCode" JD.string
        |> JDP.required "msg" JD.string
        |> JDP.required "data" (JD.list tableRecord)


tableRecord : JD.Decoder TableRecord
tableRecord =
    JD.field "table" decodeTable
        |> JD.andThen (\tableName -> JD.field "records" <| DTR.tableRecord tableName)



-- All Incoming Messages --


type IncomingMessage
    = UnknownMessage String
    | SiteMessage SiteMsg
    | DataMessage DataMsg


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


incomingMessage : JD.Decoder IncomingMessage
incomingMessage =
    let
        decoderIncoming : String -> JD.Decoder IncomingMessage
        decoderIncoming namespace =
            case namespace of
                "SITE" ->
                    JD.map SiteMessage siteMsg

                "DATA" ->
                    JD.map DataMessage dataMsg

                _ ->
                    JD.map (\_ -> UnknownMessage <| "Unknown namespace: " ++ namespace) JD.value
    in
        JD.field "namespace" JD.string
            |> JD.andThen decoderIncoming
