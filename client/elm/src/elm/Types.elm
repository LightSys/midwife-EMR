module Types
    exposing
        ( AddResponse
        , ChangeResponse
        , DelResponse
        , EditMode(..)
        , emptySystemMessage
        , ErrorCode(..)
        , EventTypeRecord
        , LabSuiteRecord
        , LabTestRecord
        , LabTestValueRecord
        , MedicationTypeRecord
        , PregnoteTypeRecord
        , RiskCodeRecord
        , RoleRecord
        , SelectQuery
        , SelectQueryResponse
        , SystemMessage
        , Table(..)
        , TableMetaInfo
        , TableModel
        , TableResponse(..)
        , UserRecord
        , VaccinationTypeRecord
        )

import Form exposing (Form)
import RemoteData as RD exposing (RemoteData(..))


type Table
    = Unknown
    | CustomField
    | CustomFieldType
    | Event
    | EventType
    | HealthTeaching
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


type TableResponse
    = LabSuiteResp (List LabSuiteRecord)
    | LabTestResp (List LabTestRecord)
    | MedicationTypeResp (List MedicationTypeRecord)


type ErrorCode
    = NoErrorCode
    | UnknownErrorCode
    | SessionExpiredErrorCode
    | SqlErrorCode


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
    , roleId : Int
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


type alias LabSuiteRecord =
    { id : Int
    , name : String
    , description : String
    , category : String
    }


type alias LabTestRecord =
    { id : Int
    , name : String
    , abbrev : String
    , normal : String
    , unit : String
    , minRangeDecimal : Float
    , maxRangeDecimal : Float
    , minRangeInteger : Int
    , maxRangeInteger : Int
    , isRange : Bool
    , isText : Bool
    , labSuite_id : Int
    }


type alias LabTestValueRecord =
    { id : Int
    , value : String
    , labTest_id : Int
    }


type alias MedicationTypeRecord =
    { id : Int
    , name : String
    , description : String
    , sortOrder : Int
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


type alias VaccinationTypeRecord =
    { id : Int
    , name : String
    , description : String
    , sortOrder : Int
    }


type alias ChangeResponse =
    { id : Int
    , table : Table
    , stateId : Int
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    }


type alias AddResponse =
    { id : Int
    , table : Table
    , pendingId : Int
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    }


type alias DelResponse =
    { id : Int
    , table : Table
    , stateId : Int
    , success : Bool
    , errorCode : ErrorCode
    , msg : String
    }
