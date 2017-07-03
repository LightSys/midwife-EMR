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
            let
                subscription =
                    NotificationSubscription Role NotifySubQualifierNone
            in
                ( MU.mergeById roleTbl roleModel.records
                    |> (\recs -> { roleModel | records = recs })
                    |> MU.setSelectQuery sq
                    |> asRoleModelIn model
                    |> Model.addNotificationSubscription subscription
                , Cmd.none
                )

