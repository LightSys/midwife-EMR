module Views.Form
    exposing
        ( cancelSaveButtons
        , dateTimeModal
        , dateTimePickerModal
        , formErrors
        , formField
        , formFieldDate
        , formFieldDatePicker
        , formTextareaField
        )

import Date exposing (Date, Month(..), day, month, year)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE


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


formField : (String -> msg) -> String -> String -> Maybe String -> Html msg
formField msg lbl placeholder val =
    H.label [ HA.class "c-label o-form-element u-small mw-form-field" ]
        [ H.text lbl
        , H.input
            [ HA.class "c-field c-field--label"
            , HA.placeholder placeholder
            , HA.value <| Maybe.withDefault "" val
            , HE.onInput msg
            ]
            []
        ]


formTextareaField : (String -> msg) -> String -> Int -> Html msg
formTextareaField onInputMsg lbl numLines =
    H.label [ HA.class "c-label o-form-element mw-form-field-wide" ]
        [ H.text lbl
        , H.textarea
            [ HA.class "c-field c-field--label"
            , HA.rows numLines
            , HA.placeholder lbl
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
    -> Maybe Date
    -> Maybe String
    -> Html msg
dateTimeModal isShown title dateMsg timeMsg closeMsg clearMsg dateVal timeVal =
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
                        , formField timeMsg "Time" "24 hr format, 14:44" timeVal
                        ]
                    ]
                , H.div [ HA.class "c-card__footer dateTimeModalButtons" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--ghost u-small"
                        , HE.onClick clearMsg
                        ]
                        [ H.text "Clear" ]
                    , H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--brand"
                        , HE.onClick closeMsg
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
    -> Maybe Date
    -> Maybe String
    -> Html msg
dateTimePickerModal isShown title openMsg dateMsg timeMsg closeMsg clearMsg dateVal timeVal =
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
                        , formField timeMsg "Time" "24 hr format, 14:44" timeVal
                        ]
                    ]
                , H.div [ HA.class "c-card__footer dateTimeModalButtons" ]
                    [ H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--ghost u-small"
                        , HE.onClick clearMsg
                        ]
                        [ H.text "Clear" ]
                    , H.button
                        [ HA.type_ "button"
                        , HA.class "c-button c-button--brand"
                        , HE.onClick closeMsg
                        ]
                        [ H.text "Ok" ]
                    ]
                ]
            ]
        ]
