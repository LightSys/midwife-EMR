module Model exposing (..)

import Material


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


type alias SystemMessage =
    { id : String
    , msgType : String
    , updatedAt : Int
    , workerId : String
    , processedBy : List String
    , systemLog : String
    }


initialModel : Model
initialModel =
    { mdl = Material.model
    , user = -1
    , selectedTab = HomeTab
    , selectedPage = HomePage
    , systemMessages = []
    }


{-| Used when there is an error decoding from JS.
-}
emptySystemMessage : SystemMessage
emptySystemMessage =
    { id = "ERROR"
    , msgType = ""
    , updatedAt = 0
    , workerId = ""
    , processedBy = []
    , systemLog = ""
    }
