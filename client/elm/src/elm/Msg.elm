module Msg
    exposing
        ( Msg(..)
        , AdhocResponseMessage(..)
        , LabSuiteMsg(..)
        , MedicationTypeMsg(..)
        , RoleMsg(..)
        , SelectDataMsg(..)
        , UserMsg(..)
        , UserProfileMsg(..)
        , VaccinationTypeMsg(..)
        )

import Form exposing (Form)
import Material
import Material.Snackbar as Snackbar
import Navigation exposing (Location)
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Model exposing (..)
import Types exposing (..)


type Msg
    = AddChgDelNotificationMessages (Maybe AddChgDelNotification)
    | AddSelectedTable
    | AdhocResponseMessages AdhocResponseMessage
    | CancelSelectedTable
    | CreateResponseMsg (Maybe CreateResponse)
    | DeleteRecord Table Int
    | DeleteResponseMsg (Maybe DeleteResponse)
    | EditSelectedTable
    | EventTypeResponse (RemoteData String (List EventTypeRecord))
    | FirstRecord
    | LabSuiteMessages LabSuiteMsg
    --| LabSuiteResponse (RemoteData String (List LabSuiteRecord))
    | LabTestResponse (RemoteData String (List LabTestRecord))
    | LabTestValueResponse (RemoteData String (List LabTestValueRecord))
    | LastRecord
    | Login
    | LoginFormMsg Form.Msg
    | Mdl (Material.Msg Msg)
    | MedicationTypeMessages MedicationTypeMsg
    | NewSystemMessage SystemMessage
    | NextRecord
    | NoOp
    | PregnoteTypeResponse (RemoteData String (List PregnoteTypeRecord))
    | PreviousRecord
    | RequestUserProfile
    | RiskCodeResponse (RemoteData String (List RiskCodeRecord))
    | RoleMessages RoleMsg
    | SaveSelectedTable
    | SelectDataMessages SelectDataMsg
    | SelectedTableEditMode EditMode (Maybe Int)
    | SelectQueryMsg (List SelectQuery)
    | SelectQueryResponseMsg (RemoteData String SelectQueryResponse)
    | SelectQuerySelectTable Table (List SelectQuery)
    | SelectTableRecord Int
    | SelectPage Page
    | SessionExpired
    | Snackbar (Snackbar.Msg String)
    | UpdateResponseMsg (Maybe UpdateResponse)
    | UrlChange Location
    | UserChoiceSet String String
    | UserChoiceUnset String
    | UserMessages UserMsg
    | UserProfileMessages UserProfileMsg
    | VaccinationTypeMessages VaccinationTypeMsg
    | VaccinationTypeResponse (RemoteData String (List VaccinationTypeRecord))


type MedicationTypeMsg
    = CancelEditMedicationType
    | CreateMedicationType
    | CreateResponseMedicationType CreateResponse
    | DeleteMedicationType (Maybe Int)
    | DeleteResponseMedicationType DeleteResponse
    | FirstMedicationType
    | FormMsgMedicationType Form.Msg
    | LastMedicationType
    | NextMedicationType
    | PrevMedicationType
    | ReadResponseMedicationType (RemoteData String (List MedicationTypeRecord)) (Maybe SelectQuery)
    | SelectedRecordEditModeMedicationType EditMode (Maybe Int)
    | SelectedRecordMedicationType (Maybe Int)
    | UpdateMedicationType
    | UpdateResponseMedicationType UpdateResponse


type SelectDataMsg
    = CancelEditSelectData
    | CreateSelectData
    | CreateResponseSelectData CreateResponse
    | DeleteSelectData (Maybe Int)
    | DeleteResponseSelectData DeleteResponse
    | FormMsgSelectData Form.Msg
    | ReadResponseSelectData (RemoteData String (List SelectDataRecord)) (Maybe SelectQuery)
    | SelectedRecordEditModeSelectData EditMode (Maybe Int) (Maybe String)
    | SelectedRecordSelectData (Maybe Int)
    | UpdateSelectData
    | UpdateResponseSelectData UpdateResponse

type LabSuiteMsg
    = CancelEditLabSuite
    | CreateLabSuite
    | CreateResponseLabSuite CreateResponse
    | DeleteLabSuite (Maybe Int)
    | DeleteResponseLabSuite DeleteResponse
    | FormMsgLabSuite Form.Msg
    | ReadResponseLabSuite (RemoteData String (List LabSuiteRecord)) (Maybe SelectQuery)
    | SelectedRecordEditModeLabSuite EditMode (Maybe Int)
    | UpdateLabSuite
    | UpdateResponseLabSuite UpdateResponse

type VaccinationTypeMsg
    = CancelEditVaccinationType
    | CreateVaccinationType
    | CreateResponseVaccinationType CreateResponse
    | DeleteVaccinationType (Maybe Int)
    | DeleteResponseVaccinationType DeleteResponse
    | FirstVaccinationType
    | FormMsgVaccinationType Form.Msg
    | LastVaccinationType
    | NextVaccinationType
    | PrevVaccinationType
    | ReadResponseVaccinationType (RemoteData String (List VaccinationTypeRecord)) (Maybe SelectQuery)
    | SelectedRecordEditModeVaccinationType EditMode (Maybe Int)
    | SelectedRecordVaccinationType (Maybe Int)
    | UpdateVaccinationType
    | UpdateResponseVaccinationType UpdateResponse


type AdhocResponseMessage
    = AdhocUnknownMsg String
    | AdhocLoginResponseMsg AuthResponse
    | AdhocUserProfileResponseMsg AuthResponse
    | AdhocUserProfileUpdateResponseMsg AdhocResponse


type RoleMsg
    = ReadResponseRole (RemoteData String (List RoleRecord)) (Maybe SelectQuery)


type UserProfileMsg
    = FormMsgUserProfile Form.Msg
    | UpdateUserProfile


type UserMsg
    = CancelEditUser
    | CreateResponseUser CreateResponse
    | CreateUser
    | CreateUserForm
    | DeleteResponseUser DeleteResponse
    | DeleteUser (Maybe Int)
    | FirstUser
    | FormMsgUser Form.Msg
    | FormMsgUserSearch Form.Msg
    | LastUser
    | NextUser
    | PrevUser
    | ReadResponseUser (RemoteData String (List UserRecord)) (Maybe SelectQuery)
    | SelectedRecordEditModeUser EditMode (Maybe Int)
    | UpdateResponseUser UpdateResponse
    | UpdateUser
