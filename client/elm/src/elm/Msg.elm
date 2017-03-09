module Msg
    exposing
        ( Msg(..)
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
    = AddResponseMsg (Maybe AddResponse)
    | AddSelectedTable
    | CancelSelectedTable
    | ChangeResponseMsg (Maybe ChangeResponse)
    | DelResponseMsg (Maybe DelResponse)
    | EditSelectedTable
    | EventTypeResponse (RemoteData String (List EventTypeRecord))
    | FirstRecord
    | LabSuiteResponse (RemoteData String (List LabSuiteRecord))
    | LabTestResponse (RemoteData String (List LabTestRecord))
    | LabTestValueResponse (RemoteData String (List LabTestValueRecord))
    | LastRecord
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
    | VaccinationTypeResponse (RemoteData String (List VaccinationTypeRecord))


type MedicationTypeMsg
    = FirstMedicationTypeRecord
    | FormMsg Form.Msg
    | LastMedicationTypeRecord
    | MedicationTypeAdd
    | MedicationTypeAddResponse AddResponse
    | MedicationTypeCancel
    | MedicationTypeChg
    | MedicationTypeChgResponse ChangeResponse
    | MedicationTypeDelete (Maybe Int)
    | MedicationTypeDelResponse DelResponse
    | MedicationTypeResponse (RemoteData String (List MedicationTypeRecord)) (Maybe SelectQuery)
    | NextMedicationTypeRecord
    | PrevMedicationTypeRecord
    | SelectedEditModeRecord EditMode (Maybe Int)
    | SelectedRecordId (Maybe Int)
