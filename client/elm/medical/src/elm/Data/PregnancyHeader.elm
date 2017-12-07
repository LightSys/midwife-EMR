module Data.PregnancyHeader
    exposing
        ( LaborInfo
        , PregHeaderContent(..)
        , PregHeaderContentMsg(..)
        )

import Dict exposing (Dict)


-- LOCAL IMPORTS --

import Data.Labor exposing (LaborRecord)
import Data.LaborStage1 exposing (LaborStage1Record)
import Data.LaborStage2 exposing (LaborStage2Record)
import Data.LaborStage3 exposing (LaborStage3Record)


type PregHeaderContentMsg
    = RotatePregHeaderContentMsg


type PregHeaderContent
    = PrenatalContent
    | LaborContent
    | IPPContent


type alias LaborInfo =
    { laborRecord : Maybe (Dict Int LaborRecord)
    , laborStage1Record : Maybe LaborStage1Record
    , laborStage2Record : Maybe LaborStage2Record
    , laborStage3Record : Maybe LaborStage3Record
    }
