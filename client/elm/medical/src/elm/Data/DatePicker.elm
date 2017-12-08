module Data.DatePicker
    exposing
        ( DateField(..)
        , DateFieldMessage(..)
        , dateFieldToString
        , decodeSelectedDate
        , IncomingDate
        )

import Date exposing (Date)
import Json.Decode as JD
import Json.Decode.Extra as JDE
import Json.Decode.Pipeline as JDP
import Json.Encode as JE


{-| For browsers that do not natively handle dates, we use the
jQueryUI DatePicker widget to receive the selected date from
outside Elm. We use one port for this which results in the
IncomingDataPicker message specifying the specific DateField
and value. The DateField is used to route the value to the
proper page's update function as a SubMsg.
-}
type DateField
    = UnknownDateField String
    | AdmittingAdmittanceDateField
    | LaborDelIppLaborDateField
    | LaborDelIppStage1DateField
    | LaborDelIppStage2DateField
    | LaborDelIppStage3DateField


stringToDateField : String -> DateField
stringToDateField str =
    case str of
        "admitDateId" ->
            AdmittingAdmittanceDateField

        "laborDateId" ->
            LaborDelIppLaborDateField

        "laborStage1Id" ->
            LaborDelIppStage1DateField

        "laborStage2Id" ->
            LaborDelIppStage2DateField

        "laborStage3Id" ->
            LaborDelIppStage3DateField

        _ ->
            UnknownDateField str


dateFieldToString : DateField -> String
dateFieldToString df =
    case df of
        AdmittingAdmittanceDateField ->
            "admitDateId"

        LaborDelIppLaborDateField ->
            "laborDateId"

        LaborDelIppStage1DateField ->
            "laborStage1Id"

        LaborDelIppStage2DateField ->
            "laborStage2Id"

        LaborDelIppStage3DateField ->
            "laborStage3Id"

        UnknownDateField str ->
            "Warning: Unknown DateField: " ++ str


type DateFieldMessage
    = UnknownDateFieldMessage String
    | DateFieldMessage IncomingDate


type alias IncomingDate =
    { dateField : DateField
    , date : Date
    }


decodeSelectedDate : JE.Value -> DateFieldMessage
decodeSelectedDate payload =
    case JD.decodeValue incomingDate payload of
        Ok val ->
            DateFieldMessage val

        Err msg ->
            let
                _ =
                    Debug.log "decodeSelectedDate decoding error" msg
            in
                UnknownDateFieldMessage msg


incomingDate : JD.Decoder IncomingDate
incomingDate =
    JDP.decode IncomingDate
        |> JDP.required "dateField" (JD.string |> JD.map stringToDateField)
        |> JDP.required "date" JDE.date
