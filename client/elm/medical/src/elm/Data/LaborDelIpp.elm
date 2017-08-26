module Data.LaborDelIpp exposing (Field(..), SubMsg(..))

import Data.DatePicker exposing (DateFieldMessage)

type SubMsg
    = PageNoop
    | AdmitForLabor
    | CancelAdmitForLabor
    | SaveAdmitForLabor
    | OpenDatePickerSubMsg String
    | FldChgSubMsg Field String
    | DateFieldSubMsg DateFieldMessage

type Field
    = AdmittanceDateFld
    | LaborDateFld


