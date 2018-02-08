module Data.SelectData
    exposing
        ( SelectDataRecord
        , filterByName
        , filterSetByString
        , getSelectDataAsMaybeString
        , getSelectDataBySelectKey
        , selectDataRecord
        , setSelectedBySelectKey
        , setSelectedByString
        )

-- LOCAL IMPORTS --

import Data.Table exposing (Table(..), tableToString)
import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Json.Encode.Extra as JEE
import List.Extra as LE
import Util as U


type alias SelectDataRecord =
    { id : Int
    , name : String
    , selectKey : String
    , label : String
    , selected : Bool
    }


selectDataRecord : JD.Decoder SelectDataRecord
selectDataRecord =
    JDP.decode SelectDataRecord
        |> JDP.required "id" JD.int
        |> JDP.required "name" JD.string
        |> JDP.required "selectKey" JD.string
        |> JDP.required "label" JD.string
        |> JDP.required "selected" (JD.map (\s -> s == 1) JD.int)


filterByName : String -> List SelectDataRecord -> List SelectDataRecord
filterByName name recs =
    List.filter (\r -> r.name == name) recs


setSelectedByString : List String -> List SelectDataRecord -> List SelectDataRecord
setSelectedByString keys sdList =
    List.map (\sd -> { sd | selected = List.member sd.selectKey keys }) sdList


{-| Sets the selected field of the record matching the passed key to the
value passed.
-}
setSelectedBySelectKey : String -> Bool -> List SelectDataRecord -> List SelectDataRecord
setSelectedBySelectKey key val =
    List.map
        (\sd ->
            if key == sd.selectKey then
                { sd | selected = val }
            else
                sd
        )


{-| Returns a Maybe SelectDataRecord that matches a passed selectKey.
-}
getSelectDataBySelectKey : String -> List SelectDataRecord -> Maybe SelectDataRecord
getSelectDataBySelectKey key =
    LE.find (\sd -> sd.selectKey == key)


{-| Filter a List SelectData by name then set the selected field of the remaining
records according the String of selectKeys passed, assuming that the selectKeys
String is delineated by a "|".
-}
filterSetByString : String -> Maybe String -> List SelectDataRecord -> List SelectDataRecord
filterSetByString name selectKeys sdList =
    let
        keys =
            String.split "|" <| Maybe.withDefault "" selectKeys
    in
    filterByName name sdList
        |> setSelectedByString keys


getSelectDataAsMaybeString : List SelectDataRecord -> Maybe String
getSelectDataAsMaybeString sdList =
    List.filterMap (\sd -> if sd.selected then Just sd.selectKey else Nothing) sdList
        |> String.join "|"
        |> Just

