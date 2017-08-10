module Processing
    exposing
        ( add
        , remove
        , processStoreInit
        , ProcessStore
        )

import Date exposing (Date)
import List.Extra as LE
import Time exposing (Time)


-- LOCAL IMPORTS

import Data.Processing exposing (..)
import Msg exposing (ProcessType(..))
import Util exposing ((=>))


-- PUBLIC API --


{-| ProcessStore hides ProcessStoreInternal from
other modules.
-}
type ProcessStore
    = ProcessStore ProcessStoreInternal


{-| Our initial processing queue is empty.
-}
processStoreInit : ProcessStore
processStoreInit =
    ProcessStore <|
        ProcessStoreInternal
            []
            1
            0
            5000
            (1000 * 30)


{-| Add a ProcessType to the in process queue and return a tuple
with the new ProcessId for the new entry as well as the updated
ProcessStore so that can be saved to the model.
-}
add : ProcessType -> Maybe Date -> ProcessStore -> ( ProcessId, ProcessStore )
add pt date (ProcessStore psi) =
    ( ProcessId psi.nextId
    , ProcessStore
        { psi
            | store = Process psi.nextId pt date :: psi.store
            , nextId = psi.nextId + 1
        }
    )


{-| Retrieves the ProcessType as specified by the ProcessId and returns
it as a Maybe within a tuple along with the updated ProcessStore with
the ProcessType removed if it was found. ProcessStore should be saved to
the model.
-}
remove : ProcessId -> ProcessStore -> ( Maybe ProcessType, ProcessStore )
remove (ProcessId id) (ProcessStore psi) =
    case LE.find (\p -> p.id == id) psi.store of
        Just p ->
            ( Just p.processType
            , ProcessStore
                { psi
                    | store = LE.filterNot (\p -> p.id == id) psi.store
                }
            )

        Nothing ->
            ( Nothing
            , ProcessStore psi
            )



-- INTERNAL --


type alias ProcessStoreInternal =
    { store : List Process
    , nextId : Int
    , currentTime : Time
    , expireInterval : Int
    , cleanupInterval : Int
    }


type alias Process =
    { id : Int
    , processType : ProcessType
    , expires : Maybe Date
    }
