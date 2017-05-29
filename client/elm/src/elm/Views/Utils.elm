module Views.Utils
    exposing
        ( button
        , buttonNoMsg
        , checkBox
        , footerMini
        , fullSizeCellOpts
        , isChecked
        , radio
        , recordChanger
        , textFld
        , textFldFocus
        )

import Color as Color
import Form
import Form.Field as FF
import Html exposing (Html)
import Html.Attributes as HA
import Material
import Material.Button as Button
import Material.Color as MColor
import Material.Elevation as Elevation
import Material.Footer as Footer
import Material.Grid as Grid
import Material.Icons.Navigation as Icon
    exposing
        ( arrow_back
        , chevron_left
        , chevron_right
        , arrow_forward
        )
import Material.Options as Options exposing (Property)
import Material.Textfield as Textfield
import Material.Toggles as Toggles


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (Msg(..), MedicationTypeMsg(..))
import Types exposing (..)


type alias Mdl =
    Material.Model


isChecked : Form.FieldState e Bool -> Bool
isChecked fld =
    case fld.value of
        Just v ->
            v

        Nothing ->
            False


radio : String -> List Int -> Msg -> Bool -> String -> Material.Model -> Html Msg
radio lbl idx msg val radioGroup mdl =
    Toggles.radio Mdl
        idx
        mdl
        [ Toggles.value val
        , Toggles.group radioGroup
        , Toggles.ripple
        , Options.onToggle msg
        ]
        [ Html.text lbl ]


checkBox : String -> List Int -> Msg -> Bool -> Bool -> Material.Model -> Html Msg
checkBox lbl idx msg allowEdit val mdl =
    Toggles.checkbox Mdl
        idx
        mdl
        [ Options.onToggle msg
        , Toggles.ripple
        , Toggles.value val
        , if not allowEdit then
            Toggles.disabled
            else
            Options.nop
        ]
        [ Html.text lbl ]


button : List Int -> Msg -> String -> Bool -> Bool -> Material.Model -> Html Msg
button idx msg lbl isDisabled isSubmit mdl =
    Button.render Mdl
        idx
        mdl
        [ Button.raised
        , Button.ripple
        , if isSubmit then
            Button.type_ "submit"
          else
            Options.nop
        , Options.css "margin-right" "5px"
        , Options.onClick msg
        , Options.disabled isDisabled
        ]
        [ Html.text lbl ]


buttonNoMsg : List Int -> String -> Bool -> Material.Model -> Html Msg
buttonNoMsg idx lbl isDisabled mdl =
    Button.render Mdl
        idx
        mdl
        [ Button.raised
        , Button.ripple
        , Options.css "margin-right" "5px"
        , Options.disabled isDisabled
        ]
        [ Html.text lbl ]


errorFor : Form.FieldState e String -> String -> Html Msg
errorFor field lbl =
    case field.error of
        Just error ->
            Html.span [ HA.class "error-field" ]
                [ Html.text <| lbl ++ " problem: " ++ toString error ]

        Nothing ->
            Html.span [] [ Html.text "" ]


fullSizeCellOpts : List (Property () a)
fullSizeCellOpts =
    [ Grid.size Grid.Desktop 12
    , Grid.size Grid.Tablet 8
    , Grid.size Grid.Phone 4
    ]


footerMini : String -> String -> Html m
footerMini headerText bodyText =
    Footer.mini
        [ MColor.text MColor.white
        , Elevation.e6
        ]
        { left =
            Footer.left []
                [ Footer.html <|
                    Html.div
                        [ HA.class "footer-warning-header" ]
                        [ Html.text headerText ]
                ]
        , right =
            Footer.right []
                [ Footer.html <| Html.text bodyText ]
        }


recordChanger : ( Msg, Msg, Msg, Msg ) -> Int -> Model -> List (Html Msg)
recordChanger ( first, prev, next, last ) mdlContext model =
    let
        isDisabled =
            model.selectedTableEditMode
                == EditModeEdit
                || model.selectedTableEditMode
                == EditModeAdd

        ( color, size ) =
            if isDisabled then
                ( Color.white, 30 )
            else
                ( Color.black, 30 )
    in
        [ Button.render Mdl
            [ mdlContext, 100 ]
            model.mdl
            [ Button.raised
            , Button.ripple
            , Options.onClick first
            , if isDisabled then
                Button.disabled
              else
                Options.nop
            ]
            [ arrow_back color size ]
        , Button.render Mdl
            [ mdlContext, 101 ]
            model.mdl
            [ Button.raised
            , Button.ripple
            , Options.onClick prev
            , if isDisabled then
                Button.disabled
              else
                Options.nop
            ]
            [ chevron_left color size ]
        , Button.render Mdl
            [ mdlContext, 102 ]
            model.mdl
            [ Button.raised
            , Button.ripple
            , Options.onClick next
            , if isDisabled then
                Button.disabled
              else
                Options.nop
            ]
            [ chevron_right color size ]
        , Button.render Mdl
            [ mdlContext, 103 ]
            model.mdl
            [ Button.raised
            , Button.ripple
            , Options.onClick last
            , if isDisabled then
                Button.disabled
              else
                Options.nop
            ]
            [ arrow_forward color size ]
        ]


textFld : String -> Form.FieldState e String -> List Int -> (String -> Msg) -> Bool -> Bool -> Material.Model -> Html Msg
textFld lbl fld idx tagger allowEdit isPassword mdl =
    Html.div []
        [ Textfield.render Mdl
            idx
            mdl
            [ Textfield.label lbl
            , Textfield.floatingLabel
            , Textfield.value <| Maybe.withDefault "" fld.value
            , Options.onInput tagger
            , if isPassword then
                Textfield.password
              else
                Options.nop
            , if not allowEdit then
                Textfield.disabled
              else
                Options.nop
            , if allowEdit then
                Options.css "font-weight" "bold"
              else
                Options.nop
            , Options.input
                [ MColor.text MColor.primary
                ]
            ]
            []
        , errorFor fld lbl
        ]

textFldFocus : String -> Form.FieldState e String -> List Int -> (String -> Msg) -> Bool -> Bool -> Material.Model -> Html Msg
textFldFocus lbl fld idx tagger allowEdit isPassword mdl =
    Html.div []
        [ Textfield.render Mdl
            idx
            mdl
            [ Textfield.label lbl
            , Textfield.floatingLabel
            , Textfield.value <| Maybe.withDefault "" fld.value
            , Options.onInput tagger
            , Textfield.autofocus
            , if isPassword then
                Textfield.password
              else
                Options.nop
            , if not allowEdit then
                Textfield.disabled
              else
                Options.nop
            , if allowEdit then
                Options.css "font-weight" "bold"
              else
                Options.nop
            , Options.input
                [ MColor.text MColor.primary
                ]
            ]
            []
        , errorFor fld lbl
        ]
