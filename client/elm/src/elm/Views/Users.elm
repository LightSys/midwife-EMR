module Views.Users exposing (view)

import FNV
import Html as Html exposing (Html, div, p, text)
import Html.Attributes as HA
import Form
import Form.Field as FF
import Material
import Material.Color as MColor
import Material.Card as Card
import Material.Grid as Grid
import Material.List as MList
import Material.Options as Options
import Material.Typography as Typo
import RemoteData as RD exposing (RemoteData(..), WebData)


-- LOCAL IMPORTS

import Model exposing (..)
import Models.Role exposing (idNameTuples, roleToString)
import Msg exposing (Msg(..), UserMsg(..))
import Types exposing (..)
import Views.Utils as VU


mdlContext : Int
mdlContext =
    FNV.hashString "Views.Users"


view : Model -> Html Msg
view ({ userModel } as model) =
    if userModel.editMode == EditModeAdd || userModel.editMode == EditModeEdit then
        viewUserEdit model
    else
        viewSearch model


viewSearch : Model -> Html Msg
viewSearch model =
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
                [ text "User Management" ]
            ]
        , Grid.cell
            -- Search input on the left or top
            [ Grid.size Grid.Desktop 6
            , Grid.size Grid.Tablet 8
            , Grid.size Grid.Phone 4
            ]
            [ viewSearchForm model
            , viewAddUser model
            ]
        , Grid.cell
            -- Search results on the right or bottom
            [ Grid.size Grid.Desktop 6
            , Grid.size Grid.Tablet 8
            , Grid.size Grid.Phone 4
            ]
            [ viewSearchResults model ]
        ]


viewAddUser : Model -> Html Msg
viewAddUser model =
    Grid.grid
        [ Grid.size Grid.Desktop 12
        , Grid.size Grid.Tablet 8
        , Grid.size Grid.Phone 4
        ]
        [ Grid.cell
            [ Grid.size Grid.Desktop 12
            , Grid.size Grid.Tablet 8
            , Grid.size Grid.Phone 4
            ]
            [ VU.button [ mdlContext, 240 ]
                (UserMessages CreateUserForm)
                "Add New User"
                False
                False
                model.mdl
            ]
        ]


viewUserEdit : Model -> Html Msg
viewUserEdit ({ userModel } as model) =
    let
        buildForm form =
            let
                tableStr =
                    case userModel.editMode of
                        EditModeAdd ->
                            "Add a New User"
                        _ ->
                            "Editing User"

                -- Buttons available while editing.
                editingContent =
                    [ VU.button [ mdlContext, 301 ] (UserMessages <| FormMsgUser Form.Submit) "Save" False False model.mdl
                    , VU.button [ mdlContext, 302 ] (UserMessages <| CancelEditUser) "Cancel back to search" False False model.mdl
                    , VU.button [ mdlContext, 303 ] (UserMessages <| DeleteUser userModel.selectedRecordId) "Delete User" False False model.mdl
                    ]

                -- Get the FieldStates.
                ( recId, recUsername, recFirstname, recLastname, recPassword, recEmail ) =
                    ( Form.getFieldAsString "id" form
                    , Form.getFieldAsString "username" form
                    , Form.getFieldAsString "firstname" form
                    , Form.getFieldAsString "lastname" form
                    , Form.getFieldAsString "password" form
                    , Form.getFieldAsString "email" form
                    )

                ( recShortName, recDisplayName, recStatus, recNote, recIsCurrentTeacher, recRoleId ) =
                    ( Form.getFieldAsString "shortName" form
                    , Form.getFieldAsString "displayName" form
                    , Form.getFieldAsBool "status" form
                    , Form.getFieldAsString "note" form
                    , Form.getFieldAsBool "isCurrentTeacher" form
                    , Form.getFieldAsString "role_id" form
                    )

                roleRadios =
                    List.map
                        (\r ->
                            Html.span [ HA.style [ ( "padding-right", "10px" ) ] ]
                                [ VU.radio (Tuple.second r)
                                    [ mdlContext, 232 + (Tuple.first r) ]
                                    (taggerRadio recRoleId <| toString (Tuple.first r))
                                    ((Tuple.first r |> toString) == Maybe.withDefault "" recRoleId.value)
                                    "RoleGroup"
                                    model.mdl
                                ]
                        )
                        (idNameTuples model.roleModel)

                -- The helper function used to create the partially applied
                -- (String -> Msg) function for each textFld.
                tagger : Form.FieldState e String -> String -> Msg
                tagger fld =
                    FF.String
                        >> (Form.Input fld.path Form.Text)
                        >> FormMsgUser
                        >> UserMessages

                -- The helper function used to create the partially applied
                -- (Bool -> Msg) function for each checkBox.
                taggerBool : Form.FieldState e Bool -> Bool -> Msg
                taggerBool fld =
                    FF.Bool
                        >> (Form.Input fld.path Form.Checkbox)
                        >> FormMsgUser
                        >> UserMessages

                taggerRadio : Form.FieldState e String -> String -> Msg
                taggerRadio fld =
                    FF.String
                        >> (Form.Input fld.path Form.Radio)
                        >> FormMsgUser
                        >> UserMessages
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
                                    True
                                    False
                                    model.mdl
                                , VU.textFld "Firstname"
                                    recFirstname
                                    [ mdlContext, 222 ]
                                    (tagger recFirstname)
                                    True
                                    False
                                    model.mdl
                                , VU.textFld "Lastname"
                                    recLastname
                                    [ mdlContext, 223 ]
                                    (tagger recLastname)
                                    True
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
                            , Grid.cell
                                [ Grid.size Grid.Desktop 4
                                , Grid.size Grid.Tablet 4
                                , Grid.size Grid.Phone 4
                                ]
                                [ VU.checkBox "Status"
                                    [ mdlContext, 229 ]
                                    (taggerBool recStatus (not (VU.isChecked recStatus)))
                                    (VU.isChecked recStatus)
                                    model.mdl
                                , VU.textFld "Note"
                                    recNote
                                    [ mdlContext, 230 ]
                                    (tagger recNote)
                                    True
                                    False
                                    model.mdl
                                , VU.checkBox "Currently Teacher"
                                    [ mdlContext, 231 ]
                                    (taggerBool recIsCurrentTeacher (not (VU.isChecked recIsCurrentTeacher)))
                                    (VU.isChecked recIsCurrentTeacher)
                                    model.mdl
                                ]
                            , Grid.cell
                                [ Grid.size Grid.Desktop 12
                                , Grid.size Grid.Tablet 8
                                , Grid.size Grid.Phone 4
                                ]
                                roleRadios
                            ]
                        ]
                    ]

        data =
            case userModel.records of
                NotAsked ->
                    Html.text ""

                Loading ->
                    Html.text "Loading"

                Failure err ->
                    Html.text <| toString err

                Success recs ->
                    buildForm userModel.form
    in
        Html.div []
            [ data ]


viewSearchResults : Model -> Html Msg
viewSearchResults model =
    let
        users =
            filterUsers model

        makeLi idx user =
            MList.li
                [ MList.withBody
                , if rem idx 2 == 0 then
                    Options.nop
                  else
                    Options.cs "altRowBackground"
                , Options.onClick <|
                    UserMessages (SelectedRecordEditModeUser EditModeEdit (Just user.id))
                ]
                [ MList.content
                    []
                    [ Html.text <|
                        user.lastname
                            ++ ", "
                            ++ user.firstname
                            ++ if String.length user.shortName > 0 then
                                " (" ++ user.shortName ++ ")"
                               else
                                ""
                    , MList.body []
                        [ Html.text <| roleToString user.role_id model.roleModel
                        , Html.text <|
                            if user.isCurrentTeacher then
                                ", Teacher"
                            else
                                ""
                        , Html.div [] [ Html.text user.note ]
                        ]
                    ]
                , MList.content2
                    []
                    [ Html.text <|
                        if user.status == False then
                            "Inactive "
                        else
                            ""
                    , Html.div [] [ Html.text user.email ]
                    ]
                ]
    in
        MList.ul
            []
            (List.indexedMap makeLi users)


{-| Filter the users according to the values the user entered
in the userSearch form.
-}
filterUsers : Model -> List UserRecord
filterUsers model =
    let
        -- Get the values for all of the fields of the search form.
        ( query, isAdministrator, isAttending, isClerk, isGuard, isSupervisor, isActive, isInActive ) =
            ( Form.getFieldAsString "query" model.userSearchForm
                |> .value
                |> Maybe.withDefault ""
                |> String.toLower
            , Form.getFieldAsBool "isAdministrator" model.userSearchForm
                |> VU.isChecked
            , Form.getFieldAsBool "isAttending" model.userSearchForm
                |> VU.isChecked
            , Form.getFieldAsBool "isClerk" model.userSearchForm
                |> VU.isChecked
            , Form.getFieldAsBool "isGuard" model.userSearchForm
                |> VU.isChecked
            , Form.getFieldAsBool "isSupervisor" model.userSearchForm
                |> VU.isChecked
            , Form.getFieldAsBool "isActive" model.userSearchForm
                |> VU.isChecked
            , Form.getFieldAsBool "isInActive" model.userSearchForm
                |> VU.isChecked
            )

        isRoleChecked =
            isAdministrator || isAttending || isClerk || isGuard || isSupervisor

        isStatusChecked =
            isActive || isInActive
    in
        case model.userModel.records of
            Success recs ->
                -- At least one role has been selected, so filter first on all of the roles.
                (if isRoleChecked then
                    List.filter
                        (\u ->
                            roleToString u.role_id model.roleModel
                                == "administrator"
                                && isAdministrator
                                || roleToString u.role_id model.roleModel
                                == "guard"
                                && isGuard
                                || roleToString u.role_id model.roleModel
                                == "clerk"
                                && isClerk
                                || roleToString u.role_id model.roleModel
                                == "attending"
                                && isAttending
                                || roleToString u.role_id model.roleModel
                                == "supervisor"
                                && isSupervisor
                        )
                        recs
                 else
                    recs
                )
                    -- Filter by status if status fields were checked.
                    |>
                        (\recs ->
                            if isStatusChecked then
                                List.filter (\u -> u.status == True && isActive || u.status == False && isInActive) recs
                            else
                                recs
                        )
                    -- Filter by the query field on username, first, last or shortName.
                    |>
                        List.filter
                            (\r ->
                                String.contains query (String.toLower r.username)
                                    || String.contains query (String.toLower r.firstname)
                                    || String.contains query (String.toLower r.lastname)
                                    || String.contains query (String.toLower r.shortName)
                            )
                    |> List.sortBy .role_id

            _ ->
                []


viewSearchForm : Model -> Html Msg
viewSearchForm model =
    let
        -- Get the FieldStates for all of the fields.
        ( query, isAdministrator, isAttending, isClerk, isGuard, isSupervisor, isActive, isInActive ) =
            ( Form.getFieldAsString "query" model.userSearchForm
            , Form.getFieldAsBool "isAdministrator" model.userSearchForm
            , Form.getFieldAsBool "isAttending" model.userSearchForm
            , Form.getFieldAsBool "isClerk" model.userSearchForm
            , Form.getFieldAsBool "isGuard" model.userSearchForm
            , Form.getFieldAsBool "isSupervisor" model.userSearchForm
            , Form.getFieldAsBool "isActive" model.userSearchForm
            , Form.getFieldAsBool "isInActive" model.userSearchForm
            )

        -- The helper function used to create the partially applied
        -- (String -> Msg) function for each textFld.
        tagger : Form.FieldState e String -> String -> Msg
        tagger fld =
            FF.String
                >> (Form.Input fld.path Form.Text)
                >> FormMsgUserSearch
                >> UserMessages

        -- The helper function used to create the partially applied
        -- (Bool -> Msg) function for each checkBox.
        taggerBool : Form.FieldState e Bool -> Bool -> Msg
        taggerBool fld =
            FF.Bool
                >> (Form.Input fld.path Form.Checkbox)
                >> FormMsgUserSearch
                >> UserMessages

        wrapDiv : Html Msg -> Html Msg
        wrapDiv element =
            Html.div [ HA.style [ ( "padding-bottom", "14px" ) ] ]
                [ element ]
    in
        Card.view
            [ Options.css "width" "100%" ]
            [ Card.text
                [ MColor.text MColor.black ]
                [ VU.textFld "First, last, username, or shortname" query [ mdlContext, 100 ] (tagger query) True False model.mdl
                , Html.label [ HA.style [ ( "font-weight", "bold" ) ] ] [ Html.text "Limit to the following roles" ]
                , wrapDiv <|
                    VU.checkBox "Administrators"
                        [ mdlContext, 201 ]
                        (taggerBool isAdministrator (not (VU.isChecked isAdministrator)))
                        (VU.isChecked isAdministrator)
                        model.mdl
                , wrapDiv <|
                    VU.checkBox "Attendings"
                        [ mdlContext, 202 ]
                        (taggerBool isAttending (not (VU.isChecked isAttending)))
                        (VU.isChecked isAttending)
                        model.mdl
                , wrapDiv <|
                    VU.checkBox "Clerks"
                        [ mdlContext, 203 ]
                        (taggerBool isClerk (not (VU.isChecked isClerk)))
                        (VU.isChecked isClerk)
                        model.mdl
                , wrapDiv <|
                    VU.checkBox "Guards"
                        [ mdlContext, 204 ]
                        (taggerBool isGuard (not (VU.isChecked isGuard)))
                        (VU.isChecked isGuard)
                        model.mdl
                , wrapDiv <|
                    VU.checkBox "Supervisors"
                        [ mdlContext, 205 ]
                        (taggerBool isSupervisor (not (VU.isChecked isSupervisor)))
                        (VU.isChecked isSupervisor)
                        model.mdl
                , Html.label [ HA.style [ ( "font-weight", "bold" ) ] ] [ Html.text "Limit to active or inactive status" ]
                , wrapDiv <|
                    VU.checkBox "Active"
                        [ mdlContext, 210 ]
                        (taggerBool isActive (not (VU.isChecked isActive)))
                        (VU.isChecked isActive)
                        model.mdl
                , wrapDiv <|
                    VU.checkBox "InActive"
                        [ mdlContext, 211 ]
                        (taggerBool isInActive (not (VU.isChecked isInActive)))
                        (VU.isChecked isInActive)
                        model.mdl
                ]
            ]
