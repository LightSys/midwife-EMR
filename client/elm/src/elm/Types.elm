module Types
    exposing
        ( AddChgDelNotification
        , AdhocResponse
        , adminPages
        , allPages
        , AuthResponse
        , CreateResponse
        , DeleteResponse
        , EditMode(..)
        , emptySystemMessage
        , ErrorCode(..)
        , EventTypeRecord
        , KeyValueForm
        , KeyValueRecord
        , KeyValueType(..)
        , LabSuiteForm
        , LabSuiteRecord
        , LabTestForm
        , LabTestRecord
        , LabTestValueForm
        , LabTestValueRecord
        , LoginForm
        , MedicationTypeForm
        , MedicationTypeRecord
        , notFoundPageDef
        , NotificationSubscription
        , NotificationType(..)
        , NotifySubQualifier(..)
        , Page(..)
        , PageDef
        , PregnoteTypeRecord
        , RiskCodeRecord
        , RoleForm
        , RoleRecord
        , SelectDataForm
        , EditableSelectDataName(..)
        , SelectDataRecord
        , SelectQuery
        , SelectQueryResponse
        , SystemMessage
        , Table(..)
        , TableMetaInfo
        , TableModel
        , TableResponse(..)
        , UpdateResponse
        , UserForm
        , UserProfileForm
        , UserRecord
        , UserSearchForm
        , VaccinationTypeForm
        , VaccinationTypeRecord
        )

import Dict exposing (Dict)
import Form exposing (Form)
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


type Table
    = Unknown
    | CustomField
    | CustomFieldType
    | Event
    | EventType
    | HealthTeaching
    | KeyValue
    | LabSuite
    | LabTest
    | LabTestResult
    | LabTestValue
    | Medication
    | MedicationType
    | Patient
    | Pregnancy
    | PregnancyHistory
    | Pregnote
    | PregnoteType
    | PrenatalExam
    | Priority
    | Risk
    | RiskCode
    | Referral
    | RoFieldsByRole
    | Role
    | Schedule
    | SelectData
    | User
    | Vaccination
    | VaccinationType


type NotificationType
    = AddNotificationType
    | ChgNotificationType
    | DelNotificationType
    | UnknownNotificationType


{-| Pages
-}
type Page
    = PageDefNotFoundPage
    | PageNotFoundPage
    | AdminConfigPage
    | AdminHomePage
    | AdminTablesPage
    | AdminUsersPage
    | ProfilePage
    | ProfileNotLoadedPage


{-| Provides the definition of each Page including the url of the
page, as well as the optional tab and List of tabs for the page.

Note: when using hashes, location needs to be something other than
the empty String or "#".
-}
type alias PageDef =
    { page : Page
    , tab : Maybe Int
    , tabs : Maybe (List ( String, Page ))
    , location : String
    }


{-| This is the PageDef returns by getPageDef whenever the sought
after PageDef is not found in the List of PageDefs that is not Nothing.
-}
notFoundPageDef : PageDef
notFoundPageDef =
    PageDef PageDefNotFoundPage Nothing Nothing "#pagedefnotfound"


{-| List PageDef for the administrator role.
-}
adminPages : List PageDef
adminPages =
    [ PageDef AdminHomePage (Just 0) (Just adminTabs) "#home"
    , PageDef AdminUsersPage (Just 1) (Just adminTabs) "#users"
    , PageDef AdminTablesPage (Just 2) (Just adminTabs) "#lookuptables"
    , PageDef AdminConfigPage (Just 3) (Just adminTabs) "#config"
    , PageDef ProfilePage Nothing (Just adminTabs) "#profile"
    ]


{-| Add pages for various roles here.
-}
allPages : List PageDef
allPages =
    adminPages


{-| List of tabs that the administrator role sees.
-}
adminTabs : List ( String, Page )
adminTabs =
    [ ( "Home", AdminHomePage )
    , ( "Users", AdminUsersPage )
    , ( "Lookup Tables", AdminTablesPage )
    , ( "Configuration", AdminConfigPage )
    ]


type alias TableModel a b =
    { records : RemoteData String (List a)
    , form : Form () b
    , selectedRecordId : Maybe Int
    , editMode : EditMode
    , nextPendingId : Int
    , selectQuery : Maybe SelectQuery
    }


type EditMode
    = EditModeAdd
    | EditModeEdit
    | EditModeView
    | EditModeTable
    | EditModeOther


{-| These correspond to the selectData table's name
field that we allow the user to edit.
-}
type EditableSelectDataName
    = AttendantSDN
    | EducationSDN
    | LocationSDN
    | MaritalStatusSDN
    | PlaceOfBirthSDN
    | ReferralsSDN
    | ReligionSDN
    | TeachingTopicsSDN


type TableResponse
    = KeyValueResp (List KeyValueRecord)
    | LabSuiteResp (List LabSuiteRecord)
    | LabTestResp (List LabTestRecord)
    | LabTestValueResp (List LabTestValueRecord)
    | MedicationTypeResp (List MedicationTypeRecord)
    | RoleResp (List RoleRecord)
    | SelectDataResp (List SelectDataRecord)
    | UserResp (List UserRecord)
    | VaccinationTypeResp (List VaccinationTypeRecord)


type ErrorCode
    = NoErrorCode
    | UnknownErrorCode
    | SessionExpiredErrorCode
    | SqlErrorCode
    | LoginSuccessErrorCode
    | LoginSuccessDifferentUserErrorCode
    | LoginFailErrorCode
    | UserProfileSuccessErrorCode
    | UserProfileFailErrorCode
    | UserProfileUpdateFailErrorCode
    | UserProfileUpdateSuccessErrorCode


type KeyValueType
    = KeyValueText
    | KeyValueList
    | KeyValueInteger
    | KeyValueDecimal
    | KeyValueDate
    | KeyValueBoolean

type alias SelectQuery =
    { table : Table
    , id : Maybe Int
    , patient_id : Maybe Int
    , pregnancy_id : Maybe Int
    }


type alias SelectQueryResponse =
    { table : Table
    , id : Maybe Int
    , patient_id : Maybe Int
    , pregnancy_id : Maybe Int
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    , data : TableResponse
    }


type alias SystemMessage =
    { id : String
    , msgType : String
    , updatedAt : Int
    , workerId : String
    , processedBy : List String
    , systemLog : String
    }


{-| Used when there is an error decoding from JS.
-}
emptySystemMessage : SystemMessage
emptySystemMessage =
    { id = "ERROR"
    , msgType = ""
    , updatedAt = 0
    , workerId = ""
    , processedBy = []
    , systemLog = ""
    }


type alias TableMetaInfo =
    { table : Table
    , name : String
    , desc : String
    }


type alias RoleForm =
    { id : Int
    , name : String
    , description : String
    }


type alias UserForm =
    { id : Int
    , username : String
    , firstname : String
    , lastname : String
    , password : String
    , email : String
    , lang : String
    , shortName : String
    , displayName : String
    , status : Bool
    , note : String
    , isCurrentTeacher : Bool
    , role_id : Int
    }


type alias UserRecord =
    { id : Int
    , username : String
    , firstname : String
    , lastname : String
    , password : String
    , email : String
    , lang : String
    , shortName : String
    , displayName : String
    , status : Bool
    , note : String
    , isCurrentTeacher : Bool
    , role_id : Int
    , stateId : Maybe Int
    }


type alias UserProfileForm =
    { userId : Int
    , username : String
    , firstname : String
    , lastname : String
    , password : String
    , email : String
    , lang : String
    , shortName : String
    , displayName : String
    , role_id : Int
    }


type alias RoleRecord =
    { id : Int
    , name : String
    , description : String
    }


type alias EventTypeRecord =
    { id : Int
    , name : String
    , description : String
    }


type alias KeyValueForm =
    { id : Int
    , kvKey : String
    , kvValue : String
    , description : String
    , valueType : String
    , acceptableValues : String
    , systemOnly : Bool
    }


type alias KeyValueRecord =
    { id : Int
    , kvKey : String
    , kvValue : String
    , description : String
    , valueType : KeyValueType
    , acceptableValues : String
    , systemOnly : Bool
    , stateId : Maybe Int
    }


{-| The category field is intentionally missing from
the form because the user should not see it. The user
edits the name field and we add the category field
on interactions with the server assuming that it is
always the same as the name field.
-}
type alias LabSuiteForm =
    { id : Int
    , name : String
    , description : String
    }


type alias LabSuiteRecord =
    { id : Int
    , name : String
    , description : String
    , category : String
    , stateId : Maybe Int
    }


{-| The labSuite_id field is meant to be read-only
from the perspective of the user.
-}
type alias LabTestForm =
    { id : Int
    , name : String
    , abbrev : String
    , normal : String
    , unit : String
    , minRangeDecimal : String
    , maxRangeDecimal : String
    , minRangeInteger : String
    , maxRangeInteger : String
    , isRange : Bool
    , isText : Bool
    , labSuite_id : Int
    }


type alias LabTestRecord =
    { id : Int
    , name : String
    , abbrev : String
    , normal : String
    , unit : String
    , minRangeDecimal : Maybe Float
    , maxRangeDecimal : Maybe Float
    , minRangeInteger : Maybe Int
    , maxRangeInteger : Maybe Int
    , isRange : Bool
    , isText : Bool
    , labSuite_id : Int
    , stateId : Maybe Int
    }


type alias LabTestValueForm =
    { id : Int
    , value : String
    , labTest_id : Int
    }


type alias LabTestValueRecord =
    { id : Int
    , value : String
    , labTest_id : Int
    , stateId : Maybe Int
    }


type alias LoginForm =
    { username : String
    , password : String
    }


type alias MedicationTypeRecord =
    { id : Int
    , name : String
    , description : String
    , sortOrder : Int
    , stateId : Maybe Int
    }


type alias MedicationTypeForm =
    { id : Int
    , name : String
    , description : String
    , sortOrder : Int
    }


{-| The selectKey field is intentionally missing from
the form because the user should not see it. The user
edits the label field and we add the selectKey field
on interactions with the server assuming that it is
always the same as the label field.
-}
type alias SelectDataForm =
    { id : Int
    , name : String
    , label : String
    , selected : Bool
    }


type alias SelectDataRecord =
    { id : Int
    , name : String
    , selectKey : String
    , label : String
    , selected : Bool
    , stateId : Maybe Int
    }


type alias PregnoteTypeRecord =
    { id : Int
    , name : String
    , description : String
    }


type alias RiskCodeRecord =
    { id : Int
    , name : String
    , riskType : String
    , description : String
    }


type alias UserSearchForm =
    { query : String
    , isAdministrator : Bool
    , isAttending : Bool
    , isClerk : Bool
    , isGuard : Bool
    , isSupervisor : Bool
    , isActive : Bool
    , isInActive : Bool
    }


type alias VaccinationTypeForm =
    { id : Int
    , name : String
    , description : String
    , sortOrder : Int
    }


type alias VaccinationTypeRecord =
    { id : Int
    , name : String
    , description : String
    , sortOrder : Int
    , stateId : Maybe Int
    }


type alias AdhocResponse =
    { adhocType : String
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    }


type alias AuthResponse =
    { adhocType : String
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    , userId : Maybe Int
    , username : Maybe String
    , firstname : Maybe String
    , lastname : Maybe String
    , email : Maybe String
    , lang : Maybe String
    , shortName : Maybe String
    , displayName : Maybe String
    , role_id : Maybe Int
    , roleName : Maybe String
    , isLoggedIn : Bool
    }


type alias UpdateResponse =
    { id : Int
    , table : Table
    , stateId : Int
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    }


type alias CreateResponse =
    { id : Int
    , table : Table
    , pendingId : Int
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    }


type alias DeleteResponse =
    { id : Int
    , table : Table
    , stateId : Int
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    }


{-| Represents what the server is sending to notify us of
data changes that other clients have made.

Note that the fields beyond the first three are optional
and will vary depending upon the table that is changed
because these additional fields are the foreign keys
of the table in question. This means that as we bring on
more tables, we will need to add their foreign keys here.
-}
type alias AddChgDelNotification =
    { notificationType : NotificationType
    , table : Table
    , id : Int
    , foreignKeys : List ( Table, Int )
    }


type NotifySubQualifier
    = NotifySubQualifierNone
    | NotifySubQualifierId Int
    | NotifySubQualifierFK ( Table, Int )


{-| Used to allow a client to register a subscription to
server notifications.

Examples:

- `NotificationSubscription User NotifySubQualifierNone`: Subscribes to all records
from the user table with no additional qualifications.
- `NotificationSubscription Pregnancy (NotifySubQualifierId 2309)`: Subscribes to the
pregnancy table record with the id of 2309.
- `NotificationSubscription Prenatal (NotifiySubQualifierFK ( Pregnancy, 2309 ))`:
Subscribes to any prenatal table records that have a foreign key relationship
to the pregnancy table on id 2309.
-}
type alias NotificationSubscription =
    { table : Table
    , qualifier : NotifySubQualifier
    }
