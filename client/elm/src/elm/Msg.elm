module Msg
    exposing
        ( Msg(..)
        , MedicationTypeMsg(..)
        )

import Form exposing (Form)
import Material
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Model exposing (..)
import Types exposing (..)


type Msg
    = NoOp
    | Mdl (Material.Msg Msg)
    | SelectTab Tab
    | NewSystemMessage SystemMessage
    | SelectQuerySelectTable SelectQuery
    | SelectTableRecord Int
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
    | ChangeConfirmationMsg (Maybe ChangeConfirmation)


type MedicationTypeMsg
    = FormMsg Form.Msg
    | MedicationTypeResponse (RemoteData String (List MedicationTypeTable))
    | MedicationTypeSave
    | MedicationTypeCancel
    | MedicationTypeSaveResponse ChangeConfirmation
