module Page.LaborDelIpp
    exposing
        ( Model
        , buildModel
        , init
        , update
        , view
        )

import Date exposing (Date, Month(..), day, month, year)
import Html as H exposing (Html)
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as JD
import Task exposing (Task)
import Window


-- LOCAL IMPORTS --

import Data.DatePicker exposing (DateField(..), DateFieldMessage(..), dateFieldToString)
import Data.LaborDelIpp exposing (Field(..), SubMsg(..))
import Data.Message exposing (MsgType(..), wrapPayload)
import Data.Patient exposing (PatientRecord)
import Data.Pregnancy exposing (getPregId, PregnancyId(..), PregnancyRecord)
import Data.Processing exposing (ProcessId(..))
import Data.SelectQuery exposing (SelectQuery, selectQueryToValue)
import Data.Session as Session exposing (Session)
import Data.Table exposing (Table(..))
import Msg exposing (logConsole, Msg(..), ProcessType(..))
import Page.Errored as Errored exposing (PageLoadError)
import Ports
import Processing exposing (ProcessStore)
import Time exposing (Time)
import Util exposing ((=>))
import Views.PregnancyHeader exposing (viewPrenatal)


-- MODEL --


type alias Model =
    { browserSupportsDate : Bool
    , currTime : Time
    , pregnancy_id : PregnancyId
    , patientRecord : Maybe PatientRecord
    , pregnancyRecord : Maybe PregnancyRecord
    , admitForLabor : Bool
    , admittanceDate : Maybe Date
    , laborDate : Maybe Date
    }


buildModel : Bool -> Time -> PregnancyId -> Maybe PatientRecord -> Maybe PregnancyRecord -> Model
buildModel browserSupportsDate currTime pregId patrec pregRec =
    Model browserSupportsDate currTime pregId patrec pregRec False Nothing Nothing


init : PregnancyId -> Session -> ProcessStore -> ( ProcessStore, Cmd Msg )
init pregId session store =
    let
        selectQuery =
            SelectQuery Pregnancy (Just (getPregId pregId)) [ Patient ]

        ( processId, processStore ) =
            Processing.add (SelectQueryType (LaborDelIppLoaded pregId) selectQuery) Nothing store

        msg =
            wrapPayload processId SelectMsgType (selectQueryToValue selectQuery)
    in
        processStore
            => Ports.outgoing msg


view : Maybe Window.Size -> Session -> Model -> Html SubMsg
view size session model =
    let
        pregHeader =
            case ( model.patientRecord, model.pregnancyRecord ) of
                ( Just patRec, Just pregRec ) ->
                    viewPrenatal patRec pregRec model.currTime size

                ( _, _ ) ->
                    H.text ""

        views =
            if model.admitForLabor then
                [ viewAdmitForm model ]
            else
                [ viewAdmitButton
                , viewFalseLabors model
                ]
    in
        H.div []
            [ pregHeader
            , H.div [ HA.class "content-wrapper" ] views
            ]


viewAdmitForm : Model -> Html SubMsg
viewAdmitForm model =
    H.div []
        [ H.h3 [ HA.class "c-text--brand mw-header-3" ] [ H.text "Admittance Details" ]
        , H.div []
            [ H.div [ HA.class "o-fieldset form-wrapper" ]
                --[ formField "Date admitted" "e.g. 2017/07/14"
                [ if model.browserSupportsDate then
                    formFieldDate (FldChgSubMsg AdmittanceDateFld)
                        "Date admitted"
                        "e.g. 08/14/2017"
                        model.admittanceDate
                  else
                    formFieldDatePicker OpenDatePickerSubMsg
                        LaborDelIppAdmittanceDateField
                        "Date admitted"
                        "e.g. 08/14/2017"
                        model.admittanceDate
                , formField "Time admitted" "e.g. 14:44"
                , if model.browserSupportsDate then
                    formFieldDate (FldChgSubMsg LaborDateFld)
                        "Date start of labor"
                        "e.g. 08/14/2017"
                        model.laborDate
                  else
                    formFieldDatePicker OpenDatePickerSubMsg
                        LaborDelIppLaborDateField
                        "Date start of labor"
                        "e.g. 08/14/2017"
                        model.laborDate
                , formField "Time start of labor" "e.g. 09:00"
                , formField "POS" "pos"
                , formField "FH" "fh"
                , formField "FHT" "fht"
                , formField "Systolic" "systolic"
                , formField "Diastolic" "diastolic"
                , formField "CR" "heart rate"
                , formField "Temp" "temperature"
                , formTextField "Comments" 3
                ]
            , H.div [ HA.class "form-wrapper-end" ]
                [ cancelSaveButtons CancelAdmitForLabor SaveAdmitForLabor ]
            ]
        ]


cancelSaveButtons : SubMsg -> SubMsg -> Html SubMsg
cancelSaveButtons cancelMsg saveMsg =
    H.span [ HA.class "c-input-group cancel-save-buttons" ]
        [ H.button [ HA.class "c-button u-large u-pillar-box-large" ]
            [ H.text "Cancel" ]
        , H.button [ HA.class "c-button c-button--brand u-large u-pillar-box-large" ]
            [ H.text "Save" ]
        ]


monthToInt : Date.Month -> Int
monthToInt m =
    case m of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


type DateFmt
    = YMDDateFmt
    | MDYDateFmt
    | DMYDateFmt


type DateSep
    = DashDateSep
    | ForwardDateSep
    | BackwardDateSep
    | PeriodDateSep


{-| TODO: remove this if we are not using it.
-}
calendarTest : Html SubMsg
calendarTest =
    H.div [ HA.class "c-calendar c-calendar--higher u-xsmall" ]
        [ H.button [ HA.class "c-calendar__control" ] [ H.text "‹" ]
        , H.div [ HA.class "c-calendar__header" ] [ H.text "2016" ]
        , H.button [ HA.class "c-calendar__control" ] [ H.text "›" ]
        , H.button [ HA.class "c-calendar__control" ] [ H.text "‹" ]
        , H.div [ HA.class "c-calendar__header" ] [ H.text "January" ]
        , H.button [ HA.class "c-calendar__control" ] [ H.text "›" ]
        , H.div [ HA.class "c-calendar__day" ] [ H.text "Su" ]
        , H.div [ HA.class "c-calendar__day" ] [ H.text "Mo" ]
        , H.div [ HA.class "c-calendar__day" ] [ H.text "Tu" ]
        , H.div [ HA.class "c-calendar__day" ] [ H.text "We" ]
        , H.div [ HA.class "c-calendar__day" ] [ H.text "Th" ]
        , H.div [ HA.class "c-calendar__day" ] [ H.text "Fr" ]
        , H.div [ HA.class "c-calendar__day" ] [ H.text "Sa" ]
        , H.button [ HA.class "c-calendar__date" ] [ H.text "27" ]
        , H.button [ HA.class "c-calendar__date" ] [ H.text "28" ]
        , H.button [ HA.class "c-calendar__date" ] [ H.text "29" ]
        , H.button [ HA.class "c-calendar__date" ] [ H.text "30" ]
        , H.button [ HA.class "c-calendar__date" ] [ H.text "31" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "01" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "02" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month c-calendar__date--today" ] [ H.text "03" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "04" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "05" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "06" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "07" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "08" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "09" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "10" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "11" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "12" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "13" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month c-calendar__date--selected" ] [ H.text "14" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "15" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "06" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "17" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "18" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "19" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "20" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "21" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "22" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "23" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "24" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "25" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "26" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "27" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "28" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "29" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "30" ]
        , H.button [ HA.class "c-calendar__date c-calendar__date--in-month" ] [ H.text "31" ]
        , H.button [ HA.class "c-calendar__date" ] [ H.text "01" ]
        , H.button [ HA.class "c-calendar__date" ] [ H.text "02" ]
        , H.button [ HA.class "c-calendar__date" ] [ H.text "03" ]
        , H.button [ HA.class "c-calendar__date" ] [ H.text "04" ]
        , H.button [ HA.class "c-calendar__date" ] [ H.text "05" ]
        , H.button [ HA.class "c-button c-button--block" ] [ H.text "Today" ]
        ]


dateFormatter : Date -> DateFmt -> DateSep -> String
dateFormatter d f s =
    let
        mthStr =
            month d |> monthToInt |> toString |> String.pad 2 '0'

        dayStr =
            day d |> toString |> String.pad 2 '0'

        yearStr =
            year d |> toString

        sep =
            case s of
                DashDateSep ->
                    "-"

                ForwardDateSep ->
                    "/"

                BackwardDateSep ->
                    "\\"

                PeriodDateSep ->
                    "."
    in
        case f of
            YMDDateFmt ->
                yearStr ++ sep ++ mthStr ++ sep ++ dayStr

            MDYDateFmt ->
                mthStr ++ sep ++ dayStr ++ sep ++ yearStr

            DMYDateFmt ->
                dayStr ++ sep ++ mthStr ++ sep ++ yearStr


{-| A date form field for browsers that support a date input type and
presumably will display their own date picker interface as required.
-}
formFieldDate : (String -> SubMsg) -> String -> String -> Maybe Date -> Html SubMsg
formFieldDate onInputMsg lbl placeholder value =
    let
        theDate =
            case value of
                Just v ->
                    dateFormatter v YMDDateFmt DashDateSep

                Nothing ->
                    ""
    in
        H.label [ HA.class "c-label o-form-element u-small mw-form-field" ]
            [ H.text lbl
            , H.input
                [ HA.class "c-field c-field--label"
                , HA.type_ "date"
                , HA.value theDate
                , HA.placeholder placeholder
                , HE.onInput onInputMsg
                ]
                []
            ]


{-| This integrates with via ports the jQueryUI datepicker widget. The openMsg
param is used to open the widget upon focus. The dateFld passed is converted to
a string id which is returned via ports from JS with the date selected in an
IncomingDate structure, which is processed by the Data.DatePicker module.

To add a new date field:
  - add a new branch in Data.DatePicker.DateField
  - add a new case in stringToDateField and dateFieldToString in Data.DatePicker.
  - add a handler in the DateFieldSubMsg branch in the page update for the date field.
  - if necessary, add a new case in the main update for the page and IncomingDatePicker msg.
-}
formFieldDatePicker : (String -> SubMsg) -> DateField -> String -> String -> Maybe Date -> Html SubMsg
formFieldDatePicker openMsg dateFld lbl placeholder value =
    let
        id =
            dateFieldToString dateFld

        theDate =
            case value of
                Just v ->
                    dateFormatter v YMDDateFmt DashDateSep

                Nothing ->
                    ""
    in
        H.label [ HA.class "c-label o-form-element u-small mw-form-field" ]
            [ H.text lbl
            , H.input
                [ HA.class "c-field c-field--label datepicker"
                , HA.type_ "text"
                , HA.id id
                , HA.value theDate
                , HA.placeholder placeholder
                , HE.onFocus <| openMsg id
                ]
                []
            ]


formField : String -> String -> Html SubMsg
formField lbl placeholder =
    H.label [ HA.class "c-label o-form-element u-small mw-form-field" ]
        [ H.text lbl
        , H.input
            [ HA.class "c-field c-field--label"
            , HA.placeholder placeholder
            ]
            []
        ]


formTextField : String -> Int -> Html SubMsg
formTextField lbl numLines =
    H.label [ HA.class "c-label o-form-element mw-form-field-wide" ]
        [ H.text lbl
        , H.textarea
            [ HA.class "c-field c-field--label"
            , HA.rows numLines
            , HA.placeholder lbl
            ]
            []
        ]


viewAdmitButton : Html SubMsg
viewAdmitButton =
    H.button
        [ HA.class "c-button c-button--brand u-xlarge"
        , HE.onClick AdmitForLabor
        ]
        [ H.text "Admit for Labor" ]


{-| TODO: populate table with real data.
-}
viewFalseLabors : Model -> Html SubMsg
viewFalseLabors model =
    let
        makeRow ( start, end ) =
            H.tr [ HA.class "c-table__row" ]
                [ H.td [ HA.class "c-table__cell" ]
                    [ H.text start ]
                , H.td [ HA.class "c-table__cell" ]
                    [ H.text end ]
                ]
    in
        H.div []
            [ H.h2 [ HA.class "c-heading" ]
                [ H.text "False Labors" ]
            , H.table [ HA.class "c-table c-table--condensed c-table--clickable" ]
                [ H.thead [ HA.class "c-table__head" ]
                    [ H.tr [ HA.class "c-table__row c-table__row--heading" ]
                        [ H.th [ HA.class "c-table__cell" ]
                            [ H.text "Start" ]
                        , H.th [ HA.class "c-table__cell" ]
                            [ H.text "End" ]
                        ]
                    ]
                , H.tbody [ HA.class "c-table__body" ] <|
                    List.map makeRow [ ( "07/14/2017 14:25", "07/14/2017 19:55" ) ]
                ]
            ]



-- UPDATE --


update : Session -> SubMsg -> Model -> ( Model, Cmd SubMsg, Cmd Msg )
update session msg model =
    case msg of
        PageNoop ->
            let
                _ =
                    Debug.log "PageNoop" "was called."
            in
                ( model, Cmd.none, Cmd.none )

        AdmitForLabor ->
            let
                _ =
                    Debug.log "LaborDelIpp.update" "AdmitForLabor"

                -- We default to the current date if it is not already filled.
                admittanceDate =
                    case model.admittanceDate of
                        Just d ->
                            Just d

                        Nothing ->
                            Just <| Date.fromTime model.currTime
            in
                ( { model
                    | admitForLabor = True
                    , admittanceDate = admittanceDate
                  }
                , Cmd.none
                , Cmd.none
                )

        CancelAdmitForLabor ->
            ( model, Cmd.none, Cmd.none )

        SaveAdmitForLabor ->
            ( model, Cmd.none, Cmd.none )

        OpenDatePickerSubMsg id ->
            ( model, Cmd.none, Task.perform OpenDatePicker (Task.succeed id) )

        FldChgSubMsg fld value ->
            let
                -- Attempt conversion to date for below if needed.
                date =
                    Date.fromString value
                        |> Result.toMaybe

                _ =
                    Debug.log "FldChgSubMsg" <| (toString fld) ++ " " ++ (toString value)
            in
                ( case fld of
                    AdmittanceDateFld ->
                        { model | admittanceDate = date }

                    LaborDateFld ->
                        { model | laborDate = date }
                , Cmd.none
                , Cmd.none
                )

        DateFieldSubMsg dateFldMsg ->
            case dateFldMsg of
                DateFieldMessage { dateField, date } ->
                    case dateField of
                        LaborDelIppAdmittanceDateField ->
                            ( { model | admittanceDate = Just date }, Cmd.none, Cmd.none )

                        LaborDelIppLaborDateField ->
                            ( { model | laborDate = Just date }, Cmd.none, Cmd.none )

                        UnknownDateField str ->
                            ( model, Cmd.none, logConsole str )

                UnknownDateFieldMessage str ->
                    ( model, Cmd.none, Cmd.none )
