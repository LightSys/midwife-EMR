module Views.Form
    exposing
        ( cancelSaveButtons
        , checkOrNot
        , checkbox
        , checkboxPlain
        , checkboxPlainWide
        , checkboxSelectData
        , checkboxString
        , checkboxWide
        , dateTimeModal
        , dateTimePickerModal
        , formErrors
        , formField
        , formFieldDate
        , formFieldDatePicker
        , formTextareaField
        , formTextareaFieldMin30em
        , radio
        , radioFieldset
        , radioFieldsetOther
        , radioFieldsetWide
        , tableMetaInfo
        )

-- LOCAL IMPORTS --

import Data.DatePicker exposing (DateField(..), DateFieldMessage(..), dateFieldToString)
import Data.SelectData exposing (SelectDataRecord)
import Data.Toast exposing (ToastType(..))
import Date exposing (Date, Month(..), day, month, year)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import List.Extra as LE
import Msg exposing (Msg(..))
import Data.Table exposing (Table(..))
import Data.TableMeta as TM exposing (getTableMeta, TableMetaCollection)
import Util as U


cancelSaveButtons : msg -> msg -> Html msg
cancelSaveButtons cancelMsg saveMsg =
    H.span [ HA.class "c-input-group cancel-save-buttons" ]
        [ H.button
            [ HA.class "c-button u-large u-pillar-box-large"
            , HE.onClick cancelMsg
            ]
            [ H.text "Cancel" ]
        , H.button
            [ HA.class "c-button c-button--brand u-large u-pillar-box-large"
            , HE.onClick saveMsg
            ]
            [ H.text "Save" ]
        ]


formErrors : List ( a, String ) -> Html msg
formErrors errors =
    List.map (\( _, error ) -> H.li [ HA.class "c-list__item" ] [ H.text error ]) errors
        |> H.ul [ HA.class "c-list u-small primary-fg" ]


formField : (String -> msg) -> String -> String -> Bool -> Maybe String -> String -> Html msg
formField msg lbl placeholder isBold val err =
    H.label [ HA.class "c-label o-form-element mw-form-field" ]
        [ H.span
            [ HA.classList [ ( "c-text--loud", isBold ) ]
            ]
            [ H.text lbl ]
        , H.input
            [ HA.class "c-field c-field--label"
            , HA.placeholder placeholder
            , HA.value <| Maybe.withDefault "" val
            , HE.onInput msg
            ]
            []
        , if String.length err > 0 then
            H.div
                [ HA.class "c-text--mono c-text--loud u-xsmall u-bg-yellow"
                , HA.style
                    [ ( "padding", "0.25em 0.25em" )
                    , ( "margin", "0.75em 0 1.25em 0" )
                    ]
                ]
                [ H.text err ]
          else
            H.text ""
        ]


formTextareaField : (String -> msg) -> String -> String -> Bool -> Maybe String -> Int -> Html msg
formTextareaField onInputMsg lbl placeholder isBold val numLines =
    H.label [ HA.class "c-label o-form-element mw-form-field-wide" ]
        [ H.span
            [ HA.classList [ ( "c-text--loud", isBold ) ]
            ]
            [ H.text lbl ]
        , H.textarea
            [ HA.class "c-field c-field--label"
            , HA.rows numLines
            , HA.placeholder placeholder
            , HA.value <| Maybe.withDefault "" val
            , HE.onInput onInputMsg
            ]
            []
        ]


formTextareaFieldMin30em : (String -> msg) -> String -> String -> Bool -> Maybe String -> Int -> Html msg
formTextareaFieldMin30em onInputMsg lbl placeholder isBold val numLines =
    H.label [ HA.class "c-label o-form-element mw-form-field-30em" ]
        [ H.span
            [ HA.classList [ ( "c-text--loud", isBold ) ]
            ]
            [ H.text lbl ]
        , H.textarea
            [ HA.class "c-field c-field--label"
            , HA.rows numLines
            , HA.placeholder placeholder
            , HA.value <| Maybe.withDefault "" val
            , HE.onInput onInputMsg
            ]
            []
        ]


{-| A date form field for browsers that support a date input type and
presumably will display their own date picker interface as required.
-}
formFieldDate : (String -> msg) -> String -> String -> Bool -> Maybe Date -> String -> Html msg
formFieldDate onInputMsg lbl placeholder isBold value err =
    let
        theDate =
            case value of
                Just v ->
                    U.dateFormatter U.YMDDateFmt U.DashDateSep v

                Nothing ->
                    ""
    in
    H.label [ HA.class "c-label o-form-element mw-form-field" ]
        [ H.span
            [ HA.classList [ ( "c-text--loud", isBold ) ] ]
            [ H.text lbl ]
        , H.input
            [ HA.class "c-field c-field--label"
            , HA.type_ "date"
            , HA.placeholder placeholder
            , HA.value theDate
            , HE.onInput onInputMsg
            ]
            []
        , if String.length err > 0 then
            H.div
                [ HA.class "c-text--mono c-text--loud u-xsmall u-bg-yellow"
                , HA.style
                    [ ( "padding", "0.25em 0.25em" )
                    , ( "margin", "0.75em 0 1.25em 0" )
                    ]
                ]
                [ H.text err ]
          else
            H.text ""
        ]


{-| This integrates with via ports the jQueryUI datepicker widget. The openMsg
param is used to open the widget upon focus. The dateFld passed is converted to
a string id which is returned via ports from JS with the date selected in an
IncomingDate structure, which is processed by the Data.DatePicker module.

To add a new date field:

  - add a new branch in Data.DatePicker.DateField
  - add a new case in stringToDateField and dateFieldToString in Data.DatePicker.
  - add a handler in the DateFieldSubMsg branch in the page update for the date field.
  - if necessary, add a new case in the main update for the page and IncomingDatePicker msg.

-}
formFieldDatePicker : (String -> msg) -> DateField -> String -> String -> Bool -> Maybe Date -> String -> Html msg
formFieldDatePicker openMsg dateFld lbl placeholder isBold value err =
    let
        id =
            dateFieldToString dateFld

        theDate =
            case value of
                Just v ->
                    U.dateFormatter U.YMDDateFmt U.DashDateSep v

                Nothing ->
                    ""
    in
    H.label [ HA.class "c-label o-form-element mw-form-field" ]
        [ H.span
            [ HA.classList [ ( "c-text--loud", isBold ) ] ]
            [ H.text lbl ]
        , H.input
            [ HA.class "c-field c-field--label datepicker"
            , HA.type_ "text"
            , HA.id id
            , HA.value theDate
            , HA.placeholder placeholder
            , HE.onFocus <| openMsg id
            ]
            []
        , if String.length err > 0 then
            H.div
                [ HA.class "c-text--mono c-text--loud u-xsmall u-bg-yellow"
                , HA.style
                    [ ( "padding", "0.25em 0.25em" )
                    , ( "margin", "0.75em 0 1.25em 0" )
                    ]
                ]
                [ H.text err ]
          else
            H.text ""
        ]


{-| Show a modal to the user to collect date and time for browsers
that natively support the date input type.
-}
dateTimeModal :
    Bool
    -> String
    -> (String -> msg)
    -> (String -> msg)
    -> msg
    -> msg
    -> msg
    -> Maybe Date
    -> Maybe String
    -> Html msg
dateTimeModal isShown title dateMsg timeMsg closeMsg saveMsg clearMsg dateVal timeVal =
    H.div []
        [ H.div [ HA.classList [ ( "c-overlay c-overlay--visible", isShown ) ] ]
            []
        , H.div
            [ HA.class "o-modal dateTimeModal"
            , HA.classList [ ( "isHidden", not isShown ) ]
            ]
            [ H.div [ HA.class "c-card" ]
                [ H.div [ HA.class "c-card__header" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--close"
                        , HE.onClick closeMsg
                        ]
                        [ H.text "x" ]
                    , H.div [ HA.class "c-heading" ]
                        [ H.text title ]
                    ]
                , H.div [ HA.class "c-card__body dateTimeModalBody" ]
                    [ H.div [ HA.class "o-fieldset form-wrapper" ]
                        [ formFieldDate dateMsg
                            "Date"
                            "e.g. 08/14/2017"
                            False
                            dateVal
                            ""
                        , formField timeMsg
                            "Time"
                            "24 hr format, 14:44"
                            False
                            timeVal
                            ""
                        ]
                    ]
                , H.div [ HA.class "c-card__footer spacedButtons" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--ghost u-small"
                        , HE.onClick clearMsg
                        ]
                        [ H.text "Clear" ]
                    , H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--brand"
                        , HE.onClick saveMsg
                        ]
                        [ H.text "Ok" ]
                    ]
                ]
            ]
        ]


{-| Show a modal to the user to collect date and time for browsers
that do NOT natively support the date input type.
-}
dateTimePickerModal :
    Bool
    -> String
    -> (String -> msg)
    -> (String -> msg)
    -> (String -> msg)
    -> msg
    -> msg
    -> msg
    -> DateField
    -> Maybe Date
    -> Maybe String
    -> Html msg
dateTimePickerModal isShown title openMsg dateMsg timeMsg closeMsg saveMsg clearMsg dateField dateVal timeVal =
    H.div [ HA.classList [ ( "c-overlay c-overlay--visible", isShown ) ] ]
        [ H.div
            [ HA.class "o-modal dateTimeModal"
            , HA.classList [ ( "isHidden", not isShown ) ]
            ]
            [ H.div [ HA.class "c-card" ]
                [ H.div [ HA.class "c-card__header" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--close"
                        , HE.onClick closeMsg
                        ]
                        [ H.text "x" ]
                    , H.h4 [ HA.class "c-heading" ]
                        [ H.text title ]
                    ]
                , H.div [ HA.class "c-card__body" ]
                    [ H.div [ HA.class "o-fieldset form-wrapper" ]
                        [ formFieldDatePicker openMsg
                            dateField
                            "Date"
                            "e.g. 08/14/2017"
                            False
                            dateVal
                            ""
                        , formField timeMsg "Time" "24 hr format, 14:44" False timeVal ""
                        ]
                    ]
                , H.div [ HA.class "c-card__footer spacedButtons" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--ghost u-small"
                        , HE.onClick clearMsg
                        ]
                        [ H.text "Clear" ]
                    , H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--brand"
                        , HE.onClick saveMsg
                        ]
                        [ H.text "Ok" ]
                    ]
                ]
            ]
        ]


{-| Bold checkbox.
-}
checkbox : String -> (Bool -> msg) -> Maybe Bool -> Html msg
checkbox lbl msg val =
    checkboxCore lbl True False msg val


{-| Unbold checkbox.
-}
checkboxPlain : String -> (Bool -> msg) -> Maybe Bool -> Html msg
checkboxPlain lbl msg val =
    checkboxCore lbl False False msg val


{-| Bold checkbox.
-}
checkboxWide : String -> (Bool -> msg) -> Maybe Bool -> Html msg
checkboxWide lbl msg val =
    checkboxCore lbl True True msg val


{-| Unbold checkbox.
-}
checkboxPlainWide : String -> (Bool -> msg) -> Maybe Bool -> Html msg
checkboxPlainWide lbl msg val =
    checkboxCore lbl False True msg val


{-| Unexposed function to allow using a checkbox with the label bolded
or not.
-}
checkboxCore : String -> Bool -> Bool -> (Bool -> msg) -> Maybe Bool -> Html msg
checkboxCore lbl isBoldLabel isWide msg val =
    H.fieldset
        [ HA.class "o-fieldset"
        , HA.classList [ ( "mw-form-field", not isWide ), ( "mw-form-field-2x", isWide ) ]
        ]
        [ H.label []
            [ H.input
                [ HA.type_ "checkbox"
                , HE.onClick (msg <| not <| Maybe.withDefault False val)
                , HA.checked <| Maybe.withDefault False val
                ]
                []
            , H.span [ HA.classList [ ( "c-text--loud", isBoldLabel ) ] ]
                [ H.text lbl ]
            ]
        ]


{-| Displays a graphical check or X depending upon whether the val passed
is True. No user input.
-}
checkOrNot : String -> Bool -> Bool -> Bool -> Html msg
checkOrNot lbl isBoldLabel isWide val =
    H.fieldset
        [ HA.class "o-fieldset"
        , HA.classList [ ( "mw-form-field", not isWide ), ( "mw-form-field-2x", isWide ) ]
        ]
        [ H.label []
            [ H.i
                [ HA.classList
                    [ ( "fa fa-check", val )
                    , ( "fa fa-exclamation-circle", not val )
                    ]
                ]
                []
            , H.span [ HA.classList [ ( "c-text--loud", isBoldLabel ) ] ]
                [ H.text <| " " ++ lbl ]
            ]
        ]


{-| Creates a UI fieldset of checkboxes corresponding to one of the multi select
options represented in the selectData table.
-}
checkboxSelectData : List ( Bool -> msg, SelectDataRecord ) -> String -> String -> Html msg
checkboxSelectData sdList label err =
    let
        boxes =
            List.map
                (\( msg, sd ) ->
                    checkboxPlain sd.label msg (Just sd.selected)
                )
                sdList
    in
    H.fieldset [ HA.class "o-fieldset mw-form-field" ] <|
        [ H.label [ HA.class "o-label" ]
            [ H.span [ HA.class "c-text--loud" ]
                [ H.text label ]
            ]
        ]
            ++ boxes


{-| Allows a checkbox user interface to result in a String rather
than a Bool. Good for populating a Maybe String field using a checkbox.
-}
checkboxString : String -> (String -> msg) -> Maybe String -> Html msg
checkboxString lbl msg val =
    let
        isChecked =
            String.length (Maybe.withDefault "" val) > 0
    in
    H.fieldset [ HA.class "o-fieldset mw-form-field" ]
        [ H.label [ HA.class "o-label" ]
            [ H.input
                [ HA.type_ "checkbox"
                , HE.onClick <|
                    if isChecked then
                        msg ""
                    else
                        msg lbl
                , HA.checked isChecked
                ]
                []
            , H.span [ HA.class "c-text--loud" ]
                [ H.text lbl ]
            ]
        ]


{-| Radio field set.
-}
radioFieldset : String -> String -> Maybe String -> (String -> msg) -> Bool -> List String -> String -> Html msg
radioFieldset title groupName value msg disabled radioTexts err =
    H.fieldset [ HA.class "o-fieldset mw-form-field" ]
        ([ H.legend [ HA.class "o-fieldset__legend" ]
            [ H.span [ HA.class "c-text--loud" ]
                [ H.text title ]
            ]
         ]
            ++ List.map (\text -> radio ( text, groupName, disabled, msg, value )) radioTexts
            ++ (if String.length err > 0 then
                    [ H.div
                        [ HA.class "c-text--mono c-text--loud u-xsmall u-bg-yellow"
                        , HA.style
                            [ ( "padding", "0.25em 0.25em" )
                            , ( "margin", "0.75em 0 1.25em 0" )
                            ]
                        ]
                        [ H.text err ]
                    ]
                else
                    []
               )
        )


{-| Radio field set without width restrictions.
-}
radioFieldsetWide : String -> String -> Maybe String -> (String -> msg) -> Bool -> List String -> String -> Html msg
radioFieldsetWide title groupName value msg disabled radioTexts err =
    H.fieldset [ HA.class "o-fieldset" ]
        ([ H.legend [ HA.class "o-fieldset__legend" ]
            [ H.span [ HA.class "c-text--loud" ]
                [ H.text title ]
            ]
         ]
            ++ List.map (\text -> radio ( text, groupName, disabled, msg, value )) radioTexts
            ++ (if String.length err > 0 then
                    [ H.div
                        [ HA.class "c-text--mono c-text--loud u-xsmall u-bg-yellow"
                        , HA.style
                            [ ( "padding", "0.25em 0.25em" )
                            , ( "margin", "0.75em 0 1.25em 0" )
                            ]
                        ]
                        [ H.text err ]
                    ]
                else
                    []
               )
        )


{-| Group of radio buttons with an Other radio button at the end with an input
text box. If the user types in that, what is typed is returned as the message and
that radio button is selected.
-}
radioFieldsetOther : String -> String -> Maybe String -> (String -> msg) -> Bool -> List String -> String -> Html msg
radioFieldsetOther title groupName value msg disabled radioTexts err =
    let
        matched =
            case LE.find (\v -> v == Maybe.withDefault "" value) radioTexts of
                Just _ ->
                    True

                Nothing ->
                    False

        radioWithOther =
            radioTexts
                ++ (if matched then
                        [ "" ]
                    else
                        [ Maybe.withDefault "" value ]
                   )
    in
    H.fieldset [ HA.class "o-fieldset mw-form-field" ]
        ([ H.legend [ HA.class "o-fieldset__legend" ]
            [ H.span [ HA.class "c-text--loud" ]
                [ H.text title ]
            ]
         ]
            ++ List.indexedMap
                (\i text ->
                    if i < List.length radioTexts then
                        radio ( text, groupName, disabled, msg, value )
                    else
                        radioOther ( text, groupName, disabled, msg, not matched, value )
                )
                radioWithOther
            ++ (if String.length err > 0 then
                    [ H.div
                        [ HA.class "c-text--mono c-text--loud u-xsmall u-bg-yellow"
                        , HA.style
                            [ ( "padding", "0.25em 0.25em" )
                            , ( "margin", "0.75em 0 1.25em 0" )
                            ]
                        ]
                        [ H.text err ]
                    ]
                else
                    []
               )
        )


{-| Same as radio but includes a text input as well. checkable passed specifies
whether or not one of the other radios is checked; if not, then this radio is
"checkable".
-}
radioOther : ( String, String, Bool, String -> msg, Bool, Maybe String ) -> Html msg
radioOther ( text, name, disabled, msg, checkable, val ) =
    H.label
        [ HA.class "c-field c-field--choice c-input-group"
        , HA.style [ ( "position", "relative" ) ]
        ]
        [ H.input
            [ HA.type_ "radio"
            , HA.style [ ( "float", "left" ) ]
            , HA.name name
            , HA.checked
                (Maybe.withDefault "" val
                    == text
                    && text
                    /= ""
                    && checkable
                )
            , HE.onClick (msg text)
            , HA.disabled disabled
            ]
            []
        , H.input
            [ HA.class "c-field"
            , HA.style
                [ ( "position", "absolute" )
                , ( "top", "50%" )
                , ( "transform", "translateY(-50%)" )
                , ( "left", "2em" )
                ]
            , HA.placeholder "or enter another"
            , HA.value <|
                if checkable then
                    Maybe.withDefault "" val
                else
                    ""
            , HE.onInput msg
            ]
            []
        ]


radio : ( String, String, Bool, String -> msg, Maybe String ) -> Html msg
radio ( text, name, disabled, msg, val ) =
    H.label [ HA.class "c-field c-field--choice" ]
        [ H.input
            [ HA.type_ "radio"
            , HA.name name
            , HA.checked (Maybe.withDefault "" val == text)
            , HE.onClick (msg text)
            , HA.disabled disabled
            ]
            []
        , H.text text
        ]


radioBool : ( String, String, Bool -> msg, Maybe Bool ) -> Html msg
radioBool ( text, name, msg, val ) =
    H.label [ HA.class "c-field c-field--choice" ]
        [ H.input
            [ HA.type_ "radio"
            , HA.name name
            , HA.checked <| Maybe.withDefault False val
            , HE.onClick (msg (not (Maybe.withDefault False val)))
            ]
            []
        , H.text text
        ]


{-| Returns a String containing who last updated the record and when.
-}
tableMetaInfo : Table -> Int -> TableMetaCollection -> String
tableMetaInfo tbl key tmColl =
    case TM.getTableMeta tbl key tmColl of
        Just tm ->
            case tm.username of
                Just u ->
                    " by " ++ u ++ " @ " ++ (U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep tm.updatedAt)

                Nothing ->
                    " @ " ++ (U.dateTimeHMFormatter U.MDYDateFmt U.DashDateSep tm.updatedAt)

        Nothing ->
            ""

