module Views.Barcodes exposing (view)

import FNV
import Html as Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Form
import Form.Field as FF
import Material
import Material.Button as Button
import Material.Card as Card
import Material.Color as MColor
import Material.Grid as Grid
import Material.Options as Options
import Material.Typography as Typo


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (Msg(..))
import Types exposing (..)
import Views.Utils as VU


mdlContext : Int
mdlContext =
    FNV.hashString "Views.Barcodes"


view : Model -> Html Msg
view model =
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
                [ Html.text "Priority Barcodes (optional)" ]
            ]
        , Grid.cell
            -- Full size
            [ Grid.size Grid.Desktop 12
            , Grid.size Grid.Tablet 8
            , Grid.size Grid.Phone 4
            ]
            [ Options.styled Html.p
                [ Typo.body2
                ]
                [ Html.img
                    [ HA.src "barcodes/PrenatalBarcodeSample.png"
                    , HA.style
                        [ ( "float", "right" )
                        ]
                    ]
                    []
                , Html.text explanationPara1
                ]
            , Options.styled Html.p
                [ Typo.body2
                ]
                [ Html.text explanationPara2 ]
            , Options.styled Html.p
                [ Typo.body2
                ]
                [ Html.text explanationPara3 ]
            , Options.styled Html.p
                [ Typo.body2
                ]
                [ Html.text explanationPara4 ]
            , Options.styled Html.p
                [ Typo.body2
                ]
                [ Html.text explanationPara5 ]
            ]
        , Grid.cell
            -- Configuration table
            [ Grid.size Grid.Desktop 12
            , Grid.size Grid.Tablet 8
            , Grid.size Grid.Phone 4
            ]
            [ Html.div []
                [ Html.h4 [] [ Html.text "Download the barcode PDF file" ]
                , Html.div []
                    [ Options.styled Html.p
                        [ Typo.body2
                        ]
                        [ Html.text "Save this PDF file and print it to create priority badges, lanyards, etc." ]
                    , Button.render Mdl
                        [ mdlContext, 100 ]
                        model.mdl
                        [ Button.link "barcodes/PrenatalBarcodes.pdf"
                        , Button.raised
                        , Button.ripple
                        , Options.attribute <| HA.attribute "download" "PrenatalBarcodes.pdf"
                        ]
                        [ Html.text "Download" ]
                    ]
                , Html.div []
                    [ Options.styled Html.p
                        [ Typo.body2
                        , Options.css "margin-top" "20px"
                        , Options.css "padding" "20px"
                        , MColor.background MColor.primary
                        , MColor.text MColor.primaryContrast
                        ]
                        [ Html.text note1 ]
                    ]
                ]
            ]
        ]

note1 : String
note1 =
    """
There are 400 priority barcodes in the PDF, but you do not have to use all of them. Just print as many as you need. If you ever need more, just print any additional that you need.
    """

explanationPara1 : String
explanationPara1 =
    """
The Midwife-EMR system has the capability, but not the requirement, of using priority barcodes in order to help manage patient workflow. This really only makes sense in contexts where there are many dozens or more prenatal exams being done in a day. This is one means to allow the patients to flow through the system in an orderly and on a first-come first-serve basis.
    """


explanationPara2 : String
explanationPara2 =
    """
When patients arrive for their prenatal exams, each are given a priority number which is a laminated badge or a card with a number on it. The badges are collected after the exam and are reused the next day. How these badges/cards are made is up to you; you may find that using lanyards works well, or large cards that you give to the patients, or clip on badges.
    """


explanationPara3 : String
explanationPara3 =
    """
The integration of the priority numbers with the software is achieved by a 6 digit barcode that is attached to each badge that allows staff to scan the badge or type in the 6 digit number at the various points of interaction during the prenatal exam.   """


explanationPara4 : String
explanationPara4 =
    """
The barcodes are used in conjunction with the Midwife-EMR priority system to insure that the priority numbers input into the system upon client arrival are accurate. Using barcodes insures accuracy by only accepting as input the barcodes, which are random 6 digit numbers, as opposed to the priority numbers themselves. The barcodes are tied to the priority numbers that they represent by Midwife-EMR's internal priority table. In essence, this is eliminating mis-keying by staff of priority numbers because a mis-key of a barcode will be detected as an invalid barcode.
    """


explanationPara5 : String
explanationPara5 =
    """
Of course, each clinic is different and only you can decide if using these badges would be helpful. Some questions to ask are, is much time spent keeping the patients in order as they progress through your clinic? Is there confusion about who is next? Are things too chaotic at certain points in the patient workflow?
    """
