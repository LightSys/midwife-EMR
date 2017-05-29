module Views.Tables exposing (view)

import FNV
import Html as Html exposing (Html, div, p, text)
import Html.Attributes as HA
import Html.Events
import Form
import Form.Field as FF
import List.Extra as LE
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
import Msg exposing (Msg(..), MedicationTypeMsg(..), SelectDataMsg(..), VaccinationTypeMsg(..))
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
viewVaccinationType : Model -> Html Msg
viewVaccinationType model =
    let
        data =
            case model.vaccinationTypeModel.records of
                Success recs ->
                    List.sortBy .sortOrder recs

                Failure e ->
                    let
                        _ =
                            Debug.log "viewVaccinationType" <| toString e
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
                                    VaccinationTypeMessages (SelectedRecordEditModeVaccinationType EditModeView (Just rec.id))
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
viewVaccinationTypeEdit : Model -> Html Msg
viewVaccinationTypeEdit ({ vaccinationTypeModel } as model) =
    let
        -- Placeholder for now.
        isEditing =
            vaccinationTypeModel.editMode
                == EditModeEdit
                || vaccinationTypeModel.editMode
                == EditModeAdd

        buildForm form =
            let
                tableStr =
                    "vaccinationType"

                -- Buttons available while editing.
                editingContent =
                    [ VU.button [ mdlContext, 301 ] (VaccinationTypeMessages <| FormMsgVaccinationType Form.Submit) "Save" False False model.mdl
                    , VU.button [ mdlContext, 302 ] (VaccinationTypeMessages <| CancelEditVaccinationType) "Cancel" False False model.mdl
                    ]

                -- Buttons available while viewing.
                viewingContent =
                    [ VU.button [ mdlContext, 300 ]
                        (SelectedRecordEditModeVaccinationType EditModeEdit vaccinationTypeModel.selectedRecordId
                            |> VaccinationTypeMessages
                        )
                        "Edit"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 303 ]
                        (SelectedRecordEditModeVaccinationType EditModeAdd vaccinationTypeModel.selectedRecordId
                            |> VaccinationTypeMessages
                        )
                        "Add"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 305 ]
                        (DeleteVaccinationType vaccinationTypeModel.selectedRecordId
                            |> VaccinationTypeMessages
                        )
                        "Delete"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 304 ]
                        (SelectedRecordEditModeVaccinationType EditModeTable Nothing
                            |> VaccinationTypeMessages
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
                        >> FormMsgVaccinationType
                        >> VaccinationTypeMessages
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
                            ( VaccinationTypeMessages FirstVaccinationType
                            , VaccinationTypeMessages PrevVaccinationType
                            , VaccinationTypeMessages NextVaccinationType
                            , VaccinationTypeMessages LastVaccinationType
                            )
                            mdlContext
                            model
                    ]

        data =
            case vaccinationTypeModel.records of
                NotAsked ->
                    Html.text ""

                Loading ->
                    Html.text "Loading"

                Failure err ->
                    Html.text <| toString err

                Success recs ->
                    buildForm vaccinationTypeModel.form
    in
        div []
            [ data ]


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


{-| Note that for the sake of simplicity, we assume that the label
and the selectKey fields are the same because there is no reason that
the user needs to try to understand what the difference is between
them. Therefore, that means that the label field across a group by
the name field must be unique.
-}
viewSelectData : Model -> Html Msg
viewSelectData model =
    let
        data =
            case model.selectDataModel.records of
                Success recs ->
                    List.filter
                        (\r ->
                            case U.editableStringToSelectDataName r.name of
                                Just sdn ->
                                    True

                                Nothing ->
                                    False
                        )
                        recs
                        |> List.sortBy .name

                Failure e ->
                    let
                        _ =
                            Debug.log "viewSelectData" <| toString e
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
                        , MTable.th [] [ Html.text "Label" ]
                        , MTable.th [] [ Html.text "Default (zero or one per name group)" ]
                        ]
                    ]
                , MTable.tbody []
                    (List.map
                        (\rec ->
                            MTable.tr
                                [ Options.onClick <|
                                    SelectDataMessages (SelectedRecordEditModeSelectData EditModeView (Just rec.id) Nothing)
                                ]
                                [ MTable.td [ MTable.numeric ] [ Html.text <| toString rec.id ]
                                , MTable.td [] [ Html.text rec.name ]
                                , MTable.td [] [ Html.text rec.label ]
                                , MTable.td [] [ Html.text <| toString rec.selected ]
                                ]
                        )
                        data
                    )
                ]
            ]


{-| Viewing, editing, or adding a single record.
-}
viewSelectDataEdit : Model -> Html Msg
viewSelectDataEdit ({ selectDataModel } as model) =
    let
        -- Placeholder for now.
        isEditing =
            selectDataModel.editMode
                == EditModeEdit
                || selectDataModel.editMode
                == EditModeAdd

        name =
            case selectDataModel.selectedRecordId of
                Just id ->
                    case selectDataModel.records of
                        Success recs ->
                            case LE.find (\r -> r.id == id) recs of
                                Just rec ->
                                    rec.name

                                Nothing ->
                                    ""

                        _ ->
                            ""

                Nothing ->
                    ""

        buildForm form =
            let
                tableStr =
                    "selectData"

                -- Buttons available while editing.
                editingContent =
                    [ VU.button [ mdlContext, 301 ] (SelectDataMessages <| FormMsgSelectData Form.Submit) "Save" False False model.mdl
                    , VU.button [ mdlContext, 302 ] (SelectDataMessages <| CancelEditSelectData) "Cancel" False False model.mdl
                    ]

                -- Buttons available while viewing.
                viewingContent =
                    [ VU.button [ mdlContext, 300 ]
                        (SelectedRecordEditModeSelectData EditModeEdit selectDataModel.selectedRecordId Nothing
                            |> SelectDataMessages
                        )
                        "Edit"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 303 ]
                        (SelectedRecordEditModeSelectData EditModeAdd selectDataModel.selectedRecordId (Just name)
                            |> SelectDataMessages
                        )
                        ("Add " ++ name)
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 305 ]
                        (DeleteSelectData selectDataModel.selectedRecordId
                            |> SelectDataMessages
                        )
                        "Delete"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 304 ]
                        (SelectedRecordEditModeSelectData EditModeTable Nothing Nothing
                            |> SelectDataMessages
                        )
                        "Table"
                        False
                        False
                        model.mdl
                    ]

                -- Get the FieldStates.
                ( recId, recName, recLabel, recSelected ) =
                    ( Form.getFieldAsString "id" form
                    , Form.getFieldAsString "name" form
                    , Form.getFieldAsString "label" form
                    , Form.getFieldAsBool "selected" form
                    )

                -- The helper function used to create the partially applied
                -- (String -> Msg) function for each textFld.
                tagger : Form.FieldState e String -> String -> Msg
                tagger fld =
                    FF.String
                        >> (Form.Input fld.path Form.Text)
                        >> FormMsgSelectData
                        >> SelectDataMessages

                -- The helper function used to create the partially applied
                -- (Bool -> Msg) function for each checkBox.
                taggerBool : Form.FieldState e Bool -> Bool -> Msg
                taggerBool fld =
                    FF.Bool
                        >> (Form.Input fld.path Form.Checkbox)
                        >> FormMsgSelectData
                        >> SelectDataMessages
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
                        , VU.textFld "Name" recName [ mdlContext, 201 ] (tagger recName) False False model.mdl
                        , VU.textFld "Label" recLabel [ mdlContext, 202 ] (tagger recLabel) isEditing False model.mdl
                        , VU.checkBox "Default" [ mdlContext, 203 ] (taggerBool recSelected (not (VU.isChecked recSelected)))
                            isEditing (VU.isChecked recSelected) model.mdl
                        ]
                    ]

        data =
            case selectDataModel.records of
                NotAsked ->
                    Html.text ""

                Loading ->
                    Html.text "Loading"

                Failure err ->
                    Html.text <| toString err

                Success recs ->
                    buildForm selectDataModel.form
    in
        div []
            [ data ]


view : Model -> Html Msg
view ({ medicationTypeModel, selectDataModel, vaccinationTypeModel } as model) =
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

                        SelectData ->
                            case selectDataModel.editMode of
                                EditModeTable ->
                                    viewSelectData

                                _ ->
                                    viewSelectDataEdit

                        VaccinationType ->
                            case vaccinationTypeModel.editMode of
                                EditModeTable ->
                                    viewVaccinationType

                                _ ->
                                    viewVaccinationTypeEdit

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
