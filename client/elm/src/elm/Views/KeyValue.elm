module Views.KeyValue exposing (view)

import FNV
import Form
import Form.Field as FF
import Html as Html exposing (Html)
import Html.Attributes as HA
import Html.Events
import Material
import Material.Button as Button
import Material.Card as Card
import Material.Chip as Chip
import Material.Color as MColor
import Material.Elevation as Elevation
import Material.Footer as Footer
import Material.Grid as Grid
import Material.Layout as Layout
import Material.List as MList
import Material.Options as Options
import Material.Table as MTable
import Material.Textfield as Textfield
import Material.Toggles as Toggles
import Material.Typography as Typo
import RemoteData as RD exposing (RemoteData(..), WebData)


-- LOCAL IMPORTS

import Model exposing (..)
import Models.Utils as MU
import Msg exposing (Msg(..), KeyValueMsg(..))
import Types exposing (..)
import Views.Utils as VU


mdlContext : Int
mdlContext =
    FNV.hashString "Views.KeyValue"


view : Model -> Html Msg
view ({ keyValueModel } as model) =
    let
        viewFunc =
            if keyValueModel.editMode == EditModeView || keyValueModel.editMode == EditModeEdit then
                viewRecord model
            else
                viewTable model
    in
        Grid.grid
            [ Grid.size Grid.Desktop 12
            , Grid.size Grid.Tablet 8
            , Grid.size Grid.Phone 4
            ]
            [ Grid.cell
                -- Top full size
                [ Grid.size Grid.Desktop 12
                , Grid.size Grid.Tablet 8
                , Grid.size Grid.Phone 4
                ]
                [ Html.h3 []
                    [ Html.text "Configuration" ]
                ]
            , Grid.cell
                -- Full size
                [ Grid.size Grid.Desktop 12
                , Grid.size Grid.Tablet 8
                , Grid.size Grid.Phone 4
                ]
                [ VU.footerMini "Info"
                    """

                These configuration settings allow you, as the administrator,
                to adjust settings for your clinic. The description field will
                explain the purpose of each setting. These settings will affect
                things like report headings, how dates are displayed, and various
                other things. These settings can be changed at any time.

                """
                ]
            , Grid.cell
                -- Configuration table
                [ Grid.size Grid.Desktop 12
                , Grid.size Grid.Tablet 8
                , Grid.size Grid.Phone 4
                ]
                [ viewFunc
                ]
            ]


viewTable : Model -> Html Msg
viewTable ({ keyValueModel } as model) =
    let
        data =
            case keyValueModel.records of
                NotAsked ->
                    []

                Loading ->
                    []

                Failure err ->
                    let
                        _ =
                            Debug.log "viewTable for Configuration" err
                    in
                        []

                Success recs ->
                    List.filter (\r -> r.systemOnly == False) recs

        -- TODO: handle KeyValueDate.
        getRepresentation valueType kvValue =
            case valueType of
                KeyValueBoolean ->
                    case kvValue of
                        "1" ->
                            "True"

                        _ ->
                            "False"

                _ ->
                    kvValue
    in
        Html.div
            []
            [ VU.msgLeftElementRight "Click on a row to edit." (Html.div [] [])
            , MTable.table
                [ Options.css "width" "100%" ]
                [ MTable.thead []
                    [ MTable.tr []
                        [ MTable.th [] [ Html.text "Id" ]
                        , MTable.th [] [ Html.text "Key" ]
                        , MTable.th [] [ Html.text "Value" ]
                        , MTable.th [ Options.css "text-align" "left" ] [ Html.text "Description" ]
                        ]
                    ]
                , MTable.tbody []
                    (data
                        |> List.map
                            (\row ->
                                MTable.tr
                                    [ Options.onClick <|
                                        KeyValueMessages (SelectedRecordEditModeKeyValue EditModeView (Just row.id))
                                    ]
                                    [ MTable.td [ MTable.numeric ] [ Html.text <| toString row.id ]
                                    , MTable.td [] [ Html.text row.kvKey ]
                                    , MTable.td [] [ Html.text <| getRepresentation row.valueType row.kvValue ]
                                    , MTable.td [ Options.css "text-align" "left" ] [ Html.text row.description ]
                                    ]
                            )
                    )
                ]
            ]


viewRecord : Model -> Html Msg
viewRecord ({ keyValueModel } as model) =
    let
        -- Placeholder for now.
        isEditing =
            keyValueModel.editMode == EditModeEdit

        -- TODO: handle all of the various valueTypes well.
        -- text done:
        -- list: done: need a select drop down
        -- integer: done: need to only allow numbers
        -- decimal: done: need to only allow numbers and a period
        -- date: ??? is there a good date picker?
        -- boolean: done: checkbox
        buildForm form =
            let
                pageTitle =
                    "Editing a Configuration Value"

                -- Buttons available while editing.
                editingContent =
                    [ VU.button [ mdlContext, 301 ] (KeyValueMessages <| FormMsgKeyValue Form.Submit) "Save" False False model.mdl
                    , VU.button [ mdlContext, 302 ] (KeyValueMessages <| CancelEditKeyValue) "Cancel" False False model.mdl
                    ]

                -- Buttons available while viewing.
                viewingContent =
                    [ VU.button [ mdlContext, 304 ]
                        (SelectedRecordEditModeKeyValue EditModeTable Nothing
                            |> KeyValueMessages
                        )
                        "Back to Table view"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 300 ]
                        (SelectedRecordEditModeKeyValue EditModeEdit keyValueModel.selectedRecordId
                            |> KeyValueMessages
                        )
                        "Edit"
                        False
                        False
                        model.mdl
                    ]

                isChecked fld =
                    -- Determine if a String field represents a boolean.
                    -- Assumes "1" is True, all else is False.
                    case Maybe.withDefault "" fld.value of
                        "1" ->
                            True

                        _ ->
                            False

                -- Get the FieldStates.
                ( recId, recValue ) =
                    ( Form.getFieldAsString "id" form
                    , Form.getFieldAsString "kvValue" form
                    )

                -- Get some field values.
                ( recIdVal, recKeyVal, recValueVal, recDescriptionVal, recValueTypeVal, recAcceptableValuesVal ) =
                    ( Form.getFieldAsString "id" form
                        |> .value
                        |> Maybe.withDefault ""
                    , Form.getFieldAsString "kvKey" form
                        |> .value
                        |> Maybe.withDefault ""
                    , Form.getFieldAsString "kvValue" form
                        |> .value
                        |> Maybe.withDefault ""
                    , Form.getFieldAsString "description" form
                        |> .value
                        |> Maybe.withDefault ""
                    , Form.getFieldAsString "valueType" form
                        |> .value
                        |> Maybe.withDefault ""
                    , Form.getFieldAsString "acceptableValues" form
                        |> .value
                        |> Maybe.withDefault ""
                    )

                acceptableValues =
                    String.split "|" recAcceptableValuesVal

                _ =
                    Debug.log "viewRecord recValueTypeVal" recValueTypeVal

                -- The helper function used to create the partially applied
                -- (String -> Msg) function for each textFld.
                tagger : Form.FieldState e String -> String -> Msg
                tagger fld =
                    FF.String
                        >> (Form.Input fld.path Form.Text)
                        >> FormMsgKeyValue
                        >> KeyValueMessages

                kvValueInput =
                    -- TODO: add case for KeyValueDate.
                    -- Consider http://package.elm-lang.org/packages/abadi199/datetimepicker/latest
                    case MU.stringToKeyValueType recValueTypeVal of
                        KeyValueList ->
                            Html.div [] <|
                                List.indexedMap
                                    (\idx val ->
                                        Html.div []
                                            [ Toggles.radio Mdl
                                                [ mdlContext, (210 + idx) ]
                                                model.mdl
                                                [ Toggles.value (val == recValueVal)
                                                , Toggles.group "keyValueList"
                                                , Toggles.ripple
                                                , if not isEditing then
                                                    Toggles.disabled
                                                  else
                                                    Options.nop
                                                , Options.onToggle <| tagger recValue val
                                                ]
                                                [ Html.text val ]
                                            ]
                                    )
                                    acceptableValues

                        KeyValueBoolean ->
                            -- We are dealing with a Bool in a String field, so we
                            -- need to make sure that the stored value is either
                            -- "1" or "0".
                            VU.checkBox recKeyVal
                                [ mdlContext, 202 ]
                                (tagger recValue <|
                                    case (not (isChecked recValue)) of
                                        True ->
                                            "1"

                                        False ->
                                            "0"
                                )
                                isEditing
                                (recValueVal == "1")
                                model.mdl

                        KeyValueDate ->
                            VU.textFldDate recKeyVal
                                recValue
                                [ mdlContext, 202 ]
                                (tagger recValue)
                                isEditing
                                False
                                model.mdl

                        _ ->
                            -- KeyValueText, KeyValueInteger and KeyValueDecimal can use the text field.
                            VU.textFld "Value"
                                recValue
                                [ mdlContext, 202 ]
                                (tagger recValue)
                                isEditing
                                False
                                model.mdl
            in
                Card.view
                    [ Options.css "width" "100%" ]
                    [ Card.text [] <|
                        if isEditing then
                            editingContent
                        else
                            viewingContent
                    , Card.text
                        [ MColor.text MColor.primaryContrast
                        ]
                        [ Options.styled Html.span
                            [ Typo.headline
                            , MColor.text MColor.primary
                            ]
                            [ Html.text recKeyVal ]
                        , Options.styled Html.p
                            [ Typo.title
                            , MColor.text MColor.accentContrast
                            ]
                            [ Html.text recDescriptionVal ]
                        ]
                    , Card.text
                        [ MColor.text MColor.black
                        ]
                        [ kvValueInput ]
                    ]

        content =
            case keyValueModel.records of
                NotAsked ->
                    Html.text ""

                Loading ->
                    Html.text "Loading"

                Failure err ->
                    Html.text <| toString err

                Success recs ->
                    buildForm keyValueModel.form
    in
        Html.div []
            [ content ]
