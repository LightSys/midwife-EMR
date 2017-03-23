module View exposing (..)

import Color as Color
import Html as Html exposing (Html, div, p, text)
import Html.Attributes as HA
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
import Views.Login
import Views.Utils as VU
import Views.Users
import Views.Tables


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

        main =
            case ( isLoggedIn, model.selectedTab ) of
                ( False, _ ) ->
                    Views.Login.view

                ( _, HomeTab ) ->
                    viewHome

                ( _, UserTab ) ->
                    case model.selectedPage of
                        UserSearchPage ->
                            Views.Users.viewUserSearch

                        UserEditPage ->
                            Views.Users.viewUserEdit

                        _ ->
                            Views.Users.viewUserSearch

                ( _, TablesTab ) ->
                    Views.Tables.view

                ( _, ProfileTab ) ->
                    viewProfile

        tabsList =
            case model.userProfile of
                Just up ->
                    if up.isLoggedIn then
                        [ "Home", "User", "Tables", "Profile" ]
                    else
                        []

                Nothing ->
                    []
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
            , tabs = tabs tabsList
            , main =
                [ main model
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


headerSmall : String -> Model -> List (Html a)
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
                    [ Options.styled p [ Typo.headline ] [ text title ]
                    ]
                , Layout.spacer
                , if isLoggedIn then
                    Layout.link
                        [ Layout.href "/logout" ]
                        [ Icon.exit_to_app Color.white 20
                        , text " Logout"
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
