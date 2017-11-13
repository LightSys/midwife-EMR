module Data.Session
    exposing
        ( Session
        , clientTouch
        , doTouch
        , serverTouch
        )

import Date
import Json.Encode as JE
import Time exposing (Time)


-- LOCAL IMPORTS

import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Processing exposing (ProcessId(..))
import Data.User as User exposing (User)
import Msg exposing (Msg)
import Ports

{-| Milliseconds of client interaction without server interaction
before initiating a touch to the server.
-}
touchNeededTime : Float
touchNeededTime =
    60.0 * 1000.0


{-| The user associated with this client as well as some
session handling fields. serverTouch is the approximate
time that the server was last contacted and clientTouch is
the time that the user last interacted with the client
application. This allows us to "touch" the server periodically
when the user is interacting with the client but not
causing the client to interact with the server. This allows
the client to maintain a more reliable session with the
server.
-}
type alias Session =
    { user : Maybe User
    , serverTouch : Time
    , clientTouch : Time
    }


{-| Record that the server touched the session. We assume that
the server really does touch the session everytime the client
application interacts with it.
-}
serverTouch : Session -> Time -> Session
serverTouch session time =
    { session | serverTouch = time }


{-| Record that the user interacted with the client application.
-}
clientTouch : Session -> Time -> Session
clientTouch session time =
    { session | clientTouch = time }


{-| Determine whether the client application needs to send a
"touch" to the server in order to force it to touch the user's
session.
-}
doTouch : Session -> Time -> ( Session, Cmd Msg )
doTouch session time =
    if session.clientTouch == 0 then
        -- This is initialized to zero to get it set right first.
        ( clientTouch session time, Cmd.none )
    else if session.serverTouch == 0 then
        -- This is initialized to zero to get it set right first.
        ( serverTouch session time, Cmd.none )
    else if abs (session.clientTouch - session.serverTouch) > touchNeededTime then
        -- Update the recorded server touch to current and actually send
        -- a touch to the server. The server will not respond so we need
        -- to record this touch here and now. The ProcessId is meaningless
        -- and not used on the server or client and there is no payload.
        ( serverTouch session time
        , wrapPayload (ProcessId -2) AdhocTouchType JE.null
            |> Ports.outgoing
        )
    else
        -- Nothing to do.
        ( session, Cmd.none )
