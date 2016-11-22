module ViewUtils exposing (..)

import Material
import Material.Grid as Grid
import Material.Options as Options exposing (Property)


fullSizeCellOpts : List (Property () a)
fullSizeCellOpts =
    [ Grid.size Grid.Desktop 12
    , Grid.size Grid.Tablet 8
    , Grid.size Grid.Phone 4
    ]
