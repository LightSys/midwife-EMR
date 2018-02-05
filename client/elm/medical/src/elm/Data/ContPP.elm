module Data.ContPP
    exposing
        ( SubMsg(..)
        )

import Dict exposing (Dict)

-- LOCAL IMPORTS --

import Data.DataCache exposing (DataCache)
import Data.PregnancyHeader exposing (PregHeaderContentMsg)
import Data.Table exposing (Table)


type SubMsg
    = PageNoop
    | RotatePregHeaderContent PregHeaderContentMsg
      -- DataCache is the mechanism used to retrieve records from
      -- the top-level that it has received from the server. The
      -- top-level intercepts this message and creates a new message
      -- with the latest DataCache that it has and sends it down to
      -- us again. We, in turn, populate our page Model based on the
      -- list of tables passed through.
    | DataCache (Maybe (Dict String DataCache)) (Maybe (List Table))
