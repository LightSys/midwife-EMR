module Models.User exposing (..)

import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)
import Models.Utils as MU


type alias UserModel =
    TableModel UserRecord UserForm


initialUserModel : UserModel
initialUserModel =
    { records = NotAsked
    , form = Form.initial [] userValidate
    , selectedRecordId = Nothing
    , editMode = EditModeTable
    , nextPendingId = -1
    , selectQuery = Nothing
    }



-- VALIDATION


userInitialForm : UserRecord -> Form () UserForm
userInitialForm userRecord =
    Form.initial
        [ ( "id", Fld.string <| toString userRecord.id )
        , ( "username", Fld.string userRecord.username )
        , ( "firstname", Fld.string userRecord.firstname )
        , ( "lastname", Fld.string userRecord.lastname )
        , ( "password", Fld.string userRecord.password )
        , ( "email", Fld.string userRecord.email )
        , ( "lang", Fld.string userRecord.lang )
        , ( "shortName", Fld.string userRecord.shortName )
        , ( "displayName", Fld.string userRecord.displayName )
        , ( "status", Fld.bool userRecord.status )
        , ( "note", Fld.string userRecord.note )
        , ( "isCurrentTeacher", Fld.bool userRecord.isCurrentTeacher )
        , ( "role_id", Fld.string <| toString userRecord.role_id )
        ]
        userValidate


userValidate : V.Validation () UserForm
userValidate =
    V.succeed UserForm
        |> V.andMap (V.field "id" V.int)
        |> V.andMap (V.field "username" V.string |> V.andThen V.nonEmpty)
        |> V.andMap (V.field "firstname" V.string |> V.andThen V.nonEmpty)
        |> V.andMap (V.field "lastname" V.string |> V.andThen V.nonEmpty)
        |> V.andMap (V.field "password" V.string |> V.defaultValue "")
        |> V.andMap (V.field "email" MU.validateOptionalEmail)
        |> V.andMap (V.field "lang" V.string |> V.defaultValue "en-US")
        |> V.andMap (V.field "shortName" V.string |> V.defaultValue "")
        |> V.andMap (V.field "displayName" V.string |> V.defaultValue "")
        |> V.andMap (V.field "status" V.bool)
        |> V.andMap (V.field "note" V.string |> V.defaultValue "")
        |> V.andMap (V.field "isCurrentTeacher" V.bool)
        |> V.andMap
            (V.field "role_id"
                (V.int
                    |> V.andThen (V.minInt 1)
                    |> V.andThen (V.maxInt 5)
                )
            )

-- FIELD UPDATES


firstRecord : UserModel -> UserModel
firstRecord userModel =
    moveToRecord (\_ list -> list) List.head userModel


prevRecord : UserModel -> UserModel
prevRecord userModel =
    moveToRecord (\rid list -> LE.takeWhile (\r -> r.id < rid) list) LE.last userModel


nextRecord : UserModel -> UserModel
nextRecord userModel =
    moveToRecord (\rid list -> LE.dropWhile (\r -> r.id <= rid) list) List.head userModel


lastRecord : UserModel -> UserModel
lastRecord userModel =
    moveToRecord (\_ list -> list) LE.last userModel


moveToRecord :
    (Int -> List UserRecord -> List UserRecord)
    -> (List UserRecord -> Maybe UserRecord)
    -> UserModel
    -> UserModel
moveToRecord func1 func2 ({ records, selectedRecordId } as userModel) =
    let
        newId =
            case ( RD.toMaybe records, selectedRecordId ) of
                ( Just recs, Just recId ) ->
                    case
                        List.sortBy .id recs
                            |> func1 recId
                            |> func2
                    of
                        Just rec ->
                            Just rec.id

                        _ ->
                            -- If we came up with an empty list, default to
                            -- the starting record.
                            Just recId

                _ ->
                    Nothing
    in
        MU.setSelectedRecordId newId userModel
            |> populateSelectedTableForm


populateSelectedTableForm : UserModel -> UserModel
populateSelectedTableForm userModel =
    case userModel.records of
        Success data ->
            case userModel.editMode of
                EditModeAdd ->
                    userModel
                        |> MU.setForm
                            (userInitialForm
                                (UserRecord userModel.nextPendingId
                                    ""
                                    ""
                                    ""
                                    ""
                                    ""
                                    ""
                                    ""
                                    ""
                                    True
                                    ""
                                    False
                                    2
                                    Nothing
                                )
                            )
                        |> MU.setNextPendingId (userModel.nextPendingId - 1)

                _ ->
                    case LE.find (\r -> r.id == (Maybe.withDefault 0 userModel.selectedRecordId)) data of
                        Just rec ->
                            userModel
                                |> MU.setForm (userInitialForm rec)

                        Nothing ->
                            userModel

        _ ->
            userModel
