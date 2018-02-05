module Data.Processing
    exposing
        ( ProcessId(..)
        )

-- LOCAL IMPORTS --



{-| Each "process" is stored with an unique id. This can be
used to correspond to the MessageId used in messages sent to
and received from the server.
-}
type ProcessId
    = ProcessId Int


