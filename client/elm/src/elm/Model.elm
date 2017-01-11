module Model
    exposing
        ( Model
        , Page(..)
        , Tab(..)
        , initialModel
        , medicationTypeValidate
        , medicationTypeInitialForm
        , State
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

import Types exposing (..)


type alias Model =
    { mdl : Material.Model
    , snackbar : Snackbar.Model String
    , transactions : States
    , selectedTab : Tab
    , selectedPage : Page
    , systemMessages : List SystemMessage
    , userId : Int
    , selectedTable : Maybe Table
    , selectedTableRecord : Int
    , selectedTableEditMode : Bool
    , eventType : RemoteData String (List EventTypeTable)
    , labSuite : RemoteData String (List LabSuiteTable)
    , labTest : RemoteData String (List LabTestTable)
    , labTestValue : RemoteData String (List LabTestValueTable)
    , medicationType : RemoteData String (List MedicationTypeTable)
    , medicationTypeForm : Form () MedicationTypeForm
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


{-| Validation for medicationType.

TODO: Note that there should be no case where the user
is editing the id field, for existing or new records.
Should field be eliminated from here?
-}
type alias MedicationTypeForm =
    { id : Int
    , name : String
    , description : String
    , sortOrder : Int
    }


medicationTypeInitialForm : MedicationTypeTable -> Form () MedicationTypeForm
medicationTypeInitialForm table =
    Form.initial
        [ ( "id", Fld.string <| toString table.id )
        , ( "name", Fld.string table.name )
        , ( "description", Fld.string table.description )
        , ( "sortOrder", Fld.string <| toString table.sortOrder )
        ]
        medicationTypeValidate


medicationTypeValidate : V.Validation () MedicationTypeForm
medicationTypeValidate =
    V.map4 MedicationTypeForm
        (V.field "id" V.int)
        (V.field "name" V.string |> V.andThen V.nonEmpty)
        (V.field "description" V.string |> V.andThen V.nonEmpty)
        (V.field "sortOrder" V.int |> V.andThen (V.minInt 0))


initialModel : Model
initialModel =
    { mdl = Material.model
    , snackbar = Snackbar.model
    , transactions = statesInit
    , selectedTab = HomeTab
    , selectedPage = HomePage
    , systemMessages = []
    , userId = -1
    , selectedTable = Nothing
    , selectedTableRecord = 0
    , selectedTableEditMode = False
    , eventType = NotAsked
    , labSuite = NotAsked
    , labTest = NotAsked
    , labTestValue = NotAsked
    , medicationType = NotAsked
    , medicationTypeForm = Form.initial [] medicationTypeValidate
    , pregnoteType = NotAsked
    , riskCode = NotAsked
    , vaccinationType = NotAsked
    , role = NotAsked
    , user = NotAsked
    }
