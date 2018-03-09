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
import Regex exposing (Regex)


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
    | AdmittingStartLaborDateField
    | LaborDelIppLaborDateField
    | LaborDelIppStage1DateField
    | LaborDelIppStage2DateField
    | LaborDelIppStage3DateField
    | FalseLaborDateField
    | MembraneRuptureDateField
    | BabyBFedEstablishedDateField
    | BabyNbsDateField
    | BabyBcgDateField
    | NewBornExamDateField
    | ContPostpartumCheckDateField
    | BabyMed1DateField
      -- When we need a certain number of form fields
      -- that are dependent upon data. The first Int
      -- is for the field type or category or whatever
      -- course grained definition is required, and
      -- the second Int is the find grained identifier
      -- which can be correlated to an id of some sort.
    | DynamicDateField Int Int
    | DischargeDateField
    | PostpartumCheckDateField
    | PostpartumCheckHgbField
    | PostpartumCheckScheduledField
    | BirthCertDateOfCommTaxField
    | BirthCertDateOfMarriageField


dynamicRegex : Regex
dynamicRegex =
    Regex.regex "dynamicDateId-(\\d+)-(\\d+)"


stringToDateField : String -> DateField
stringToDateField str =
    case str of
        "admitDateId" ->
            AdmittingAdmittanceDateField

        "admitStartLaborDateId" ->
            AdmittingStartLaborDateField

        "babyBFedEstablisedId" ->
            BabyBFedEstablishedDateField

        "babyBcgId" ->
            BabyBcgDateField

        "babyNbsId" ->
            BabyNbsDateField

        "babyMed1Id" ->
            BabyMed1DateField

        "birthCertificateDateOfCommTaxId" ->
            BirthCertDateOfCommTaxField

        "birthCertificateDateOfMarriageId" ->
            BirthCertDateOfMarriageField

        "contPostpartumCheckId" ->
            ContPostpartumCheckDateField

        "dischargeDateId" ->
            DischargeDateField

        "falseLaborDateId" ->
            FalseLaborDateField

        "laborDateId" ->
            LaborDelIppLaborDateField

        "laborStage1Id" ->
            LaborDelIppStage1DateField

        "laborStage2Id" ->
            LaborDelIppStage2DateField

        "laborStage3Id" ->
            LaborDelIppStage3DateField

        "membraneRuptureId" ->
            MembraneRuptureDateField

        "newbornExamId" ->
            NewBornExamDateField

        "postpartumCheckId" ->
            PostpartumCheckDateField

        "postpartumCheckHgbId" ->
            PostpartumCheckHgbField

        "postpartumCheckScheduledId" ->
            PostpartumCheckScheduledField

        str ->
            case Regex.find Regex.All dynamicRegex str
                |> List.head
            of
                Just match ->
                    let
                        category =
                            case List.take 1 match.submatches
                                |> List.head
                            of
                                Just (Just cat) ->
                                    cat

                                _ ->
                                    ""

                        field =
                            case List.take 2 match.submatches
                                |> List.reverse
                                |> List.head
                            of
                                Just (Just fld) ->
                                    fld

                                _ ->
                                    ""

                        dateFld =
                            case ( String.toInt category, String.toInt field ) of
                                ( Ok cat, Ok fld ) ->
                                    DynamicDateField cat fld

                                ( _, _ ) ->
                                    UnknownDateField str
                    in
                    dateFld

                Nothing ->
                    UnknownDateField str



dateFieldToString : DateField -> String
dateFieldToString df =
    case df of
        DynamicDateField num1 num2 ->
            "dynamicDateId-" ++ (toString num1) ++ "-" ++ (toString num2)

        AdmittingAdmittanceDateField ->
            "admitDateId"

        AdmittingStartLaborDateField ->
            "admitStartLaborDateId"

        BabyBFedEstablishedDateField ->
            "babyBFedEstablisedId"

        BabyBcgDateField ->
            "babyBcgId"

        BabyNbsDateField ->
            "babyNbsId"

        BabyMed1DateField ->
            "babyMed1Id"

        BirthCertDateOfCommTaxField ->
            "birthCertificateDateOfCommTaxId"

        BirthCertDateOfMarriageField ->
            "birthCertificateDateOfMarriageId"

        ContPostpartumCheckDateField ->
            "contPostpartumCheckId"

        DischargeDateField ->
            "dischargeDateId"

        FalseLaborDateField ->
            "falseLaborDateId"

        LaborDelIppLaborDateField ->
            "laborDateId"

        LaborDelIppStage1DateField ->
            "laborStage1Id"

        LaborDelIppStage2DateField ->
            "laborStage2Id"

        LaborDelIppStage3DateField ->
            "laborStage3Id"

        MembraneRuptureDateField ->
            "membraneRuptureId"

        NewBornExamDateField ->
            "newbornExamId"

        PostpartumCheckDateField ->
            "postpartumCheckId"

        PostpartumCheckHgbField ->
            "postpartumCheckHgbId"

        PostpartumCheckScheduledField ->
            "postpartumCheckScheduledId"

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
