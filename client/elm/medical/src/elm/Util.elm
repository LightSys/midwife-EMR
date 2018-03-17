module Util
    exposing
        ( (=>)
        , DateFmt(..)
        , DateSep(..)
        , MaybeDateTime(..)
        , SortOrder(..)
        , addToMaybeList
        , boolToInt
        , calcEdd
        , dateFormatter
        , datePlusTimeTuple
        , dateTimeHMFormatter
        , dateToDateMonString
        , dateToStringValue
        , dateToTimeString
        , datesInOrder
        , deriveDateFromMaybeDateMaybeString
        , diff2DatesString
        , diff2MaybeDatesString
        , filterStringInList
        , filterStringLikeFloat
        , filterStringLikeInt
        , filterStringLikeIntOrNegInt
        , filterStringLikeTime
        , filterStringNotInList
        , formatDohId
        , getGA
        , maybeBoolToMaybeInt
        , maybeDateMaybeTimeToMaybeDateTime
        , maybeDatePlusTime
        , maybeDateTimeErrors
        , maybeDateTimeValue
        , maybeDateToTimeString
        , maybeDateToValue
        , maybeHoursMaybeMinutesToMaybeMinutes
        , maybeIntToMaybeBool
        , maybeIntToNegOne
        , maybeOr
        , maybeStringLength
        , maybeStringToIntValue
        , maybeStringToMaybeFloat
        , maybeStringToMaybeInt
        , minutesToHours
        , minutesToMinutes
        , monthToInt
        , nbsp
        , pipeToComma
        , removeTimeFromDate
        , sortDate
        , stringToIntBetween
        , stringToTimeTuple
        , timeToTimeString
        , validateBool
        , validateDate
        , validateFloat
        , validateInt
        , validateJustTime
        , validatePopulatedString
        , validatePopulatedStringInList
        , validateTime
        )

import Char
import Date exposing (Date, Month(..), day, hour, minute, month, second, year)
import Date.Extra.Compare as DEComp
import Date.Extra.Config.Config_en_us as DECC
import Date.Extra.Core as DECore
import Date.Extra.Create as DEC
import Date.Extra.Duration as DED
import Date.Extra.Format as DEF
import Date.Extra.Period as DEP
import Html as H exposing (Html)
import Html.Attributes as HA
import Json.Decode as JD
import Json.Encode as JE
import Time exposing (Time)


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


{-| Simple conversion of a Bool to an Int like the
database is expecting.
-}
boolToInt : Bool -> Int
boolToInt bool =
    case bool of
        True ->
            1

        False ->
            0


maybeStringLength : Maybe String -> Int
maybeStringLength str =
    case str of
        Just s ->
            String.length s

        Nothing ->
            0


{-| Takes a string with pipes as separators and
returns a string with commas as separators.
-}
pipeToComma : String -> String
pipeToComma str =
    String.split "|" str
        |> String.join ", "


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


{-| Return the String if it is in the list of allowable
strings, otherwise return an empty string.
-}
filterStringInList : List String -> String -> String
filterStringInList strings str =
    case List.member str strings of
        True ->
            str

        False ->
            ""


{-| Return the String if it is NOT in the list of disallowed
strings, otherwise return an empty string.
-}
filterStringNotInList : List String -> String -> String
filterStringNotInList strings str =
    case List.member str strings of
        True ->
            ""

        False ->
            str


{-| Return a String that contains only digits.
-}
filterStringLikeInt : String -> String
filterStringLikeInt str =
    String.toList str
        |> List.filter (\d -> Char.isDigit d)
        |> String.fromList


{-| Return a String that contains only digits but
will allow a negative.
-}
filterStringLikeIntOrNegInt : String -> String
filterStringLikeIntOrNegInt str =
    let
        result =
            (String.toList str
                |> List.take 1
                |> List.filter (\d -> Char.isDigit d || d == '-')
            )
                ++ (String.toList str
                        |> List.drop 1
                        |> List.filter (\d -> Char.isDigit d)
                   )
    in
    String.fromList result


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


{-| Returns the first non-Maybe value.
Copied from Maybe.Extra.or.
-}
maybeOr : Maybe a -> Maybe a -> Maybe a
maybeOr ma mb =
    case ma of
        Nothing ->
            mb

        Just _ ->
            ma


{-| Returns True if the Bool is Nothing.
-}
validateBool : Maybe Bool -> Bool
validateBool bool =
    case bool of
        Just b ->
            False

        Nothing ->
            True


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


{-| Returns True if the String is Nothing or
not found in the list passed.
-}
validatePopulatedStringInList : List String -> Maybe String -> Bool
validatePopulatedStringInList strings str =
    case str of
        Just s ->
            not <| List.member s strings

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


type MaybeDateTime
    = NoMaybeDateTime
    | ValidMaybeDateTime Date
    | InvalidMaybeDateTime String


{-| Returns a MaybeDateTime taking a Maybe Date and a Maybe String, the latter which
should evaluate to a time tuple, as well as an error message to use as necessary.
-}
maybeDateMaybeTimeToMaybeDateTime : Maybe Date -> Maybe String -> String -> MaybeDateTime
maybeDateMaybeTimeToMaybeDateTime date timeTuple errMsg =
    case ( date, timeTuple ) of
        ( Just d, Just tt ) ->
            case maybeDatePlusTime date timeTuple of
                Just dt ->
                    ValidMaybeDateTime dt

                Nothing ->
                    InvalidMaybeDateTime errMsg

        ( _, _ ) ->
            NoMaybeDateTime


maybeDateTimeErrors : List MaybeDateTime -> List String
maybeDateTimeErrors maybeDateTimes =
    List.filterMap
        (\dt ->
            case dt of
                InvalidMaybeDateTime err ->
                    Just err

                _ ->
                    Nothing
        )
        maybeDateTimes


maybeDateTimeValue : MaybeDateTime -> Maybe Date
maybeDateTimeValue dt =
    case dt of
        ValidMaybeDateTime d ->
            Just d

        _ ->
            Nothing


{-| Add Maybe String representing time to a Maybe Date and return a
Maybe Date. Returns Nothing if either argument is Nothing or
if the Maybe String does not evaluate to a time tuple.
-}
maybeDatePlusTime : Maybe Date -> Maybe String -> Maybe Date
maybeDatePlusTime d t =
    case ( d, t ) of
        ( Just theDate, Just theTime ) ->
            case stringToTimeTuple theTime of
                Just ( h, m ) ->
                    Just (datePlusTimeTuple theDate ( h, m ))

                Nothing ->
                    Nothing

        ( _, _ ) ->
            Nothing


{-| Take a Maybe Date and a Maybe String that could be in the form
of a time tuple and return a Date, or return the default supplied
instead.
-}
deriveDateFromMaybeDateMaybeString : Maybe Date -> Maybe String -> Date -> Date
deriveDateFromMaybeDateMaybeString date timeTuple defaultDate =
    case
        ( date
        , stringToTimeTuple (Maybe.withDefault "" timeTuple)
        )
    of
        ( Just d, Just ( h, m ) ) ->
            datePlusTimeTuple d ( h, m )

        ( _, _ ) ->
            defaultDate


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
-}
dateToStringValue : Date -> JE.Value
dateToStringValue date =
    DEF.utcIsoString date |> JE.string


timeToTimeString : Time -> String
timeToTimeString t =
    Date.fromTime t
        |> DEF.format DECC.config "%H%M"


{-| Returns True if the String is Nothing or does
not fit the hhmm pattern.
-}
validateTime : Maybe String -> Bool
validateTime time =
    case time of
        Just t ->
            case stringToTimeTuple t of
                Just ( _, _ ) ->
                    False

                Nothing ->
                    True

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


stringToTimeTuple : String -> Maybe ( Int, Int )
stringToTimeTuple t =
    let
        hours =
            filterStringLikeInt t
                |> String.toList
                |> List.take 2
                |> String.fromList
                |> String.toInt
                |> Result.toMaybe

        minutes =
            filterStringLikeInt t
                |> String.toList
                |> List.drop 2
                |> String.fromList
                |> String.toInt
                |> Result.toMaybe
    in
    case ( String.length t, hours, minutes ) of
        ( 4, Just h, Just m ) ->
            if h > -1 && h < 24 && m > -1 && m < 60 then
                Just ( h, m )
            else
                Nothing

        _ ->
            Nothing


{-| We allow four characters 0-9 that make up the hhmm
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
                |> List.take 4
                |> List.filter (\d -> Char.isDigit d)
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
    dateFormatter f s d ++ " " ++ DEF.format DECC.config "%H:%M" d


dateToTimeString : Date -> String
dateToTimeString d =
    DEF.format DECC.config "%H%M" d


maybeDateToTimeString : Maybe Date -> Maybe String
maybeDateToTimeString date =
    case date of
        Just d ->
            Just <| dateToTimeString d

        Nothing ->
            Nothing


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


{-| Returns the different between two Maybe Dates in
a human readable format or an empty String if either
of them are Nothing.
-}
diff2MaybeDatesString : Maybe Date -> Maybe Date -> String
diff2MaybeDatesString date1 date2 =
    case ( date1, date2 ) of
        ( Just d1, Just d2 ) ->
            diff2DatesString d1 d2

        ( _, _ ) ->
            ""


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
                    toString n ++ " " ++ unit ++ "s"

        dateDelta =
            case DEComp.is DEComp.Before d1 d2 of
                True ->
                    -- d1 is before d2
                    DED.diff d2 d1

                False ->
                    -- d1 is after (or same as) d2
                    DED.diff d1 d2

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


{-| Return True if d1 precedes or is equal to d2.
-}
datesInOrder : Date -> Date -> Bool
datesInOrder d1 d2 =
    DEComp.is DEComp.SameOrBefore d1 d2


{-| Private.
-}
minutesToHoursMinutes : Maybe Int -> Maybe ( Int, Int )
minutesToHoursMinutes minutes =
    case minutes of
        Just m ->
            Just ( m // 60, rem m 60 )

        Nothing ->
            Nothing


minutesToHours : Maybe Int -> Maybe Int
minutesToHours minutes =
    case minutesToHoursMinutes minutes of
        Just ( h, _ ) ->
            Just h

        Nothing ->
            Nothing


minutesToMinutes : Maybe Int -> Maybe Int
minutesToMinutes minutes =
    case minutesToHoursMinutes minutes of
        Just ( _, m ) ->
            Just m

        Nothing ->
            Nothing


maybeHoursMaybeMinutesToMaybeMinutes : Maybe Int -> Maybe Int -> Maybe Int
maybeHoursMaybeMinutesToMaybeMinutes hours minutes =
    case ( hours, minutes ) of
        ( Just h, Just m ) ->
            Just <| (h * 60) + m

        ( Just h, Nothing ) ->
            Just <| h * 60

        ( Nothing, Just m ) ->
            Just m

        ( Nothing, Nothing ) ->
            Nothing


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
            ( toString weeks, toString days ++ "/7" )
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
            String.slice 0 2 doh
                ++ "-"
                ++ String.slice 2 4 doh
                ++ "-"
                ++ String.slice 4 6 doh

        Nothing ->
            ""


maybeBoolToMaybeInt : Maybe Bool -> JE.Value
maybeBoolToMaybeInt bool =
    case bool of
        Just True ->
            JE.int 1

        Just False ->
            JE.int 0

        Nothing ->
            JE.null


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
<https://stackoverflow.com/questions/33971362/how-can-i-get-special-characters-using-elm-html-module>
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
