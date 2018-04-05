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
    | FldChgIntString Int String
    | FldChgStringList String Bool


{-| Type of dialog.
-}
type Dialog
    = OpenDialog
    | CloseNoSaveDialog
    | CloseSaveDialog
    | EditDialog



-- Various strings matching the name field of the selectData table. --


newbornExamAbdomen : String
newbornExamAbdomen =
    "newbornExamAbdomen"


newbornExamAnus : String
newbornExamAnus =
    "newbornExamAnus"


newbornExamAppearance : String
newbornExamAppearance =
    "newbornExamAppearance"


newbornExamBack : String
newbornExamBack =
    "newbornExamBack"


newbornExamChest : String
newbornExamChest =
    "newbornExamChest"


newbornExamColor : String
newbornExamColor =
    "newbornExamColor"


newbornExamCord : String
newbornExamCord =
    "newbornExamCord"


newbornExamEars : String
newbornExamEars =
    "newbornExamEars"


newbornExamExtremities : String
newbornExamExtremities =
    "newbornExamExtremities"


newbornExamEyes : String
newbornExamEyes =
    "newbornExamEyes"


newbornExamFemoralPulses : String
newbornExamFemoralPulses =
    "newbornExamFemoralPulses"


newbornExamGenitaliaFemale : String
newbornExamGenitaliaFemale =
    "newbornExamGenitaliaFemale"


newbornExamGenitaliaMale : String
newbornExamGenitaliaMale =
    "newbornExamGenitaliaMale"


newbornExamHead : String
newbornExamHead =
    "newbornExamHead"


newbornExamHeart : String
newbornExamHeart =
    "newbornExamHeart"


newbornExamHips : String
newbornExamHips =
    "newbornExamHips"


newbornExamLungs : String
newbornExamLungs =
    "newbornExamLungs"


newbornExamMouth : String
newbornExamMouth =
    "newbornExamMouth"


newbornExamNeck : String
newbornExamNeck =
    "newbornExamNeck"


newbornExamNose : String
newbornExamNose =
    "newbornExamNose"


newbornExamSkin : String
newbornExamSkin =
    "newbornExamSkin"

postpartumCheckBabyLungs : String
postpartumCheckBabyLungs =
    "postpartumCheckBabyLungs"

postpartumCheckBabyColor : String
postpartumCheckBabyColor =
    "postpartumCheckBabyColor"

postpartumCheckBabySkin : String
postpartumCheckBabySkin =
    "postpartumCheckBabySkin"

postpartumCheckBabyCord : String
postpartumCheckBabyCord =
    "postpartumCheckBabyCord"

postpartumCheckBabySSInfection : String
postpartumCheckBabySSInfection =
    "postpartumCheckBabySSInfection"

postpartumCheckBabyFeeding : String
postpartumCheckBabyFeeding =
    "postpartumCheckBabyFeeding"

postpartumCheckMotherBreasts : String
postpartumCheckMotherBreasts =
    "postpartumCheckMotherBreasts"

postpartumCheckMotherFundus : String
postpartumCheckMotherFundus =
    "postpartumCheckMotherFundus"

postpartumCheckMotherPerineum : String
postpartumCheckMotherPerineum =
    "postpartumCheckMotherPerineum"

postpartumCheckMotherLochia : String
postpartumCheckMotherLochia =
    "postpartumCheckMotherLochia"

postpartumCheckMotherUrine : String
postpartumCheckMotherUrine =
    "postpartumCheckMotherUrine"

postpartumCheckMotherStool : String
postpartumCheckMotherStool =
    "postpartumCheckMotherStool"

postpartumCheckMotherSSInfection : String
postpartumCheckMotherSSInfection =
    "postpartumCheckMotherSSInfection"

postpartumCheckMotherFamilyPlanning : String
postpartumCheckMotherFamilyPlanning =
    "postpartumCheckMotherFamilyPlanning"


