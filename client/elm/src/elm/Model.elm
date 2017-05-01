module Model
    exposing
        ( addNotificationSubscription
        , asMedicationTypeModelIn
        , asRoleModelIn
        , asUserModelIn
        , initialModel
        , loginFormValidate
        , Model
        , setMedicationTypeModel
        , setRoleModel
        , State
        , UserProfile
        , userProfileInitialForm
        , userProfileFormValidate
        , userSearchFormValidate
        )

import Date exposing (Date)
import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import Material
import Material.Snackbar as Snackbar
import RemoteData as RD exposing (RemoteData(..))
import Time exposing (Time)


-- LOCAL IMPORTS

import Models.MedicationType as MedicationType
import Models.Role as Role
import Models.User as User
import Models.Utils as MU
import Types exposing (..)


type alias Model =
    { dataNotificationSubscriptions : List NotificationSubscription
    , eventType : RemoteData String (List EventTypeRecord)
    , labSuite : RemoteData String (List LabSuiteRecord)
    , labTest : RemoteData String (List LabTestRecord)
    , labTestValue : RemoteData String (List LabTestValueRecord)
    , loginForm : Form () LoginForm
    , mdl : Material.Model
    , medicationTypeModel : MedicationType.MedicationTypeModel
    , nextPendingId : Int
    , pregnoteType : RemoteData String (List PregnoteTypeRecord)
    , pageDefs : Maybe (List PageDef)
    , riskCode : RemoteData String (List RiskCodeRecord)
    , role : RemoteData String RoleRecord
    , roleModel : Role.RoleModel
    , selectedPage : Page
    , selectedTableEditMode : EditMode
    , selectedTable : Maybe Table
    , selectedTableRecord : Int
    , snackbar : Snackbar.Model String
    , systemMessages : List SystemMessage
    , transactions : States
    , user : RemoteData String UserRecord
    , userModel : User.UserModel
    , userProfile : Maybe UserProfile
    , userProfileForm : Form () UserProfileForm
    , userSearchForm : Form () UserSearchForm
    , vaccinationType : RemoteData String (List VaccinationTypeRecord)
    }


type alias States =
    { states : List State
    , nextId : Int
    , currentTime : Time
    , expireInterval : Int
    , cleanupInterval : Int
    }


type alias State =
    { id : Int
    , state : String
    , expires : Maybe Date
    }


type alias UserProfile =
    { userId : Int
    , username : String
    , firstname : String
    , lastname : String
    , email : String
    , lang : String
    , shortName : String
    , displayName : String
    , role_id : Int
    , roleName : String
    , isLoggedIn : Bool
    }


initialUserProfile =
    Nothing


statesInit : States
statesInit =
    emptyStates


emptyStates =
    { states = []
    , nextId = 1
    , currentTime = 0
    , expireInterval = 1000
    , cleanupInterval = 1000 * 10
    }


loginFormValidate : V.Validation () LoginForm
loginFormValidate =
    V.map2 LoginForm
        (V.field "username" (V.string |> V.defaultValue "" |> V.andThen V.nonEmpty))
        (V.field "password" (V.string |> V.defaultValue "" |> V.andThen V.nonEmpty))


userProfileInitialForm : UserProfile -> Form () UserProfileForm
userProfileInitialForm profile =
    Form.initial
        [ ( "userid", Fld.string <| toString profile.userId )
        , ( "username", Fld.string profile.username )
        , ( "firstname", Fld.string profile.firstname )
        , ( "lastname", Fld.string profile.lastname )
        , ( "password", Fld.string "" )
        , ( "email", Fld.string profile.email )
        , ( "lang", Fld.string profile.lang )
        , ( "shortName", Fld.string profile.shortName )
        , ( "displayName", Fld.string profile.displayName )
        , ( "role_id", Fld.string <| toString profile.role_id )
        ]
        userProfileFormValidate


optionalString : V.Validation e String
optionalString =
    V.oneOf
        [ V.string
        , V.emptyString
        ]


userProfileFormValidate : V.Validation () UserProfileForm
userProfileFormValidate =
    V.succeed UserProfileForm
        |> V.andMap (V.field "userid" V.int)
        |> V.andMap (V.field "username" V.string |> V.andThen V.nonEmpty)
        |> V.andMap (V.field "firstname" V.string |> V.andThen V.nonEmpty)
        |> V.andMap (V.field "lastname" V.string |> V.andThen V.nonEmpty)
        |> V.andMap (V.field "password" optionalString)
        |> V.andMap (V.field "email" MU.validateOptionalEmail)
        |> V.andMap (V.field "lang" optionalString)
        |> V.andMap (V.field "shortName" optionalString)
        |> V.andMap (V.field "displayName" optionalString)
        |> V.andMap
            (V.field "role_id"
                (V.int
                    |> V.andThen (V.minInt 1)
                    |> V.andThen (V.maxInt 5)
                )
            )


userSearchFormValidate : V.Validation () UserSearchForm
userSearchFormValidate =
    V.map8 UserSearchForm
        (V.field "query" (V.string |> V.defaultValue ""))
        (V.field "isAdministrator" V.bool)
        (V.field "isAttending" V.bool)
        (V.field "isClerk" V.bool)
        (V.field "isGuard" V.bool)
        (V.field "isSupervisor" V.bool)
        (V.field "isActive" V.bool)
        (V.field "isInActive" V.bool)


initialModel : Model
initialModel =
    { dataNotificationSubscriptions = []
    , eventType = NotAsked
    , labSuite = NotAsked
    , labTest = NotAsked
    , labTestValue = NotAsked
    , loginForm = Form.initial [] loginFormValidate
    , mdl = Material.model
    , medicationTypeModel = MedicationType.initialMedicationTypeModel
    , nextPendingId = -1
    , pregnoteType = NotAsked
    , pageDefs = Nothing
    , riskCode = NotAsked
    , role = NotAsked
    , roleModel = Role.initialRoleModel
    , selectedPage = AdminHomePage
    , selectedTableEditMode = EditModeView
    , selectedTable = Nothing
    , selectedTableRecord = 0
    , snackbar = Snackbar.model
    , systemMessages = []
    , transactions = statesInit
    , user = NotAsked
    , userModel = User.initialUserModel
    , userProfile = initialUserProfile
    , userProfileForm = Form.initial [] userProfileFormValidate
    , userSearchForm = Form.initial [] userSearchFormValidate
    , vaccinationType = NotAsked
    }



-- Top-level Setters


{-| Add a subscription to our list of subscriptions, but do not allow
duplicates.

TODO: removeNotificationSubscription
-}
addNotificationSubscription : NotificationSubscription -> Model -> Model
addNotificationSubscription subscription model =
    if List.member subscription model.dataNotificationSubscriptions then
        model
    else
        (\model ->
            { model
                | dataNotificationSubscriptions = subscription :: model.dataNotificationSubscriptions
            }
        )
            model


setMedicationTypeModel : MedicationType.MedicationTypeModel -> Model -> Model
setMedicationTypeModel mtm model =
    (\model -> { model | medicationTypeModel = mtm }) model


asMedicationTypeModelIn : Model -> MedicationType.MedicationTypeModel -> Model
asMedicationTypeModelIn =
    flip setMedicationTypeModel


setRoleModel : Role.RoleModel -> Model -> Model
setRoleModel rm model =
    (\model -> { model | roleModel = rm }) model


asRoleModelIn : Model -> Role.RoleModel -> Model
asRoleModelIn =
    flip setRoleModel


setUserModel : User.UserModel -> Model -> Model
setUserModel um model =
    (\model -> { model | userModel = um }) model


asUserModelIn : Model -> User.UserModel -> Model
asUserModelIn =
    flip setUserModel
