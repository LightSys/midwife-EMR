module Const exposing (..)


{-| Medium phone size.
-}
breakpointSmall : Int
breakpointSmall =
    300

{-| Nexus 7 in portrait.
-}
breakpointMedium : Int
breakpointMedium =
    600

{-| Larger tablets and desktop, etc.
-}
breakpointLarge : Int
breakpointLarge =
    992

{-| Form field type.
-}
type FldChgValue
    = FldChgString String
    | FldChgBool Bool

