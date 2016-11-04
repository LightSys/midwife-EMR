port module Ports
    exposing
        ( systemMessages
        , searchUser
        )

import Json.Decode


-- LOCAL IMPORTS

import Types exposing (..)
import Msg exposing (Msg)


-- INCOMING PORTS


port systemMessages : (Json.Decode.Value -> msg) -> Sub msg



-- OUTGOING PORTS


port searchUser : String -> Cmd msg
