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
    | EventTypeResponse (RemoteData String (List EventTypeTable))
    | FirstRecord
    | LabSuiteResponse (RemoteData String (List LabSuiteTable))
    | LabTestResponse (RemoteData String (List LabTestTable))
    | LabTestValueResponse (RemoteData String (List LabTestValueTable))
    | LastRecord
    | Mdl (Material.Msg Msg)
    | MedicationTypeMessages MedicationTypeMsg
    | NewSystemMessage SystemMessage
    | NextRecord
    | NoOp
    | PregnoteTypeResponse (RemoteData String (List PregnoteTypeTable))
    | PreviousRecord
    | RiskCodeResponse (RemoteData String (List RiskCodeTable))
    | SaveSelectedTable
    | SelectedTableEditMode EditMode (Maybe Int)
    | SelectQueryResponseMsg (RemoteData String SelectQueryResponse)
    | SelectQuerySelectTable SelectQuery
    | SelectTableRecord Int
    | SelectTab Tab
    | SessionExpired
    | Snackbar (Snackbar.Msg String)
    | VaccinationTypeResponse (RemoteData String (List VaccinationTypeTable))


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
    | MedicationTypeResponse (RemoteData String (List MedicationTypeTable)) (Maybe SelectQuery)
    | NextMedicationTypeRecord
    | PrevMedicationTypeRecord
    | SelectedEditModeRecord EditMode (Maybe Int)
    | SelectedRecordId (Maybe Int)
