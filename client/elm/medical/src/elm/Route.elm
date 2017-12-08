module Route exposing (Route(..), fromLocation, href, modifyUrl)

import Html exposing (Attribute)
import Html.Attributes as HA
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)

-- ROUTING --

type Route
    = AdmittingRoute
    | LaborDelIppRoute


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map AdmittingRoute (s "")
        , Url.map LaborDelIppRoute (s "labordelipp")
        ]

-- INTERNAL --

routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                AdmittingRoute ->
                    [ ]

                LaborDelIppRoute ->
                    [ "labordelipp" ]
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


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just AdmittingRoute
    else
        parseHash route location
