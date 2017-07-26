module Route exposing (Route(..), fromLocation, href, modifyUrl)

import Html exposing (Attribute)
import Html.Attributes as HA
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)

-- ROUTING --

type Route
    = LaborDelIpp


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map LaborDelIpp (s "")
        ]

-- INTERNAL --

routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                LaborDelIpp ->
                    [ ]
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
        Just LaborDelIpp
    else
        parseHash route location
