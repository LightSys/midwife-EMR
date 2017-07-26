module Data.User exposing (User, Username)


type alias User =
    { username : Username
    }

type Username
    = Username String
