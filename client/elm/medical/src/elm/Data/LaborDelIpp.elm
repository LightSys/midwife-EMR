module Data.LaborDelIpp exposing (Dialog(..), Field(..), SubMsg(..))

import Dict exposing (Dict)
import Time exposing (Time)


-- LOCAL IMPORTS --

import Data.DataCache exposing (DataCache)
import Data.DatePicker exposing (DateFieldMessage)
import Data.Labor exposing (LaborId, LaborRecordNew)
import Data.LaborStage1 exposing (LaborStage1Id, LaborStage1Record, LaborStage1RecordNew)
import Data.Table exposing (Table)


type SubMsg
    = PageNoop
      -- DataCache is the mechanism used to retrieve records from
      -- the top-level that it has received from the server. The
      -- top-level intercepts this message and creates a new message
      -- with the latest DataCache that it has and sends it down to
      -- us again. We, in turn, populate our page Model based on the
      -- list of tables passed through.
    | DataCache (Maybe (Dict String DataCache)) (Maybe (List Table))
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
    | HandleStage1DateTimeModal Dialog
    | HandleStage1SummaryModal Dialog
    | HandleStage2DateTimeModal Dialog
    | HandleStage3DateTimeModal Dialog
    | ClearStage1DateTime
    | ClearStage2DateTime
    | ClearStage3DateTime
    | TickSubMsg Time
    | LaborDetailsLoaded


type Dialog
    = OpenDialog
    | CloseNoSaveDialog
    | CloseSaveDialog
    | EditDialog


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
    | Stage1MobilityFld
    | Stage1DurationLatentFld
    | Stage1DurationActiveFld
    | Stage1CommentsFld
    | Stage2DateFld
    | Stage2TimeFld
    | Stage3DateFld
    | Stage3TimeFld
