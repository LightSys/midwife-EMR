module View.Tables exposing (view)

import Array
import Color as Color
import Html as Html exposing (Html, div, p, text)
import Html.Attributes as HA
import Html.Events
import FNV
import Material
import Material.Button as Button
import Material.Card as Card
import Material.Color as MColor
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
import Msg exposing (Msg(..))
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
    Html.p [] [ Html.text "Please select a table." ]


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
    [ Button.render Mdl
        [ mdlContext, 100 ]
        model.mdl
        [ Button.raised
        , Button.ripple
        , Button.onClick FirstRecord
        ]
        [ arrow_back Color.black 30 ]
    , Button.render Mdl
        [ mdlContext, 101 ]
        model.mdl
        [ Button.raised
        , Button.ripple
        , Button.onClick PreviousRecord
        ]
        [ chevron_left Color.black 30 ]
    , Button.render Mdl
        [ mdlContext, 102 ]
        model.mdl
        [ Button.raised
        , Button.ripple
        , Button.onClick NextRecord
        ]
        [ chevron_right Color.black 30 ]
    , Button.render Mdl
        [ mdlContext, 103 ]
        model.mdl
        [ Button.raised
        , Button.ripple
        , Button.onClick LastRecord
        ]
        [ arrow_forward Color.black 30 ]
    ]


viewMedicationType : Model -> Html Msg
viewMedicationType model =
    let
        textFld lbl fld idx =
            Textfield.render Mdl
                idx
                model.mdl
                [ Textfield.label lbl
                , Textfield.floatingLabel
                , Textfield.value fld
                , Textfield.disabled
                , Options.inner
                    [ MColor.text MColor.primary
                    ]
                ]

        buildForm rec =
            let
                tableStr =
                    case model.selectedTable of
                        Just t ->
                            U.tableToString t

                        Nothing ->
                            ""
            in
                Card.view
                    [ Options.css "width" "100%" ]
                    [ Card.title []
                        [ Card.head []
                            [ Html.text tableStr ]
                        ]
                    , Card.text
                        [ MColor.text MColor.black
                        ]
                        [ textFld "Record id" (toString rec.id) [ mdlContext, 200 ]
                        , textFld "Name" rec.name [ mdlContext, 201 ]
                        , textFld "Description" rec.description [ mdlContext, 202 ]
                        , textFld "Sort Order" (toString rec.sortOrder) [ mdlContext, 203 ]
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
                    case
                        recs
                            |> Array.fromList
                            |> Array.get model.selectedTableRecord
                    of
                        Just r ->
                            buildForm r

                        Nothing ->
                            Html.text "Record not found."
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
                [ Html.h3 []
                    [ text "" ]
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
