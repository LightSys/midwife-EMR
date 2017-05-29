port module Ports
    exposing
        ( addChgDelNotification
        , adhocResponse
        , createResponse
        , deleteResponse
        , login
        , medicationTypeCreate
        , medicationTypeDelete
        , medicationTypeUpdate
        , requestUserProfile
        , selectDataCreate
        , selectDataDelete
        , selectDataUpdate
        , selectQuery
        , selectQueryResponse
        , systemMessages
        , updateResponse
        , userCreate
        , userDelete
        , userUpdate
        , userProfileUpdate
        , vaccinationTypeCreate
        , vaccinationTypeDelete
        , vaccinationTypeUpdate
        )

import Json.Decode as JD
import Json.Encode as JE


-- LOCAL IMPORTS

import Encoders exposing (..)
import Types exposing (..)
import Msg exposing (Msg)


-- INCOMING PORTS


port addChgDelNotification : (JE.Value -> msg) -> Sub msg


port adhocResponse : (JD.Value -> msg) -> Sub msg


port createResponse : (JD.Value -> msg) -> Sub msg


port deleteResponse : (JD.Value -> msg) -> Sub msg


port selectQueryResponse : (JD.Value -> msg) -> Sub msg


port updateResponse : (JD.Value -> msg) -> Sub msg


port systemMessages : (JD.Value -> msg) -> Sub msg


port userProfile : (JD.Value -> msg) -> Sub msg



-- OUTGOING PORTS


port login : JE.Value -> Cmd msg


port medicationTypeCreate : JE.Value -> Cmd msg


port medicationTypeDelete : JE.Value -> Cmd msg


port medicationTypeUpdate : JE.Value -> Cmd msg


port requestUserProfile : JE.Value -> Cmd msg


port selectDataCreate : JE.Value -> Cmd msg


port selectDataDelete : JE.Value -> Cmd msg


port selectDataUpdate : JE.Value -> Cmd msg



port selectQuery : JE.Value -> Cmd msg


port userCreate : JE.Value -> Cmd msg


port userDelete : JE.Value -> Cmd msg


port userUpdate : JE.Value -> Cmd msg


port userProfileUpdate : JE.Value -> Cmd msg


port vaccinationTypeCreate : JE.Value -> Cmd msg


port vaccinationTypeDelete : JE.Value -> Cmd msg


port vaccinationTypeUpdate : JE.Value -> Cmd msg
