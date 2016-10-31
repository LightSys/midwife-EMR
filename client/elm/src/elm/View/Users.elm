module View.Users exposing (..)

import Html as Html exposing (Html, div, p, text)


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (Msg(..))


viewUserSearch : Model -> Html Msg
viewUserSearch model =
    p [] [ text "User search page" ]


viewUserEdit : Model -> Html Msg
viewUserEdit model =
    p [] [ text "User edit page" ]
