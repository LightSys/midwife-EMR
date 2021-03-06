module Route
    exposing
        ( addDialogUrl
        , fromLocation
        , href
        , modifyUrl
        , back
        , Route(..)
        )

import Html exposing (Attribute)
import Html.Attributes as HA
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)


-- ROUTING --


type Route
    = AdmittingRoute
    | ContPPRoute
    | ContPPDialogRoute
    | LaborDelIppRoute
    | LaborDelIppDialogRoute
    | PostpartumRoute
    | PostpartumDialogRoute
    | BirthCertificateRoute
    | BirthCertificateDialogRoute


admittingRouteString : String
admittingRouteString =
    ""

contPPRouteString : String
contPPRouteString =
    "contpp"


laborDelIppRouteString : String
laborDelIppRouteString =
    "labordelipp"


postpartumRouteString : String
postpartumRouteString =
    "postpartum"

birthCertificateRouteString : String
birthCertificateRouteString =
    "birthcertificate"

dialogRouteString : String
dialogRouteString =
    "dialog"


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map AdmittingRoute (s admittingRouteString)
        , Url.map ContPPDialogRoute (s contPPRouteString </> s dialogRouteString)
        , Url.map ContPPRoute (s contPPRouteString)
        , Url.map LaborDelIppDialogRoute (s laborDelIppRouteString </> s dialogRouteString)
        , Url.map LaborDelIppRoute (s laborDelIppRouteString)
        , Url.map PostpartumDialogRoute (s postpartumRouteString </> s dialogRouteString)
        , Url.map PostpartumRoute (s postpartumRouteString)
        , Url.map BirthCertificateRoute (s birthCertificateRouteString)
        , Url.map BirthCertificateDialogRoute (s birthCertificateRouteString </> s dialogRouteString)
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                AdmittingRoute ->
                    [ admittingRouteString ]

                BirthCertificateRoute ->
                    [ birthCertificateRouteString ]

                BirthCertificateDialogRoute ->
                    [ birthCertificateRouteString, dialogRouteString ]

                ContPPRoute ->
                    [ contPPRouteString ]

                ContPPDialogRoute ->
                    [ contPPRouteString, dialogRouteString ]

                LaborDelIppRoute ->
                    [ laborDelIppRouteString ]

                LaborDelIppDialogRoute ->
                    [ laborDelIppRouteString, dialogRouteString ]

                PostpartumRoute ->
                    [ postpartumRouteString ]

                PostpartumDialogRoute ->
                    [ postpartumRouteString, dialogRouteString ]
    in
        case List.length pieces of
            0 ->
                "#"

            _ ->
                "#/" ++ String.join "/" pieces



-- PUBLIC HELPERS --


href : Route -> Attribute msg
href route =
    HA.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


addDialogUrl : Route -> Cmd msg
addDialogUrl =
    routeToString >> flip (++) ("/" ++ dialogRouteString) >> Navigation.newUrl


back : Cmd msg
back =
    Navigation.back 1


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just AdmittingRoute
    else
        parseHash route location
