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
        )
import Http
import RemoteData as RD exposing (RemoteData(..))


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


decodeEventTypeTable : JE.Value -> RemoteData String (List EventTypeTable)
decodeEventTypeTable payload =
    JD.decodeValue (JD.list eventTypeDecoder) payload
        |> RD.fromResult


labSuiteDecoder : JD.Decoder LabSuiteTable
labSuiteDecoder =
    decode LabSuiteTable
        |> required "id" JD.int
        |> optional "name" JD.string ""
        |> optional "description" JD.string ""
        |> optional "category" JD.string ""


decodeLabSuiteTable : JE.Value -> RemoteData String (List LabSuiteTable)
decodeLabSuiteTable payload =
    JD.decodeValue (JD.list labSuiteDecoder) payload
        |> RD.fromResult


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


decodeLabTestTable : JE.Value -> RemoteData String (List LabTestTable)
decodeLabTestTable payload =
    JD.decodeValue (JD.list labTestDecoder) payload
        |> RD.fromResult


labTestValueDecoder : JD.Decoder LabTestValueTable
labTestValueDecoder =
    decode LabTestValueTable
        |> required "id" JD.int
        |> required "value" JD.string
        |> required "labTest_id" JD.int


decodeLabTestValueTable : JE.Value -> RemoteData String (List LabTestValueTable)
decodeLabTestValueTable payload =
    JD.decodeValue (JD.list labTestValueDecoder) payload
        |> RD.fromResult


medicationTypeDecoder : JD.Decoder MedicationTypeTable
medicationTypeDecoder =
    decode MedicationTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string
        |> required "sortOrder" JD.int


decodeMedicationTypeTable : JE.Value -> RemoteData String (List MedicationTypeTable)
decodeMedicationTypeTable payload =
    JD.decodeValue (JD.list medicationTypeDecoder) payload
        |> RD.fromResult


pregnoteTypeDecoder : JD.Decoder PregnoteTypeTable
pregnoteTypeDecoder =
    decode PregnoteTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string


decodePregnoteTypeTable : JE.Value -> RemoteData String (List PregnoteTypeTable)
decodePregnoteTypeTable payload =
    JD.decodeValue (JD.list pregnoteTypeDecoder) payload
        |> RD.fromResult


riskCodeDecoder : JD.Decoder RiskCodeTable
riskCodeDecoder =
    decode RiskCodeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "riskType" JD.string
        |> required "description" JD.string


decodeRiskCodeTable : JE.Value -> RemoteData String (List RiskCodeTable)
decodeRiskCodeTable payload =
    JD.decodeValue (JD.list riskCodeDecoder) payload
        |> RD.fromResult


vaccinationTypeDecoder : JD.Decoder VaccinationTypeTable
vaccinationTypeDecoder =
    decode VaccinationTypeTable
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string
        |> required "sortOrder" JD.int


decodeVaccinationTypeTable : JE.Value -> RemoteData String (List VaccinationTypeTable)
decodeVaccinationTypeTable payload =
    JD.decodeValue (JD.list vaccinationTypeDecoder) payload
        |> RD.fromResult
