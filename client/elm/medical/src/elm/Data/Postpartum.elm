module Data.Postpartum
    exposing
        ( Field(..)
        , SubMsg(..)
        )

import Dict exposing (Dict)

-- LOCAL IMPORTS --

import Const exposing (Dialog(..), FldChgValue)
import Data.DataCache exposing (DataCache)
import Data.DatePicker exposing (DateFieldMessage)
import Data.PostpartumCheck exposing (PostpartumCheckId)
import Data.PregnancyHeader exposing (PregHeaderContentMsg)
import Data.Table exposing (Table)
import Time exposing (Time)


type SubMsg
    = PageNoop
    | RotatePregHeaderContent PregHeaderContentMsg
      -- DataCache is the mechanism used to retrieve records from
      -- the top-level that it has received from the server. The
      -- top-level intercepts this message and creates a new message
      -- with the latest DataCache that it has and sends it down to
      -- us again. We, in turn, populate our page Model based on the
      -- list of tables passed through.
    | DataCache (Maybe (Dict String DataCache)) (Maybe (List Table))
    | HandlePostpartumCheckModal Dialog (Maybe PostpartumCheckId)
    | FldChgSubMsg Field FldChgValue
      -- These two are used for browsers that do not support the
      -- input date type and require the use of jQueryUI datepicker.
    | OpenDatePickerSubMsg String
    | DateFieldSubMsg DateFieldMessage
    | CloseAllDialogs
    | PostpartumTick Time


type Field
    = PCCheckDateFld
    | PCCheckTimeFld
    | PCBabyWeightFld
    | PCBabyTempFld
    | PCBabyCRFld
    | PCBabyRRFld
    | PCBabyLungsFld
    | PCBabyColorFld
    | PCBabySkinFld
    | PCBabyCordFld
    | PCBabyUrineFld
    | PCBabyStoolFld
    | PCBabySSInfectionFld
    | PCBabyFeedingFld
    | PCBabyFeedingDailyFld
    | PCMotherTempFld
    | PCMotherSystolicFld
    | PCMotherDiastolicFld
    | PCMotherCRFld
    | PCMotherBreastsFld
    | PCMotherFundusFld
    | PCMotherPerineumFld
    | PCMotherLochiaFld
    | PCMotherUrineFld
    | PCMotherStoolFld
    | PCMotherSSInfectionFld
    | PCMotherFamilyPlanningFld
    | PCBirthCertReqFld
    | PCHgbRequestedFld
    | PCHgbTestDateFld
    | PCHgbTestResultFld
    | PCIronGivenFld
    | PCCommentsFld
    | PCNextScheduledCheckFld





