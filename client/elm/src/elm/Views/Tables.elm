module Views.Tables exposing (view)

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
import Views.Utils as VU


type alias Mdl =
    Material.Model


mdlContext : Int
mdlContext =
    FNV.hashString "Views.Tables"


liTable : TableMetaInfo -> Bool -> Html Msg
liTable tblMeta isSelected =
    MList.li
        [ MList.withBody
        , Options.cs "listItem"
        , if isSelected then
            Options.cs "selectedListItem"
          else
            Options.nop
        , SelectQuery tblMeta.table Nothing Nothing Nothing
            |> SelectQuerySelectTable
            |> Html.Events.onClick
            |> Options.attribute
        ]
        [ MList.content []
            [ text tblMeta.name
            , MList.body []
                [ text tblMeta.desc ]
            ]
        ]


tableList : Model -> List (Html Msg)
tableList model =
    [ Grid.grid []
        [ Grid.cell
            [ Grid.size Grid.Desktop 12
            , Grid.size Grid.Tablet 8
            , Grid.size Grid.Phone 4
            ]
            [ MList.ul []
                (List.map
                    (\t -> liTable t (Just t.table == model.selectedTable))
                    C.listLookupTables
                )
            ]
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


{-| The default table view which is a table.
-}
viewMedicationType : Model -> Html Msg
viewMedicationType model =
    let
        data =
            case model.medicationTypeModel.records of
                Success recs ->
                    List.sortBy .sortOrder recs

                Failure e ->
                    let
                        _ =
                            Debug.log "viewMedicationType" <| toString e
                    in
                        []

                _ ->
                    []
    in
        Html.div
            [ HA.class "horizontal-scroll" ]
            [ MTable.table []
                [ MTable.thead []
                    [ MTable.tr []
                        [ MTable.th [] [ Html.text "Id" ]
                        , MTable.th [] [ Html.text "Name" ]
                        , MTable.th [] [ Html.text "Description" ]
                        , MTable.th [] [ Html.text "Sort order" ]
                        ]
                    ]
                , MTable.tbody []
                    (List.map
                        (\rec ->
                            MTable.tr
                                [ Options.onClick <|
                                    MedicationTypeMessages (SelectedRecordEditModeMedicationType EditModeView (Just rec.id))
                                ]
                                [ MTable.td [ MTable.numeric ] [ Html.text <| toString rec.id ]
                                , MTable.td [] [ Html.text rec.name ]
                                , MTable.td [] [ Html.text rec.description ]
                                , MTable.td [ MTable.numeric ] [ Html.text <| toString rec.sortOrder ]
                                ]
                        )
                        data
                    )
                ]
            ]


{-| Viewing, editing, or adding a single record.
-}
viewMedicationTypeEdit : Model -> Html Msg
viewMedicationTypeEdit ({ medicationTypeModel } as model) =
    let
        -- Placeholder for now.
        isEditing =
            medicationTypeModel.editMode
                == EditModeEdit
                || medicationTypeModel.editMode
                == EditModeAdd

        buildForm form =
            let
                tableStr =
                    "medicationType"

                -- Buttons available while editing.
                editingContent =
                    [ VU.button [ mdlContext, 301 ] (MedicationTypeMessages <| FormMsgMedicationType Form.Submit) "Save" False False model.mdl
                    , VU.button [ mdlContext, 302 ] (MedicationTypeMessages <| CancelEditMedicationType) "Cancel" False False model.mdl
                    ]

                -- Buttons available while viewing.
                viewingContent =
                    [ VU.button [ mdlContext, 300 ]
                        (SelectedRecordEditModeMedicationType EditModeEdit medicationTypeModel.selectedRecordId
                            |> MedicationTypeMessages
                        )
                        "Edit"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 303 ]
                        (SelectedRecordEditModeMedicationType EditModeAdd medicationTypeModel.selectedRecordId
                            |> MedicationTypeMessages
                        )
                        "Add"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 305 ]
                        (DeleteMedicationType medicationTypeModel.selectedRecordId
                            |> MedicationTypeMessages
                        )
                        "Delete"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 304 ]
                        (SelectedRecordEditModeMedicationType EditModeTable Nothing
                            |> MedicationTypeMessages
                        )
                        "Table"
                        False
                        False
                        model.mdl
                    ]

                -- Get the FieldStates.
                ( recId, recName, recDescription, recSortOrder ) =
                    ( Form.getFieldAsString "id" form
                    , Form.getFieldAsString "name" form
                    , Form.getFieldAsString "description" form
                    , Form.getFieldAsString "sortOrder" form
                    )

                -- The helper function used to create the partially applied
                -- (String -> Msg) function for each textFld.
                tagger : Form.FieldState e String -> String -> Msg
                tagger fld =
                    FF.String
                        >> (Form.Input fld.path Form.Text)
                        >> FormMsgMedicationType
                        >> MedicationTypeMessages
            in
                Card.view
                    [ Options.css "width" "100%" ]
                    [ Card.title []
                        [ Card.head []
                            [ Html.text tableStr ]
                        ]
                    , Card.text []
                        [ Card.head [] <|
                            if isEditing then
                                editingContent
                            else
                                viewingContent
                        ]
                    , Card.text
                        [ MColor.text MColor.black
                        ]
                        [ VU.textFld "Record id" recId [ mdlContext, 200 ] (tagger recId) False False model.mdl
                        , VU.textFld "Name" recName [ mdlContext, 201 ] (tagger recName) isEditing False model.mdl
                        , VU.textFld "Description" recDescription [ mdlContext, 202 ] (tagger recDescription) isEditing False model.mdl
                        , VU.textFld "Sort Order (must be unique)" recSortOrder [ mdlContext, 203 ] (tagger recSortOrder) isEditing False model.mdl
                        ]
                    , Card.actions [ Card.border ] <|
                        VU.recordChanger
                            ( MedicationTypeMessages FirstMedicationType
                            , MedicationTypeMessages PrevMedicationType
                            , MedicationTypeMessages NextMedicationType
                            , MedicationTypeMessages LastMedicationType
                            )
                            mdlContext
                            model
                    ]

        data =
            case medicationTypeModel.records of
                NotAsked ->
                    Html.text ""

                Loading ->
                    Html.text "Loading"

                Failure err ->
                    Html.text <| toString err

                Success recs ->
                    buildForm medicationTypeModel.form
    in
        div []
            [ data ]


view : Model -> Html Msg
view ({ medicationTypeModel } as model) =
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
                            case medicationTypeModel.editMode of
                                EditModeTable ->
                                    viewMedicationType

                                _ ->
                                    viewMedicationTypeEdit

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
            ]
