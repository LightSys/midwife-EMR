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
    = NoOp
    | Mdl (Material.Msg Msg)
    | Snackbar (Snackbar.Msg String)
    | SelectTab Tab
    | NewSystemMessage SystemMessage
    | SelectQuerySelectTable SelectQuery
    | SelectedTableEditMode EditMode (Maybe Int)
    | SelectTableRecord Int
    | AddSelectedTable
    | EditSelectedTable
    | SaveSelectedTable
    | CancelSelectedTable
    | FirstRecord
    | PreviousRecord
    | NextRecord
    | LastRecord
    | MedicationTypeMessages MedicationTypeMsg
    | EventTypeResponse (RemoteData String (List EventTypeTable))
    | LabSuiteResponse (RemoteData String (List LabSuiteTable))
    | LabTestResponse (RemoteData String (List LabTestTable))
    | LabTestValueResponse (RemoteData String (List LabTestValueTable))
    | PregnoteTypeResponse (RemoteData String (List PregnoteTypeTable))
    | RiskCodeResponse (RemoteData String (List RiskCodeTable))
    | VaccinationTypeResponse (RemoteData String (List VaccinationTypeTable))
    | ChangeResponseMsg (Maybe ChangeResponse)
    | AddResponseMsg (Maybe AddResponse)
    | DelResponseMsg (Maybe DelResponse)


type MedicationTypeMsg
    = FormMsg Form.Msg
    | SelectedRecordId (Maybe Int)
    | SelectedEditModeRecord EditMode (Maybe Int)
    | MedicationTypeResponse (RemoteData String (List MedicationTypeTable))
    | MedicationTypeSave
    | MedicationTypeAdd
    | MedicationTypeDelete (Maybe Int)
    | MedicationTypeCancel
    | MedicationTypeSaveResponse ChangeResponse
    | MedicationTypeAddResponse AddResponse
    | MedicationTypeDelResponse DelResponse
    | FirstMedicationTypeRecord
    | PrevMedicationTypeRecord
    | NextMedicationTypeRecord
    | LastMedicationTypeRecord
