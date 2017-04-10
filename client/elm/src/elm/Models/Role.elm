module Models.Role exposing (..)

import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)
import Models.Utils as MU


type alias RoleModel =
    TableModel RoleRecord RoleForm


initialRoleModel : RoleModel
initialRoleModel =
    { records = NotAsked
    , form = Form.initial [] roleValidate
    , selectedRecordId = Nothing
    , editMode = EditModeTable
    , nextPendingId = -1
    , selectQuery = Nothing
    }



-- VALIDATION


roleInitialForm : RoleRecord -> Form () RoleForm
roleInitialForm roleRecord =
    Form.initial
        [ ( "id", Fld.string <| toString roleRecord.id )
        , ( "name", Fld.string roleRecord.name )
        , ( "description", Fld.string roleRecord.description )
        ]
        roleValidate


roleValidate : V.Validation () RoleForm
roleValidate =
    V.succeed RoleForm
        |> V.andMap (V.field "id" V.int)
        |> V.andMap (V.field "name" V.string |> V.andThen V.nonEmpty)
        |> V.andMap (V.field "description" V.string |> V.andThen V.nonEmpty)


-- Field Access

roleToString : Int -> RoleModel -> String
roleToString roleId roleModel =
    case roleModel.records of
        Success recs ->
            case LE.find (\r -> r.id == roleId) recs of
                Just rec ->
                    rec.name

                Nothing ->
                    ""

        _ ->
            ""

idNameTuples : RoleModel -> List ( Int, String )
idNameTuples roleModel =
    case roleModel.records of
        Success recs ->
            List.map (\r -> (r.id, r.name)) recs

        _ ->
            []
