module Util exposing ((=>))

(=>) : a -> b -> ( a, b )
(=>) =
    (,)

infixl 0 =>


