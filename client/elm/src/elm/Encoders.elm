module Encoders exposing (..)

import Json.Encode as JE
import Json.Decode.Pipeline exposing (decode, required, requiredAt)


-- LOCAL IMPORTS

import Types exposing (..)
import Utils as U


tableToValue : Table -> JE.Value
tableToValue table =
    JE.string <| U.tableToString table


maybeIntToNegOne : Maybe Int -> JE.Value
maybeIntToNegOne int =
    case int of
        Just i ->
            JE.int i

        Nothing ->
            JE.int -1


selectQueryToValue : SelectQuery -> JE.Value
selectQueryToValue sq =
    JE.object
        [ ( "table", tableToValue sq.table )
        , ( "id", maybeIntToNegOne sq.id )
        , ( "patient_id", maybeIntToNegOne sq.patient_id )
        , ( "pregnancy_id", maybeIntToNegOne sq.pregnancy_id )
        ]


medicationTypeToValue : MedicationTypeRecord -> JE.Value
medicationTypeToValue mt =
    JE.object
        [ ( "id", JE.int mt.id )
        , ( "name", JE.string mt.name )
        , ( "description", JE.string mt.description )
        , ( "sortOrder", JE.int mt.sortOrder )
        , case mt.stateId of
            Just num ->
                ( "stateId", JE.int num )

            Nothing ->
                ( "stateId", JE.null )
        ]


selectDataToValue : SelectDataRecord -> JE.Value
selectDataToValue sd =
    JE.object
        [ ( "id", JE.int sd.id )
        , ( "name", JE.string sd.name )
        , ( "selectKey", JE.string sd.selectKey )
        , ( "label", JE.string sd.label )
        , ( "selected", JE.bool sd.selected )
        , case sd.stateId of
            Just num ->
                ( "stateId", JE.int num )

            Nothing ->
                ( "stateId", JE.null )
        ]


vaccinationTypeToValue : VaccinationTypeRecord -> JE.Value
vaccinationTypeToValue vt =
    JE.object
        [ ( "id", JE.int vt.id )
        , ( "name", JE.string vt.name )
        , ( "description", JE.string vt.description )
        , ( "sortOrder", JE.int vt.sortOrder )
        , case vt.stateId of
            Just num ->
                ( "stateId", JE.int num )

            Nothing ->
                ( "stateId", JE.null )
        ]


userToValue : UserRecord -> JE.Value
userToValue user =
    JE.object
        [ ( "id", JE.int user.id )
        , ( "username", JE.string user.username )
        , ( "firstname", JE.string user.firstname )
        , ( "lastname", JE.string user.lastname )
        , ( "password", JE.string user.password )
        , ( "email", JE.string user.email )
        , ( "lang", JE.string user.lang )
        , ( "shortName", JE.string user.shortName )
        , ( "displayName", JE.string user.displayName )
        , if user.status then
            ( "status", JE.int 1 )
          else
            ( "status", JE.int 0 )
        , ( "note", JE.string user.note )
        , if user.isCurrentTeacher then
            ( "isCurrentTeacher", JE.int 1 )
          else
            ( "isCurrentTeacher", JE.int 0 )
        , ( "role_id", JE.int user.role_id )
        , case user.stateId of
            Just num ->
                ( "stateId", JE.int num )

            Nothing ->
                ( "stateId", JE.null )
        ]


userProfileFormToValue : UserProfileForm -> JE.Value
userProfileFormToValue upForm =
    JE.object
        [ ( "userId", JE.int upForm.userId )
        , ( "username", JE.string upForm.username )
        , ( "firstname", JE.string upForm.firstname )
        , ( "lastname", JE.string upForm.lastname )
        , ( "password", JE.string upForm.password )
        , ( "email", JE.string upForm.email )
        , ( "lang", JE.string upForm.lang )
        , ( "shortName", JE.string upForm.shortName )
        , ( "displayName", JE.string upForm.displayName )
        , ( "role_id", JE.int upForm.role_id )
        ]


loginFormToValue : LoginForm -> JE.Value
loginFormToValue login =
    JE.object
        [ ( "username", JE.string login.username )
        , ( "password", JE.string login.password )
        ]


{-| We don't care what we send to the server.
-}
requestUserProfile : JE.Value
requestUserProfile =
    JE.bool True
