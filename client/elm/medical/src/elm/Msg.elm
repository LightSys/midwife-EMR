module Msg
    exposing
        ( logConsole
        , Msg(..)
        , ProcessType(..)
        )

import Task
import Time exposing (Time)
import Window


-- LOCAL IMPORTS --

import Data.DatePicker exposing (DateField, DateFieldMessage)
import Data.LaborDelIpp as LaborDelIpp
import Data.Message as Message exposing (IncomingMessage(..))
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
    | OpenDatePicker String
    | IncomingDatePicker DateFieldMessage



logConsole : String -> Cmd Msg
logConsole msg =
    Task.perform LogConsole (Task.succeed msg)


{-| The data that is stored in the process store. This is used as
the bridge over the asyncronous divide between making a websocket
request and receiving the response from the server.
-}
type ProcessType
    = SelectQueryType Msg SelectQuery
