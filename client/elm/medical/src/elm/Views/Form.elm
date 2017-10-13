module Views.Form
    exposing
        ( cancelSaveButtons
        , checkbox
        , dateTimeModal
        , dateTimePickerModal
        , formErrors
        , formField
        , formFieldDate
        , formFieldDatePicker
        , formTextareaField
        , radio
        , radioFieldset
        , radioFieldsetOther
        )

import Date exposing (Date, Month(..), day, month, year)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import List.Extra as LE


-- LOCAL IMPORTS --

import Data.DatePicker exposing (DateField(..), DateFieldMessage(..), dateFieldToString)
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


formField : (String -> msg) -> String -> String -> Bool -> Maybe String -> Html msg
formField msg lbl placeholder isBold val =
    H.label [ HA.class "c-label o-form-element u-small mw-form-field" ]
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
        ]


formTextareaField : (String -> msg) -> String -> String -> Maybe String -> Int -> Html msg
formTextareaField onInputMsg lbl placeholder val numLines =
    H.label [ HA.class "c-label o-form-element mw-form-field-wide" ]
        [ H.text lbl
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
formFieldDate : (String -> msg) -> String -> String -> Maybe Date -> Html msg
formFieldDate onInputMsg lbl placeholder value =
    let
        theDate =
            case value of
                Just v ->
                    U.dateFormatter U.YMDDateFmt U.DashDateSep v

                Nothing ->
                    ""
    in
        H.label [ HA.class "c-label o-form-element u-small mw-form-field" ]
            [ H.text lbl
            , H.input
                [ HA.class "c-field c-field--label"
                , HA.type_ "date"
                , HA.placeholder placeholder
                , HA.defaultValue theDate
                , HE.onInput onInputMsg
                ]
                []
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
formFieldDatePicker : (String -> msg) -> DateField -> String -> String -> Maybe Date -> Html msg
formFieldDatePicker openMsg dateFld lbl placeholder value =
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
        H.label [ HA.class "c-label o-form-element u-small mw-form-field" ]
            [ H.text lbl
            , H.input
                [ HA.class "c-field c-field--label datepicker"
                , HA.type_ "text"
                , HA.id id
                , HA.value theDate
                , HA.placeholder placeholder
                , HE.onFocus <| openMsg id
                ]
                []
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
    H.div [ HA.classList [ ( "c-overlay c-overlay--transparent", isShown ) ] ]
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
                        [ formFieldDate dateMsg
                            "Date"
                            "e.g. 08/14/2017"
                            dateVal
                        , formField timeMsg "Time" "24 hr format, 14:44" False timeVal
                        ]
                    ]
                , H.div [ HA.class "c-card__footer modalButtons" ]
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
    -> Maybe Date
    -> Maybe String
    -> Html msg
dateTimePickerModal isShown title openMsg dateMsg timeMsg closeMsg saveMsg clearMsg dateVal timeVal =
    H.div [ HA.classList [ ( "c-overlay c-overlay--transparent", isShown ) ] ]
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
                            LaborDelIppStage1DateField
                            "Date"
                            "e.g. 08/14/2017"
                            dateVal
                        , formField timeMsg "Time" "24 hr format, 14:44" False timeVal
                        ]
                    ]
                , H.div [ HA.class "c-card__footer modalButtons" ]
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


checkbox : String -> (Bool -> msg) -> Maybe Bool -> Html msg
checkbox lbl msg val =
    H.fieldset [ HA.class "o-fieldset mw-form-field" ]
        [ H.input
            [ HA.type_ "checkbox"
            , HE.onClick (msg <| not <| Maybe.withDefault False val)
            , HA.checked <| Maybe.withDefault False val
            ]
            []
        , H.span [ HA.class "c-text--loud" ]
            [ H.text lbl ]
        ]


{-| Radio field set.
-}
radioFieldset : String -> String -> Maybe String -> (String -> msg) -> Bool -> List String -> Html msg
radioFieldset title groupName value msg disabled radioTexts =
    H.fieldset [ HA.class "o-fieldset mw-form-field" ]
        ([ H.legend [ HA.class "o-fieldset__legend" ]
            [ H.span [ HA.class "c-text--loud" ]
                [ H.text title ]
            ]
         ]
            ++ (List.map (\text -> radio ( text, groupName, disabled, msg, value )) radioTexts)
        )


{-| Group of radio buttons with an Other radio button at the end with an input
text box. If the user types in that, what is typed is returned as the message and
that radio button is selected.
-}
radioFieldsetOther : String -> String -> Maybe String -> (String -> msg) -> Bool -> List String -> Html msg
radioFieldsetOther title groupName value msg disabled radioTexts =
    let
        matched =
            case LE.find (\v -> v == Maybe.withDefault "" value) radioTexts of
                Just _ ->
                    True

                Nothing ->
                    False

        radioWithOther =
            radioTexts
                ++ if matched then
                    [ "" ]
                   else
                    [ Maybe.withDefault "" value ]
    in
        H.fieldset [ HA.class "o-fieldset mw-form-field" ]
            ([ H.legend [ HA.class "o-fieldset__legend" ]
                [ H.span [ HA.class "c-text--loud" ]
                    [ H.text title ]
                ]
             ]
                ++ (List.indexedMap
                        (\i text ->
                            if i < List.length radioTexts then
                                radio ( text, groupName, disabled, msg, value )
                            else
                                radioOther ( text, groupName, disabled, msg, not matched, value )
                        )
                        radioWithOther
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
                , ( "left", "1.5em" )
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
