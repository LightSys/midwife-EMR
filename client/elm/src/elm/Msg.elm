module Msg
    exposing
        ( Msg(..)
        , AdhocResponseMessage(..)
        , MedicationTypeMsg(..)
        )

import Form exposing (Form)
import Material
import Material.Snackbar as Snackbar
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Model exposing (..)
import Types exposing (..)


type Msg
    = AddSelectedTable
    | AdhocResponseMessages AdhocResponseMessage
    | CancelSelectedTable
    | CreateResponseMsg (Maybe CreateResponse)
    | DeleteResponseMsg (Maybe DeleteResponse)
    | EditSelectedTable
    | EventTypeResponse (RemoteData String (List EventTypeRecord))
    | FirstRecord
    | LabSuiteResponse (RemoteData String (List LabSuiteRecord))
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
    | RiskCodeResponse (RemoteData String (List RiskCodeRecord))
    | SaveSelectedTable
    | SelectedTableEditMode EditMode (Maybe Int)
    | SelectQueryResponseMsg (RemoteData String SelectQueryResponse)
    | SelectQuerySelectTable SelectQuery
    | SelectTableRecord Int
    | SelectTab Tab
    | SessionExpired
    | Snackbar (Snackbar.Msg String)
    | UpdateResponseMsg (Maybe UpdateResponse)
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

type AdhocResponseMessage
    = AdhocUnknownMsg String
    | AdhocLoginResponseMsg LoginResponse
