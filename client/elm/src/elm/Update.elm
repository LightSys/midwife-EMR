module Update
    exposing
        ( update
        )

import Dict
import Form exposing (Form)
import Form.Field as Fld
import Form.Validate as V
import Json.Decode as JD
import Json.Encode as JE
import List.Extra as LE
import Material
import Material.Snackbar as Snackbar
import RemoteData as RD exposing (RemoteData(..))
import Task


-- LOCAL IMPORTS

import Decoders exposing (..)
import Encoders as E
import Model exposing (..)
import Models.MedicationType as MedType
import Models.VaccinationType as VacType
import Models.Utils as MU
import Msg exposing (..)
import Navigation as Nav
import Ports
import Transactions as Trans
import Types exposing (..)
import Updates.Adhoc as Updates exposing (adhocUpdate)
import Updates.LabSuite as Updates exposing (labSuiteUpdate)
import Updates.LabTest as Updates exposing (labTestUpdate)
import Updates.LabTestValue as Updates exposing (labTestValueUpdate)
import Updates.MedicationType as Updates exposing (medicationTypeUpdate)
import Updates.VaccinationType as Updates exposing (vaccinationTypeUpdate)
import Updates.Profile as Updates exposing (userProfileUpdate)
import Updates.SelectData as Updates exposing (selectDataUpdate)
import Updates.Role as Updates exposing (roleUpdate)
import Updates.User as Updates exposing (userUpdate)
import Utils as U


type alias Mdl =
    Material.Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddChgDelNotificationMessages acdNotification ->
            -- Determine if we are subscribed to the table affected by the change.
            model ! (processDataNotification acdNotification model)

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
                        LabSuite ->
                            Updates.labSuiteUpdate (CreateResponseLabSuite a) model

                        LabTest ->
                            Updates.labTestUpdate (CreateResponseLabTest a) model

                        LabTestValue ->
                            Updates.labTestValueUpdate (CreateResponseLabTestValue a) model

                        MedicationType ->
                            Updates.medicationTypeUpdate (CreateResponseMedicationType a) model

                        SelectData ->
                            Updates.selectDataUpdate (CreateResponseSelectData a) model

                        User ->
                            Updates.userUpdate (CreateResponseUser a) model

                        VaccinationType ->
                            Updates.vaccinationTypeUpdate (CreateResponseVaccinationType a) model

                        _ ->
                            let
                                _ =
                                    Debug.log "Unhandled CreateResponseMsg" <| toString add
                            in
                                model ! []

                Nothing ->
                    model ! []

        DeleteRecord table id ->
            -- Delete a record out of the model as required by processing AddChgDelNotificationMessages.
            let
                newModel =
                    case table of
                        MedicationType ->
                            MU.deleteById id model.medicationTypeModel.records
                                |> flip MU.setRecords model.medicationTypeModel
                                |> (\tblModel -> { model | medicationTypeModel = tblModel})

                        User ->
                            MU.deleteById id model.userModel.records
                                |> flip MU.setRecords model.userModel
                                |> (\tblModel -> { model | userModel = tblModel})

                        _ ->
                            let
                                _ =
                                    Debug.log "DeleteRecord Warning" <| "Unhandled table: " ++ (U.tableToString table)
                            in
                                model
            in
                newModel ! []

        DeleteResponseMsg del ->
            case del of
                Just d ->
                    case d.table of
                        LabSuite ->
                            Updates.labSuiteUpdate (DeleteResponseLabSuite d) model

                        LabTest ->
                            Updates.labTestUpdate (DeleteResponseLabTest d) model

                        LabTestValue ->
                            Updates.labTestValueUpdate (DeleteResponseLabTestValue d) model

                        MedicationType ->
                            Updates.medicationTypeUpdate (DeleteResponseMedicationType d) model

                        SelectData ->
                            Updates.selectDataUpdate (DeleteResponseSelectData d) model

                        User ->
                            Updates.userUpdate (DeleteResponseUser d) model

                        _ ->
                            let
                                _ =
                                    Debug.log "Unhandled DeleteResponseMsg" <| toString del
                            in
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

        LabSuiteMessages labSuiteMsg ->
            Updates.labSuiteUpdate labSuiteMsg model

        LabTestMessages labTestMsg ->
            Updates.labTestUpdate labTestMsg model

        LabTestValueMessages labTestValueMsg ->
            Updates.labTestValueUpdate labTestValueMsg model

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

        SelectDataMessages sdMsg ->
            Updates.selectDataUpdate sdMsg model

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

        SelectQueryMsg queries ->
            let
                _ =
                    Debug.log "SelectQueryMsg" <| toString queries

                newCmds =
                    List.map (\q -> Ports.selectQuery (E.selectQueryToValue q)) queries
            in
                model ! newCmds

        SelectQueryResponseMsg sqr ->
            let
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
                                                --update (LabSuiteResponse (RD.succeed list)) model
                                                Updates.labSuiteUpdate
                                                    (ReadResponseLabSuite
                                                        (RD.succeed list)
                                                        (Just selQry)
                                                    )
                                                    model

                                            LabTestResp list ->
                                                --update (LabTestResponse (RD.succeed list)) model
                                                Updates.labTestUpdate
                                                    (ReadResponseLabTest
                                                        (RD.succeed list)
                                                        (Just selQry)
                                                    )
                                                    model

                                            LabTestValueResp list ->
                                                --update (LabTestValueResponse (RD.succeed list)) model
                                                Updates.labTestValueUpdate
                                                    (ReadResponseLabTestValue
                                                        (RD.succeed list)
                                                        (Just selQry)
                                                    )
                                                    model

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

                                            SelectDataResp list ->
                                                Updates.selectDataUpdate
                                                    (ReadResponseSelectData
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

                                            VaccinationTypeResp list ->
                                                -- Put the records into RemoteData format as expected and
                                                -- pass to update function for processing.
                                                Updates.vaccinationTypeUpdate
                                                    (ReadResponseVaccinationType
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

        SelectQuerySelectTable table queries ->
            -- Perform a SelectQuery and set the selectTable field for the sake of
            -- knowing which lookup table the user is working with at the moment.
            { model
                | selectedTable = Just table
                , selectedTableRecord = 0
                , selectedTableEditMode = EditModeTable
            }
                ! [ Task.perform SelectQueryMsg (Task.succeed queries) ]

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
                        LabSuite ->
                            Updates.labSuiteUpdate (UpdateResponseLabSuite c) model

                        LabTest ->
                            Updates.labTestUpdate (UpdateResponseLabTest c) model

                        LabTestValue ->
                            Updates.labTestValueUpdate (UpdateResponseLabTestValue c) model

                        MedicationType ->
                            Updates.medicationTypeUpdate (UpdateResponseMedicationType c) model

                        User ->
                            Updates.userUpdate (UpdateResponseUser c) model

                        SelectData ->
                            Updates.selectDataUpdate (UpdateResponseSelectData  c) model

                        _ ->
                            let
                                _ =
                                    Debug.log "Unhandled UpdateResponseMsg" <| toString change
                            in
                                model ! []

                Nothing ->
                    model ! []

        UrlChange location ->
            { model | selectedPage = U.locationToPage location adminPages } ! []

        UserChoiceSet key val ->
            { model | userChoice = Dict.insert key val model.userChoice } ! []

        UserChoiceUnset key ->
            { model | userChoice = Dict.remove key model.userChoice } ! []

        UserMessages userMsg ->
            Updates.userUpdate userMsg model

        UserProfileMessages userProfileMsg ->
            Updates.userProfileUpdate userProfileMsg model

        VaccinationTypeMessages vtMsg ->
            Updates.vaccinationTypeUpdate vtMsg model

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


{-| Create a list of Cmds necessary to respond to the server notification
sent against our own subscriptions to those notifications.
-}
processDataNotification : Maybe AddChgDelNotification -> Model -> List (Cmd Msg)
processDataNotification acdNotification model =
    case acdNotification of
        Nothing ->
            []

        Just notification ->
            List.filter (\sub -> sub.table == notification.table)
                model.dataNotificationSubscriptions
                |> List.map (deriveDataNotificationCmd notification)


{-| Determine the correct Cmd in order to handle the server's notification of
a data change and our subscriptions to the same.

Upon a match, ADD and CHG events result in requesting the affected record from
the server while DEL events result in the affected record being deleted in the
model.
-}
deriveDataNotificationCmd : AddChgDelNotification -> NotificationSubscription -> Cmd Msg
deriveDataNotificationCmd notification sub =
    let
        qry =
            SelectQuery notification.table (Just notification.id) Nothing Nothing
    in
        case sub.qualifier of
            NotifySubQualifierNone ->
                -- Subscribe to all changes to the table irrespective of key field.
                case notification.notificationType of
                    UnknownNotificationType ->
                        Cmd.none

                    DelNotificationType ->
                        Task.perform (DeleteRecord notification.table)
                            (Task.succeed notification.id)

                    _ ->
                        -- ADD and CHG
                        Task.perform SelectQueryMsg (Task.succeed [qry])

            NotifySubQualifierId id ->
                -- Only interested in this particular key field.
                if id == notification.id then
                    case notification.notificationType of
                        UnknownNotificationType ->
                            Cmd.none

                        DelNotificationType ->
                            Task.perform (DeleteRecord notification.table)
                                (Task.succeed notification.id)

                        _ ->
                            -- ADD and CHG
                            Task.perform SelectQueryMsg (Task.succeed [qry])
                else
                    Cmd.none

            NotifySubQualifierFK ( tbl, id ) ->
                -- Interested in all rows affected by this foreign key.
                -- Note: notification is a list of ( Table, Int ).
                case LE.find (\( notTbl, notId ) -> notTbl == tbl && notId == id) notification.foreignKeys of
                    Just ( _, _ ) ->
                        case notification.notificationType of
                            UnknownNotificationType ->
                                Cmd.none

                            DelNotificationType ->
                                Task.perform (DeleteRecord notification.table)
                                    (Task.succeed notification.id)

                            _ ->
                                -- ADD and CHG
                                Task.perform SelectQueryMsg (Task.succeed [qry])

                    Nothing ->
                        Cmd.none
