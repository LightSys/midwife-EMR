module Transactions
    exposing
        ( delState
        , getExpired
        , getState
        , setExpires
        , setState
        )

import Date exposing (Date)
import List.Extra as LE
import Time exposing (Time)


-- LOCAL IMPORTS

import Model exposing (Model, State)


setState : String -> Maybe Date -> Model -> ( Model, Maybe Int )
setState str datetime model =
    let
        transactions =
            model.transactions

        state =
            State transactions.nextId str datetime

        states =
            state :: transactions.states
    in
        ( { model
            | transactions =
                { transactions
                    | states = states
                    , nextId = model.transactions.nextId + 1
                }
          }
        , Just state.id
        )


getState : Int -> Model -> Maybe String
getState id model =
    let
        state =
            LE.find (\s -> s.id == id) model.transactions.states

        str =
            case state of
                Just s ->
                    Just s.state

                Nothing ->
                    Nothing
    in
        str


delState : Int -> Model -> ( Model, Maybe Int )
delState id model =
    let
        transactions =
            model.transactions

        newStates =
            LE.filterNot (\s -> s.id == id) transactions.states
    in
        ( { model
            | transactions =
                { transactions | states = newStates }
          }
        , if List.length model.transactions.states /= List.length newStates then
            Just id
          else
            Nothing
        )


setExpires : Int -> Date -> Model -> ( Model, Maybe Int )
setExpires id datetime model =
    let
        transactions =
            model.transactions

        isFound =
            getState id model

        newStates =
            LE.updateIf (\s -> s.id == id)
                (\s -> State s.id s.state (Just datetime))
                model.transactions.states
    in
        ( { model
            | transactions =
                { transactions | states = newStates }
          }
        , case isFound of
            Just s ->
                Just id

            Nothing ->
                Nothing
        )


getExpired : Model -> List Int
getExpired model =
    let
        expired =
            List.filterMap
                (\s ->
                    case s.expires of
                        Just e ->
                            if Date.toTime e < model.transactions.currentTime then
                                Just s.id
                            else
                                Nothing

                        Nothing ->
                            Nothing
                )
                model.transactions.states
    in
        expired
