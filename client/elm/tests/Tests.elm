module Tests exposing (..)

import Date
import Expect
import Fuzz
import Json.Decode as JD
import RemoteData as RD exposing (RemoteData(..))
import Test exposing (..)


-- Project specific imports.

import Model exposing (Model, initialModel)
import Msg exposing (..)
import Transactions as Trans
import Types exposing (..)
import Update
    exposing
        ( update
        , getSelectedTableRecordAsString
        , updateMedicationType
        )


all : Test
all =
    describe "Tests"
        [ stateTests
        , getSelectedTableRecordAsStringTest
        ]


initialMedicationTypeTable : List MedicationTypeTable
initialMedicationTypeTable =
    [ MedicationTypeTable 1 "name1" "description1" 1 Nothing
    , MedicationTypeTable 2 "name2" "description2" 2 Nothing
    , MedicationTypeTable 3 "name3" "description3" 3 Nothing
    ]


getSelectedTableRecordAsStringTest : Test
getSelectedTableRecordAsStringTest =
    describe "getSelectedTableRecordAsString"
        [ test "medicationType: no selected table returns Nothing" <|
            \() ->
                let
                    result =
                        getSelectedTableRecordAsString initialModel
                in
                    Expect.equal result Nothing
        , test "medicationType: selected table first record" <|
            \() ->
                let
                    result =
                        { initialModel | selectedTable = Just MedicationType }
                            |> updateMedicationType (MedicationTypeResponse (RD.succeed initialMedicationTypeTable))
                            |> (\( model, _ ) -> getSelectedTableRecordAsString model)
                in
                    Expect.notEqual result Nothing
        ]


stateTests : Test
stateTests =
    describe "Transactions module"
        [ test "should insert a state into the model" <|
            \() ->
                let
                    initialModel =
                        Model.initialModel

                    controlString =
                        "This is a test"

                    ( newModel, stateId ) =
                        Trans.setState controlString Nothing initialModel

                    isOk =
                        case stateId of
                            Just id ->
                                List.length newModel.transactions.states == 1

                            Nothing ->
                                False
                in
                    Expect.equal isOk True
        , test "should retrieve a state from the model" <|
            \() ->
                let
                    initialModel =
                        Model.initialModel

                    controlString =
                        "This is a test"

                    ( updatedModel, stateId ) =
                        Trans.setState controlString Nothing initialModel

                    newStr =
                        case stateId of
                            Just id ->
                                Trans.getState id updatedModel

                            Nothing ->
                                Nothing

                    isOk =
                        case newStr of
                            Just s ->
                                s == controlString

                            Nothing ->
                                False
                in
                    Expect.equal isOk True
        , test "should delete a state from the model" <|
            \() ->
                let
                    initialModel =
                        Model.initialModel

                    controlString =
                        "This is a test"

                    ( updatedModel, stateId ) =
                        Trans.setState controlString Nothing initialModel

                    ( updatedModel2, stateId2 ) =
                        case stateId of
                            Just id ->
                                Trans.delState id updatedModel

                            Nothing ->
                                ( updatedModel, Nothing )

                    isOk =
                        stateId
                            == stateId2
                            && List.length updatedModel.transactions.states
                            == 1
                            && List.length updatedModel2.transactions.states
                            == 0
                in
                    Expect.equal isOk True
        , test "should return a list of expired states" <|
            \() ->
                let
                    initialModel =
                        Model.initialModel

                    ( ctrlStr1, ctrlStr2, expires1, expires2 ) =
                        ( "This is a test"
                        , "yet another test"
                        , Date.fromTime 1000
                        , Date.fromTime 1500
                        )

                    -- Add a state to the model without an expiration.
                    ( updatedModel, stateId ) =
                        Trans.setState ctrlStr1 Nothing initialModel

                    -- Add a state to the model with an expiration.
                    ( updatedModel2, stateId2 ) =
                        Trans.setState ctrlStr2 (Just expires2) updatedModel

                    -- Update the state without the expiration with an expiration.
                    ( updatedModel3, stateId3 ) =
                        case stateId of
                            Just id ->
                                Trans.setExpires id expires1 updatedModel2

                            Nothing ->
                                ( updatedModel2, Nothing )

                    -- Move the current time in the model forward past the expirations.
                    ( updatedModel4, stateId4 ) =
                        let
                            transactions =
                                updatedModel3.transactions
                        in
                            ( { updatedModel3
                                | transactions =
                                    { transactions | currentTime = 2000 }
                              }
                            , Nothing
                            )

                    expired =
                        case stateId of
                            Just id ->
                                Trans.getExpired updatedModel4

                            Nothing ->
                                []

                    isOk =
                        case ( stateId2, stateId3 ) of
                            ( Just id2, Just id3 ) ->
                                List.length expired
                                    == 2
                                    && List.member id2 expired
                                    && List.member id3 expired

                            _ ->
                                False
                in
                    Expect.equal isOk True
        ]
