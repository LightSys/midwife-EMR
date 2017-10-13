module Msg
    exposing
        ( logConsole
        , Msg(..)
        , ProcessType(..)
        )

import Json.Encode as JE
import Task
import Time exposing (Time)
import Window


-- LOCAL IMPORTS --

import Data.DatePicker exposing (DateField, DateFieldMessage)
import Data.Labor exposing (LaborId, LaborRecord, LaborRecordNew)
import Data.LaborDelIpp as LaborDelIpp
import Data.LaborStage1 exposing (LaborStage1Record, LaborStage1RecordNew)
import Data.LaborStage2 exposing (LaborStage2Record, LaborStage2RecordNew)
import Data.Message as Message exposing (IncomingMessage(..), MsgType)
import Data.Pregnancy exposing (PregnancyId)
import Data.Processing exposing (ProcessId)
import Data.SelectQuery exposing (SelectQuery)
import Data.TableRecord exposing (..)
import Route exposing (Route)


type Msg
    = Noop
    | Tick Time
    | LogConsole String
    | WindowResize (Maybe Window.Size)
    | SetRoute (Maybe Route)
    | LaborDelIppLoaded PregnancyId
    | LaborDelIppMsg LaborDelIpp.SubMsg
    | Message IncomingMessage
    | ProcessTypeMsg ProcessType MsgType JE.Value
    | OpenDatePicker String
    | IncomingDatePicker DateFieldMessage
    | AddLabor


{-| Initiate a Cmd to send a message to the console. This function
is located here to address circular dependencies.
-}
logConsole : String -> Cmd Msg
logConsole msg =
    Task.perform LogConsole (Task.succeed msg)


{-| The data that is stored in the process store. This temporary
data store is used as the bridge over the asyncronous divide
between making a websocket request and receiving the response
from the server. It is used for all CRUD with the server because
we are not assuming optimistic changes, therefore we need a means
to "remember" what we should do when the server responds positively.
-}
type ProcessType
    = AddLaborType Msg LaborRecordNew
    | AddLaborStage1Type Msg LaborStage1RecordNew
    | AddLaborStage2Type Msg LaborStage2RecordNew
    | UpdateLaborStage1Type Msg LaborStage1Record
    | UpdateLaborStage2Type Msg LaborStage2Record
    | SelectQueryType Msg SelectQuery
