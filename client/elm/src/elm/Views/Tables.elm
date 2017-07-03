module Views.Tables exposing (view)

import Dict
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
import String


-- LOCAL IMPORTS

import Constants as C
import Msg
    exposing
        ( LabSuiteMsg(..)
        , LabTestMsg(..)
        , LabTestValueMsg(..)
        , Msg(..)
        , MedicationTypeMsg(..)
        , SelectDataMsg(..)
        , VaccinationTypeMsg(..)
        )
import Model exposing (..)
import Models.Utils as MU
import Types exposing (..)
import Utils as U
import Views.Utils as VU


type alias Mdl =
    Material.Model


mdlContext : Int
mdlContext =
    FNV.hashString "Views.Tables"


labSuiteKey : String
labSuiteKey =
    "labSuiteSelected"


labTestKey : String
labTestKey =
    "labTestSelected"


{-| Displays a list of "tables" to choose from. If the table is
LabSuite, it also retrieves LabTest and LabTestValue from the
server since they are all handled together.
-}
liTable : TableMetaInfo -> Bool -> Html Msg
liTable tblMeta isSelected =
    MList.li
        [ MList.withBody
        , Options.cs "listItem"
        , if isSelected then
            Options.cs "selectedListItem"
          else
            Options.nop
        , if tblMeta.table == LabSuite then
            [ SelectQuery LabTest Nothing Nothing Nothing
            , SelectQuery LabSuite Nothing Nothing Nothing
            , SelectQuery LabTestValue Nothing Nothing Nothing
            ]
                |> SelectQuerySelectTable LabSuite
                |> Html.Events.onClick
                |> Options.attribute
          else
            [ SelectQuery tblMeta.table Nothing Nothing Nothing ]
                |> SelectQuerySelectTable tblMeta.table
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


{-| Note currently being used.
-}
viewLabTest : Model -> Html Msg
viewLabTest model =
    let
        data =
            case model.labTestModel.records of
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


viewLabTestValueTable : Model -> Html Msg
viewLabTestValueTable ({ labTestModel, labTestValueModel } as model ) =
    let
        fKey =
            case labTestModel.selectedRecordId of
                Just id ->
                    id

                Nothing ->
                    -- If not set for some reason, at least we display nothing.
                    -1

        testName =
            Maybe.withDefault "" <| MU.getNameById fKey labTestModel.records

        data =
            case labTestValueModel.records of
                NotAsked ->
                    []

                Loading ->
                    []

                Failure err ->
                    let
                        _ =
                            Debug.log "viewLabTestValueTable" err
                    in
                        []

                Success data ->
                    List.filter (\r -> r.labTest_id == fKey) data
    in
        Html.div []
            [ Card.view
                [ Options.css "width" "100%" ]
                [ Card.title []
                    [ Card.head []
                        [ Html.text testName ]
                    ]
                , Card.text
                    [ MColor.text MColor.accent
                    , MColor.background MColor.accentContrast
                    , Elevation.e6
                    , Options.css "margin-bottom" "20px"
                    ]
                    [ Html.text "These records limit the choices for this particular test to the values in this list." ]
                ]
            , Html.div []
                [ VU.button [ mdlContext, 450 ]
                    (LabTestMessages <| SelectedRecordEditModeLabTest EditModeView labTestModel.selectedRecordId)
                    "Back to Lab Test"
                    False
                    False
                    model.mdl
                ]
            , VU.msgLeftElementRight "Click on a row to edit or delete." <|
                VU.button [ mdlContext, 451 ]
                    (SelectedRecordEditModeLabTestValue EditModeAdd Nothing
                        |> LabTestValueMessages
                    )
                    "Add"
                    False
                    False
                    model.mdl
            , MTable.table
                [ Options.css "width" "100%" ]
                [ MTable.thead []
                    [ MTable.tr []
                        [ MTable.th [] [ Html.text "Id" ]
                        , MTable.th [] [ Html.text "Value" ]
                        ]
                    ]
                , MTable.tbody []
                    (data
                        |> List.map
                            (\row ->
                                MTable.tr
                                    [ Options.onClick <|
                                        LabTestValueMessages (SelectedRecordEditModeLabTestValue EditModeView (Just row.id))
                                    ]
                                    [ MTable.td [ MTable.numeric ] [ Html.text <| toString row.id ]
                                    , MTable.td [] [ Html.text row.value ]
                                    ]
                            )
                    )
                ]
            ]


viewLabTestValueRecord : Model -> Html Msg
viewLabTestValueRecord ({ labTestModel, labTestValueModel } as model) =
    let
        isEditing =
            labTestValueModel.editMode
                == EditModeEdit
                || labTestValueModel.editMode
                == EditModeAdd

        buildForm form =
            let
                tableStr =
                    "labTestValue"

                -- Buttons available while editing.
                editingContent =
                    [ VU.button [ mdlContext, 441 ] (LabTestValueMessages <| FormMsgLabTestValue Form.Submit) "Save" False False model.mdl
                    , VU.button [ mdlContext, 442 ] (LabTestValueMessages <| CancelEditLabTestValue) "Cancel" False False model.mdl
                    ]

                -- Buttons available while viewing.
                viewingContent =
                    [ VU.button [ mdlContext, 444 ]
                        (SelectedRecordEditModeLabTestValue EditModeTable Nothing
                            |> LabTestValueMessages
                        )
                        "Back to Lab Test Values"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 440 ]
                        (SelectedRecordEditModeLabTestValue EditModeEdit labTestValueModel.selectedRecordId
                            |> LabTestValueMessages
                        )
                        "Edit"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 445 ]
                        (DeleteLabTestValue labTestValueModel.selectedRecordId
                            |> LabTestValueMessages
                        )
                        "Delete"
                        False
                        False
                        model.mdl
                    ]

                -- Get the FieldStates.
                ( recId, recValue ) =
                    ( Form.getFieldAsString "id" form
                    , Form.getFieldAsString "value" form
                    )

                -- The helper function used to create the partially applied
                -- (String -> Msg) function for each textFld.
                tagger : Form.FieldState e String -> String -> Msg
                tagger fld =
                    FF.String
                        >> (Form.Input fld.path Form.Text)
                        >> FormMsgLabTestValue
                        >> LabTestValueMessages
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
                        [ VU.textFld "Record id" recId [ mdlContext, 450 ] (tagger recId) False False model.mdl
                        , VU.textFld "Value" recValue [ mdlContext, 451 ] (tagger recValue) isEditing False model.mdl
                        ]
                    ]

        data =
            case labTestValueModel.records of
                NotAsked ->
                    Html.text ""

                Loading ->
                    Html.text "Loading"

                Failure err ->
                    Html.text <| toString err

                Success recs ->
                    buildForm labTestValueModel.form
    in
        div []
            [ data ]


viewLabTestRecord : Model -> Html Msg
viewLabTestRecord ({ labSuiteModel, labTestModel, labTestValueModel } as model) =
    let
        isEditing =
            labTestModel.editMode
                == EditModeEdit
                || labTestModel.editMode
                == EditModeAdd

        labTestValueData =
            case labTestValueModel.records of
                NotAsked ->
                    []

                Loading ->
                    []

                Failure err ->
                    let
                        _ =
                            Debug.log "labTestValue" err
                    in
                        []

                Success data ->
                    data

        buildForm form =
            let
                tableStr =
                    "labTest"

                -- Buttons available while editing.
                editingContent =
                    [ VU.button [ mdlContext, 411 ] (LabTestMessages <| FormMsgLabTest Form.Submit) "Save" False False model.mdl
                    , VU.button [ mdlContext, 412 ] (LabTestMessages <| CancelEditLabTest) "Cancel" False False model.mdl
                    ]

                -- Buttons available while viewing.
                viewingContent =
                    [ VU.button [ mdlContext, 424 ]
                        (SelectedRecordEditModeLabTest EditModeOther Nothing
                            |> LabTestMessages
                        )
                        "Back to Lab Suite Records"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 420 ]
                        (SelectedRecordEditModeLabTest EditModeEdit labTestModel.selectedRecordId
                            |> LabTestMessages
                        )
                        "Edit"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 425 ]
                        (DeleteLabTest labTestModel.selectedRecordId
                            |> LabTestMessages
                        )
                        "Delete"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 426 ]
                        (SelectedRecordEditModeLabTestValue EditModeTable Nothing
                            |> LabTestValueMessages
                        )
                        "Add or Edit Acceptable Test Values"
                        False
                        False
                        model.mdl
                    ]

                -- Get the FieldStates.
                ( recId, recName, recAbbrev, recNormal, recUnit, recMinRangeDecimal, recMaxRangeDecimal ) =
                    ( Form.getFieldAsString "id" form
                    , Form.getFieldAsString "name" form
                    , Form.getFieldAsString "abbrev" form
                    , Form.getFieldAsString "normal" form
                    , Form.getFieldAsString "unit" form
                    , Form.getFieldAsString "minRangeDecimal" form
                    , Form.getFieldAsString "maxRangeDecimal" form
                    )

                ( recMinRangeInteger, recMaxRangeInteger, recIsRange, recIsText ) =
                    ( Form.getFieldAsString "minRangeInteger" form
                    , Form.getFieldAsString "maxRangeInteger" form
                    , Form.getFieldAsBool "isRange" form
                    , Form.getFieldAsBool "isText" form
                    )

                -- The helper function used to create the partially applied
                -- (String -> Msg) function for each textFld.
                tagger : Form.FieldState e String -> String -> Msg
                tagger fld =
                    FF.String
                        >> (Form.Input fld.path Form.Text)
                        >> FormMsgLabTest
                        >> LabTestMessages
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
                        [ MColor.text MColor.accent
                        , MColor.background MColor.accentContrast
                        , Elevation.e6
                        ]
                        [ Html.text "If you use min/max range fields, use either the Decimal pair or the Whole Number pair, not both." ]
                    , Card.text
                        [ MColor.text MColor.black
                        ]
                        [ VU.textFld "Record id" recId [ mdlContext, 400 ] (tagger recId) False False model.mdl
                        , VU.textFld "Name" recName [ mdlContext, 401 ] (tagger recName) isEditing False model.mdl
                        , VU.textFld "Abbreviation" recAbbrev [ mdlContext, 402 ] (tagger recAbbrev) isEditing False model.mdl
                        , VU.textFld "Normal" recNormal [ mdlContext, 403 ] (tagger recNormal) isEditing False model.mdl
                        , VU.textFld "Unit" recUnit [ mdlContext, 404 ] (tagger recUnit) isEditing False model.mdl
                        , VU.textFld "Min Range as Decimal" recMinRangeDecimal [ mdlContext, 405 ] (tagger recMinRangeDecimal) isEditing False model.mdl
                        , VU.textFld "Max Range as Decimal" recMaxRangeDecimal [ mdlContext, 406 ] (tagger recMaxRangeDecimal) isEditing False model.mdl
                        , VU.textFld "Min Range as Whole Number" recMinRangeInteger [ mdlContext, 407 ] (tagger recMinRangeInteger) isEditing False model.mdl
                        , VU.textFld "Max Range as Whole Number" recMaxRangeInteger [ mdlContext, 408 ] (tagger recMaxRangeInteger) isEditing False model.mdl
                        ]
                    ]

        data =
            case labTestModel.records of
                NotAsked ->
                    Html.text ""

                Loading ->
                    Html.text "Loading"

                Failure err ->
                    Html.text <| toString err

                Success recs ->
                    buildForm labTestModel.form
    in
        div []
            [ data ]


viewLabSuiteRecord : Model -> Html Msg
viewLabSuiteRecord ({ labSuiteModel } as model) =
    let
        -- Placeholder for now.
        isEditing =
            labSuiteModel.editMode
                == EditModeEdit
                || labSuiteModel.editMode
                == EditModeAdd

        buildForm form =
            let
                tableStr =
                    "labSuite"

                -- Buttons available while editing.
                editingContent =
                    [ VU.button [ mdlContext, 301 ] (LabSuiteMessages <| FormMsgLabSuite Form.Submit) "Save" False False model.mdl
                    , VU.button [ mdlContext, 302 ] (LabSuiteMessages <| CancelEditLabSuite) "Cancel" False False model.mdl
                    ]

                -- Buttons available while viewing.
                viewingContent =
                    [ VU.button [ mdlContext, 304 ]
                        (SelectedRecordEditModeLabSuite EditModeTable Nothing
                            |> LabSuiteMessages
                        )
                        "Back to Table view"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 300 ]
                        (SelectedRecordEditModeLabSuite EditModeEdit labSuiteModel.selectedRecordId
                            |> LabSuiteMessages
                        )
                        "Edit"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 305 ]
                        (DeleteLabSuite labSuiteModel.selectedRecordId
                            |> LabSuiteMessages
                        )
                        "Delete"
                        False
                        False
                        model.mdl
                    ]

                -- Get the FieldStates.
                ( recId, recName, recDescription ) =
                    ( Form.getFieldAsString "id" form
                    , Form.getFieldAsString "name" form
                    , Form.getFieldAsString "description" form
                    )

                -- The helper function used to create the partially applied
                -- (String -> Msg) function for each textFld.
                tagger : Form.FieldState e String -> String -> Msg
                tagger fld =
                    FF.String
                        >> (Form.Input fld.path Form.Text)
                        >> FormMsgLabSuite
                        >> LabSuiteMessages
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
                        ]
                    ]

        data =
            case labSuiteModel.records of
                NotAsked ->
                    Html.text ""

                Loading ->
                    Html.text "Loading"

                Failure err ->
                    Html.text <| toString err

                Success recs ->
                    buildForm labSuiteModel.form
    in
        div []
            [ data ]


viewLabSuiteTable : Model -> Html Msg
viewLabSuiteTable ({ labSuiteModel } as model) =
    let
        data =
            case labSuiteModel.records of
                NotAsked ->
                    []

                Loading ->
                    []

                Failure err ->
                    let
                        _ =
                            Debug.log "viewLabSuiteTable" err
                    in
                        []

                Success data ->
                    data
    in
        Html.div []
            [ Html.div []
                [ VU.button [ mdlContext, 450 ]
                    (LabSuiteMessages <| SelectedRecordEditModeLabSuite EditModeOther labSuiteModel.selectedRecordId)
                    "Back to Labs Overview"
                    False
                    False
                    model.mdl
                ]
            , VU.msgLeftElementRight "Click on a row to edit or delete." <|
                VU.button [ mdlContext, 451 ]
                    (SelectedRecordEditModeLabSuite EditModeAdd Nothing
                        |> LabSuiteMessages
                    )
                    "Add"
                    False
                    False
                    model.mdl
            , MTable.table
                [ Options.css "width" "100%" ]
                [ MTable.thead []
                    [ MTable.tr []
                        [ MTable.th [] [ Html.text "Id" ]
                        , MTable.th [] [ Html.text "Name" ]
                        , MTable.th [] [ Html.text "description" ]
                        ]
                    ]
                , MTable.tbody []
                    (data
                        |> List.map
                            (\row ->
                                MTable.tr
                                    [ Options.onClick <|
                                        LabSuiteMessages (SelectedRecordEditModeLabSuite EditModeView (Just row.id))
                                    ]
                                    [ MTable.td [ MTable.numeric ] [ Html.text <| toString row.id ]
                                    , MTable.td [] [ Html.text row.name ]
                                    , MTable.td [] [ Html.text row.description ]
                                    ]
                            )
                    )
                ]
            ]


viewLabs : Model -> Html Msg
viewLabs ({ labSuiteModel, labTestModel, labTestValueModel } as model) =
    let
        labSuiteData =
            case labSuiteModel.records of
                NotAsked ->
                    []

                Loading ->
                    []

                Failure err ->
                    let
                        _ =
                            Debug.log "viewLabs" err
                    in
                        []

                Success data ->
                    data
                        |> List.sortBy .name

        labTestData =
            case labTestModel.records of
                NotAsked ->
                    []

                Loading ->
                    []

                Failure err ->
                    let
                        _ =
                            Debug.log "labTestData" err
                    in
                        []

                Success data ->
                    data

        labTestValue =
            case labTestValueModel.records of
                NotAsked ->
                    []

                Loading ->
                    []

                Failure err ->
                    let
                        _ =
                            Debug.log "labTestValue" err
                    in
                        []

                Success data ->
                    data

        -- labTest records have a labSuite_id foreign key that is never negative.
        selectedLabSuiteId =
            Maybe.withDefault -1 labSuiteModel.selectedRecordId
            --case Dict.get labSuiteKey model.userChoice of
                --Just id ->
                    --Result.withDefault -1 (String.toInt id)

                --Nothing ->
                    ---1

        selectedLabSuiteName =
            Maybe.withDefault "" <| MU.getNameById selectedLabSuiteId labSuiteModel.records

        getMinMax row =
            case ( row.minRangeDecimal, row.maxRangeDecimal, row.minRangeInteger, row.maxRangeInteger ) of
                ( Just minD, Just maxD, _, _ ) ->
                    ( toString minD, toString maxD )

                ( _, _, Just minI, Just maxI ) ->
                    ( toString minI, toString maxI )

                ( _, _, _, _ ) ->
                    ( "", "" )

        getTestValues : Int -> List LabTestValueRecord -> String
        getTestValues labTest_id data =
            List.filter (\r -> r.labTest_id == labTest_id) data
                |> List.map .value
                |> List.intersperse ", "
                |> String.concat

        -- Each labTest record.
        makeLi idx row =
            let
                ( minVal, maxVal ) =
                    getMinMax row

                labTestVals =
                    getTestValues row.id labTestValue
            in
                MList.li
                    [ MList.withSubtitle
                    , if rem idx 2 == 0 then
                        Options.nop
                      else
                        Options.cs "altRowBackground"
                    , Options.onClick <|
                        LabTestMessages <|
                            SelectedRecordEditModeLabTest EditModeView (Just row.id)
                    ]
                    [ MList.content
                        []
                        [ Html.text <| (toString row.id) ++ ". " ++ row.name ++ " (" ++ row.abbrev ++ ")"
                        , MList.subtitle
                            []
                            [ if String.length row.normal > 0 then
                                Html.span [ HA.class "bodyItem" ] [ Html.text <| "Normal: " ++ row.normal ++ " " ]
                              else
                                Html.text ""
                            , if String.length row.unit > 0 then
                                Html.span [ HA.class "bodyItem" ] [ Html.text <| "Unit: " ++ row.unit ++ " " ]
                              else
                                Html.text ""
                            , if row.isRange then
                                Html.span [ HA.class "bodyItem" ] [ Html.text <| "Min: " ++ minVal ++ ", Max: " ++ maxVal ++ " " ]
                              else
                                Html.text ""
                            , if String.length labTestVals > 0 then
                                Html.span [ HA.class "bodyItem" ] [ Html.text <| "Values: " ++ labTestVals ++ " " ]
                              else
                                Html.text ""
                            ]
                        ]
                    ]
    in
        Html.div []
            [ Html.div
                [ HA.style [ ( "margin-bottom", "10px" ) ] ]
                [ VU.button [ mdlContext, 420 ]
                    (LabSuiteMessages <| SelectedRecordEditModeLabSuite EditModeTable labSuiteModel.selectedRecordId)
                    "Add/Edit Lab Suites"
                    False
                    False
                    model.mdl
                ]
            , Html.div []
                -- Radio buttons for the lab suites.
                (labSuiteData
                    |> List.indexedMap
                        (\idx row ->
                            Html.span
                                [ HA.style
                                    [ ( "padding", "0 10px 0 10px" ) ]
                                ]
                                [ Toggles.radio Mdl
                                    [ mdlContext, (400 + idx) ]
                                    model.mdl
                                    [ Toggles.value (selectedLabSuiteId == row.id)
                                    , Toggles.group "labSuite"
                                    , Toggles.ripple
                                    --, Options.onToggle (UserChoiceSet labSuiteKey (toString row.id))
                                    , Options.onToggle (LabSuiteMessages <| SelectedRecordEditModeLabSuite EditModeOther (Just row.id))
                                    ]
                                    [ Html.text row.name ]
                                ]
                        )
                )
            , Html.hr [] []
            , Html.div
                [ HA.class "horizontal-scroll"
                , HA.hidden (String.length selectedLabSuiteName == 0)
                ]
                [ VU.msgLeftElementRight "Click on a row to edit or delete." <|
                    VU.button [ mdlContext, 430 ]
                        (SelectedRecordEditModeLabTest EditModeAdd Nothing
                            |> LabTestMessages
                        )
                        ("Add a New " ++ selectedLabSuiteName ++ " Lab Test")
                        False
                        False
                        model.mdl
                ]
            , MList.ul []
                -- List of Lab tests for given lab suite.
                (labTestData
                    |> List.filter (\row -> selectedLabSuiteId == row.labSuite_id)
                    |> List.indexedMap (\idx row -> makeLi idx row)
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
            [ VU.msgLeftElementRight "Click on a row to edit or delete." <|
                VU.button [ mdlContext, 320 ]
                    (SelectedRecordEditModeVaccinationType EditModeAdd model.vaccinationTypeModel.selectedRecordId
                        |> VaccinationTypeMessages
                    )
                    "Add"
                    False
                    False
                    model.mdl
            , MTable.table
                [ Options.css "width" "100%" ]
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
                    [ VU.button [ mdlContext, 304 ]
                        (SelectedRecordEditModeVaccinationType EditModeTable Nothing
                            |> VaccinationTypeMessages
                        )
                        "Back to table view"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 300 ]
                        (SelectedRecordEditModeVaccinationType EditModeEdit vaccinationTypeModel.selectedRecordId
                            |> VaccinationTypeMessages
                        )
                        "Edit"
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
            [ VU.msgLeftElementRight "Click on a row to edit or delete." <|
                VU.button [ mdlContext, 310 ]
                    (SelectedRecordEditModeMedicationType EditModeAdd model.medicationTypeModel.selectedRecordId
                        |> MedicationTypeMessages
                    )
                    "Add"
                    False
                    False
                    model.mdl
            , MTable.table
                [ Options.css "width" "100%" ]
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
                    [ VU.button [ mdlContext, 304 ]
                        (SelectedRecordEditModeMedicationType EditModeTable Nothing
                            |> MedicationTypeMessages
                        )
                        "Back to table view"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 300 ]
                        (SelectedRecordEditModeMedicationType EditModeEdit medicationTypeModel.selectedRecordId
                            |> MedicationTypeMessages
                        )
                        "Edit"
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
            [ VU.msgLeftElementRight "Click on a row to edit or delete." <|
                Html.span [] []
            , MTable.table
                [ Options.css "width" "100%" ]
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
                    [ VU.button [ mdlContext, 304 ]
                        (SelectedRecordEditModeSelectData EditModeTable Nothing Nothing
                            |> SelectDataMessages
                        )
                        "Back to table view"
                        False
                        False
                        model.mdl
                    , VU.button [ mdlContext, 300 ]
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
                        , VU.checkBox "Default"
                            [ mdlContext, 203 ]
                            (taggerBool recSelected (not (VU.isChecked recSelected)))
                            isEditing
                            (VU.isChecked recSelected)
                            model.mdl
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
view ({ labSuiteModel, labTestModel, labTestValueModel, medicationTypeModel, selectDataModel, vaccinationTypeModel } as model) =
    let
        ( selectedTable, dataView ) =
            case model.selectedTable of
                Just t ->
                    ( U.tableToString t
                    , case t of
                        LabSuite ->
                            case labSuiteModel.editMode of
                                EditModeOther ->
                                    viewLabs

                                EditModeTable ->
                                    viewLabSuiteTable

                                EditModeView ->
                                    viewLabSuiteRecord

                                EditModeEdit ->
                                    viewLabSuiteRecord

                                EditModeAdd ->
                                    viewLabSuiteRecord

                        LabTest ->
                            case labTestModel.editMode of
                                EditModeAdd ->
                                    viewLabTestRecord

                                EditModeView ->
                                    viewLabTestRecord

                                EditModeEdit ->
                                    viewLabTestRecord

                                EditModeTable ->
                                    viewLabs

                                _ ->
                                    (\_ -> Html.div [] [ Html.text <| "Editmode is: " ++ (toString labTestModel.editMode) ])

                        LabTestValue ->
                            case labTestValueModel.editMode of
                                EditModeTable ->
                                    viewLabTestValueTable

                                EditModeView ->
                                    viewLabTestValueRecord

                                EditModeEdit ->
                                    viewLabTestValueRecord

                                EditModeAdd ->
                                    viewLabTestValueRecord

                                _ ->
                                    (\_ -> Html.div [] [ Html.text <| "Editmode for labTestValue is: " ++ (toString labTestValueModel.editMode) ])

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
