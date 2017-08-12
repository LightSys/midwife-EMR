module Views.PregnancyHeader
    exposing
        ( viewPrenatal
        )

import Date
import Html as H exposing (Html)
import Html.Attributes as HA
import Time exposing (Time)
import Time.DateTime as TDT


-- LOCAL IMPORTS --

import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (PregnancyRecord)
import Util as U


{-| Note that the currTime passed is currently static, though it
will have been accurate as of when this page was first called.

TODO: refactor to work on tablets and phones.
-}
viewPrenatal : PatientRecord -> PregnancyRecord -> Time -> Html msg
viewPrenatal patRec pregRec currTime =
    H.div [ HA.class "o-grid u-high pregnancy-header-bg" ]
        [ H.div [ HA.class "o-grid__cell o-grid__cell--width-33" ]
            [ prenatalColumnOne patRec pregRec ]
        , H.div [ HA.class "o-grid__cell o-grid__cell--width-33" ]
            [ prenatalColumnTwo patRec pregRec currTime ]
        , H.div [ HA.class "o-grid__cell o-grid__cell--width-33" ]
            [ prenatalColumnThree patRec pregRec currTime ]
        ]


prenatalColumnOne : PatientRecord -> PregnancyRecord -> Html msg
prenatalColumnOne patRec pregRec =
    H.div []
        [ H.div [ HA.class "c-text--loud" ]
            [ H.text <| pregRec.lastname ++ ", " ++ pregRec.firstname ]
        , H.div []
            [ fieldLabel "Nickname"
            , fieldValue pregRec.nickname
            ]
        , H.div []
            [ fieldLabel "G"
            , fieldValue <| Maybe.map toString pregRec.gravida
            , H.span [] [ H.text " " ]
            , fieldLabelWithClass "margin-left-abit" "P"
            , fieldValue <| Maybe.map toString pregRec.para
            , H.span [] [ H.text " " ]
            , fieldLabelWithClass "margin-left-abit" "A"
            , fieldValue <| Maybe.map toString pregRec.abortions
            , H.span [] [ H.text " " ]
            , fieldLabelWithClass "margin-left-abit" "S"
            , fieldValue <| Maybe.map toString pregRec.stillBirths
            , H.span [] [ H.text " " ]
            , fieldLabelWithClass "margin-left-abit" "L"
            , fieldValue <| Maybe.map toString pregRec.living
            ]
        ]

prenatalColumnTwo : PatientRecord -> PregnancyRecord -> Time -> Html msg
prenatalColumnTwo patRec pregRec currTime =
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

        lmp =
            case pregRec.lmp of
                Just lmp ->
                    Just <| U.dateToDateString lmp "-"

                Nothing ->
                    Just ""
    in
        H.div []
            [ H.div [ HA.style [ ("position", "relative") ] ]
                [ fieldLabelWithClass "align-right-3em" "Age"
                , fieldValue age
                ]
            , H.div []
                [ fieldLabelWithClass "align-right-3em" "id"
                , fieldValue <| Just (U.formatDohId patRec.dohID)
                ]
            , H.div []
                [ fieldLabelWithClass "align-right-3em" "LMP"
                , fieldValue lmp
                ]
            ]

prenatalColumnThree : PatientRecord -> PregnancyRecord -> Time -> Html msg
prenatalColumnThree patRec pregRec currTime =
    let
        edd =
            case (pregRec.lmp, pregRec.useAlternateEdd, pregRec.alternateEdd) of
                (Just lmp, Just useAlt, Just altEdd) ->
                    if useAlt then
                        Just altEdd
                    else
                        U.calcEdd (Just lmp)

                (Just lmp, _, _) ->
                    U.calcEdd (Just lmp)

                (_, _, _) ->
                    Nothing

        eddString =
            case edd of
                Just ed ->
                    U.dateToDateString ed "-"

                Nothing ->
                    ""
        ga =
            case edd of
                Just ed ->
                    U.getGA ed (Date.fromTime currTime)

                Nothing ->
                    ""
    in
        H.div []
            [ H.div []
                [ fieldLabelWithClass "align-right-5em" "Curr GA"
                , fieldValue <| Just ga
                ]
            , H.div []
                [ fieldLabelWithClass "align-right-5em" "Prenatal"
                -- TODO: replace hard code with actual from schedule table.
                , fieldValue <| Just "Tue @ Mercy"
                ]
            , H.div []
                [ fieldLabelWithClass "align-right-5em" "EDD"
                , fieldValue <| Just eddString
                ]
            ]

fieldLabel : String -> Html msg
fieldLabel lbl =
    H.span [ HA.class "c-text--quiet" ]
        [ H.text <| lbl ++ ": " ]


fieldLabelWithClass : String -> String -> Html msg
fieldLabelWithClass class lbl =
    H.span [ HA.class <| "c-text--quiet " ++ class ]
        [ H.text <| lbl ++ ": " ]


fieldValue : Maybe String -> Html msg
fieldValue val =
    H.span [ HA.class "c-text--loud c-text--mono" ]
        [ H.text <| Maybe.withDefault "" val ]
