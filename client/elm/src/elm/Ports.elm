port module Ports exposing (..)

import Json.Decode


-- LOCAL IMPORTS

import Model exposing (SystemMessage)
import Msg exposing (Msg)


-- INCOMING PORTS


port systemMessages : (Json.Decode.Value -> msg) -> Sub msg
