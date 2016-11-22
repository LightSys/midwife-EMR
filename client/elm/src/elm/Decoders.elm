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
        , resolveResult
        )
import Http
import RemoteData as RD exposing (RemoteData(..), WebData)


-- LOCAL IMPORTS

import Types exposing (..)


-- System Messages.


systemMessageDecoder : JD.Decoder SystemMessage
systemMessageDecoder =
    decode SystemMessage
        |> required "id" JD.string
        |> required "msgType" JD.string
        |> required "updatedAt" JD.int
        |> required "workerId" JD.string
        |> required "processedBy" (JD.list JD.string)
        |> required "systemLog" JD.string


decodeSystemMessage : JE.Value -> SystemMessage
decodeSystemMessage payload =
    case JD.decodeValue systemMessageDecoder payload of
        Ok val ->
            val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeSystemMessage decoding error" message
            in
                emptySystemMessage



-- Tables.


eventTypeDecoder : JD.Decoder EventTypeTable
eventTypeDecoder =
    decode EventTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string


decodeEventTypeTable : JE.Value -> WebData (List EventTypeTable)
decodeEventTypeTable payload =
    case JD.decodeValue (JD.list eventTypeDecoder) payload of
        Ok val ->
            Success val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeEventTypeTable decoding error" message
            in
                Failure <| Http.UnexpectedPayload message


labSuiteDecoder : JD.Decoder LabSuiteTable
labSuiteDecoder =
    decode LabSuiteTable
        |> required "id" JD.int
        |> optional "name" JD.string ""
        |> optional "description" JD.string ""
        |> optional "category" JD.string ""


decodeLabSuiteTable : JE.Value -> WebData (List LabSuiteTable)
decodeLabSuiteTable payload =
    case JD.decodeValue (JD.list labSuiteDecoder) payload of
        Ok val ->
            Success val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeLabSuiteTable decoding error" message
            in
                Failure <| Http.UnexpectedPayload message


labTestDecoder : JD.Decoder LabTestTable
labTestDecoder =
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


decodeLabTestTable : JE.Value -> WebData (List LabTestTable)
decodeLabTestTable payload =
    case JD.decodeValue (JD.list labTestDecoder) payload of
        Ok val ->
            Success val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeLabTestTable decoding error" message
            in
                Failure <| Http.UnexpectedPayload message


labTestValueDecoder : JD.Decoder LabTestValueTable
labTestValueDecoder =
    decode LabTestValueTable
        |> required "id" JD.int
        |> required "value" JD.string
        |> required "labTest_id" JD.int


decodeLabTestValueTable : JE.Value -> WebData (List LabTestValueTable)
decodeLabTestValueTable payload =
    case JD.decodeValue (JD.list labTestValueDecoder) payload of
        Ok val ->
            Success val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeLabTestValueTable decoding error" message
            in
                Failure <| Http.UnexpectedPayload message


medicationTypeDecoder : JD.Decoder MedicationTypeTable
medicationTypeDecoder =
    decode MedicationTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string
        |> required "sortOrder" JD.int


decodeMedicationTypeTable : JE.Value -> WebData (List MedicationTypeTable)
decodeMedicationTypeTable payload =
    case JD.decodeValue (JD.list medicationTypeDecoder) payload of
        Ok val ->
            Success val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeMedicationTypeTable decoding error" message
            in
                Failure <| Http.UnexpectedPayload message


pregnoteTypeDecoder : JD.Decoder PregnoteTypeTable
pregnoteTypeDecoder =
    decode PregnoteTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string


decodePregnoteTypeTable : JE.Value -> WebData (List PregnoteTypeTable)
decodePregnoteTypeTable payload =
    case JD.decodeValue (JD.list pregnoteTypeDecoder) payload of
        Ok val ->
            Success val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodePregnoteTypeTable decoding error" message
            in
                Failure <| Http.UnexpectedPayload message


riskCodeDecoder : JD.Decoder RiskCodeTable
riskCodeDecoder =
    decode RiskCodeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "riskType" JD.string
        |> required "description" JD.string


decodeRiskCodeTable : JE.Value -> WebData (List RiskCodeTable)
decodeRiskCodeTable payload =
    case JD.decodeValue (JD.list riskCodeDecoder) payload of
        Ok val ->
            Success val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeRiskCodeTable decoding error" message
            in
                Failure <| Http.UnexpectedPayload message


vaccinationTypeDecoder : JD.Decoder VaccinationTypeTable
vaccinationTypeDecoder =
    decode VaccinationTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string
        |> required "sortOrder" JD.int


decodeVaccinationTypeTable : JE.Value -> WebData (List VaccinationTypeTable)
decodeVaccinationTypeTable payload =
    case JD.decodeValue (JD.list vaccinationTypeDecoder) payload of
        Ok val ->
            Success val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeVaccinationTypeTable decoding error" message
            in
                Failure <| Http.UnexpectedPayload message
