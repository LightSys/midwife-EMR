module Views.Utils exposing (..)

import Html exposing (Html)
import Html.Attributes as HA
import Material
import Material.Color as MColor
import Material.Elevation as Elevation
import Material.Footer as Footer
import Material.Grid as Grid
import Material.Options as Options exposing (Property)


fullSizeCellOpts : List (Property () a)
fullSizeCellOpts =
    [ Grid.size Grid.Desktop 12
    , Grid.size Grid.Tablet 8
    , Grid.size Grid.Phone 4
    ]


footerMini : String -> String -> Html m
footerMini headerText bodyText =
    Footer.mini
        [ MColor.text MColor.white
        , Elevation.e6
        ]
        { left =
            Footer.left []
                [ Footer.html <|
                    Html.div
                        [ HA.class "footer-warning-header" ]
                        [ Html.text headerText ]
                ]
        , right =
            Footer.right []
                [ Footer.html <| Html.text bodyText ]
        }
