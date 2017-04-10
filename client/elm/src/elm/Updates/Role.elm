module Updates.Role exposing (roleUpdate)


import Form exposing (Form)


-- LOCAL IMPORTS


import Msg exposing (..)
import Model exposing (..)
import Models.Utils as MU
import Types exposing (..)


roleUpdate : RoleMsg -> Model -> ( Model, Cmd Msg )
roleUpdate msg ({roleModel} as model) =
    case msg of
        ReadResponseRole roleTbl sq ->
            ( roleModel
                |> MU.setRecords roleTbl
                |> MU.setSelectedRecordId (Just 0)
                |> MU.setSelectQuery sq
                |> asRoleModelIn model
            , Cmd.none
            )

