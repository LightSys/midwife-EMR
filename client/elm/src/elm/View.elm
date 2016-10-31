module View exposing (..)

import Html as Html exposing (Html, div, p, text)
import Material
import Material.Color as Color
import Material.Layout as Layout
import Material.Options as Options
import Material.Typography as Typo


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (Msg(..))
import View.Users


type alias Mdl =
    Material.Model


view : Model -> Html Msg
view model =
    let
        main =
            case model.selectedTab of
                HomeTab ->
                    viewHome

                UserTab ->
                    case model.selectedPage of
                        UserSearchPage ->
                            View.Users.viewUserSearch

                        UserEditPage ->
                            View.Users.viewUserEdit

                        _ ->
                            View.Users.viewUserSearch

                TablesTab ->
                    viewTablesMain

                ProfileTab ->
                    viewProfile
    in
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.fixedTabs
            , Layout.selectedTab (tabToInt model.selectedTab)
            , Layout.onSelectTab (\t -> intToTab t |> SelectTab)
            ]
            { header = headerSmall "Midwife-EMR" model
            , drawer = []
            , tabs = tabs [ "Home", "User", "Tables", "Profile" ]
            , main = [ main model ]
            }


{-| Translation from Tab to Int for the sake of MDL.
-}
tabToInt : Tab -> Int
tabToInt tab =
    case tab of
        HomeTab ->
            0

        UserTab ->
            1

        TablesTab ->
            2

        ProfileTab ->
            3


{-| Translation from Int to Tab for the sake of MDL. Since
    MDL requires Ints to represent tabs, we cannot escape
    these mappings.
-}
intToTab : Int -> Tab
intToTab num =
    case num of
        0 ->
            HomeTab

        1 ->
            UserTab

        2 ->
            TablesTab

        3 ->
            ProfileTab

        _ ->
            HomeTab


tabSpan : String -> Html a
tabSpan lbl =
    Options.span [ Options.cs "tabLabel" ] [ text lbl ]


tabs : List String -> ( List (Html a), List (Options.Property b d) )
tabs labels =
    ( List.map tabSpan labels
    , [ Color.background Color.primaryDark
      , Color.text Color.primaryContrast
      ]
    )


headerSmall : String -> Model -> List (Html a)
headerSmall title model =
    let
        contents =
            [ Layout.row []
                [ Layout.title []
                    [ Options.styled p [ Typo.headline ] [ text title ]
                    ]
                ]
            ]
    in
        contents


viewHome : Model -> Html Msg
viewHome model =
    p [] [ text "Home page" ]


viewTablesMain : Model -> Html Msg
viewTablesMain model =
    p [] [ text "Tables main page" ]


viewProfile : Model -> Html Msg
viewProfile model =
    p [] [ text "Profile page" ]
