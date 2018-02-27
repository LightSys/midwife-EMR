module Data.BabyMedicationType
    exposing
        ( BabyMedicationTypeId(..)
        , BabyMedicationTypeRecord
        , babyMedicationTypeRecord
        , getByName
        , getNameUseLocation
        )

import Data.Table exposing (Table(..), tableToString)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import List.Extra as LE
import Util as U


type BabyMedicationTypeId
    = BabyMedicationTypeId Int


type alias BabyMedicationTypeRecord =
    { id : Int
    , name : String
    , description : Maybe String
    , useLocation : Bool
    }


babyMedicationTypeRecord : JD.Decoder BabyMedicationTypeRecord
babyMedicationTypeRecord =
    JDP.decode BabyMedicationTypeRecord
        |> JDP.required "id" JD.int
        |> JDP.required "name" JD.string
        |> JDP.required "description" (JD.maybe JD.string)
        |> JDP.required "useLocation" (JD.map (\u -> u == 1) JD.int)


getNameUseLocation : Int -> List BabyMedicationTypeRecord -> Maybe ( String, Bool )
getNameUseLocation id recsList =
    case LE.find (\r -> r.id == id) recsList of
        Just rec ->
            Just ( rec.name, rec.useLocation )

        Nothing ->
            Nothing


getByName : String -> List BabyMedicationTypeRecord -> Maybe BabyMedicationTypeRecord
getByName name recsList =
    LE.find
        (\r -> String.contains (String.toLower name) (String.toLower r.name))
        recsList
