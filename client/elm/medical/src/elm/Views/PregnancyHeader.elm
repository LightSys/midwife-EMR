module Views.PregnancyHeader
    exposing
        ( view
        , PregHeaderContent(..)
        )

import Date exposing (Date)
import Date.Extra.Duration as DED
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Encode as JE
import Time exposing (Time)
import Window


-- LOCAL IMPORTS --

import Const
import Data.Labor exposing (LaborRecord)
import Data.LaborDelIpp exposing (SubMsg(..))
import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (PregnancyRecord)
import Util as U


type PregHeaderContent
    = PrenatalContent
    | LaborContent
    | IPPContent


{-| Delegate to the appropriate view.
-}
view :
    PatientRecord
    -> PregnancyRecord
    -> Maybe (List LaborRecord)
    -> PregHeaderContent
    -> Time
    -> Maybe Window.Size
    -> Html SubMsg
view patRec pregRec laborRecs pregHeaderCnt currTime winSize =
    case pregHeaderCnt of
        PrenatalContent ->
            viewPrenatal patRec pregRec laborRecs pregHeaderCnt currTime winSize

        LaborContent ->
            viewLabor patRec pregRec laborRecs pregHeaderCnt currTime winSize

        IPPContent ->
            viewIPP patRec pregRec laborRecs pregHeaderCnt currTime winSize


viewLabor :
    PatientRecord
    -> PregnancyRecord
    -> Maybe (List LaborRecord)
    -> PregHeaderContent
    -> Time
    -> Maybe Window.Size
    -> Html SubMsg
viewLabor patRec pregRec laborRecs pregHeaderCnt currTime winSize =
    let
        ( nickname, edd ) =
            ( getNickname pregRec, getEdd pregRec )

        laborRec =
            case laborRecs of
                Just recs ->
                    List.reverse recs
                        |> List.head

                Nothing ->
                    Nothing

        partnerName =
            case ( pregRec.partnerFirstname, pregRec.partnerLastname ) of
                ( Just first, Just last ) ->
                    Just <| last ++ ", " ++ first

                ( _, _ ) ->
                    Nothing
    in
        H.div [ HA.class "c-card c-card--accordion pregnancy-header-wrapper" ]
            [ H.input
                [ HA.type_ "checkbox"
                , HA.checked True
                  -- Default accordion to open at start.
                , HA.id "pregnancy_header_accordion"
                ]
                []
            , H.label [ HA.class "c-text--loud c-card__item", HA.for "pregnancy_header_accordion" ]
                [ H.span [] [ H.text <| pregRec.lastname ++ ", " ++ pregRec.firstname ++ nickname ++ " " ]
                , (getGaSpan edd currTime)
                , prenatalLaborIppButton pregHeaderCnt
                ]
            , H.div [ HA.class "c-card__item pregnancy-header" ]
                [ headerColumnOne patRec pregRec currTime partnerName
                , laborColumnTwo laborRec
                , laborColumnThree laborRec
                ]
            ]


viewIPP :
    PatientRecord
    -> PregnancyRecord
    -> Maybe (List LaborRecord)
    -> PregHeaderContent
    -> Time
    -> Maybe Window.Size
    -> Html SubMsg
viewIPP patRec pregRec laborRecs pregHeaderCnt currTime winSize =
    prenatalLaborIppButton pregHeaderCnt


viewPrenatal :
    PatientRecord
    -> PregnancyRecord
    -> Maybe (List LaborRecord)
    -> PregHeaderContent
    -> Time
    -> Maybe Window.Size
    -> Html SubMsg
viewPrenatal patRec pregRec laborRecs pregHeaderCnt currTime winSize =
    let
        ( nickname, edd ) =
            ( getNickname pregRec, getEdd pregRec )
    in
        H.div [ HA.class "c-card c-card--accordion pregnancy-header-wrapper" ]
            [ H.input
                [ HA.type_ "checkbox"
                , HA.checked True
                  -- Default accordion to open at start.
                , HA.id "pregnancy_header_accordion"
                ]
                []
            , H.label [ HA.class "c-text--loud c-card__item", HA.for "pregnancy_header_accordion" ]
                [ H.span [] [ H.text <| pregRec.lastname ++ ", " ++ pregRec.firstname ++ nickname ++ " " ]
                , (getGaSpan edd currTime)
                , prenatalLaborIppButton pregHeaderCnt
                ]
            , H.div [ HA.class "c-card__item pregnancy-header" ]
                [ headerColumnOne patRec pregRec currTime Nothing
                , prenatalColumnTwo patRec pregRec currTime
                , prenatalColumnThree patRec pregRec currTime
                ]
            ]


getNickname : PregnancyRecord -> String
getNickname pregRec =
    case pregRec.nickname of
        Just nn ->
            if String.length nn > 0 then
                " (" ++ nn ++ ")"
            else
                ""

        Nothing ->
            ""


getEdd : PregnancyRecord -> Maybe Date
getEdd pregRec =
    case ( pregRec.lmp, pregRec.useAlternateEdd, pregRec.alternateEdd ) of
        ( Just lmp, Just useAlt, Just altEdd ) ->
            if useAlt then
                Just altEdd
            else
                U.calcEdd (Just lmp)

        ( Just lmp, _, _ ) ->
            U.calcEdd (Just lmp)

        ( _, _, _ ) ->
            Nothing


{-| Display the GA with a non-breaking space serving as
the whitespace.
-}
getGaSpan : Maybe Date -> Time -> Html msg
getGaSpan edd currTime =
    case edd of
        Just ed ->
            let
                ( wks, days ) =
                    U.getGA ed (Date.fromTime currTime)
            in
                U.nbsp wks days

        Nothing ->
            H.span [] []


pregHeaderContentToString : PregHeaderContent -> String
pregHeaderContentToString phc =
    case phc of
        PrenatalContent ->
            "Prenatal"

        IPPContent ->
            "IPP"

        LaborContent ->
            "Labor"


prenatalLaborIppButton : PregHeaderContent -> Html SubMsg
prenatalLaborIppButton phc =
    H.span [ HA.style [ ( "margin-left", "2em" ) ], HA.class "u-xsmall" ]
        [ H.button
            [ HA.style [ ( "margin-left", "2em" ) ]
            , HA.class "u-pillar-box--large u-high c-button c-button--ghost-brand"
            , HE.onClick NextPregHeaderContent
            ]
            [ H.text <| pregHeaderContentToString phc ]
        ]


headerColumnOne : PatientRecord -> PregnancyRecord -> Time -> Maybe String -> Html msg
headerColumnOne patRec pregRec currTime partnerName =
    let
        age =
            case patRec.dob of
                Just dob ->
                    -- Date.Extra.Duration.diff can return a positive year and
                    -- negative month when the birthday is the current month.
                    DED.diff (Date.fromTime currTime) dob
                        |> (\d ->
                                if d.month < 0 then
                                    d.year - 1
                                else
                                    d.year
                           )
                        |> toString
                        |> flip (++) " ("
                        |> flip (++) (U.dateToDateMonString dob "-")
                        |> flip (++) ")"
                        |> Just

                Nothing ->
                    Just ""
    in
        H.div [ HA.class "pregnancy-header-col" ]
            [ H.div [ HA.class "pregnancy-header-fldval" ]
                [ fieldLabel "G" "3em"
                , fieldValue <| Maybe.map toString pregRec.gravida
                , H.span [] [ H.text " " ]
                , fieldLabel "P" "1.5em"
                , fieldValue <| Maybe.map toString pregRec.para
                , H.span [] [ H.text " " ]
                , fieldLabel "A" "1.5em"
                , fieldValue <| Maybe.map toString pregRec.abortions
                , H.span [] [ H.text " " ]
                , fieldLabel "S" "1.5em"
                , fieldValue <| Maybe.map toString pregRec.stillBirths
                , H.span [] [ H.text " " ]
                , fieldLabel "L" "1.5em"
                , fieldValue <| Maybe.map toString pregRec.living
                ]
            , H.div [ HA.class "pregnancy-header-fldval" ]
                [ fieldLabel "Age" "3em"
                , fieldValue age
                ]
            , if partnerName /= Nothing then
                H.div [ HA.class "pregnancy-header-fldval" ]
                    [ fieldLabel "Ptnr" "3em"
                    , fieldValue partnerName
                    ]
              else
                H.span [] []
            ]


laborColumnTwo : Maybe LaborRecord -> Html msg
laborColumnTwo laborRec =
    let
        ( admitVal, laborVal, pos, fh, fht ) =
            case laborRec of
                Just lr ->
                    ( U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep lr.admittanceDate
                    , U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep lr.startLaborDate
                    , lr.pos
                    , toString lr.fh
                    , toString lr.fht
                    )

                Nothing ->
                    ( "", "", "", "", "" )
    in
        H.div [ HA.class "pregnancy-header-col" ]
            [ H.div [ HA.class "pregnancy-header-fldval" ]
                [ fieldLabel "Lbr" "3em"
                , fieldValue <| Just laborVal
                ]
            , H.div [ HA.class "pregnancy-header-fldval" ]
                [ fieldLabel "Admt" "3em"
                , fieldValue <| Just admitVal
                ]
            , H.div [ HA.class "pregnancy-header-fldval" ]
                [ fieldLabel "POS" "3em"
                , fieldValue <| Just pos
                , H.span [] [ H.text " " ]
                , fieldLabel "FH" "2.0em"
                , fieldValue <| Just fh
                , H.span [] [ H.text " " ]
                , fieldLabel "FHT" "2.5em"
                , fieldValue <| Just fht
                ]
            ]


laborColumnThree : Maybe LaborRecord -> Html msg
laborColumnThree laborRec =
    let
        ( bp, cr, temp ) =
            case laborRec of
                Just lr ->
                    ( (toString lr.systolic) ++ "/" ++ (toString lr.diastolic)
                    , toString lr.cr
                    , toString lr.temp
                    )

                Nothing ->
                    ( "", "", "" )
    in
        H.div [ HA.class "pregnancy-header-col" ]
            [ H.div [ HA.class "pregnancy-header-fldval" ]
                [ fieldLabel "BP" "3em"
                , fieldValue <| Just bp
                ]
            , H.div [ HA.class "pregnancy-header-fldval" ]
                [ fieldLabel "CR" "3em"
                , fieldValue <| Just cr
                ]
            , H.div [ HA.class "pregnancy-header-fldval" ]
                [ fieldLabel "Temp" "3em"
                , fieldValue <| Just temp
                ]
            ]


prenatalColumnTwo : PatientRecord -> PregnancyRecord -> Time -> Html msg
prenatalColumnTwo patRec pregRec currTime =
    let
        lmp =
            case pregRec.lmp of
                Just lmp ->
                    U.dateToDateMonString lmp "-"

                Nothing ->
                    ""

        edd =
            getEdd pregRec

        eddString =
            case edd of
                Just ed ->
                    U.dateToDateMonString ed "-"

                Nothing ->
                    ""
    in
        H.div [ HA.class "pregnancy-header-col" ]
            [ H.div [ HA.class "pregnancy-header-fldval" ]
                [ fieldLabel "LMP" "3em"
                , fieldValue <| Just lmp
                ]
            , H.div [ HA.class "pregnancy-header-fldval" ]
                [ fieldLabel "EDD" "3em"
                , fieldValue <| Just eddString
                ]
            ]


prenatalColumnThree : PatientRecord -> PregnancyRecord -> Time -> Html msg
prenatalColumnThree patRec pregRec currTime =
    H.div [ HA.class "pregnancy-header-col" ]
        [ H.div [ HA.class "pregnancy-header-fldval" ]
            [ fieldLabel "ID" "3em"
            , fieldValue <| Just (U.formatDohId patRec.dohID)
            ]
        , H.div [ HA.class "pregnancy-header-fldval" ]
            [ fieldLabel "Appt" "3em"
              -- TODO: replace hard code with actual from schedule table.
            , fieldValue <| Just "Tue @ MMC"
            ]
        ]


fieldLabel : String -> String -> Html msg
fieldLabel lbl minWidth =
    H.span
        [ HA.style [ ( "min-width", minWidth ) ]
        , HA.class "c-text--quiet u-xsmall pregnancy-header-fld"
        ]
        [ H.text <| lbl ++ ": " ]


fieldValue : Maybe String -> Html msg
fieldValue val =
    H.span [ HA.class "c-text--loud c-text--mono u-small pregnancy-header-val" ]
        [ H.text <| Maybe.withDefault "" val ]
