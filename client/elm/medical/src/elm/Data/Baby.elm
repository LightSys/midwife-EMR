module Data.Baby
    exposing
        ( BabyId(..)
        , BabyRecord
        , BabyRecordNew
        , babyRecord
        , getBabyId
        , MaleFemale(..)
        )

import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP


type BabyId
    = BabyId Int


getBabyId : BabyId -> Int
getBabyId (BabyId id) =
    id


type MaleFemale
    = Male
    | Female


maleFemale : JD.Decoder String -> JD.Decoder MaleFemale
maleFemale =
    JD.map stringToMaleFemale


stringToMaleFemale : String -> MaleFemale
stringToMaleFemale str =
    case String.toUpper str of
        "M" ->
            Male

        "F" ->
            Female

        _ ->
            let
                _ =
                    Debug.log "Data.Baby.stringToMaleFemale" "Error: unknown str of '" ++ str ++ "' encountered."
            in
                Female


maleFemaleToString : MaleFemale -> String
maleFemaleToString mf =
    case mf of
        Male ->
            "M"

        Female ->
            "F"


type alias BabyRecord =
    { id : Int
    , birthNbr : Int
    , lastname : Maybe String
    , firstname : Maybe String
    , middlename : Maybe String
    , sex : MaleFemale
    , birthWeight : Maybe Int
    , bFedEstablished : Maybe Date
    , nbsDate : Maybe Date
    , nbsResult : Maybe String
    , bcgDate : Maybe Date
    , comments : Maybe String
    , labor_id : Int
    }


type alias BabyRecordNew =
    { birthNbr : Int
    , lastname : Maybe String
    , firstname : Maybe String
    , middlename : Maybe String
    , sex : MaleFemale
    , birthWeight : Maybe Int
    , bFedEstablished : Maybe Date
    , nbsDate : Maybe Date
    , nbsResult : Maybe String
    , bcgDate : Maybe Date
    , comments : Maybe String
    , labor_id : Int
    }


babyRecord : JD.Decoder BabyRecord
babyRecord =
    JDP.decode BabyRecord
        |> JDP.required "id" JD.int
        |> JDP.required "birthNbr" JD.int
        |> JDP.required "lastname" (JD.maybe JD.string)
        |> JDP.required "firstname" (JD.maybe JD.string)
        |> JDP.required "middlename" (JD.maybe JD.string)
        |> JDP.required "sex" (JD.string |> maleFemale)
        |> JDP.required "birthWeight" (JD.maybe JD.int)
        |> JDP.required "bFedEstablished" (JD.maybe JDE.date)
        |> JDP.required "nbsDate" (JD.maybe JDE.date)
        |> JDP.required "nbsResult" (JD.maybe JD.string)
        |> JDP.required "bcgDate" (JD.maybe JDE.date)
        |> JDP.required "comments" (JD.maybe JD.string)
        |> JDP.required "labor_id" JD.int
