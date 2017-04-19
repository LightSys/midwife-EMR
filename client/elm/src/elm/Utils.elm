module Utils
    exposing
        ( addMessage
        , addWarning
        , getIdxRemoteDataById
        , getPageDef
        , humanReadableError
        , locationToPage
        , maybeStringToInt
        , setDefaultSelectedPage
        , setPageDefs
        , stringToErrorCode
        , stringToTable
        , tabIndexToPage
        , tableToString
        )

import Json.Encode as JE
import List.Extra as LE
import Material.Snackbar as Snackbar
import Navigation exposing (Location)
import RemoteData as RD exposing (RemoteData(..))
import Regex as RX
import Tuple


-- LOCAL IMPORTS

import Model exposing (..)
import Msg exposing (..)
import Types exposing (..)


{-| Sets the pageDefs field in the model as appropriate
should the userProfile field be populated.
-}
setPageDefs : Model -> Model
setPageDefs model =
    case model.userProfile of
        Just up ->
            case up.roleName of
                "administrator" ->
                    { model | pageDefs = Just adminPages }

                _ ->
                    -- TODO: finish this for all of the roles.
                    model

        Nothing ->
            model


{-| Set the default selected page for the role if the pageDefs field
is populated and the selectedPage is still set to ProfileNotLoadedPage.
-}
setDefaultSelectedPage : Model -> Model
setDefaultSelectedPage model =
    case model.pageDefs of
        Just pageDefs ->
            let
                page =
                    case model.selectedPage == ProfileNotLoadedPage of
                        True ->
                            -- Find either the default page for this role which we
                            -- assume to be the first page...
                            -- TODO: or if there is a location already specified,
                            -- look up the page associated with that location if
                            -- possible, falling back to the default page if necessary.
                            -- TODO: probably need programWithFlags to send in the
                            -- current location at load for this?
                            case List.head pageDefs of
                                Just pageDef ->
                                    pageDef.page

                                Nothing ->
                                    -- We have an empty List in pageDefs?
                                    model.selectedPage

                        False ->
                            model.selectedPage
            in
                { model | selectedPage = page }

        Nothing ->
            model


{-| Returns the Page associated with the tab specified
if found in the tabs of the PageDef passed, otherwise
returns the currently selected page, i.e. does nothing.
-}
tabIndexToPage : Int -> Maybe PageDef -> Model -> Page
tabIndexToPage idx pageDef model =
    case pageDef of
        Just pdef ->
            case pdef.tabs of
                Just tabs ->
                    case LE.getAt idx tabs of
                        Just pair ->
                            -- Expects ( String, Page )
                            Tuple.second pair

                        Nothing ->
                            model.selectedPage

                Nothing ->
                    model.selectedPage

        Nothing ->
            model.selectedPage


{-| Returns the associated PageDef for any Page passed, or
Nothing is not found.
-}
getPageDef : Page -> Maybe (List PageDef) -> Maybe PageDef
getPageDef page pageDefs =
    case pageDefs of
        Just pageDefs ->
            case LE.find (\pd -> pd.page == page) pageDefs of
                Just pageDef ->
                    Just pageDef

                Nothing ->
                    -- If we are looking for a Page without a corresponding
                    -- PageDef, that means that something was not set up right.
                    Just notFoundPageDef

        Nothing ->
            Nothing


{-| Returns the Page associated with the specified Location against
the List of PageDefs provided. Returns a default PageDef in case an
appropriate PageDef is not found.
-}
locationToPage : Location -> List PageDef -> Page
locationToPage location pageDefs =
    case LE.find (\pd -> pd.location == location.hash) pageDefs of
        Just pageDef ->
            pageDef.page

        Nothing ->
            --PageNotFoundPage
            PageDefNotFoundPage


tableToString : Table -> String
tableToString table =
    case table of
        Unknown ->
            ""

        CustomField ->
            "customField"

        CustomFieldType ->
            "customFieldType"

        Event ->
            "event"

        EventType ->
            "eventType"

        HealthTeaching ->
            "healthTeaching"

        LabSuite ->
            "labSuite"

        LabTest ->
            "labTest"

        LabTestResult ->
            "labTestResult"

        LabTestValue ->
            "labTestValue"

        Medication ->
            "medication"

        MedicationType ->
            "medicationType"

        Patient ->
            "patient"

        Pregnancy ->
            "pregnancy"

        PregnancyHistory ->
            "pregnancyHistory"

        Pregnote ->
            "pregnote"

        PregnoteType ->
            "pregnoteType"

        PrenatalExam ->
            "prenatalExam"

        Priority ->
            "priority"

        Risk ->
            "risk"

        RiskCode ->
            "riskCode"

        Referral ->
            "referral"

        RoFieldsByRole ->
            "roFieldsByRole"

        Role ->
            "role"

        Schedule ->
            "schedule"

        SelectData ->
            "selectData"

        User ->
            "user"

        Vaccination ->
            "vaccination"

        VaccinationType ->
            "vaccinationType"


stringToTable : String -> Table
stringToTable name =
    case name of
        "customField" ->
            CustomField

        "customFieldType" ->
            CustomFieldType

        "event" ->
            Event

        "eventType" ->
            EventType

        "healthTeaching" ->
            HealthTeaching

        "labSuite" ->
            LabSuite

        "labTest" ->
            LabTest

        "labTestResult" ->
            LabTestResult

        "labTestValue" ->
            LabTestValue

        "medication" ->
            Medication

        "medicationType" ->
            MedicationType

        "patient" ->
            Patient

        "pregnancy" ->
            Pregnancy

        "pregnancyHistory" ->
            PregnancyHistory

        "pregnote" ->
            Pregnote

        "pregnoteType" ->
            PregnoteType

        "prenatalExam" ->
            PrenatalExam

        "priority" ->
            Priority

        "risk" ->
            Risk

        "riskCode" ->
            RiskCode

        "referral" ->
            Referral

        "roFieldsByRole" ->
            RoFieldsByRole

        "role" ->
            Role

        "schedule" ->
            Schedule

        "selectData" ->
            SelectData

        "user" ->
            User

        "vaccination" ->
            Vaccination

        "vaccinationType" ->
            VaccinationType

        _ ->
            Unknown


{-| Converts a String to an Int using a default
value passed upon failure.
-}
maybeStringToInt : Int -> Maybe String -> Int
maybeStringToInt default str =
    Maybe.withDefault "" str
        |> String.toInt
        |> Result.withDefault default


addMessage : String -> Model -> ( Model, Cmd Msg )
addMessage msg model =
    let
        sbContent =
            Snackbar.toast "" msg

        ( sbModel, sbCmd ) =
            Snackbar.add sbContent model.snackbar
    in
        ( { model | snackbar = sbModel }, Cmd.map Snackbar sbCmd )


addWarning : String -> Model -> ( Model, Cmd Msg )
addWarning msg model =
    let
        sbContent =
            Snackbar.Contents msg (Just "Warning") "" 10000 250

        ( sbModel, sbCmd ) =
            Snackbar.add sbContent model.snackbar
    in
        ( { model | snackbar = sbModel }, Cmd.map Snackbar sbCmd )


getIdxRemoteDataById : Int -> RemoteData e (List { a | id : Int }) -> Maybe Int
getIdxRemoteDataById id rdata =
    case rdata of
        Success recs ->
            case LE.findIndex (\r -> r.id == id) recs of
                Just idx ->
                    Just idx

                Nothing ->
                    Nothing

        _ ->
            Nothing


{-| Returns a human readable message for known SQL errors,
otherwise returns SQL error message, or full message if
not a SQL error message.
-}
humanReadableError : String -> String
humanReadableError msg =
    msg
        |> Debug.log "humanReadableError"
        |> RX.split (RX.AtMost 1) (RX.regex " - ER_")
        |> List.drop 1
        |> List.head
        |> Maybe.withDefault msg
        |> sqlErrToHuman


{-| Maps known SQL errors to human readable messages. If match
is not found, returns the original message.
-}
sqlErrToHuman : String -> String
sqlErrToHuman msg =
    let
        errMaps =
            [ ( "ROW_IS_REFERENCED", "The record cannot be deleted because it is currently being used by a record in another table." )
            , ( "DUP_ENTRY", "One of the fields is the same as another record. Please change it so that it is unique." )
            ]

        newMsg =
            List.map
                (\em ->
                    if String.startsWith (Tuple.first em) msg then
                        Tuple.second em
                    else
                        ""
                )
                errMaps
                |> String.join " "
                |> String.trim
                |> (\s ->
                        if String.length s > 0 then
                            s
                        else
                            msg
                   )
    in
        newMsg


stringToErrorCode : String -> ErrorCode
stringToErrorCode str =
    case str of
        "NoErrorCode" ->
            NoErrorCode

        "UnknownErrorCode" ->
            UnknownErrorCode

        "SessionExpiredErrorCode" ->
            SessionExpiredErrorCode

        "SqlErrorCode" ->
            SqlErrorCode

        "LoginSuccessErrorCode" ->
            LoginSuccessErrorCode

        "LoginFailErrorCode" ->
            LoginFailErrorCode

        "UserProfileSuccessErrorCode" ->
            UserProfileSuccessErrorCode

        "UserProfileFailErrorCode" ->
            UserProfileFailErrorCode

        "UserProfileUpdateSuccessErrorCode" ->
            UserProfileUpdateSuccessErrorCode

        "UserProfileUpdateFailErrorCode" ->
            UserProfileUpdateFailErrorCode

        _ ->
            UnknownErrorCode
