module Data.User exposing (getUser, User, userDecoder)

import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Pipeline as Pipeline exposing (decode, optional, required)
import Json.Encode as JE


type alias User =
    { id : Int
    , username : String
    , firstname : Maybe String
    , lastname : Maybe String
    , shortName : Maybe String
    , displayName : Maybe String
    }


userDecoder : JD.Decoder User
userDecoder =
    decode User
        |> required "id" JD.int
        |> required "username" JD.string
        |> required "lastname" (JD.nullable JD.string)
        |> required "firstname" (JD.nullable JD.string)
        |> required "shortName" (JD.nullable JD.string)
        |> required "displayName" (JD.nullable JD.string)


getUser : Int -> Dict Int User -> Maybe User
getUser id users =
    Dict.get id users
