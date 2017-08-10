module Util
    exposing
        ( (=>)
        , maybeIntToNegOne
        )

import Json.Encode as JE


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
infixl 0 =>


maybeIntToNegOne : Maybe Int -> JE.Value
maybeIntToNegOne int =
    case int of
        Just i ->
            JE.int i

        Nothing ->
            JE.int -1
