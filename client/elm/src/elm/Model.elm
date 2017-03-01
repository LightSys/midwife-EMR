module Model
    exposing
        ( Model
        , Page(..)
        , Tab(..)
        , initialModel
        , State
        , asMedicationTypeModelIn
        , setMedicationTypeModel
        )

import Date exposing (Date)
import Form exposing (Form)
import Form.Validate as V
import Material
import Material.Snackbar as Snackbar
import RemoteData as RD exposing (RemoteData(..))
import Time exposing (Time)


-- LOCAL IMPORTS

import Models.MedicationType as MedicationType
import Types exposing (..)


type alias Model =
    { mdl : Material.Model
    , snackbar : Snackbar.Model String
    , transactions : States
    , nextPendingId : Int
    , selectedTab : Tab
    , selectedPage : Page
    , systemMessages : List SystemMessage
    , userId : Int
    , selectedTable : Maybe Table
    , selectedTableRecord : Int
    , selectedTableEditMode : EditMode
    , eventType : RemoteData String (List EventTypeTable)
    , labSuite : RemoteData String (List LabSuiteTable)
    , labTest : RemoteData String (List LabTestTable)
    , labTestValue : RemoteData String (List LabTestValueTable)
    , medicationTypeModel : MedicationType.MedicationTypeModel
    , pregnoteType : RemoteData String (List PregnoteTypeTable)
    , riskCode : RemoteData String (List RiskCodeTable)
    , vaccinationType : RemoteData String (List VaccinationTypeTable)
    , role : RemoteData String RoleTable
    , user : RemoteData String UserTable
    }


type Page
    = HomePage
    | UserSearchPage
    | UserEditPage
    | TableMainPage
    | ProfilePage


type Tab
    = HomeTab
    | UserTab
    | TablesTab
    | ProfileTab


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


initialModel : Model
initialModel =
    { mdl = Material.model
    , snackbar = Snackbar.model
    , transactions = statesInit
    , nextPendingId = -1
    , selectedTab = HomeTab
    , selectedPage = HomePage
    , systemMessages = []
    , userId = -1
    , selectedTable = Nothing
    , selectedTableRecord = 0
    , selectedTableEditMode = EditModeView
    , eventType = NotAsked
    , labSuite = NotAsked
    , labTest = NotAsked
    , labTestValue = NotAsked
    , medicationTypeModel = MedicationType.initialMedicationTypeModel
    , pregnoteType = NotAsked
    , riskCode = NotAsked
    , vaccinationType = NotAsked
    , role = NotAsked
    , user = NotAsked
    }

-- Top-level Setters

setMedicationTypeModel : MedicationType.MedicationTypeModel -> Model -> Model
setMedicationTypeModel mtm model =
    (\model -> { model | medicationTypeModel = mtm }) model


asMedicationTypeModelIn : Model -> MedicationType.MedicationTypeModel -> Model
asMedicationTypeModelIn =
    flip setMedicationTypeModel

