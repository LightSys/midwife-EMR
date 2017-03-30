module Model
    exposing
        ( Model
        , UserProfile
        , initialModel
        , State
        , asMedicationTypeModelIn
        , setMedicationTypeModel
        , loginFormValidate
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
import Types exposing (..)


type alias Model =
    { eventType : RemoteData String (List EventTypeRecord)
    , labSuite : RemoteData String (List LabSuiteRecord)
    , labTest : RemoteData String (List LabTestRecord)
    , labTestValue : RemoteData String (List LabTestValueRecord)
    , loginForm : Form () LoginForm
    , mdl : Material.Model
    , medicationTypeModel : MedicationType.MedicationTypeModel
    , nextPendingId : Int
    , pregnoteType : RemoteData String (List PregnoteTypeRecord)
    , riskCode : RemoteData String (List RiskCodeRecord)
    , role : RemoteData String RoleRecord
    , selectedPage : Page
    , selectedTableEditMode : EditMode
    , selectedTable : Maybe Table
    , selectedTableRecord : Int
    , selectedTab : Tab
    , snackbar : Snackbar.Model String
    , systemMessages : List SystemMessage
    , transactions : States
    , user : RemoteData String UserRecord
    , userProfile : Maybe UserProfile
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


initialModel : Model
initialModel =
    { eventType = NotAsked
    , labSuite = NotAsked
    , labTest = NotAsked
    , labTestValue = NotAsked
    , loginForm = Form.initial [] loginFormValidate
    , mdl = Material.model
    , medicationTypeModel = MedicationType.initialMedicationTypeModel
    , nextPendingId = -1
    , pregnoteType = NotAsked
    , riskCode = NotAsked
    , role = NotAsked
    , selectedPage = AdminHomePage
    , selectedTab = HomeTab
    , selectedTableEditMode = EditModeView
    , selectedTable = Nothing
    , selectedTableRecord = 0
    , snackbar = Snackbar.model
    , systemMessages = []
    , transactions = statesInit
    , user = NotAsked
    , userProfile = initialUserProfile
    , vaccinationType = NotAsked
    }



-- Top-level Setters


setMedicationTypeModel : MedicationType.MedicationTypeModel -> Model -> Model
setMedicationTypeModel mtm model =
    (\model -> { model | medicationTypeModel = mtm }) model


asMedicationTypeModelIn : Model -> MedicationType.MedicationTypeModel -> Model
asMedicationTypeModelIn =
    flip setMedicationTypeModel
