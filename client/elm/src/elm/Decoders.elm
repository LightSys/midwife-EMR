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


roleTable : JD.Decoder RoleRecord
roleTable =
    decode RoleRecord
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string


userRecord : JD.Decoder UserRecord
userRecord =
    let
        -- The server sends bools as a 0 or 1 so convert to Bool.
        handleBools :
            Int
            -> String
            -> String
            -> String
            -> String
            -> String
            -> Maybe String
            -> String
            -> Maybe String
            -> Int
            -> String
            -> Int
            -> Int
            -> Maybe Int
            -> UserRecord
        handleBools id username firstname lastname password email lang shortName displayName status note isCurrentTeacher role_id statusId =
            let
                ( statusBool, ictBool ) =
                    ( status == 1, isCurrentTeacher == 1 )
            in
                UserRecord id
                    username
                    firstname
                    lastname
                    password
                    email
                    (Maybe.withDefault "" lang)
                    shortName
                    (Maybe.withDefault "" displayName)
                    statusBool
                    note
                    ictBool
                    role_id
                    Nothing
    in
        decode handleBools
            |> required "id" JD.int
            |> required "username" JD.string
            |> required "firstname" JD.string
            |> required "lastname" JD.string
            |> required "password" JD.string
            |> required "email" JD.string
            |> optional "lang" (JD.maybe JD.string) Nothing
            |> required "shortName" JD.string
            |> optional "displayName" (JD.maybe JD.string) Nothing
            |> required "status" JD.int
            |> required "note" JD.string
            |> required "isCurrentTeacher" JD.int
            |> required "role_id" JD.int
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
                LabSuite ->
                    partialSelectQueryResponse
                        |> required "data" (JD.map LabSuiteResp (JD.list labSuiteTable))

                LabTest ->
                    partialSelectQueryResponse
                        |> required "data" (JD.map LabTestResp (JD.list labTestTable))

                MedicationType ->
                    partialSelectQueryResponse
                        |> required "data" (JD.map MedicationTypeResp (JD.list medicationTypeTable))

                Role ->
                    partialSelectQueryResponse
                        |> required "data" (JD.map RoleResp (JD.list roleTable))

                SelectData ->
                    partialSelectQueryResponse
                        |> required "data" (JD.map SelectDataResp (JD.list selectDataTable))

                User ->
                    partialSelectQueryResponse
                        |> required "data" (JD.map UserResp (JD.list userRecord))

                VaccinationType ->
                    partialSelectQueryResponse
                        |> required "data" (JD.map VaccinationTypeResp (JD.list vaccinationTypeTable))

                _ ->
                    JD.fail <| "selectQueryResponse: Unknown table named " ++ table ++ " returned from server."
    in
        JD.field "table" JD.string
            |> JD.andThen decodeData


decodeSelectQueryResponse : JE.Value -> RemoteData String SelectQueryResponse
decodeSelectQueryResponse payload =
    JD.decodeValue selectQueryResponse payload
        |> RD.fromResult


decodeUserRecord : Maybe String -> Maybe UserRecord
decodeUserRecord payload =
    case payload of
        Just p ->
            case JD.decodeString userRecord p of
                Ok val ->
                    Just val

                Err msg ->
                    let
                        _ =
                            Debug.log "decodeUserRecord" <| toString msg
                    in
                        Nothing

        Nothing ->
            Nothing


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


selectDataTable : JD.Decoder SelectDataRecord
selectDataTable =
    let
        -- The server sends bools as a 0 or 1 so convert to Bool.
        handleBools : Int -> String -> String -> String -> Int -> Maybe Int -> SelectDataRecord
        handleBools id name selectKey label selected stateId =
            let
                isSelected =
                    selected == 1
            in
                SelectDataRecord id name selectKey label isSelected stateId
    in
        decode handleBools
            |> required "id" JD.int
            |> required "name" JD.string
            |> required "selectKey" JD.string
            |> required "label" JD.string
            |> required "selected" JD.int
            |> hardcoded Nothing


decodeSelectDataRecord : Maybe String -> Maybe SelectDataRecord
decodeSelectDataRecord payload =
    case payload of
        Just p ->
            case JD.decodeString selectDataTable p of
                Ok val ->
                    Just val

                Err msg ->
                    Nothing

        Nothing ->
            Nothing


decodeVaccinationTypeRecord : Maybe String -> Maybe VaccinationTypeRecord
decodeVaccinationTypeRecord payload =
    case payload of
        Just p ->
            case JD.decodeString vaccinationTypeTable p of
                Ok val ->
                    Just val

                Err msg ->
                    Nothing

        Nothing ->
            Nothing


vaccinationTypeTable : JD.Decoder VaccinationTypeRecord
vaccinationTypeTable =
    decode VaccinationTypeRecord
        |> required "id" JD.int
        |> required "name" JD.string
        |> required "description" JD.string
        |> required "sortOrder" JD.int
        |> hardcoded Nothing


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

        "ADHOC_USER_PROFILE_RESPONSE" ->
            JD.map AdhocUserProfileResponseMsg userProfileResponse

        "ADHOC_USER_PROFILE_UPDATE_RESPONSE" ->
            JD.map AdhocUserProfileUpdateResponseMsg userProfileUpdateResponse

        _ ->
            JD.map AdhocUnknownMsg <| JD.succeed ("Unknown adhoc message with tag: " ++ tag)


adhocResponse : JD.Decoder AdhocResponseMessage
adhocResponse =
    JD.field "adhocType" JD.string
        |> JD.andThen getDecoderAdhocResponse


loginResponse : JD.Decoder AuthResponse
loginResponse =
    decode AuthResponse
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
        |> optional "roleName" (JD.maybe JD.string) Nothing
        |> required "isLoggedIn" JD.bool


userProfileUpdateResponse : JD.Decoder AdhocResponse
userProfileUpdateResponse =
    decode AdhocResponse
        |> required "adhocType" JD.string
        |> required "success" JD.bool
        |> required "errorCode" decodeErrorCode
        |> required "msg" JD.string


userProfileResponse : JD.Decoder AuthResponse
userProfileResponse =
    decode AuthResponse
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
        |> optional "roleName" (JD.maybe JD.string) Nothing
        |> required "isLoggedIn" JD.bool


decodeAdhocResponse : JE.Value -> AdhocResponseMessage
decodeAdhocResponse payload =
    let
        _ =
            Debug.log "decodeAdhocResponse" <| toString payload
    in
        case JD.decodeValue adhocResponse payload of
            Ok val ->
                val

            Err message ->
                AdhocUnknownMsg message


decodeNotificationType : JD.Decoder NotificationType
decodeNotificationType =
    JD.string |> JD.map U.stringToNotificationType


decodeTableId : JD.Decoder ( Table, Int )
decodeTableId =
    JD.map2 (,)
        (JD.field "table" decodeTable)
        (JD.field "id" JD.int)


{-| The first three fields are what the server always sends
and the others are foreign keys of the table in question, so
they will vary. Will need to add foreign keys here when the
client starts handling other tables.
-}
addChgDelNotification : JD.Decoder AddChgDelNotification
addChgDelNotification =
    decode AddChgDelNotification
        |> required "notificationType" decodeNotificationType
        |> required "table" decodeTable
        |> required "id" JD.int
        |> required "foreignKeys" (JD.list decodeTableId)


decodeAddChgDelNotification : JE.Value -> Maybe AddChgDelNotification
decodeAddChgDelNotification payload =
    let
        _ =
            Debug.log "decodeAddChgDelNotification" <| toString payload
    in
        case JD.decodeValue addChgDelNotification payload of
            Ok val ->
                Just val

            Err msg ->
                let
                    _ =
                        Debug.log "decodeAddChgDelNotification Error" msg
                in
                    Nothing
