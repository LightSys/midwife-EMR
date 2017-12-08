module Data.Admitting
    exposing
        ( AdmittingSubMsg(..)
        , Field(..)
        )

import Dict exposing (Dict)
import Time exposing (Time)


-- LOCAL IMPORTS --

import Const exposing (FldChgValue)
import Data.DataCache exposing (DataCache)
import Data.Labor exposing (LaborId, LaborRecord, LaborRecordNew)
import Data.PregnancyHeader exposing (PregHeaderContentMsg)
import Data.Table exposing (Table)


type AdmittingSubMsg
    = AdmittingPageNoop
      -- Date/time from the top-level so we can prefill date/time fields.
    | AdmittingTickSubMsg Time
      -- Current view of pregnancy header.
    | RotatePregHeaderContent PregHeaderContentMsg
      -- Our data cache.
    | DataCache (Maybe (Dict String DataCache)) (Maybe (List Table))
      -- The user pressed the admit for labor button.
    | AdmitForLabor
      -- The user cancelled either an add or update of the admit for labor form.
    | CancelAdmitForLabor
      -- User saved the admit for labor form; can be add or update.
    | SaveAdmitForLabor (Maybe LaborId)
      -- The server confirms add or update of labor record.
    | AdmitForLaborSaved LaborRecordNew (Maybe LaborId)
      -- User edits an existing labor record.
    | EditAdmittance LaborId
      -- All changes to fields in the user add/edit form.
    | FldChgSubMsg Field FldChgValue
      -- Date picker for add/edit labor form.
    | OpenDatePickerSubMsg String


type Field
    = AdmittanceDateFld
    | AdmittanceTimeFld
    | LaborDateFld
    | LaborTimeFld
    | PosFld
    | FhFld
    | FhtFld
    | SystolicFld
    | DiastolicFld
    | CrFld
    | TempFld
    | CommentsFld
