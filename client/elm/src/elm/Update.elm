module Update
    exposing
        ( update
        )

import Form exposing (Form)
import Form.Field as Fld
import Json.Decode as JD
import Json.Encode as JE
import List.Extra as LE
import Material
import Material.Snackbar as Snackbar
import RemoteData as RD exposing (RemoteData(..))
import Form.Validate as V


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Models.MedicationType as MedType
import Models.Utils as MU
import Msg exposing (..)
import Navigation as Nav
import Ports
import Transactions as Trans
import Types exposing (..)
import Updates.Adhoc as Updates exposing (adhocUpdate)
import Updates.MedicationType as Updates exposing (medicationTypeUpdate)
import Updates.Profile as Updates exposing (userProfileUpdate)
import Updates.Role as Updates exposing (roleUpdate)
import Updates.User as Updates exposing (userUpdate)
import Utils as U


type alias Mdl =
    Material.Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddChgDelNotificationMessages acdNotification ->
            let
                _ =
                    Debug.log "AddChgDelNotificationMessages" <| toString acdNotification
            in
                model ! []

        AdhocResponseMessages adhocResponse ->
            Updates.adhocUpdate adhocResponse model

        AddSelectedTable ->
            let
                newModel =
                    { model | selectedTableEditMode = EditModeAdd }
                        |> populateSelectedTableForm
            in
                newModel ! []

        CancelSelectedTable ->
            let
                -- User canceled, so reset data back to what we had before.
                newModel =
                    populateSelectedTableForm model
            in
                { newModel | selectedTableEditMode = EditModeView } ! []

        CreateResponseMsg add ->
            case add of
                Just a ->
                    case a.table of
                        MedicationType ->
                            Updates.medicationTypeUpdate (CreateResponseMedicationType a) model

                        User ->
                            Updates.userUpdate (CreateResponseUser a) model

                        _ ->
                            model ! []

                Nothing ->
                    model ! []

        DeleteResponseMsg del ->
            case del of
                Just d ->
                    case d.table of
                        MedicationType ->
                            Updates.medicationTypeUpdate (DeleteResponseMedicationType d) model

                        User ->
                            Updates.userUpdate (DeleteResponseUser d) model

                        _ ->
                            model ! []

                Nothing ->
                    model ! []

        EditSelectedTable ->
            { model | selectedTableEditMode = EditModeEdit } ! []

        EventTypeResponse eventTypeTbl ->
            { model | eventType = eventTypeTbl } ! []

        FirstRecord ->
            let
                newModel =
                    { model | selectedTableRecord = 0 }
                        |> populateSelectedTableForm
            in
                newModel ! []

        LabSuiteResponse labSuiteTbl ->
            { model | labSuite = labSuiteTbl } ! []

        LabTestResponse labTestTbl ->
            { model | labTest = labTestTbl } ! []

        LabTestValueResponse labTestValueTbl ->
            { model | labTestValue = labTestValueTbl } ! []

        LastRecord ->
            let
                newModel =
                    { model
                        | selectedTableRecord = ((numRecsSelectedTable model) - 1)
                    }
                        |> populateSelectedTableForm
            in
                newModel ! []

        Login ->
            let
                newCmd =
                    case Form.getOutput model.loginForm of
                        Just login ->
                            Ports.login (E.loginFormToValue login)

                        Nothing ->
                            Cmd.none
            in
                model ! [ newCmd ]

        LoginFormMsg formMsg ->
            case ( formMsg, Form.getOutput model.loginForm ) of
                ( Form.Submit, Just records ) ->
                    -- If we get here, it passed valiation. Wait for user to submit.
                    model ! []

                _ ->
                    -- Otherwise, pass it through validation again.
                    ( Form.update loginFormValidate formMsg model.loginForm
                        |> (\lf -> { model | loginForm = lf })
                    , Cmd.none
                    )

        Mdl matMsg ->
            Material.update Mdl matMsg model

        MedicationTypeMessages mtMsg ->
            Updates.medicationTypeUpdate mtMsg model

        NewSystemMessage sysMsg ->
            -- We only keep the most recent 1000 messages.
            let
                newSysMessages =
                    if sysMsg.id /= "ERROR" then
                        sysMsg
                            :: model.systemMessages
                            |> List.take 1000
                    else
                        model.systemMessages
            in
                { model | systemMessages = newSysMessages } ! []

        NextRecord ->
            let
                newModel =
                    { model
                        | selectedTableRecord = min ((numRecsSelectedTable model) - 1) (model.selectedTableRecord + 1)
                    }
                        |> populateSelectedTableForm
            in
                newModel ! []

        NoOp ->
            let
                _ =
                    Debug.log "NoOp" "was called"
            in
                model ! []

        PregnoteTypeResponse pregnoteTypeTbl ->
            { model | pregnoteType = pregnoteTypeTbl } ! []

        PreviousRecord ->
            let
                newModel =
                    { model | selectedTableRecord = max 0 (model.selectedTableRecord - 1) }
                        |> populateSelectedTableForm
            in
                newModel ! []

        RequestUserProfile ->
            model ! [ Ports.requestUserProfile E.requestUserProfile ]

        RiskCodeResponse riskCodeTbl ->
            { model | riskCode = riskCodeTbl } ! []

        RoleMessages roleMsg ->
            Updates.roleUpdate roleMsg model

        SaveSelectedTable ->
            -- Note: the real save is done with other messages like MedicationTypeMessages
            { model | selectedTableEditMode = EditModeView } ! []

        SelectedTableEditMode mode id ->
            let
                -- TODO: fix this because it is passed record id but
                -- selectedTableRecord required index.
                newModel =
                    { model
                        | selectedTableEditMode = mode
                        , selectedTableRecord = Maybe.withDefault 0 id
                    }

                newModel2 =
                    if mode /= EditModeTable && id /= Nothing then
                        populateSelectedTableForm newModel
                    else
                        newModel
            in
                newModel2 ! []

        SelectQueryMsg query ->
            let
                _ =
                    Debug.log "SelectQueryMsg" <| toString query
            in
                model ! [ Ports.selectQuery (E.selectQueryToValue query) ]

        SelectQueryResponseMsg sqr ->
            let
                --_ =
                    --Debug.log "SelectQueryResponseMsg" <| toString sqr

                ( newModel, newCmd ) =
                    -- Unwrap sqr from the RemoteData wrapper.
                    case sqr of
                        Success selQryResp ->
                            let
                                selQry =
                                    MU.selectQueryResponseToSelectQuery selQryResp
                            in
                                case ( selQryResp.success, selQryResp.errorCode ) of
                                    ( _, NoErrorCode ) ->
                                        case selQryResp.data of
                                            LabSuiteResp list ->
                                                update (LabSuiteResponse (RD.succeed list)) model

                                            LabTestResp list ->
                                                update (LabTestResponse (RD.succeed list)) model

                                            MedicationTypeResp list ->
                                                -- Put the records into RemoteData format as expected and
                                                -- pass to update function for processing.
                                                Updates.medicationTypeUpdate
                                                    (ReadResponseMedicationType
                                                        (RD.succeed list)
                                                        (Just selQry)
                                                    )
                                                    model

                                            RoleResp list ->
                                                Updates.roleUpdate
                                                    (ReadResponseRole
                                                        (RD.succeed list)
                                                        (Just selQry)
                                                    )
                                                    model

                                            UserResp list ->
                                                Updates.userUpdate
                                                    (ReadResponseUser
                                                        (RD.succeed list)
                                                        (Just selQry)
                                                    )
                                                    model

                                    ( _, SessionExpiredErrorCode ) ->
                                        update SessionExpired model

                                    ( _, SqlErrorCode ) ->
                                        -- TODO: handle SQL error.
                                        model ! []

                                    ( _, UnknownErrorCode ) ->
                                        -- TODO: handle this too.
                                        model ! []

                                    ( _, _ ) ->
                                        model ! []

                        Failure err ->
                            let
                                _ =
                                    Debug.log "SelectQueryResponseMsg" <| toString err
                            in
                                model ! []

                        _ ->
                            model ! []
            in
                ( newModel, newCmd )

        SelectQuerySelectTable query ->
            -- Perform a SelectQuery and set the selectTable field.
            { model
                | selectedTable = Just query.table
                , selectedTableRecord = 0
                , selectedTableEditMode = EditModeTable
            }
                ! [ Ports.selectQuery (E.selectQueryToValue query) ]

        SelectPage page ->
            -- Set the selected Page as well as get the url in sync.
            let
                newCmd =
                    case U.getPageDef page model.pageDefs of
                        Just pdef ->
                            Nav.newUrl pdef.location

                        Nothing ->
                            Cmd.none
            in
                { model | selectedPage = page } ! [ newCmd ]

        SelectTableRecord rec ->
            let
                newModel =
                    { model | selectedTableRecord = rec }
                        |> populateSelectedTableForm
            in
                newModel ! []

        SessionExpired ->
            -- Set the isLoggedIn field in the user profile to False.
            let
                ( newModel, newCmd ) =
                    U.addWarning "Your session has expired. Please login again." model

                userProfile =
                    case newModel.userProfile of
                        Just up ->
                            Just { up | isLoggedIn = False }

                        Nothing ->
                            Nothing
            in
                { newModel | userProfile = userProfile } ! [ newCmd ]

        Snackbar msg ->
            let
                ( snackbar, newCmd ) =
                    Snackbar.update msg model.snackbar
            in
                { model | snackbar = snackbar } ! [ Cmd.map Snackbar newCmd ]

        UpdateResponseMsg change ->
            case change of
                Just c ->
                    case c.table of
                        MedicationType ->
                            Updates.medicationTypeUpdate (UpdateResponseMedicationType c) model

                        User ->
                            Updates.userUpdate (UpdateResponseUser c) model

                        _ ->
                            model ! []

                Nothing ->
                    model ! []

        UrlChange location ->
            { model | selectedPage = U.locationToPage location adminPages } ! []

        UserMessages userMsg ->
            Updates.userUpdate userMsg model

        UserProfileMessages userProfileMsg ->
            Updates.userProfileUpdate userProfileMsg model

        VaccinationTypeResponse vaccinationTypeTbl ->
            { model | vaccinationType = vaccinationTypeTbl } ! []


populateSelectedTableForm : Model -> Model
populateSelectedTableForm model =
    -- Is there a selected table?
    case model.selectedTable of
        Just t ->
            -- Is this a table that we can handle?
            case t of
                MedicationType ->
                    -- Is there data for that table?
                    case model.medicationTypeModel.records of
                        Success data ->
                            let
                                -- Populate the form with the record we need.
                                ( form, newModel ) =
                                    case model.medicationTypeModel.editMode of
                                        EditModeAdd ->
                                            let
                                                -- Get an unique sorting id as default value.
                                                nextSortOrder =
                                                    MU.getRecNextMax (\r -> r.sortOrder) data
                                            in
                                                ( MedicationTypeRecord model.nextPendingId "" "" nextSortOrder Nothing
                                                    |> MedType.medicationTypeInitialForm
                                                , { model | nextPendingId = model.nextPendingId - 1 }
                                                )

                                        _ ->
                                            case LE.getAt (Maybe.withDefault 0 model.medicationTypeModel.selectedRecordId) data of
                                                Just rec ->
                                                    ( MedType.medicationTypeInitialForm rec, model )

                                                Nothing ->
                                                    ( model.medicationTypeModel.form, model )
                            in
                                newModel.medicationTypeModel
                                    |> MU.setForm form
                                    |> asMedicationTypeModelIn newModel

                        _ ->
                            model

                _ ->
                    model

        Nothing ->
            model


{-| Returns the number of records in the selected table
or zero if anything goes wrong.
-}
numRecsSelectedTable : Model -> Int
numRecsSelectedTable model =
    case model.selectedTable of
        Just t ->
            case t of
                MedicationType ->
                    case model.medicationTypeModel.records of
                        Success val ->
                            (List.length val)

                        _ ->
                            0

                VaccinationType ->
                    case model.vaccinationType of
                        Success val ->
                            (List.length val)

                        _ ->
                            0

                -- TODO: add more tables.
                _ ->
                    0

        Nothing ->
            0
