module Views.PregnancyHeader
    exposing
        ( viewPrenatal
        )

import Date
import Html as H exposing (Html)
import Html.Attributes as HA
import Json.Encode as JE
import Time exposing (Time)
import Time.DateTime as TDT
import Window


-- LOCAL IMPORTS --

import Const
import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (PregnancyRecord)
import Util as U


{-| Note that the currTime passed is currently static, though it
will have been accurate as of when this page was first called.
-}
viewPrenatal : PatientRecord -> PregnancyRecord -> Time -> Maybe Window.Size -> Html msg
viewPrenatal patRec pregRec currTime winSize =
    let
        nickname =
            case pregRec.nickname of
                Just nn ->
                    if String.length nn > 0 then
                        " (" ++ nn ++ ")"
                    else
                        ""

                Nothing ->
                    ""

        edd =
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

        -- Display the GA with a non-breaking space serving as the whitespace.
        gaSpan =
            case edd of
                Just ed ->
                    let
                        ( wks, days ) =
                            U.getGA ed (Date.fromTime currTime)
                    in
                        U.nbsp wks days

                Nothing ->
                    H.span [] []
    in
        H.div [ HA.class "c-card c-card--accordion pregnancy-header-wrapper" ]
            [ H.input [ HA.type_ "checkbox", HA.id "pregnancy_header_accordion" ] []
            , H.label [ HA.class "c-text--loud c-card__item", HA.for "pregnancy_header_accordion" ]
                [ H.span [] [ H.text <| pregRec.lastname ++ ", " ++ pregRec.firstname ++ nickname ++ " " ]
                , gaSpan
                ]
            , H.div [ HA.class "c-card__item pregnancy-header" ]
                [ prenatalColumnOne patRec pregRec currTime
                , prenatalColumnTwo patRec pregRec currTime
                , prenatalColumnThree patRec pregRec currTime
                ]
            ]


prenatalColumnOne : PatientRecord -> PregnancyRecord -> Time -> Html msg
prenatalColumnOne patRec pregRec currTime =
    let
        age =
            case patRec.dob of
                Just dob ->
                    -- Note: the elm-time delta algorithm for years merely subtracts year value
                    -- from each DateTime instance, which can be quite inaccurate if one's bday
                    -- has not yet occurred this year. We do a bit better by using months.
                    TDT.delta (TDT.fromTimestamp currTime) (TDT.fromTimestamp (Date.toTime dob))
                        |> .months
                        |> flip (//) 12
                        |> toString
                        |> flip (++) " ("
                        |> flip (++) (U.dateToDateString dob "-")
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
            ]


prenatalColumnTwo : PatientRecord -> PregnancyRecord -> Time -> Html msg
prenatalColumnTwo patRec pregRec currTime =
    let
        lmp =
            case pregRec.lmp of
                Just lmp ->
                    U.dateToDateString lmp "-"

                Nothing ->
                    ""

        edd =
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

        eddString =
            case edd of
                Just ed ->
                    U.dateToDateString ed "-"

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
