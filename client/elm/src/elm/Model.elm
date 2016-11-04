module Model
    exposing
        ( Model
        , Page(..)
        , Tab(..)
        , initialModel
        )

import Material


-- LOCAL IMPORTS

import Types exposing (..)


type alias Model =
    { mdl : Material.Model
    , selectedTab : Tab
    , selectedPage : Page
    , systemMessages : List SystemMessage
    , user : Int
    }


type Page
    = HomePage
    | UserSearchPage
    | UserEditPage
    | TableMainPage
    | ProfilePage


type Tab
    = HomeTab
    | UserTab
    | TablesTab
    | ProfileTab


initialModel : Model
initialModel =
    { mdl = Material.model
    , user = -1
    , selectedTab = HomeTab
    , selectedPage = HomePage
    , systemMessages = []
    }
