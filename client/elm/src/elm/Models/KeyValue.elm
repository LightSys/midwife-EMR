module Models.KeyValue exposing (..)

import Date
import Form exposing (Form)
import Form.Error as Error
import Form.Field as Fld
import Form.Validate as V
import List.Extra as LE
import RemoteData as RD exposing (RemoteData(..))


-- LOCAL IMPORTS

import Types exposing (..)
import Models.Utils as MU


-- MODEL


type alias KeyValueModel =
    TableModel KeyValueRecord KeyValueForm


initialKeyValueModel : KeyValueModel
initialKeyValueModel =
    { records = NotAsked
    , form = Form.initial [] keyValueValidate
    , selectedRecordId = Nothing
    , editMode = EditModeTable
    , nextPendingId = -1
    , selectQuery = Nothing
    }



-- VALIDATION


keyValueInitialForm : KeyValueRecord -> Form () KeyValueForm
keyValueInitialForm rec =
    Form.initial
        [ ( "id", Fld.string <| toString rec.id )
        , ( "kvKey", Fld.string rec.kvKey )
        , ( "kvValue", Fld.string rec.kvValue )
        , ( "description", Fld.string rec.description )
        , ( "valueType", Fld.string <| MU.keyValueTypeToString rec.valueType )
        , ( "acceptableValues", Fld.string rec.acceptableValues )
        , ( "systemOnly", Fld.bool rec.systemOnly )
        ]
        keyValueValidate


keyValueValidate : V.Validation () KeyValueForm
keyValueValidate =
    V.map7 KeyValueForm
        (V.field "id" V.int)
        (V.field "kvKey" V.string |> V.andThen V.nonEmpty)
        (V.field "kvValue" (V.string |> V.defaultValue ""))
        (V.field "description" (V.string |> V.defaultValue ""))
        (V.field "valueType" V.string)
        (V.field "acceptableValues" (V.string |> V.defaultValue ""))
        (V.field "systemOnly" V.bool)


keyValueValidateByType : V.Validation () String -> V.Validation () KeyValueForm
keyValueValidateByType kvValueFunc =
    V.map7 KeyValueForm
        (V.field "id" V.int)
        (V.field "kvKey" V.string |> V.andThen V.nonEmpty)
        (V.field "kvValue" kvValueFunc)
        (V.field "description" (V.string |> V.defaultValue ""))
        (V.field "valueType" V.string)
        (V.field "acceptableValues" (V.string |> V.defaultValue ""))
        (V.field "systemOnly" V.bool)


{-| Determine the type of validation to perform on the kvValue field based
upon the fields valueType and acceptableValues.
-}
keyValueValidateWithForm : Form () KeyValueForm -> V.Validation () KeyValueForm
keyValueValidateWithForm form =
    let
        value =
            Form.getFieldAsString "kvValue" form
                |> .value
                |> Maybe.withDefault ""

        valueType =
            Form.getFieldAsString "valueType" form
                |> .value
                |> Maybe.withDefault ""
                |> MU.stringToKeyValueType

        acceptableValues =
            Form.getFieldAsString "acceptableValues" form
                |> .value
                |> Maybe.withDefault ""
                |> String.split "|"

        integerFunc validation =
            -- Insure that it can be parsed to an Int, but return a String.
            V.customValidation validation
                (\r ->
                    case String.toInt r of
                        Ok val ->
                            Ok <| toString val

                        Err msg ->
                            Err (Error.value Error.InvalidInt)
                )

        decimalFunc validation =
            -- Insure that it can be parsed to a Float, but return a String.
            V.customValidation validation
                (\r ->
                    case String.toFloat r of
                        Ok val ->
                            Ok <| toString val

                        Err msg ->
                            Err (Error.value Error.InvalidFloat)
                )

        dateFunc validation =
            -- Insure that it can be parsed to a Date, but return a String.
            V.customValidation validation
                (\r ->
                    case Date.fromString r of
                        Ok val ->
                            Ok <| toString val

                        Err msg ->
                            Err (Error.value Error.InvalidDate)
                )

        booleanFunc validation =
            -- Insure that it can be parsed to a Bool, but return a String.
            V.customValidation validation
                (\r ->
                    case r of
                        "1" ->
                            Ok "1"

                        "0" ->
                            Ok "0"

                        _ ->
                            Err (Error.value Error.InvalidBool)
                )
    in
        case valueType of
            KeyValueText ->
                keyValueValidateByType (V.string |> V.defaultValue "")

            KeyValueList ->
                keyValueValidateByType (V.string |> V.andThen (V.includedIn acceptableValues))

            KeyValueInteger ->
                keyValueValidateByType (V.string |> integerFunc)

            KeyValueDecimal ->
                keyValueValidateByType (V.string |> decimalFunc)

            KeyValueDate ->
                keyValueValidateByType (V.string |> dateFunc)

            KeyValueBoolean ->
                keyValueValidateByType (V.string |> booleanFunc)



-- FIELD UPDATES


populateSelectedTableForm : KeyValueModel -> KeyValueModel
populateSelectedTableForm record =
    case record.records of
        Success data ->
            case record.editMode of
                EditModeAdd ->
                    -- We don't do add for configuration values.
                    record

                _ ->
                    case LE.find (\r -> r.id == (Maybe.withDefault 0 record.selectedRecordId)) data of
                        Just rec ->
                            record
                                |> MU.setForm (keyValueInitialForm rec)

                        Nothing ->
                            record

        _ ->
            record
