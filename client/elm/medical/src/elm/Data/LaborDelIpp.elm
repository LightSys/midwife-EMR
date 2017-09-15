module Data.LaborDelIpp exposing (Field(..), SubMsg(..))

import Time exposing (Time)


-- LOCAL IMPORTS --

import Data.DatePicker exposing (DateFieldMessage)
import Data.Labor exposing (LaborId, LaborRecordNew)


type SubMsg
    = PageNoop
    | AdmitForLabor
    | CancelAdmitForLabor
    | SaveAdmitForLabor
    | AdmitForLaborSaved LaborRecordNew (Maybe LaborId)
      -- These two are used for browsers that do not support the
      -- input date type and require the use of jQueryUI datepicker.
    | OpenDatePickerSubMsg String
    | DateFieldSubMsg DateFieldMessage
      -- This is for all fields other than those requiring the
      -- datepicker above.
    | FldChgSubMsg Field String
    | NextPregHeaderContent
    | HandleStage1DateTimeModal
    | HandleStage2DateTimeModal
    | HandleStage3DateTimeModal
    | ClearStage1DateTime
    | ClearStage2DateTime
    | ClearStage3DateTime
    | TickSubMsg Time


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
    | Stage1DateFld
    | Stage1TimeFld
    | Stage2DateFld
    | Stage2TimeFld
    | Stage3DateFld
    | Stage3TimeFld
