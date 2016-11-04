module Msg
    exposing
        ( Msg(..)
        )

import Material


-- LOCAL IMPORTS

import Model exposing (..)
import Types exposing (..)


type Msg
    = NoOp
    | Mdl (Material.Msg Msg)
    | SelectTab Tab
    | NewSystemMessage SystemMessage
