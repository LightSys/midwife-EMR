port module Ports
    exposing
        ( addResponse
        , changeResponse
        , delResponse
        , medicationTypeAdd
        , medicationTypeDel
        , medicationTypeUpdate
        , selectQuery
        , selectQueryResponse
        , systemMessages
        )

import Json.Decode as JD
import Json.Encode as JE


-- LOCAL IMPORTS

import Encoders exposing (..)
import Types exposing (..)
import Msg exposing (Msg)


-- INCOMING PORTS


port addResponse : (JD.Value -> msg) -> Sub msg


port changeResponse : (JD.Value -> msg) -> Sub msg


port delResponse : (JD.Value -> msg) -> Sub msg


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
