module Views.Profile exposing (view)

import Html as Html exposing (Html, div, p, text)


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (Msg(..))


view : Model -> Html Msg
view model =
    p [] [ text "Profile" ]
