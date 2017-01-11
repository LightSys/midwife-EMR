module View.Tables exposing (view)

import Array
import Color as Color
import FNV
import Html as Html exposing (Html, div, p, text)
import Html.Attributes as HA
import Html.Events
import Form
import Form.Field as FF
import Material
import Material.Button as Button
import Material.Card as Card
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
import Material.Layout as Layout
import Material.List as MList
import Material.Options as Options
import Material.Table as MTable
import Material.Textfield as Textfield
import Material.Typography as Typo
import RemoteData as RD exposing (RemoteData(..), WebData)
import String


-- LOCAL IMPORTS

import Constants as C
import Model exposing (..)
import Msg exposing (Msg(..), MedicationTypeMsg(..))
import Types exposing (..)
import Utils as U
import ViewUtils as VU


type alias Mdl =
    Material.Model


mdlContext : Int
mdlContext =
    FNV.hashString "View.Tables"


liTable : TableMetaInfo -> Html Msg
liTable table =
    let
        name =
            table.name

        desc =
            table.desc

        tbl =
            table.table
    in
        MList.li
            [ MList.withBody
            , Options.css "border-bottom" "solid 1px #999"
            ]
            [ MList.content
                [ SelectQuery tbl Nothing Nothing Nothing
                    |> SelectQuerySelectTable
                    |> Html.Events.onClick
                    |> Options.attribute
                ]
                [ text name
                , MList.body []
                    [ text desc ]
                ]
            ]


tableList : Model -> List (Html Msg)
tableList model =
    let
        tables =
            List.map liTable C.listLookupTables
    in
        [ Grid.grid []
            [ Grid.cell
                [ Grid.size Grid.Desktop 12
                , Grid.size Grid.Tablet 8
                , Grid.size Grid.Phone 4
                ]
                [ MList.ul [] tables ]
            ]
        ]


instructionsText : String
instructionsText =
    """
    Select a table on the left.
    """


viewNoTable : Model -> Html Msg
viewNoTable model =
    Html.p [] [ Html.text "Please select a table on the left." ]


viewLabTest : Model -> Html Msg
viewLabTest model =
    let
        data =
            case model.labTest of
                NotAsked ->
                    []

                Loading ->
                    []

                Failure err ->
                    let
                        _ =
                            Debug.log "viewLabTest" err
                    in
                        []

                Success data ->
                    data
    in
        MTable.table []
            [ MTable.thead []
                [ MTable.tr []
                    [ MTable.th [] [ Html.text "id" ]
                    , MTable.th [] [ Html.text "name" ]
                    , MTable.th [] [ Html.text "abbrev" ]
                    , MTable.th [] [ Html.text "normal" ]
                    , MTable.th [] [ Html.text "unit" ]
                    , MTable.th [] [ Html.text "minRangeDecimal" ]
                    , MTable.th [] [ Html.text "maxRangeDecimal" ]
                    , MTable.th [] [ Html.text "minRangeInteger" ]
                    , MTable.th [] [ Html.text "maxRangeInteger" ]
                    , MTable.th [] [ Html.text "isRange" ]
                    , MTable.th [] [ Html.text "isText" ]
                    , MTable.th [] [ Html.text "labSuite_id" ]
                    ]
                ]
            , MTable.tbody []
                (data
                    |> List.map
                        (\row ->
                            MTable.tr []
                                [ MTable.td [ MTable.numeric ] [ Html.text <| toString row.id ]
                                , MTable.td [] [ Html.text row.name ]
                                , MTable.td [] [ Html.text row.abbrev ]
                                , MTable.td [] [ Html.text row.normal ]
                                , MTable.td [] [ Html.text row.unit ]
                                , MTable.td [ MTable.numeric ] [ Html.text <| toString row.minRangeDecimal ]
                                , MTable.td [ MTable.numeric ] [ Html.text <| toString row.maxRangeDecimal ]
                                , MTable.td [ MTable.numeric ] [ Html.text <| toString row.minRangeInteger ]
                                , MTable.td [ MTable.numeric ] [ Html.text <| toString row.maxRangeInteger ]
                                , MTable.td [] [ Html.text <| toString row.isRange ]
                                , MTable.td [] [ Html.text <| toString row.isText ]
                                , MTable.td [ MTable.numeric ] [ Html.text <| toString row.labSuite_id ]
                                ]
                        )
                )
            ]


viewLabSuite : Model -> Html Msg
viewLabSuite model =
    let
        data =
            case model.labSuite of
                NotAsked ->
                    []

                Loading ->
                    []

                Failure err ->
                    let
                        _ =
                            Debug.log "viewLabSuite" err
                    in
                        []

                Success data ->
                    data
    in
        MTable.table []
            [ MTable.thead []
                [ MTable.tr []
                    [ MTable.th [] [ Html.text "id" ]
                    , MTable.th [] [ Html.text "name" ]
                    , MTable.th [] [ Html.text "description" ]
                    , MTable.th [] [ Html.text "category" ]
                    ]
                ]
            , MTable.tbody []
                (data
                    |> List.map
                        (\row ->
                            MTable.tr []
                                [ MTable.td [ MTable.numeric ] [ Html.text (toString row.id) ]
                                , MTable.td [] [ Html.text row.name ]
                                , MTable.td [] [ Html.text row.description ]
                                , MTable.td [] [ Html.text row.category ]
                                ]
                        )
                )
            ]


recordChanger : Model -> List (Html Msg)
recordChanger model =
    let
        isDisabled =
            model.selectedTableEditMode

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
            , Options.onClick FirstRecord
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
            , Options.onClick PreviousRecord
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
            , Options.onClick NextRecord
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
            , Options.onClick LastRecord
            , if isDisabled then
                Button.disabled
              else
                Options.nop
            ]
            [ arrow_forward color size ]
        ]


viewMedicationType : Model -> Html Msg
viewMedicationType model =
    let
        -- Placeholder for now.
        isEditing =
            model.selectedTableEditMode

        textFld lbl fld idx allowEdit =
            let
                tagger : String -> Msg
                tagger =
                    FF.String
                        >> (Form.Input fld.path Form.Text)
                        >> FormMsg
                        >> MedicationTypeMessages
            in
                Textfield.render Mdl
                    idx
                    model.mdl
                    [ Textfield.label lbl
                    , Textfield.floatingLabel
                    , Textfield.value <| Maybe.withDefault "" fld.value
                    , Options.onInput tagger
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

        buildForm form =
            let
                tableStr =
                    case model.selectedTable of
                        Just t ->
                            U.tableToString t

                        Nothing ->
                            ""

                btn idx msg lbl =
                    Button.render Mdl
                        [ mdlContext, idx ]
                        model.mdl
                        [ Button.raised
                        , Button.ripple
                        , Options.css "margin-left" "30px"
                        , Options.onClick msg
                        ]
                        [ Html.text lbl ]

                editingContent =
                    [ Html.text tableStr
                    , btn 301 (MedicationTypeMessages <| MedicationTypeSave) "Save"
                    , btn 302 (MedicationTypeMessages <| MedicationTypeCancel) "Cancel"
                    ]

                viewingContent =
                    [ Html.text tableStr
                    , btn 300 EditSelectedTable "Edit"
                    ]

                ( recId, recName, recDescription, recSortOrder ) =
                    ( Form.getFieldAsString "id" form
                    , Form.getFieldAsString "name" form
                    , Form.getFieldAsString "description" form
                    , Form.getFieldAsString "sortOrder" form
                    )
            in
                Card.view
                    [ Options.css "width" "100%" ]
                    [ Card.title []
                        [ Card.head [] <|
                            if isEditing then
                                editingContent
                            else
                                viewingContent
                        ]
                    , Card.text
                        [ MColor.text MColor.black
                        ]
                        [ textFld "Record id" recId [ mdlContext, 200 ] False
                        , textFld "Name" recName [ mdlContext, 201 ] isEditing
                        , textFld "Description" recDescription [ mdlContext, 202 ] isEditing
                        , textFld "Sort Order" recSortOrder [ mdlContext, 203 ] isEditing
                        ]
                    , Card.actions [ Card.border ] <| recordChanger model
                    ]

        data =
            case model.medicationType of
                NotAsked ->
                    Html.text ""

                Loading ->
                    Html.text "Loading"

                Failure err ->
                    Html.text <| toString err

                Success recs ->
                    buildForm model.medicationTypeForm
    in
        div []
            [ data ]


view : Model -> Html Msg
view model =
    let
        ( selectedTable, dataView ) =
            case model.selectedTable of
                Just t ->
                    ( U.tableToString t
                    , case t of
                        LabSuite ->
                            viewLabSuite

                        LabTest ->
                            viewLabTest

                        MedicationType ->
                            viewMedicationType

                        _ ->
                            viewNoTable
                    )

                Nothing ->
                    ( "", viewNoTable )
    in
        Grid.grid
            [ Grid.size Grid.Desktop 12
            , Grid.size Grid.Tablet 8
            , Grid.size Grid.Phone 4
            ]
            [ Grid.cell
                -- Left side lookup table header.
                [ Grid.size Grid.Desktop 4
                , Grid.size Grid.Tablet 3
                , Grid.size Grid.Phone 4
                ]
                [ Html.h3 []
                    [ text "Lookup tables" ]
                ]
            , Grid.cell
                -- Right side table header.
                [ Grid.size Grid.Desktop 8
                , Grid.size Grid.Tablet 5
                , Grid.size Grid.Phone 4
                ]
                [ VU.footerMini "Warning"
                    """

                    Do not change the "meaning" of lookup table
                    records if there already exist production patient
                    records that reference them. Doing so may effectively
                    change "history" by changing the meaning of already
                    recorded data within the patient records.

                    """
                ]
            , Grid.cell
                -- Left side, list of lookup tables.
                [ Grid.size Grid.Desktop 4
                , Grid.size Grid.Tablet 3
                , Grid.size Grid.Phone 4
                ]
                (tableList model)
            , Grid.cell
                -- Right side, detail view of selected table.
                [ Grid.size Grid.Desktop 8
                , Grid.size Grid.Tablet 5
                , Grid.size Grid.Phone 4
                ]
                [ dataView model
                ]
            , Grid.cell
                -- Right side, model
                [ Grid.size Grid.Desktop 12
                , Grid.size Grid.Tablet 8
                , Grid.size Grid.Phone 4
                ]
                [ Html.text <| toString model.medicationType
                ]
            , Grid.cell
                -- Right side, model
                [ Grid.size Grid.Desktop 12
                , Grid.size Grid.Tablet 8
                , Grid.size Grid.Phone 4
                ]
                [ Html.text <| toString model.transactions
                ]
            ]
