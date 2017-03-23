module Views.Login exposing (view)

import FNV
import Html as Html exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Form
import Form.Field as FF
import Material
import Material.Card as Card
import Material.Color as MColor
import Material.Grid as Grid
import Material.Options as Options


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (Msg(..))
import Types exposing (..)
import Views.Utils as VU


type alias Mdl =
    Material.Model


mdlContext : Int
mdlContext =
    FNV.hashString "Views.Login"


view : Model -> Html Msg
view model =
    let
        ( username, password ) =
            ( Form.getFieldAsString "username" model.loginForm
            , Form.getFieldAsString "password" model.loginForm
            )

        tagger : Form.FieldState e String -> String -> Msg
        tagger fld =
            FF.String
                >> (Form.Input fld.path Form.Text)
                >> LoginFormMsg

        isDisabled =
            case ( username.error, password.error ) of
                ( Nothing, Nothing ) ->
                    False

                _ ->
                    True
    in
        Grid.grid []
            [ Grid.cell [ Grid.size Grid.All 12 ]
                [ Html.form
                    [ HE.onSubmit Login
                    ]
                    [ Card.view
                        [ Options.css "width" "100%"
                        ]
                        [ Card.title []
                            [ Card.head []
                                [ Html.text "Please log in" ]
                            ]
                        , Card.text
                            [ MColor.text MColor.black
                            ]
                            [ VU.textFld "Username" username [ mdlContext, 100 ] (tagger username) True False model.mdl
                            , VU.textFld "Password" password [ mdlContext, 101 ] (tagger password) True True model.mdl
                            , VU.buttonNoMsg [ mdlContext, 102 ] "Log in" isDisabled model.mdl
                            ]
                        ]
                    ]
                ]
            ]
