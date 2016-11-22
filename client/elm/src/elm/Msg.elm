module Msg
    exposing
        ( Msg(..)
        )

import Material
import RemoteData as RD exposing (RemoteData(..), WebData)


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
    | EventTypeResponse (WebData (List EventTypeTable))
    | LabSuiteResponse (WebData (List LabSuiteTable))
    | LabTestResponse (WebData (List LabTestTable))
    | LabTestValueResponse (WebData (List LabTestValueTable))
    | MedicationTypeResponse (WebData (List MedicationTypeTable))
    | PregnoteTypeResponse (WebData (List PregnoteTypeTable))
    | RiskCodeResponse (WebData (List RiskCodeTable))
    | VaccinationTypeResponse (WebData (List VaccinationTypeTable))
