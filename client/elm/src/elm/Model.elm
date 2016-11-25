module Model
    exposing
        ( Model
        , Page(..)
        , Tab(..)
        , initialModel
        )

import Material
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)


type alias Model =
    { mdl : Material.Model
    , selectedTab : Tab
    , selectedPage : Page
    , systemMessages : List SystemMessage
    , userId : Int
    , selectedTable : Maybe Table
    , selectedTableRecord : Int
    , eventType : RemoteData String (List EventTypeTable)
    , labSuite : RemoteData String (List LabSuiteTable)
    , labTest : RemoteData String (List LabTestTable)
    , labTestValue : RemoteData String (List LabTestValueTable)
    , medicationType : RemoteData String (List MedicationTypeTable)
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


initialModel : Model
initialModel =
    { mdl = Material.model
    , selectedTab = HomeTab
    , selectedPage = HomePage
    , systemMessages = []
    , userId = -1
    , selectedTable = Nothing
    , selectedTableRecord = 0
    , eventType = NotAsked
    , labSuite = NotAsked
    , labTest = NotAsked
    , labTestValue = NotAsked
    , medicationType = NotAsked
    , pregnoteType = NotAsked
    , riskCode = NotAsked
    , vaccinationType = NotAsked
    , role = NotAsked
    , user = NotAsked
    }
