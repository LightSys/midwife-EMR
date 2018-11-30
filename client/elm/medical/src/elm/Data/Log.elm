module Data.Log
    exposing
        ( Severity(..)
        , logToValue
        , severityToString
        )

import Json.Encode as JE
import Time exposing (Time)


type Severity
    = InfoSeverity
    | WarningSeverity
    | ErrorSeverity


severityToString : Severity -> String
severityToString severity =
    case severity of
        InfoSeverity ->
            "Info"

        WarningSeverity ->
            "Warning"

        ErrorSeverity ->
            "Error"


logToValue : Severity -> String -> Time -> JE.Value
logToValue severity msg timestamp =
    JE.object
        [ ( "timestamp", JE.float (Time.inMilliseconds timestamp) )
        , ( "severity", JE.string (severityToString severity) )
        , ( "message", JE.string msg )
        ]
