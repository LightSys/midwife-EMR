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


changeConfirmation : JD.Decoder ChangeConfirmation
changeConfirmation =
    decode ChangeConfirmation
        |> required "id" JD.int
        |> required "table" JD.string
        |> required "pendingTransaction" JD.int
        |> required "success" JD.bool


decodeChangeConfirmation : JE.Value -> Maybe ChangeConfirmation
decodeChangeConfirmation payload =
    case JD.decodeValue changeConfirmation payload of
        Ok val ->
            Just val

        Err message ->
            let
                _ =
                    Debug.log "Decoders.decodeChangeConfirmation decoding error" message
            in
                Nothing
