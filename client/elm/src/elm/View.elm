module View exposing (..)

import Color as Color
import Html as Html exposing (Html, div, p, text)
import Html.Attributes as HA
import List.Extra as LE
import Material
import Material.Button as Button
import Material.Color as MColor
import Material.Grid as Grid
import Material.Icons.Action as Icon exposing (exit_to_app)
import Material.Layout as Layout
import Material.Options as Options
import Material.Table as Table
import Material.Snackbar as Snackbar
import Material.Typography as Typo
import String


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (Msg(..))
import Types exposing (..)
import Utils exposing (getPageDef, tabIndexToPage)
import Views.Login
import Views.Profile
import Views.Tables
import Views.Utils as VU
import Views.Users


type alias Mdl =
    Material.Model


view : Model -> Html Msg
view model =
    let
        isLoggedIn =
            case model.userProfile of
                Just up ->
                    up.isLoggedIn

                Nothing ->
                    False

        pageDef : Maybe PageDef
        pageDef =
            getPageDef model.selectedPage adminPages

        ( selectedTab, tabsList ) =
            case pageDef of
                Just pdef ->
                    case ( pdef.tab, pdef.tabs ) of
                        ( Just t, Just ts ) ->
                            -- Showing one of the tabs.
                            ( t, List.map Tuple.first ts )

                        ( Nothing, Just ts ) ->
                            -- Showing a page but not one of the tabs, like the
                            -- Profile page.
                            ( -1, List.map Tuple.first ts )

                        _ ->
                            -- Showing a page without tabs.
                            ( -1, [] )

                Nothing ->
                    ( 0, [] )

        theView =
            case isLoggedIn of
                False ->
                    Views.Login.view

                True ->
                    case model.selectedPage of
                        AdminHomePage ->
                            viewHome

                        AdminUsersPage ->
                            Views.Users.viewUserSearch

                        AdminTablesPage ->
                            Views.Tables.view

                        ProfilePage ->
                            Views.Profile.view
    in
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.fixedTabs
            , Layout.selectedTab selectedTab
            , Layout.onSelectTab (\idx -> tabIndexToPage idx pageDef model |> SelectPage)
            ]
            { header = headerSmall "Midwife-EMR" model
            , drawer = []
            , tabs = tabs tabsList
            , main =
                [ theView model
                , Html.map (\m -> Snackbar m) <| Snackbar.view model.snackbar
                ]
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
    , [ MColor.background MColor.primaryDark
      , MColor.text MColor.primaryContrast
      ]
    )


headerSmall : String -> Model -> List (Html Msg)
headerSmall title model =
    let
        isLoggedIn =
            case model.userProfile of
                Just up ->
                    up.isLoggedIn

                Nothing ->
                    False

        contents =
            [ Layout.row []
                [ Layout.title []
                    [ Options.styled p
                        [ Typo.headline
                        , Options.onClick (SelectPage AdminHomePage)
                        ]
                        [ text title ]
                    ]
                , Layout.spacer
                , if isLoggedIn then
                    Layout.navigation []
                        [ Layout.link
                            [ Layout.href "#profile" ]
                            [ Icon.exit_to_app Color.white 20
                            , text " Profile"
                            ]
                        , Layout.link
                            [ Layout.href "/logout" ]
                            [ Icon.exit_to_app Color.white 20
                            , text " Logout"
                            ]
                        ]
                  else
                    Layout.title []
                        [ Options.styled p [ Typo.body1 ] [ text "Please log in." ]
                        ]
                ]
            ]
    in
        contents


systemLog : Model -> Html msg
systemLog model =
    let
        makeRow idx m =
            Html.li
                [ HA.classList
                    [ ( "system-log-line", True )
                    , ( "system-log-line-even", idx % 2 == 0 )
                    , ( "system-log-line-odd", idx % 2 /= 0 )
                    ]
                ]
                -- Remove the process id from the beginning of the string.
                [ m.systemLog
                    |> String.split "|"
                    |> List.drop 1
                    |> List.head
                    |> Maybe.withDefault ""
                    |> text
                ]

        rows =
            List.take 300 model.systemMessages
                |> List.indexedMap makeRow
    in
        Html.div []
            [ Html.h4 []
                [ text "System Log "
                , Html.small []
                    [ text "Most recent 300, newest at the top" ]
                ]
            , Html.ul [ HA.class "system-log" ] rows
            ]


viewHome : Model -> Html Msg
viewHome model =
    let
        cellOpts =
            [ Grid.size Grid.Desktop 12
            , Grid.size Grid.Tablet 8
            , Grid.size Grid.Phone 4
            ]
    in
        Grid.grid []
            [ Grid.cell VU.fullSizeCellOpts
                [ Html.h3 []
                    [ text "Home" ]
                ]
            , Grid.cell cellOpts
                [ Options.styled p
                    []
                    [ systemLog model ]
                ]
            ]


viewProfile : Model -> Html Msg
viewProfile model =
    p [] [ text "Profile page" ]
