module Views.Page exposing (ActivePage(..), frame)

import Html as H exposing (Html)
import Html.Attributes as HA
import Window


-- LOCAL IMPORTS --

import Const
import Data.Pregnancy as Pregnancy exposing (getPregId, PregnancyId)
import Data.User as User exposing (User, Username)
import Route exposing (Route)


type ActivePage
    = Other
    | LaborDelIpp


frame : Maybe Window.Size -> Bool -> Maybe PregnancyId -> Maybe User -> ActivePage -> Html msg -> Html msg
frame winSize isLoading pregId user page content =
    H.div
        -- Set the font-family, etc. to use for everything within.
        [ HA.class "c-text"
        ]
        [ viewHeader winSize pregId user isLoading page
        , H.div
            []
            [ content ]
        ]


{-| Display the navigation menus at the top, adjusting for the size of the screen.
-}
viewHeader : Maybe Window.Size -> Maybe PregnancyId -> Maybe User -> Bool -> ActivePage -> Html msg
viewHeader winSize pregId user isLoading page =
    let
        toPrenatalUrl =
            case pregId of
                Just p ->
                    "/toprenatal/" ++ (toString <| getPregId p)

                Nothing ->
                    "/toprenatal"

        _ =
            Debug.log "viewHeader" <| toString page
    in
        case winSize of
            Nothing ->
                H.text "Loading ..."

            Just size ->
                case size.width >= Const.breakpointMedium of
                    True ->
                        -- Nexus 7 size and above.
                        H.div []
                            [ H.div [ HA.class "navigation-larger" ]
                                [ H.ul
                                    -- Top navigation bar.
                                    [ HA.class "c-nav c-nav--inline primary-bg primary-contrast-fg" ]
                                    [ (buildNavItem Large False False (AsRoute Route.LaborDelIpp) "Midwife-EMR")
                                    , (buildNavItem (FA "fa fa-sign-out") True False (AsLink "/logout") " Logout")
                                    , (buildNavItem (FA "fa fa-file-text") True False (AsRoute Route.LaborDelIpp) " Reports")
                                    , (buildNavItem (FA "fa fa-stethoscope") True False (AsLink toPrenatalUrl) " Prenatal")
                                    ]
                                , H.ul
                                    -- Bottom navigation bar.
                                    [ HA.class "c-nav c-nav--inline nav-override-small accent-bg accent-contrast-fg" ]
                                    [ (buildNavItem Small False (page == LaborDelIpp) (AsRoute Route.LaborDelIpp) "Labor-Delivery-IPP")
                                    , (buildNavItem Small False False (AsRoute Route.LaborDelIpp) "Cont-Postpartum")
                                    , (buildNavItem Small False False (AsRoute Route.LaborDelIpp) "Postpartum")
                                    , (buildNavItem Small False False (AsRoute Route.LaborDelIpp) "Birth-Cert")
                                    ]
                                ]
                            ]

                    False ->
                        -- Smaller than Nexus 7.
                        case size.width < Const.breakpointSmall of
                            True ->
                                -- Small phone.
                                -- TODO: if we are doing this, should not load content either.
                                H.text "Sorry, the application cannot run on this device."

                            False ->
                                -- Large phone, small tablet.
                                H.div []
                                    [ H.div [ HA.class "navigation-larger" ]
                                        [ H.ul
                                            -- Top navigation bar.
                                            [ HA.class "c-nav c-nav--inline primary-bg primary-contrast-fg" ]
                                            [ (buildNavItem Large False False (AsRoute Route.LaborDelIpp) "Midwife-EMR")
                                            , (buildNavItem (FA "fa fa-sign-out") True False (AsLink "/logout") " Logout")
                                            , (buildNavItem (FA "fa fa-file-text") True False (AsRoute Route.LaborDelIpp) " Reports")
                                            , (buildNavItem (FA "fa fa-stethoscope") True False (AsLink toPrenatalUrl) " Prenatal")
                                            ]
                                        , H.ul
                                            -- Bottom navigation bar.
                                            [ HA.class "c-nav c-nav--inline nav-override-small accent-bg accent-contrast-fg" ]
                                            [ (buildNavItem Small False (page == LaborDelIpp) (AsRoute Route.LaborDelIpp) "LD")
                                            , (buildNavItem Small False False (AsRoute Route.LaborDelIpp) "CPP")
                                            , (buildNavItem Small False False (AsRoute Route.LaborDelIpp) "PP")
                                            , (buildNavItem Small False False (AsRoute Route.LaborDelIpp) "Cert")
                                            ]
                                        ]
                                    ]


{-| The size to render the "text" of the menu item, or
in the case of font-awesome, the class string to use
to render the icon.
-}
type NavType
    = Small
    | Medium
    | Large
    | FA String


{-| AsLink links leave the SPA and AsRoute links route
within the SPA.
-}
type LinkType
    = AsRoute Route
    | AsLink String


{-| Builds out a navigation link for either a Route or an href,
using either Font-Awesome icon or not with various font sizes,
and optionally pulling right and differentiating an active link.
-}
buildNavItem : NavType -> Bool -> Bool -> LinkType -> String -> Html msg
buildNavItem navType pullRight isActive linkType text =
    H.li
        [ HA.class
            ("c-nav__item"
                ++ if pullRight then
                    " c-nav__item--right"
                   else
                    ""
            )
        ]
        [ H.a
            [ case linkType of
                AsRoute route ->
                    Route.href route

                AsLink link ->
                    HA.href link
            , HA.class "headerLink"
            ]
            (case navType of
                Small ->
                    [ H.span
                        [ HA.class "u-small"
                        , if isActive then
                            HA.class "c-text--loud"
                          else
                            HA.class ""
                        ]
                        [ H.text text ]
                    ]

                Medium ->
                    [ H.span
                        [ HA.class "u-medium"
                        , if isActive then
                            HA.class "c-text--loud"
                          else
                            HA.class ""
                        ]
                        [ H.text text ]
                    ]

                Large ->
                    [ H.span
                        [ HA.class "u-xlarge"
                        , if isActive then
                            HA.class "c-text--loud"
                          else
                            HA.class ""
                        ]
                        [ H.text text ]
                    ]

                FA str ->
                    [ H.i
                        [ HA.class str ]
                        []
                    , H.span
                        [ if isActive then
                            HA.class "c-text--loud"
                          else
                            HA.class ""
                        , HA.class "nav-item-has-icon"
                        ]
                        [ H.text text ]
                    ]
            )
        ]
