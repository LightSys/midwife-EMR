module Views.Profile exposing (view)

import FNV
import Form
import Form.Field as FF
import Html as Html exposing (Html, div, p, text)
import Material
import Material.Card as Card
import Material.Color as MColor
import Material.Grid as Grid
import Material.Options as Options


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (Msg(..), UserProfileMsg(..))
import Models.Role as MU
import Views.Utils as VU


mdlContext : Int
mdlContext =
    FNV.hashString "Views.Profile"


view : Model -> Html Msg
view ({ userModel } as model) =
    let
        buildForm form =
            let
                tableStr =
                    "Edit Your Profile"

                -- Buttons available while editing.
                editingContent =
                    [ VU.button [ mdlContext, 101 ] (UserProfileMessages <| FormMsgUserProfile Form.Submit) "Save" False False model.mdl
                    ]

                -- Get the FieldStates.
                ( recId, recUsername, recFirstname, recLastname, recPassword, recEmail ) =
                    ( Form.getFieldAsString "userid" form
                    , Form.getFieldAsString "username" form
                    , Form.getFieldAsString "firstname" form
                    , Form.getFieldAsString "lastname" form
                    , Form.getFieldAsString "password" form
                    , Form.getFieldAsString "email" form
                    )

                ( recLang, recShortName, recDisplayName, recRoleId ) =
                    ( Form.getFieldAsString "lang" form
                    , Form.getFieldAsString "shortName" form
                    , Form.getFieldAsString "displayName" form
                    , Form.getFieldAsString "role_id" form
                    )

                roleName =
                    case recRoleId.value of
                        Just rid ->
                            case String.toInt rid of
                                Ok val ->
                                    MU.roleToString val model.roleModel

                                Err _ ->
                                    ""

                        Nothing ->
                            ""

                -- The helper function used to create the partially applied
                -- (String -> Msg) function for each textFld.
                tagger : Form.FieldState e String -> String -> Msg
                tagger fld =
                    FF.String
                        >> (Form.Input fld.path Form.Text)
                        >> FormMsgUserProfile
                        >> UserProfileMessages
            in
                Card.view
                    [ Options.css "width" "100%" ]
                    [ Card.title []
                        [ Card.head []
                            [ Html.text tableStr ]
                        ]
                    , Card.text []
                        [ Card.head [] editingContent ]
                    , Card.text
                        [ MColor.text MColor.black
                        ]
                        [ Grid.grid
                            [ Grid.size Grid.Desktop 12
                            , Grid.size Grid.Tablet 8
                            , Grid.size Grid.Phone 4
                            ]
                            [ Grid.cell
                                [ Grid.size Grid.Desktop 4
                                , Grid.size Grid.Tablet 4
                                , Grid.size Grid.Phone 4
                                ]
                                [ VU.textFld "Record id"
                                    recId
                                    [ mdlContext, 220 ]
                                    (tagger recId)
                                    False
                                    False
                                    model.mdl
                                , VU.textFldFocus "Username"
                                    recUsername
                                    [ mdlContext, 221 ]
                                    (tagger recUsername)
                                    False
                                    False
                                    model.mdl
                                , VU.textFld "Firstname"
                                    recFirstname
                                    [ mdlContext, 222 ]
                                    (tagger recFirstname)
                                    False
                                    False
                                    model.mdl
                                , VU.textFld "Lastname"
                                    recLastname
                                    [ mdlContext, 223 ]
                                    (tagger recLastname)
                                    False
                                    False
                                    model.mdl
                                ]
                            , Grid.cell
                                [ Grid.size Grid.Desktop 4
                                , Grid.size Grid.Tablet 4
                                , Grid.size Grid.Phone 4
                                ]
                                [ VU.textFld "Password"
                                    recPassword
                                    [ mdlContext, 224 ]
                                    (tagger recPassword)
                                    True
                                    True
                                    model.mdl
                                , VU.textFld "Email"
                                    recEmail
                                    [ mdlContext, 225 ]
                                    (tagger recEmail)
                                    True
                                    False
                                    model.mdl
                                , VU.textFld "Short name"
                                    recShortName
                                    [ mdlContext, 227 ]
                                    (tagger recShortName)
                                    True
                                    False
                                    model.mdl
                                , VU.textFld "Display name"
                                    recDisplayName
                                    [ mdlContext, 228 ]
                                    (tagger recDisplayName)
                                    True
                                    False
                                    model.mdl
                                ]
                            ]
                        ]
                    ]

        data =
            case model.userProfile of
                Just profile ->
                    buildForm model.userProfileForm

                Nothing ->
                    Html.text ""
    in
        Html.div []
            [ data ]
