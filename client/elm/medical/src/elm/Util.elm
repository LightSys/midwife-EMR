module Util
    exposing
        ( (=>)
        , addToMaybeList
        , calcEdd
        , DateFmt(..)
        , DateSep(..)
        , dateToDateMonString
        , dateFormatter
        , datePlusTimeTuple
        , dateTimeHMFormatter
        , dateToStringValue
        , diff2DatesString
        , filterStringLikeInt
        , filterStringLikeFloat
        , filterStringLikeTime
        , formatDohId
        , getGA
        , maybeIntToMaybeBool
        , maybeIntToNegOne
        , maybeDateToValue
        , maybeStringToMaybeFloat
        , maybeStringToMaybeInt
        , maybeStringToIntValue
        , monthToInt
        , nbsp
        , removeTimeFromDate
        , sortDate
        , SortOrder(..)
        , stringToIntBetween
        , stringToTimeString
        , stringToTimeTuple
        , timeToTimeString
        , validateDate
        , validateFloat
        , validateJustTime
        , validateInt
        , validatePopulatedString
        , validateTime
        )

import Char
import Date exposing (Date, Month(..), day, month, year, hour, minute, second)
import Date.Extra.Compare as DEComp
import Date.Extra.Config.Config_en_us as DECC
import Date.Extra.Core as DECore
import Date.Extra.Create as DEC
import Date.Extra.Format as DEF
import Date.Extra.Period as DEP
import Html as H exposing (Html)
import Html.Attributes as HA
import Json.Decode as JD
import Json.Encode as JE
import Time exposing (Time)


-- LOCAL IMPORTS --


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
infixl 0 =>


type SortOrder
    = AscendingSort
    | DescendingSort


sortDate : SortOrder -> Date -> Date -> Order
sortDate sortOrder a b =
    let
        ( comp1, comp2 ) =
            case sortOrder of
                AscendingSort ->
                    ( DEComp.SameOrAfter, DEComp.After )

                DescendingSort ->
                    ( DEComp.SameOrBefore, DEComp.Before )
    in
        case DEComp.is comp1 a b of
            True ->
                case DEComp.is comp2 a b of
                    True ->
                        GT

                    False ->
                        EQ

            False ->
                LT


{-| Convert a String to a Maybe Int if the String can be
converted to an Int and the Int falls between (exclusive of)
the min and max values passed.
-}
stringToIntBetween : Maybe String -> Int -> Int -> Maybe Int
stringToIntBetween str min max =
    case str of
        Just s ->
            case String.toInt s of
                Ok i ->
                    if i < min || i > max then
                        Nothing
                    else
                        Just i

                Err _ ->
                    Nothing

        Nothing ->
            Nothing


{-| Return a String that contains only digits.
-}
filterStringLikeInt : String -> String
filterStringLikeInt str =
    String.toList str
        |> List.filter (\d -> Char.isDigit d)
        |> String.fromList


{-| Return a String that contains only digits or
the decimal point.

TODO: This needs to be localized.
-}
filterStringLikeFloat : String -> String
filterStringLikeFloat str =
    String.toList str
        |> List.filter (\d -> Char.isDigit d || d == '.')
        |> String.fromList


{-| Convert a Maybe String into an appropriate JE.Value
as either a string or null.
-}
maybeStringToIntValue : Maybe String -> JE.Value
maybeStringToIntValue str =
    case str of
        Just s ->
            case String.toInt s of
                Ok i ->
                    JE.int i

                Err _ ->
                    JE.null

        Nothing ->
            JE.null


{-| Returns True if the String is Nothing or
does not have length.
-}
validatePopulatedString : Maybe String -> Bool
validatePopulatedString str =
    case str of
        Just s ->
            String.length s == 0

        Nothing ->
            True


{-| Returns True if the String is Nothing or could not
be contrued as a valid Int. This is used instead of
Validate.ifNotInt because of the Maybe String input.
-}
validateInt : Maybe String -> Bool
validateInt str =
    case str of
        Just s ->
            String.length (filterStringLikeInt s) == 0

        Nothing ->
            True


{-| Returns True if the String is Nothing or could not
be contrued as a valid Float.
-}
validateFloat : Maybe String -> Bool
validateFloat str =
    case str of
        Just s ->
            String.length (filterStringLikeFloat s) == 0

        Nothing ->
            True



-- DATE/TIME Related --


type DateFmt
    = YMDDateFmt
    | MDYDateFmt
    | DMYDateFmt


type DateSep
    = DashDateSep
    | ForwardDateSep
    | BackwardDateSep
    | PeriodDateSep


dateSepToString : DateSep -> String
dateSepToString ds =
    case ds of
        DashDateSep ->
            "-"

        ForwardDateSep ->
            "/"

        BackwardDateSep ->
            "\\"

        PeriodDateSep ->
            "."


monthToInt : Date.Month -> Int
monthToInt =
    DECore.monthToInt


{-| Add hours and minutes to a Date. Will remove any existing
time from the Date passed before adding hours and minutes.
-}
datePlusTimeTuple : Date -> ( Int, Int ) -> Date
datePlusTimeTuple date ( hour, min ) =
    removeTimeFromDate date
        |> DEP.add DEP.Hour hour
        |> DEP.add DEP.Minute min


{-| Convert a Maybe Date into a JE.Value representing a
date/time in String or null format without casting the
time into the local timezone.
-}
maybeDateToValue : Maybe Date -> JE.Value
maybeDateToValue date =
    case date of
        Just d ->
            dateToStringValue d

        Nothing ->
            JE.null


{-| Returns a JE.Value of a Date in UTC.

partof: #SPC-dates-client-encode
-}
dateToStringValue : Date -> JE.Value
dateToStringValue date =
    DEF.utcIsoString date |> JE.string


timeToTimeString : Time -> String
timeToTimeString t =
    Date.fromTime t
        |> DEF.format DECC.config "%H:%M"


{-| Returns True if the String is Nothing or does
not fit the hh:mm pattern.
-}
validateTime : Maybe String -> Bool
validateTime time =
    case time of
        Just t ->
            String.length (stringToTimeString t) == 0

        Nothing ->
            True


{-| Returns True if the String is Something
and it does not evaluate to a valid time. A non-existent
String is fine.
-}
validateJustTime : Maybe String -> Bool
validateJustTime time =
    case time of
        Just t ->
            case stringToTimeTuple t of
                Just ( _, _ ) ->
                    False

                Nothing ->
                    True

        Nothing ->
            False


{-| Returns True if the Date is Nothing.
-}
validateDate : Maybe Date -> Bool
validateDate date =
    case date of
        Just d ->
            False

        Nothing ->
            True


{-| Return a String in the pattern hh:mm based on the String
passed, or an empty String if the input does not conform.
-}
stringToTimeString : String -> String
stringToTimeString t =
    filterStringLikeTime t
        |> String.split ":"
        |> (\list ->
                let
                    h =
                        List.head list
                            |> (\s -> stringToIntBetween s -1 24)

                    m =
                        List.reverse list
                            |> List.head
                            |> (\s -> stringToIntBetween s -1 60)
                in
                    case ( h, m ) of
                        ( Just hour, Just minute ) ->
                            (toString hour |> String.padLeft 2 '0')
                                ++ ":"
                                ++ (toString minute |> String.padLeft 2 '0')

                        ( _, _ ) ->
                            ""
           )


stringToTimeTuple : String -> Maybe ( Int, Int )
stringToTimeTuple t =
    filterStringLikeTime t
        |> String.split ":"
        |> (\list ->
                let
                    h =
                        List.head list
                            |> (\s -> stringToIntBetween s -1 24)

                    m =
                        List.reverse list
                            |> List.head
                            |> (\s -> stringToIntBetween s -1 60)
                in
                    case ( h, m ) of
                        ( Just hour, Just minute ) ->
                            Just ( hour, minute )

                        ( _, _ ) ->
                            Nothing
           )


{-| We allow characters 0-9 and ":" that make up the hh:mm
pattern. We do not actually enforce the pattern, i.e. what is
an valid time or not, just the characters and the length of
the string. Most validation will need to take place at submission.
-}
filterStringLikeTime : String -> String
filterStringLikeTime str =
    let
        -- Get the string to at most 5 characters that could be acceptable.
        filtered =
            String.toList str
                |> List.take 5
                |> List.filter (\d -> Char.isDigit d || d == ':')
                |> String.fromList
    in
        filtered


dateFormatter : DateFmt -> DateSep -> Date -> String
dateFormatter f s d =
    let
        sep =
            dateSepToString s
    in
        case f of
            YMDDateFmt ->
                DEF.format DECC.config ("%Y" ++ sep ++ "%m" ++ sep ++ "%d") d

            MDYDateFmt ->
                DEF.format DECC.config ("%m" ++ sep ++ "%d" ++ sep ++ "%Y") d

            DMYDateFmt ->
                DEF.format DECC.config ("%d" ++ sep ++ "%m" ++ sep ++ "%Y") d


{-| Human readable date and time formatter that does not
include seconds.
-}
dateTimeHMFormatter : DateFmt -> DateSep -> Date -> String
dateTimeHMFormatter f s d =
    (dateFormatter f s d) ++ " " ++ (DEF.format DECC.config "%H:%M" d)


dateToDateMonString : Date -> String -> String
dateToDateMonString date sep =
    DEF.format DECC.config ("%b" ++ sep ++ "%d" ++ sep ++ "%Y") date


{-| Remove the time portion from a Date. The result will be a Date
instance with hour, minute, second set to zero, but it will still
be in the current timezone, i.e. ISO8601 compliant.
-}
removeTimeFromDate : Date -> Date
removeTimeFromDate d =
    DEC.dateFromFields (Date.year d)
        (Date.month d)
        (Date.day d)
        0
        0
        0
        0


{-| Return the difference between two dates in a
human readable format as a String with the difference
expressed as a positive. Only displays days, hours, and
minutes.

Note: the order of the dates passed does not matter since
the difference is expressed as a positive no matter what.
-}
diff2DatesString : Date -> Date -> String
diff2DatesString d1 d2 =
    let
        doCommas first second =
            if String.length first > 0 then
                if String.length second > 0 then
                    first ++ ", " ++ second
                else
                    first
            else
                second

        doSingular num unit =
            case abs num of
                0 ->
                    ""

                1 ->
                    "1 " ++ unit

                n ->
                    (toString n) ++ " " ++ unit ++ "s"


        dateDelta =
            case DEComp.is DEComp.Before d1 d2 of
                True ->
                    -- d1 is before d2
                    DEP.diff d2 d1

                False ->
                    -- d1 is after (or same as) d2
                    DEP.diff d1 d2

        days =
            doSingular dateDelta.day "day"

        hours =
            doSingular dateDelta.hour "hour"

        minutes =
            doSingular dateDelta.minute "minute"
    in
        doCommas days hours
            |> flip doCommas minutes
            |> String.trim


{-| Calculate the estimated due date based upon the
date of the last mentrual period.
-}
calcEdd : Maybe Date -> Maybe Date
calcEdd theLmp =
    case theLmp of
        Just lmp ->
            Just <| DEP.add DEP.Day 280 lmp

        Nothing ->
            Nothing


{-| Return the gestational age as a ( String, String ) tuple based on the
estimated due date and reference date passed. The first element in the
tuple is the weeks and the second is the partial week in "n/7" format where
n is the number of days of the partial week.
-}
getGA : Date -> Date -> ( String, String )
getGA edd rdate =
    let
        lmp =
            DEP.add DEP.Day -280 (removeTimeFromDate edd)

        delta =
            DEP.diff (removeTimeFromDate rdate) lmp

        ( weeks, days ) =
            ( delta.week, delta.day )

        ga =
            ( toString weeks, (toString days) ++ "/7" )
    in
        if weeks > 45 || weeks < 0 then
            -- Do not return unreasonable values.
            ( "", "" )
        else
            ga


maybeIntToNegOne : Maybe Int -> JE.Value
maybeIntToNegOne int =
    case int of
        Just i ->
            JE.int i

        Nothing ->
            JE.int -1


formatDohId : Maybe String -> String
formatDohId doh =
    case doh of
        Just doh ->
            (String.slice 0 2 doh)
                ++ "-"
                ++ (String.slice 2 4 doh)
                ++ "-"
                ++ (String.slice 4 6 doh)

        Nothing ->
            ""


maybeIntToMaybeBool : JD.Decoder (Maybe Bool)
maybeIntToMaybeBool =
    JD.maybe JD.int
        |> JD.map
            (\val ->
                case val of
                    Just v ->
                        if v > 0 then
                            Just True
                        else
                            Just False

                    Nothing ->
                        Nothing
            )


maybeStringToMaybeInt : Maybe String -> Maybe Int
maybeStringToMaybeInt str =
    case str of
        Just s ->
            case String.toInt s of
                Ok i ->
                    Just i

                Err _ ->
                    Nothing

        Nothing ->
            Nothing


maybeStringToMaybeFloat : Maybe String -> Maybe Float
maybeStringToMaybeFloat str =
    case str of
        Just s ->
            case String.toFloat s of
                Ok f ->
                    Just f

                Err _ ->
                    Nothing

        Nothing ->
            Nothing


{-| Put a non-breaking space in between two strings within a span. Adapted from:
https://stackoverflow.com/questions/33971362/how-can-i-get-special-characters-using-elm-html-module
-}
nbsp : String -> String -> Html msg
nbsp pre post =
    H.span []
        [ H.span [] [ H.text pre ]
        , H.span [ HA.property "innerHTML" (JE.string "&nbsp;") ] []
        , H.span [] [ H.text post ]
        ]


addToMaybeList : a -> Maybe (List a) -> Maybe (List a)
addToMaybeList a aList =
    case aList of
        Just list ->
            Just <| a :: list

        Nothing ->
            Just [ a ]