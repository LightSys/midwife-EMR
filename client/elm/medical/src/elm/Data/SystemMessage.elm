module Data.SystemMessage
    exposing
        ( SystemMessageType(..)
        , systemMessageType
        )

import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Pipeline as JDP
import Json.Encode as JE


{-| Note: will need to add to this as server sends different types
of values.

SystemMode 0: Normal operations
SystemMode 1: No new logins of non-administrators (does not affect this app)
SystemMode 2: Only administrators can use the system (do immediate logout)
-}
type SystemMessageType
    = SystemMode Int
    | SystemMessageTypeUnknown


systemMessageType : JD.Decoder SystemMessageType
systemMessageType =
    JD.oneOf
        [ JD.at
            [ "payload"
            , "data"
            , "SystemMode"
            ]
            (JD.map SystemMode JD.int)
        ]
