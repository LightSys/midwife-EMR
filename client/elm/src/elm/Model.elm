module Model
    exposing
        ( Model
        , Page(..)
        , Tab(..)
        , initialModel
        )

import Material
import RemoteData as RD exposing (RemoteData(..), WebData)


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
    , eventType : WebData (List EventTypeTable)
    , labSuite : WebData (List LabSuiteTable)
    , labTest : WebData (List LabTestTable)
    , labTestValue : WebData (List LabTestValueTable)
    , medicationType : WebData (List MedicationTypeTable)
    , pregnoteType : WebData (List PregnoteTypeTable)
    , riskCode : WebData (List RiskCodeTable)
    , vaccinationType : WebData (List VaccinationTypeTable)
    , role : WebData RoleTable
    , user : WebData UserTable
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
    , userId = -1
    , selectedTab = HomeTab
    , selectedPage = HomePage
    , systemMessages = []
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
