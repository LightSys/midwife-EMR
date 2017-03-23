module Decoders exposing (..)

import Json.Decode as JD
import Json.Encode as JE
import Json.Decode.Pipeline
    exposing
        ( decode
        , hardcoded
        , optional
        , optionalAt
        , required
        , requiredAt
        )
import Http
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Msg exposing (..)
import Types exposing (..)
import Utils as U


-- System Messages.


systemMessage : JD.Decoder SystemMessage
systemMessage =
    decode SystemMessage
        |> required "id" JD.string
        |> required "msgType" JD.string
        |> required "updatedAt" JD.int
        |> required "workerId" JD.string
        |> required "processedBy" (JD.list JD.string)
        |> required "systemLog" JD.string


decodeSystemMessage : JE.Value -> SystemMessage
decodeSystemMessage payload =
    case JD.decodeValue systemMessage payload of
        Ok val ->
            val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeSystemMessage decoding error" message
            in
                emptySystemMessage



-- Tables.


eventTypeTable : JD.Decoder EventTypeRecord
eventTypeTable =
    decode EventTypeRecord
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string


labSuiteTable : JD.Decoder LabSuiteRecord
labSuiteTable =
    decode LabSuiteRecord
        |> required "id" JD.int
        |> optional "name" JD.string ""
        |> optional "description" JD.string ""
        |> optional "category" JD.string ""


labTestTable : JD.Decoder LabTestRecord
labTestTable =
    let
        -- The server sends bools as a 0 or 1 so convert to Bool.
        handleBools : Int -> String -> String -> String -> String -> Float -> Float -> Int -> Int -> Int -> Int -> Int -> LabTestRecord
        handleBools id name abbrev normal unit minRangeDecimal maxRangeDecimal minRangeInteger maxRangeInteger isRange isText labSuite_id =
            let
                ( isR, isT ) =
                    ( isRange == 1, isText == 1 )
            in
                LabTestRecord id name abbrev normal unit minRangeDecimal maxRangeDecimal minRangeInteger maxRangeInteger isR isT labSuite_id
    in
        decode handleBools
            |> required "id" JD.int
            |> optional "name" JD.string ""
            |> optional "abbrev" JD.string ""
            |> optional "normal" JD.string ""
            |> optional "unit" JD.string ""
            |> optional "minRangeDecimal" JD.float 0.0
            |> optional "maxRangeDecimal" JD.float 0.0
            |> optional "minRangeInteger" JD.int 0
            |> optional "maxRangeInteger" JD.int 0
            |> optional "isRange" JD.int 0
            |> optional "isText" JD.int 0
            |> required "labSuite_id" JD.int


labTestValueTable : JD.Decoder LabTestValueRecord
labTestValueTable =
    decode LabTestValueRecord
        |> required "id" JD.int
        |> required "value" JD.string
        |> required "labTest_id" JD.int


medicationTypeTable : JD.Decoder MedicationTypeRecord
medicationTypeTable =
    decode MedicationTypeRecord
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string
        |> required "sortOrder" JD.int
        |> hardcoded Nothing


partialSelectQueryResponse : JD.Decoder (TableResponse -> SelectQueryResponse)
partialSelectQueryResponse =
    decode SelectQueryResponse
        |> required "table" decodeTable
        |> required "id" (JD.nullable JD.int)
        |> required "patient_id" (JD.nullable JD.int)
        |> required "pregnancy_id" (JD.nullable JD.int)
        |> required "success" JD.bool
        |> required "errorCode" decodeErrorCode
        |> required "msg" JD.string


selectQueryResponse : JD.Decoder SelectQueryResponse
selectQueryResponse =
    let
        decodeData : String -> JD.Decoder SelectQueryResponse
        decodeData table =
            case U.stringToTable table of
                MedicationType ->
                    partialSelectQueryResponse
                        |> required "data" (JD.map MedicationTypeResp (JD.list medicationTypeTable))

                LabSuite ->
                    partialSelectQueryResponse
                        |> required "data" (JD.map LabSuiteResp (JD.list labSuiteTable))

                LabTest ->
                    partialSelectQueryResponse
                        |> required "data" (JD.map LabTestResp (JD.list labTestTable))

                _ ->
                    JD.fail "Unknown table returned from select."
    in
        JD.field "table" JD.string
            |> JD.andThen decodeData


decodeSelectQueryResponse : JE.Value -> RemoteData String SelectQueryResponse
decodeSelectQueryResponse payload =
    JD.decodeValue selectQueryResponse payload
        |> RD.fromResult


decodeMedicationTypeRecord : Maybe String -> Maybe MedicationTypeRecord
decodeMedicationTypeRecord payload =
    case payload of
        Just p ->
            case JD.decodeString medicationTypeTable p of
                Ok val ->
                    Just val

                Err msg ->
                    Nothing

        Nothing ->
            Nothing


pregnoteTypeTable : JD.Decoder PregnoteTypeRecord
pregnoteTypeTable =
    decode PregnoteTypeRecord
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string


riskCodeTable : JD.Decoder RiskCodeRecord
riskCodeTable =
    decode RiskCodeRecord
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "riskType" JD.string
        |> required "description" JD.string


vaccinationTypeTable : JD.Decoder VaccinationTypeRecord
vaccinationTypeTable =
    decode VaccinationTypeRecord
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string
        |> required "sortOrder" JD.int


decodeTable : JD.Decoder Table
decodeTable =
    JD.string |> JD.map U.stringToTable


decodeErrMessage : JD.Decoder String
decodeErrMessage =
    JD.string |> JD.map U.humanReadableError


decodeErrorCode : JD.Decoder ErrorCode
decodeErrorCode =
    JD.string |> JD.map U.stringToErrorCode


updateResponse : JD.Decoder UpdateResponse
updateResponse =
    decode UpdateResponse
        |> required "id" JD.int
        |> required "table" decodeTable
        |> required "stateId" JD.int
        |> required "success" JD.bool
        |> required "errorCode" decodeErrorCode
        |> required "msg" decodeErrMessage


decodeUpdateResponse : JE.Value -> Maybe UpdateResponse
decodeUpdateResponse payload =
    case JD.decodeValue updateResponse payload of
        Ok val ->
            Just val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeUpdateResponse decoding error" message
            in
                Nothing


createResponse : JD.Decoder CreateResponse
createResponse =
    decode CreateResponse
        |> required "id" JD.int
        |> required "table" decodeTable
        |> required "pendingId" JD.int
        |> required "success" JD.bool
        |> required "errorCode" decodeErrorCode
        |> required "msg" decodeErrMessage


decodeCreateResponse : JE.Value -> Maybe CreateResponse
decodeCreateResponse payload =
    case JD.decodeValue createResponse payload of
        Ok val ->
            Just val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeCreateResponse decoding error" message
            in
                Nothing


deleteResponse : JD.Decoder DeleteResponse
deleteResponse =
    decode DeleteResponse
        |> required "id" JD.int
        |> required "table" decodeTable
        |> required "stateId" JD.int
        |> required "success" JD.bool
        |> required "errorCode" decodeErrorCode
        |> required "msg" decodeErrMessage


decodeDeleteResponse : JE.Value -> Maybe DeleteResponse
decodeDeleteResponse payload =
    case JD.decodeValue deleteResponse payload of
        Ok val ->
            Just val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeDeleteResponse decoding error" message
            in
                Nothing


getDecoderAdhocResponse : String -> JD.Decoder AdhocResponseMessage
getDecoderAdhocResponse tag =
    case tag of
        "ADHOC_LOGIN_RESPONSE" ->
            JD.map AdhocLoginResponseMsg loginResponse

        _ ->
            JD.map AdhocUnknownMsg <| JD.succeed ("Unknown adhoc message with tag: " ++ tag)


adhocResponse : JD.Decoder AdhocResponseMessage
adhocResponse =
    JD.field "adhocType" JD.string
        |> JD.andThen getDecoderAdhocResponse


loginResponse : JD.Decoder LoginResponse
loginResponse =
    decode LoginResponse
        |> required "adhocType" JD.string
        |> required "success" JD.bool
        |> required "errorCode" decodeErrorCode
        |> required "msg" JD.string
        |> optional "userId" (JD.maybe JD.int) Nothing
        |> optional "username" (JD.maybe JD.string) Nothing
        |> optional "firstname" (JD.maybe JD.string) Nothing
        |> optional "lastname" (JD.maybe JD.string) Nothing
        |> optional "email" (JD.maybe JD.string) Nothing
        |> optional "lang" (JD.maybe JD.string) Nothing
        |> optional "shortName" (JD.maybe JD.string) Nothing
        |> optional "displayName" (JD.maybe JD.string) Nothing
        |> optional "role_id" (JD.maybe JD.int) Nothing
        |> required "isLoggedIn" JD.bool


decodeAdhocResponse : JE.Value -> AdhocResponseMessage
decodeAdhocResponse payload =
    case JD.decodeValue adhocResponse payload of
        Ok val ->
            let
                _ =
                    Debug.log "decodeAdhocResponse" <| toString val
            in
                val

        Err message ->
            AdhocUnknownMsg message
