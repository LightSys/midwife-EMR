port module Ports
    exposing
        ( systemMessages
        , searchUser
        , selectQuery
        , eventType
        , labSuite
        , labTest
        , labTestValue
        , medicationType
        , pregnoteType
        , riskCode
        , vaccinationType
        )

import Json.Decode as JD
import Json.Encode as JE


-- LOCAL IMPORTS

import Encoders exposing (..)
import Types exposing (..)
import Msg exposing (Msg)


-- INCOMING PORTS


port systemMessages : (JD.Value -> msg) -> Sub msg


port eventType : (JD.Value -> msg) -> Sub msg


port labSuite : (JD.Value -> msg) -> Sub msg


port labTest : (JD.Value -> msg) -> Sub msg


port labTestValue : (JD.Value -> msg) -> Sub msg


port medicationType : (JD.Value -> msg) -> Sub msg


port pregnoteType : (JD.Value -> msg) -> Sub msg


port riskCode : (JD.Value -> msg) -> Sub msg


port vaccinationType : (JD.Value -> msg) -> Sub msg



-- OUTGOING PORTS


port searchUser : String -> Cmd msg


port selectQuery : JE.Value -> Cmd msg
