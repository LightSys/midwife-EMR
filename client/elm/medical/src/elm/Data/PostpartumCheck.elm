module Data.PostpartumCheck
    exposing
        ( Breasts(..)
        , ColorSkin(..)
        , Cord(..)
        , FamilyPlanning(..)
        , Feeding(..)
        , getPostpartumId
        , Lochia(..)
        , Lungs(..)
        , Perineum(..)
        , PostpartumCheck
        , PostpartumId(..)
        , Skin(..)
        , SSInfectionBaby(..)
        , SSInfectionMother(..)
        , Stool(..)
        , Urine(..)
        )

import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP


type PostpartumId
    = PostpartumId Int


getPostpartumId : PostpartumId -> Int
getPostpartumId (PostpartumId id) =
    id


type Lungs
    = ClearBilaterallyLungs
    | CrackelsPresentLungs
    | WheezesPresentLungs
    | ErrorLungs


lungs : JD.Decoder String -> JD.Decoder Lungs
lungs =
    JD.map stringToLungs


stringToLungs : String -> Lungs
stringToLungs str =
    case str of
        "clear" ->
            ClearBilaterallyLungs

        "crackels" ->
            CrackelsPresentLungs

        "wheezes" ->
            WheezesPresentLungs

        _ ->
            ErrorLungs


lungsToString : Lungs -> String
lungsToString lungs =
    case lungs of
        ClearBilaterallyLungs ->
            "clear"

        CrackelsPresentLungs ->
            "crackels"

        WheezesPresentLungs ->
            "wheezes"

        ErrorLungs ->
            "error"


type ColorSkin
    = PinkColorSkin
    | JaundiceMildColorSkin
    | JaundiceModerateColorSkin
    | JaundiceSevereColorSkin
    | PaleColorSkin
    | ErrorColorSkin


colorSkin : JD.Decoder String -> JD.Decoder ColorSkin
colorSkin =
    JD.map stringToColorSkin


stringToColorSkin : String -> ColorSkin
stringToColorSkin str =
    case str of
        "pink" ->
            PinkColorSkin

        "jaundiceMild" ->
            JaundiceMildColorSkin

        "JaundiceModerate" ->
            JaundiceModerateColorSkin

        "JaundiceSevere" ->
            JaundiceSevereColorSkin

        "pale" ->
            PaleColorSkin

        _ ->
            ErrorColorSkin


colorSkinToString : ColorSkin -> String
colorSkinToString cs =
    case cs of
        PinkColorSkin ->
            "pink"

        JaundiceMildColorSkin ->
            "jaundiceMild"

        JaundiceModerateColorSkin ->
            "jaundiceModerate"

        JaundiceSevereColorSkin ->
            "jaundiceSevere"

        PaleColorSkin ->
            "pale"

        ErrorColorSkin ->
            "error"


type Skin
    = PeelingSkin
    | RashSkin
    | SmoothMoistSkin
    | CradleCopSkin
    | ErrorSkin


skin : JD.Decoder String -> JD.Decoder Skin
skin =
    JD.map stringToSkin


stringToSkin : String -> Skin
stringToSkin str =
    case str of
        "peeling" ->
            PeelingSkin

        "rash" ->
            RashSkin

        "smoothMoist" ->
            SmoothMoistSkin

        "cradleCop" ->
            CradleCopSkin

        _ ->
            ErrorSkin


skinToString : Skin -> String
skinToString skin =
    case skin of
        PeelingSkin ->
            "peeling"

        RashSkin ->
            "rash"

        SmoothMoistSkin ->
            "smoothMoist"

        CradleCopSkin ->
            "cradleCop"

        ErrorSkin ->
            "error"


type Cord
    = DryCord
    | HealingCord
    | ClampRemovedCord
    | NoRednessCord
    | NoOdorCord
    | NoDischargeCord
    | StumpAbsentCord
    | GranulomaCord
    | BleedingCord



-- TODO: make decoders for here and below.


type SSInfectionBaby
    = AbsentSSInfectionBaby
    | FeverSSInfectionBaby
    | CoughSSInfectionBaby
    | RetractionsSSInfectionBaby
    | TachycordiaSSInfectionBaby
    | TachypneaSSInfectionBaby


type Feeding
    = BreastOnlyFeeding
    | MixedFeeding
    | BottleFeeding


type Breasts
    = SoftBreasts
    | FillingBreasts
    | MilkinBreasts
    | EngorgedBreasts
    | InflammedBreasts
    | PainfulBreasts
    | MastitisBreasts
    | CrackedNippleLeftBreasts
    | CrackedNippleRightBreasts
    | SoresBreasts


type Perineum
    = IntactPerineum
    | HealingWellPerineum
    | SwollenPerineum
    | RedPerineum
    | DischargePerineum
    | OdorPerineum
    | LacerationWellApproximatedPerineum


type Lochia
    = RedLochia
    | PinkLochia
    | WhiteLochia
    | AbundantLochia
    | ModerateLochia
    | ScantLochia
    | NoneLochia
    | OdorLochia
    | ClotsLochia


type Urine
    = NormalUrine
    | PainfulUrine


type Stool
    = YesStool
    | NoStool
    | PainfulStool
    | HemorrhoidsStool


type SSInfectionMother
    = NoneSSInfectionMother
    | FeverSSINfectionMother
    | TachycordiaSSInfectionMother
    | BreastSymptomsSSInfectionMother
    | PerineumSSInfectionMother
    | UterusSSInfectionMother


type FamilyPlanning
    = PillsFamilyPlanning
    | IUDFamilyPlanning
    | NaturalFamilyPlanning
    | CondomsFamilyPlanning
    | ImplanonFamilyPlanning
    | TubalLigationFamilyPlanning
    | DepoFamilyPlanning


type alias PostpartumCheck =
    { id : Int
    , datetime : Date
    , examiner : String
    , b_weight : Int
    , b_hr : Int
    , b_temp : Float
    , b_rr : Int
    , b_lungs : List Lungs
    , b_color : List ColorSkin
    , b_skin : List Skin
    , b_cord : List Cord
    , b_urine : Int
    , b_stool : Int
    , b_ssInfection : List SSInfectionBaby
    , b_feeding : List Feeding
    , b_feedingFreq : Int
    , b_comments : Maybe String
    , m_temp : Float
    , m_systolic : Int
    , m_diastolic : Int
    , m_hr : Int
    , m_breasts : List Breasts
    , m_perineum : List Perineum
    , m_lochia : List Lochia
    , m_urine : List Urine
    , m_stool : List Stool
    , m_ssInfection : List SSInfectionMother
    , m_nbrIron : Int
    , m_hgb : Int
    , m_birthCertRequired : Bool
    , m_familyPlanning : List FamilyPlanning
    , m_comments : Maybe String
    , m_nextVisit : Maybe Date
    }
