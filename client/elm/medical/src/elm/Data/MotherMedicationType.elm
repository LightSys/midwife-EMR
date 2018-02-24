module Data.MotherMedicationType
    exposing
        ( MotherMedicationTypeId(..)
        , MotherMedicationTypeRecord
        , motherMedicationTypeRecord
        , getName
        )

import Data.Table exposing (Table(..), tableToString)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import List.Extra as LE
import Util as U


type MotherMedicationTypeId
    = MotherMedicationTypeId Int


type alias MotherMedicationTypeRecord =
    { id : Int
    , name : String
    , description : Maybe String
    }


motherMedicationTypeRecord : JD.Decoder MotherMedicationTypeRecord
motherMedicationTypeRecord =
    JDP.decode MotherMedicationTypeRecord
        |> JDP.required "id" JD.int
        |> JDP.required "name" JD.string
        |> JDP.required "description" (JD.maybe JD.string)


getName : Int -> List MotherMedicationTypeRecord -> Maybe String
getName id recsList =
    case LE.find (\r -> r.id == id) recsList of
        Just rec ->
            Just rec.name

        Nothing ->
            Nothing

