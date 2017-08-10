port module Ports exposing (incoming, outgoing)

import Json.Encode as JE

port incoming : (JE.Value -> msg) -> Sub msg

port outgoing : JE.Value -> Cmd msg
