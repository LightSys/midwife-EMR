module Page.NotFound exposing (view)

import Data.Session as Session exposing (Session)
import Html as H exposing (Html)
import Html.Attributes as HA


-- VIEW --

view : Session -> Html msg
view session =
    H.main_
        [ HA.id "content"
        , HA.class "container"
        , HA.tabindex -1
        ]
        [ H.div
            [ HA.class "row" ]
            [ H.text "Page not found." ]
        ]

