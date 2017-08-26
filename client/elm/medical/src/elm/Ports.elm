port module Ports
    exposing
        ( incoming
        , openDatePicker
        , outgoing
        , selectedDate
        )

import Json.Encode as JE


-- Incoming --


port incoming : (JE.Value -> msg) -> Sub msg


port selectedDate : (JE.Value -> msg) -> Sub msg



-- Outgoing --


port outgoing : JE.Value -> Cmd msg


port openDatePicker : JE.Value -> Cmd msg
