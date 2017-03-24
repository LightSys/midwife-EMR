port module Ports
    exposing
        ( adhocResponse
        , createResponse
        , deleteResponse
        , login
        , medicationTypeCreate
        , medicationTypeDelete
        , medicationTypeUpdate
        , requestUserProfile
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


port adhocResponse : (JD.Value -> msg) -> Sub msg


port createResponse : (JD.Value -> msg) -> Sub msg


port deleteResponse : (JD.Value -> msg) -> Sub msg


port selectQueryResponse : (JD.Value -> msg) -> Sub msg


port updateResponse : (JD.Value -> msg) -> Sub msg


port systemMessages : (JD.Value -> msg) -> Sub msg


port userProfile : (JD.Value -> msg) -> Sub msg



-- OUTGOING PORTS


port medicationTypeCreate : JE.Value -> Cmd msg


port medicationTypeDelete : JE.Value -> Cmd msg


port medicationTypeUpdate : JE.Value -> Cmd msg


port searchUser : String -> Cmd msg


port selectQuery : JE.Value -> Cmd msg


port requestUserProfile : JE.Value -> Cmd msg


port login : JE.Value -> Cmd msg



{- :
   port medicationTypeAdd : JE.Value -> Cmd msg
   port medicationTypeDelete : JE.Value -> Cmd msg
-}
