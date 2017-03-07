module Decoders exposing (..)

import Json.Decode as JD
import Json.Encode as JE
import Json.Decode.Pipeline
    exposing
        ( decode
        , required
        , requiredAt
        , optional
        , optionalAt
        , hardcoded
        )
import Http
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

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


eventTypeTable : JD.Decoder EventTypeTable
eventTypeTable =
    decode EventTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string


decodeEventTypeTable : JE.Value -> RemoteData String (List EventTypeTable)
decodeEventTypeTable payload =
    JD.decodeValue (JD.list eventTypeTable) payload
        |> RD.fromResult


labSuiteTable : JD.Decoder LabSuiteTable
labSuiteTable =
    decode LabSuiteTable
        |> required "id" JD.int
        |> optional "name" JD.string ""
        |> optional "description" JD.string ""
        |> optional "category" JD.string ""


decodeLabSuiteTable : JE.Value -> RemoteData String (List LabSuiteTable)
decodeLabSuiteTable payload =
    JD.decodeValue (JD.list labSuiteTable) payload
        |> RD.fromResult


labTestTable : JD.Decoder LabTestTable
labTestTable =
    let
        -- The server sends bools as a 0 or 1 so convert to Bool.
        handleBools : Int -> String -> String -> String -> String -> Float -> Float -> Int -> Int -> Int -> Int -> Int -> LabTestTable
        handleBools id name abbrev normal unit minRangeDecimal maxRangeDecimal minRangeInteger maxRangeInteger isRange isText labSuite_id =
            let
                ( isR, isT ) =
                    ( isRange == 1, isText == 1 )
            in
                LabTestTable id name abbrev normal unit minRangeDecimal maxRangeDecimal minRangeInteger maxRangeInteger isR isT labSuite_id
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


decodeLabTestTable : JE.Value -> RemoteData String (List LabTestTable)
decodeLabTestTable payload =
    JD.decodeValue (JD.list labTestTable) payload
        |> RD.fromResult


labTestValueTable : JD.Decoder LabTestValueTable
labTestValueTable =
    decode LabTestValueTable
        |> required "id" JD.int
        |> required "value" JD.string
        |> required "labTest_id" JD.int


decodeLabTestValueTable : JE.Value -> RemoteData String (List LabTestValueTable)
decodeLabTestValueTable payload =
    JD.decodeValue (JD.list labTestValueTable) payload
        |> RD.fromResult


medicationTypeTable : JD.Decoder MedicationTypeTable
medicationTypeTable =
    decode MedicationTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string
        |> required "sortOrder" JD.int
        |> hardcoded Nothing


decodeMedicationTypeTable : JE.Value -> RemoteData String (List MedicationTypeTable)
decodeMedicationTypeTable payload =
    JD.decodeValue (JD.list medicationTypeTable) payload
        |> RD.fromResult


decodeMedicationTypeRecord : Maybe String -> Maybe MedicationTypeTable
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


pregnoteTypeTable : JD.Decoder PregnoteTypeTable
pregnoteTypeTable =
    decode PregnoteTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string


decodePregnoteTypeTable : JE.Value -> RemoteData String (List PregnoteTypeTable)
decodePregnoteTypeTable payload =
    JD.decodeValue (JD.list pregnoteTypeTable) payload
        |> RD.fromResult


riskCodeTable : JD.Decoder RiskCodeTable
riskCodeTable =
    decode RiskCodeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "riskType" JD.string
        |> required "description" JD.string


decodeRiskCodeTable : JE.Value -> RemoteData String (List RiskCodeTable)
decodeRiskCodeTable payload =
    JD.decodeValue (JD.list riskCodeTable) payload
        |> RD.fromResult


vaccinationTypeTable : JD.Decoder VaccinationTypeTable
vaccinationTypeTable =
    decode VaccinationTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string
        |> required "sortOrder" JD.int


decodeVaccinationTypeTable : JE.Value -> RemoteData String (List VaccinationTypeTable)
decodeVaccinationTypeTable payload =
    JD.decodeValue (JD.list vaccinationTypeTable) payload
        |> RD.fromResult


decodeTable : JD.Decoder Table
decodeTable =
    JD.string |> JD.map U.stringToTable

decodeErrMessage : JD.Decoder String
decodeErrMessage =
    JD.string |> JD.map U.humanReadableError


changeResponse : JD.Decoder ChangeResponse
changeResponse =
    decode ChangeResponse
        |> required "id" JD.int
        |> required "table" decodeTable
        |> required "stateId" JD.int
        |> required "success" JD.bool
        |> required "msg" decodeErrMessage


decodeChangeResponse : JE.Value -> Maybe ChangeResponse
decodeChangeResponse payload =
    case JD.decodeValue changeResponse payload of
        Ok val ->
            Just val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeChangeResponse decoding error" message
            in
                Nothing


addResponse : JD.Decoder AddResponse
addResponse =
    decode AddResponse
        |> required "id" JD.int
        |> required "table" decodeTable
        |> required "pendingId" JD.int
        |> required "success" JD.bool
        |> required "msg" decodeErrMessage


decodeAddResponse : JE.Value -> Maybe AddResponse
decodeAddResponse payload =
    case JD.decodeValue addResponse payload of
        Ok val ->
            Just val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeAddResponse decoding error" message
            in
                Nothing

delResponse : JD.Decoder DelResponse
delResponse =
    decode DelResponse
        |> required "id" JD.int
        |> required "table" decodeTable
        |> required "stateId" JD.int
        |> required "success" JD.bool
        |> required "msg" decodeErrMessage

decodeDelResponse : JE.Value -> Maybe DelResponse
decodeDelResponse payload =
    case JD.decodeValue delResponse payload of
        Ok val ->
            Just val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeDelResponse decoding error" message
            in
                Nothing
