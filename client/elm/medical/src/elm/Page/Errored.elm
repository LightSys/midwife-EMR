module Page.Errored exposing (PageLoadError, pageLoadError, view)

import Html as H exposing (Html)
import Html.Attributes as HA

-- LOCAL IMPORTS --

import Data.Session as Session exposing (Session)
import Views.Page as Page exposing (ActivePage)

-- MODEL --

type PageLoadError
    = PageLoadError Model

type alias Model =
    { activePage : ActivePage
    , errorMessage : String
    }

pageLoadError : ActivePage -> String -> PageLoadError
pageLoadError activePage errorMessage =
    PageLoadError { activePage = activePage, errorMessage = errorMessage }


view : Session -> PageLoadError -> Html msg
view session (PageLoadError model) =
    H.main_
        [ HA.id "content"
        , HA.class "container"
        , HA.tabindex -1
        ]
        [ H.div
            [ HA.class "row" ]
            [ H.p [] [ H.text model.errorMessage ] ]
        ]
