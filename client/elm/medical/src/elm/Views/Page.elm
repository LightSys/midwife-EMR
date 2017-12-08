module Views.Page exposing (ActivePage(..), frame)

import Html as H exposing (Html)
import Html.Attributes as HA
import Window


-- LOCAL IMPORTS --

import Const
import Data.Pregnancy as Pregnancy exposing (getPregId, PregnancyId)
import Data.User as User exposing (User, Username)
import Data.Toast exposing (ToastRecord, ToastType(..))
import Route exposing (Route)


type ActivePage
    = Other
    | Admitting
    | LaborDelIpp


{-| Display the frame including the navigation menus at the top. The
isLoading parameter signals whether there are still outstanding data
requests that this particular page needs in order to display properly.
-}
frame : Maybe Window.Size -> Bool -> Maybe PregnancyId -> Maybe User -> Maybe ToastRecord -> ActivePage -> Html msg -> Html msg
frame winSize isLoading pregId user toastRec page content =
    let
        frameContents =
            H.div
                [ HA.class "o-container o-container--large c-text"
                  -- BlazeCSS: overlays require a parent that with
                  -- a position of relative.
                , HA.style [ ( "position", "relative" ) ]
                ]
                [ toast toastRec
                , viewHeader winSize pregId user isLoading page
                , H.div
                    []
                    [ (if isLoading then
                        viewLoading winSize
                       else
                        content
                      )
                    ]
                ]

        displayContents =
            case winSize of
                Just size ->
                    if size.width < Const.breakpointSmall then
                        H.text "Sorry, this application cannot run on a device this small."
                    else
                        frameContents

                Nothing ->
                    -- Quite odd that we would get here without knowing window size since that
                    -- should be requested as a Cmd in init. Show the frameContents anyway.
                    frameContents
    in
        displayContents


{-| TODO: finish this.
-}
viewLoading : Maybe Window.Size -> Html msg
viewLoading winSize =
    H.div [] [ H.text "Loading ..." ]


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
    in
        H.div []
            [ H.div [ HA.class "navigation-larger" ]
                [ H.ul
                    -- Top navigation bar.
                    [ HA.class "c-nav c-nav--inline primary-bg primary-contrast-fg" ]
                    [ (buildNavItem Large False False (AsRoute Route.LaborDelIppRoute) "Midwife-EMR" "Midwife-EMR")
                    , (buildNavItem (FA "fa fa-sign-out") True False (AsLink "/logout") " Logout" " Logout")
                    , (buildNavItem (FA "fa fa-file-text") True False (AsRoute Route.LaborDelIppRoute) " Reports" " Rpts")
                    , (buildNavItem (FA "fa fa-stethoscope") True False (AsLink toPrenatalUrl) " Prenatal" " Prenatal")
                    ]
                , H.ul
                    -- Bottom navigation bar.
                    [ HA.class "c-nav c-nav--inline nav-override-small accent-bg accent-contrast-fg" ]
                    [ (buildNavItem Small False (page == Admitting) (AsRoute Route.AdmittingRoute) "Admitting" "AD")
                    , (buildNavItem Small False (page == LaborDelIpp) (AsRoute Route.LaborDelIppRoute) "Labor-Delivery-IPP" "LD")
                    , (buildNavItem Small False False (AsRoute Route.LaborDelIppRoute) "Cont-Postpartum" "CPP")
                    , (buildNavItem Small False False (AsRoute Route.LaborDelIppRoute) "Postpartum" "PP")
                    , (buildNavItem Small False False (AsRoute Route.LaborDelIppRoute) "Birth-Cert" "Cert")
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
buildNavItem : NavType -> Bool -> Bool -> LinkType -> String -> String -> Html msg
buildNavItem navType pullRight isActive linkType text smallText =
    let
        outerSpanCls =
            case navType of
                Small ->
                    "u-small"

                Medium ->
                    "u-medium"

                Large ->
                    "u-xlarge"

                _ ->
                    ""
    in
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
                            [ H.span [ HA.class "buildNavItem-text" ]
                                [ H.text text ]
                            , H.span [ HA.class "buildNavItem-smallText" ]
                                [ H.text smallText ]
                            ]
                        ]

                    _ ->
                        [ H.span
                            [ HA.class outerSpanCls
                            , if isActive then
                                HA.class "c-text--loud"
                              else
                                HA.class ""
                            ]
                            [ H.span [ HA.class "buildNavItem-text" ]
                                [ H.text text ]
                            , H.span [ HA.class "buildNavItem-smallText" ]
                                [ H.text smallText ]
                            ]
                        ]
                )
            ]


toast : Maybe ToastRecord -> Html msg
toast toastRec =
    case toastRec of
        Just trec ->
            case trec.toastType of
                InfoToast ->
                    toastInfo trec.msgs

                WarningToast ->
                    toastWarn trec.msgs

                ErrorToast ->
                    toastError trec.msgs

        Nothing ->
            H.text ""

toastInfo : List String -> Html msg
toastInfo msgs =
    let
        doMsg msg =
            H.div [ HA.class "c-alert c-alert--success u-small" ]
                [ H.text msg ]
    in
        H.div [ HA.class "c-alerts c-alerts--topleft" ]
            (List.map doMsg msgs)

toastWarn : List String -> Html msg
toastWarn msgs =
    let
        doMsg msg =
            H.div [ HA.class "c-alert c-alert--warning u-small" ]
                [ H.text msg ]
    in
        H.div [ HA.class "c-alerts c-alerts--topleft" ]
            (List.map doMsg msgs)


toastError : List String -> Html msg
toastError msgs =
    let
        doMsg msg =
            H.div [ HA.class "c-alert c-alert--error u-small" ]
                [ H.text msg ]
    in
        H.div [ HA.class "c-alerts c-alerts--topleft" ]
            (List.map doMsg msgs)
