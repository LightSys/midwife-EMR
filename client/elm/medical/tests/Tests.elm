module Tests exposing (..)

import Date
import Date.Extra.Compare as DEComp
import Date.Extra.Create as DEC
import Date.Extra.Period as DEP
import Date.Extra.Utils as DEU
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Test exposing (..)
import Expect
import Fuzz exposing (list, int, tuple, string)
import String


-- LOCAL IMPORTS

import Data.DataCache as DataCache exposing (DataCache(..))
import Data.Labor as Labor
import Data.LaborStage1 exposing (LaborStage1Record)
import Data.Table exposing (Table(..))
import Util as U


{--
all : Test
all =
    describe "Sample Test Suite"
        [ describe "Unit test examples"
            [ test "Addition" <|
                \() ->
                    Expect.equal (3 + 7) 10
            , test "String.left" <|
                \() ->
                    Expect.equal "a" (String.left 1 "abcdefg")
            , test "This test should fail - you should remove it" <|
                \() ->
                    Expect.fail "Failed as expected!"
            ]
        , describe "Fuzz test examples, using randomly generated input"
            [ fuzz (list int) "Lists always have positive length" <|
                \aList ->
                    List.length aList |> Expect.atLeast 0
            , fuzz (list int) "Sorting a list does not change its length" <|
                \aList ->
                    List.sort aList |> List.length |> Expect.equal (List.length aList)
            , fuzzWith { runs = 1000 } int "List.member will find an integer in a list containing it" <|
                \i ->
                    List.member i [ i ] |> Expect.true "If you see this, List.member returned False!"
            , fuzz2 string string "The length of a string equals the sum of its substrings' lengths" <|
                \s1 s2 ->
                    s1 ++ s2 |> String.length |> Expect.equal (String.length s1 + String.length s2)
            ]
        ]
--}


all : Test
all =
    describe "All Medical Tests"
        [ dateHandling
        , dataCache
        ]


dataCache : Test
dataCache =
    describe "DataCache mechanism"
        [ test "put adds values" <|
            \() ->
                let
                    v1 =
                        LaborStage1Record 1
                           (Just (Date.fromTime 0.0))
                           Nothing
                           Nothing
                           Nothing
                           Nothing
                           100
                            |> LaborStage1DataCache

                    dict : Dict String DataCache
                    dict =
                        DataCache.put v1 Dict.empty
                in
                    Expect.true "Expected dict size to be 1." (Dict.size dict == 1)
        , test "get retrieves values" <|
            \() ->
                let
                    v1 =
                        LaborStage1Record 1
                           (Just (Date.fromTime 0.0))
                           Nothing
                           Nothing
                           Nothing
                           Nothing
                           100
                            |> LaborStage1DataCache

                    dict : Dict String DataCache
                    dict =
                        DataCache.put v1 Dict.empty

                    found =
                        case DataCache.get LaborStage1 dict of
                            Just _ ->
                                True

                            Nothing ->
                                False
                in
                    Expect.true "Expected dict to contain value." found
        , test "del deletes values" <|
            \() ->
                let
                    v1 =
                        LaborStage1Record 1
                           (Just (Date.fromTime 0.0))
                           Nothing
                           Nothing
                           Nothing
                           Nothing
                           100
                            |> LaborStage1DataCache

                    dict : Dict String DataCache
                    dict =
                        DataCache.put v1 Dict.empty

                    newDict =
                        DataCache.del LaborStage1 dict
                in
                    Expect.true "Expected dict to be empty." (Dict.size newDict == 0)
        ]

dateHandling : Test
dateHandling =
    describe "Proper ISO8601 handling of dates"
        [ test "Date to Json.Encode.Value, partof: #TST-dates-encode" <|
            \() ->
                Expect.equal
                    (Date.fromTime 0
                        |> U.dateToStringValue
                        |> JD.decodeValue JD.string
                        |> Result.withDefault ""
                    )
                    "1970-01-01T00:00:00.000Z"
        , test "Json Value with dates to Record with interpretation of dates as UTC, partof: #TST-dates-decode" <|
            \() ->
                let
                    input =
                        """
                        {"temp" : 37.2,
                        "admittanceDate" : "2017-09-06T10:30:00.000Z",
                        "startLaborDate" : "2017-09-06T06:01:00.000Z",
                        "id" : 11,
                        "pos" : "LOA",
                        "updatedBy" : 98,
                        "fht" : 144,
                        "systolic" : 135,
                        "fh" : 24,
                        "diastolic" : 90,
                        "cr" : 88,
                        "pregnancy_id" : 852,
                        "updatedAt" : "2017-09-06T10:26:47.000Z",
                        "supervisor" : null,
                        "falseLabor" : 0,
                        "comments" : "Testing",
                        "endLaborDate" : null
                        }
                        """

                    admittanceDate =
                        case JD.decodeString Labor.laborRecord input of
                            Ok rec ->
                                rec.admittanceDate

                            Err _ ->
                                DEC.dateFromFields 2012 Date.Dec 12 12 12 12 12

                    tmpDate =
                        DEC.dateFromFields 2017 Date.Sep 6 10 30 0 0

                    offset =
                        negate <| DEC.getTimezoneOffset tmpDate

                    -- Account for the timezone that we are testing within.
                    controlDate =
                        DEP.add DEP.Minute offset tmpDate
                in
                    Expect.equal (DEComp.is DEComp.Same controlDate admittanceDate) True
        , test "Remove time from Date" <|
            \() ->
                Expect.equal
                    (Date.fromTime 43567
                        |> U.removeTimeFromDate
                    )
                    (Date.fromTime 0
                        |> DEC.getTimezoneOffset
                        |> (*) (60 * 1000)
                        |> toFloat
                        |> Date.fromTime
                    )
        , test "Date plus Time tuple" <|
            \() ->
                let
                    ( h, m ) =
                        ( 3, 44 )
                in
                    Expect.equal
                        (Date.fromTime 33842
                            |> flip U.datePlusTimeTuple ( h, m )
                        )
                        (Date.fromTime 0
                            |> DEC.getTimezoneOffset
                            |> (*) (60 * 1000)
                            |> (+) (h * 60 * 60 * 1000)
                            |> (+) (m * 60 * 1000)
                            |> toFloat
                            |> Date.fromTime
                        )

        , test "Calculate the estimated due date" <|
            \() ->
                Expect.equal
                    (DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        |> Just
                        |> U.calcEdd
                    )
                    (DEC.dateFromFields 2017 Date.Oct 8 0 0 0 0
                        |> Just
                    )
        , test "Calculate the estimated due date traversing a leap year day" <|
            \() ->
                Expect.equal
                    (DEC.dateFromFields 2016 Date.Jan 6 0 0 0 0
                        |> Just
                        |> U.calcEdd
                    )
                    (DEC.dateFromFields 2016 Date.Oct 12 0 0 0 0
                        |> Just
                    )
        , test "Calculate gestational age" <|
            \() ->
                let
                    ( edd, rdate ) =
                        ( DEC.dateFromFields 2017 Date.Nov 5 3 4 2 3
                        , DEC.dateFromFields 2017 Date.Sep 9 12 13 5 5
                        )
                in
                    Expect.equal
                        (U.getGA edd rdate)
                        ("31", "6/7")
        , test "sortDate unequal, ascending" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Feb 1 0 0 0 0
                        )
                in
                    Expect.equal (U.sortDate U.AscendingSort a b) LT
        , test "sortDate unequal, descending" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Feb 1 0 0 0 0
                        )
                in
                    Expect.equal (U.sortDate U.DescendingSort a b) GT
        , test "sortDate equal, ascending" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        )
                in
                    Expect.equal (U.sortDate U.AscendingSort a b) EQ
        , test "sortDate equal, descending" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        )
                in
                    Expect.equal (U.sortDate U.DescendingSort a b) EQ
        , test "diff2Date equal dates" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) ""
        , test "diff2Date dates ascending by hour" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 1 0 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "1 hour"
        , test "diff2Date dates descending by hour" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 1 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "1 hour"
        , test "diff2Date dates ascending multiple hours" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 2 0 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "2 hours"
        , test "diff2Date dates descending multiple hours" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 2 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "2 hours"
        , test "diff2Date dates ascending by minute" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 1 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "1 minute"
        , test "diff2Date dates descending by minute" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 1 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "1 minute"
        , test "diff2Date dates ascending by multiple minutes" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 5 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "5 minutes"
        , test "diff2Date dates descending by multiple minutes" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 5 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "5 minutes"
        , test "diff2Date dates ascending by day plus hours minutes" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 3 4 2 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "2 days, 4 hours, 2 minutes"
        , test "diff2Date dates descending by day plus hours minutes" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 3 4 2 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "2 days, 4 hours, 2 minutes"
        , test "diff2Date dates ascending by day plus minutes" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        , DEC.dateFromFields 2017 Date.Jan 3 0 2 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "2 days, 2 minutes"
        , test "diff2Date dates descending by day plus minutes" <|
            \() ->
                let
                    ( a, b ) =
                        ( DEC.dateFromFields 2017 Date.Jan 3 0 2 0 0
                        , DEC.dateFromFields 2017 Date.Jan 1 0 0 0 0
                        )
                in
                    Expect.equal (U.diff2DatesString a b) "2 days, 2 minutes"
        ]
