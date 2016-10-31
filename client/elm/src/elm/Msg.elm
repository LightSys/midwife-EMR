module Msg exposing (..)

import Material


-- LOCAL IMPORTS

import Model exposing (..)


type Msg
    = NoOp
    | Mdl (Material.Msg Msg)
    | SelectTab Tab
