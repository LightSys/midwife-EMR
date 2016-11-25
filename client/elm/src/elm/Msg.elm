module Msg
    exposing
        ( Msg(..)
        )

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
    | FirstRecord
    | PreviousRecord
    | NextRecord
    | LastRecord
    | EventTypeResponse (RemoteData String (List EventTypeTable))
    | LabSuiteResponse (RemoteData String (List LabSuiteTable))
    | LabTestResponse (RemoteData String (List LabTestTable))
    | LabTestValueResponse (RemoteData String (List LabTestValueTable))
    | MedicationTypeResponse (RemoteData String (List MedicationTypeTable))
    | PregnoteTypeResponse (RemoteData String (List PregnoteTypeTable))
    | RiskCodeResponse (RemoteData String (List RiskCodeTable))
    | VaccinationTypeResponse (RemoteData String (List VaccinationTypeTable))
