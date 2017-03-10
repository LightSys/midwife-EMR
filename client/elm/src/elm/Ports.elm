port module Ports
    exposing
        ( createResponse
        , deleteResponse
        , medicationTypeAdd
        , medicationTypeDel
        , medicationTypeUpdate
        , selectQuery
        , selectQueryResponse
        , systemMessages
        , updateResponse
        )

import Json.Decode as JD
import Json.Encode as JE


-- LOCAL IMPORTS

import Encoders exposing (..)
import Types exposing (..)
import Msg exposing (Msg)


-- INCOMING PORTS


port createResponse : (JD.Value -> msg) -> Sub msg


port updateResponse : (JD.Value -> msg) -> Sub msg


port deleteResponse : (JD.Value -> msg) -> Sub msg


port selectQueryResponse : (JD.Value -> msg) -> Sub msg


port systemMessages : (JD.Value -> msg) -> Sub msg


-- OUTGOING PORTS


port medicationTypeAdd : JE.Value -> Cmd msg


port medicationTypeDel : JE.Value -> Cmd msg


port medicationTypeUpdate : JE.Value -> Cmd msg


port searchUser : String -> Cmd msg


port selectQuery : JE.Value -> Cmd msg



{- :
   port medicationTypeAdd : JE.Value -> Cmd msg
   port medicationTypeDelete : JE.Value -> Cmd msg
-}
