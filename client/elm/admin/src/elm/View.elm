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
import Views.Barcodes
import Views.KeyValue
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
        ( hasLoadedUserProfile, isLoggedIn ) =
            case model.userProfile of
                Just up ->
                    ( True, up.isLoggedIn )

                Nothing ->
                    ( False, False )

        pageDef : Maybe PageDef
        pageDef =
            getPageDef model.selectedPage model.pageDefs

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
            case ( hasLoadedUserProfile, isLoggedIn ) of
                ( False, _ ) ->
                    viewSplash

                ( True, False ) ->
                    Views.Login.view

                ( True, True ) ->
                    case model.selectedPage of
                        AdminHomePage ->
                            viewHome

                        AdminBarcodesPage ->
                            Views.Barcodes.view

                        AdminConfigPage ->
                            Views.KeyValue.view

                        AdminUsersPage ->
                            Views.Users.view

                        AdminTablesPage ->
                            Views.Tables.view

                        ProfilePage ->
                            Views.Profile.view

                        ProfileNotLoadedPage ->
                            -- Show the splash page while loading the user profile.
                            viewSplash

                        PageDefNotFoundPage ->
                            viewPageDefNotFound

                        PageNotFoundPage ->
                            viewPageNotFound
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
            , tabs =
                if hasLoadedUserProfile then
                    tabs tabsList
                else
                    tabs []
            , main =
                [ theView model
                , Html.map (\m -> Snackbar m) <| Snackbar.view model.snackbar
                ]
            }


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
                        , Options.css "cursor" "pointer"
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
                        [ Options.styled p
                            [ Typo.body1 ]
                            [ text <|
                                if model.userProfile == Nothing then
                                    ""
                                else
                                    "Please log in."
                            ]
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
                [ text "Midwife-EMR Activity "
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


{-| Show a splash screen while the user's profile information is
not yet loaded.
-}
viewSplash : Model -> Html Msg
viewSplash model =
    let
        _ =
            Debug.log "viewSplash" <| model.pageDefs
    in
        Grid.grid []
            [ Grid.cell
                [ Grid.size Grid.Desktop 4
                , Grid.size Grid.Tablet 2
                , Grid.size Grid.Phone 1
                ]
                []
            , Grid.cell
                [ Grid.size Grid.Desktop 4
                , Grid.size Grid.Tablet 4
                , Grid.size Grid.Phone 2
                , Grid.align Grid.Middle
                , Grid.stretch
                , Grid.maxWidth "400px"
                ]
                [ Html.h3
                    [ HA.style [ ( "color", "#999999" ) ]
                    ]
                    [ text "One moment as we load your user information ..." ]
                ]
            , Grid.cell
                [ Grid.size Grid.Desktop 4
                , Grid.size Grid.Tablet 2
                , Grid.size Grid.Phone 1
                ]
                []
            ]


{-| This means that the PageDef was not put into the proper list of
page definitions.
-}
viewPageDefNotFound : Model -> Html Msg
viewPageDefNotFound model =
    Html.text "The PageDef was not found in the list of page definitions."


{-| This means that the proper Page data constructor was not put
into the Page type.
-}
viewPageNotFound : Model -> Html Msg
viewPageNotFound model =
    Html.text "The Page was not found in the Page type."
