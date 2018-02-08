module Data.ContPP
    exposing
        ( Field(..)
        , SubMsg(..)
        )

import Dict exposing (Dict)

-- LOCAL IMPORTS --

import Const exposing (Dialog(..), FldChgValue)
import Data.DataCache exposing (DataCache)
import Data.DatePicker exposing (DateFieldMessage)
import Data.PregnancyHeader exposing (PregHeaderContentMsg)
import Data.Table exposing (Table)


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
    | HandleNewbornExamModal Dialog
      -- These two are used for browsers that do not support the
      -- input date type and require the use of jQueryUI datepicker.
    | OpenDatePickerSubMsg String
    | DateFieldSubMsg DateFieldMessage
    | FldChgSubMsg Field FldChgValue


type Field
    = NBSDateFld
    | NBSTimeFld
    | NBSExaminersFld
    | NBSRRFld
    | NBSHRFld
    | NBSTemperatureFld
    | NBSLengthFld
    | NBSHeadCirFld
    | NBSChestCirFld
    | NBSAppearanceFld
    | NBSColorFld
    | NBSSkinFld
    | NBSHeadFld
    | NBSEyesFld
    | NBSEarsFld
    | NBSNoseFld
    | NBSMouthFld
    | NBSNeckFld
    | NBSChestFld
    | NBSLungsFld
    | NBSHeartFld
    | NBSAbdomenFld
    | NBSHipsFld
    | NBSCordFld
    | NBSFemoralPulsesFld
    | NBSGenitaliaFld
    | NBSAnusFld
    | NBSBackFld
    | NBSExtremitiesFld
    | NBSEstGAFld
    | NBSMoroReflexFld
    | NBSMoroReflexCommentFld
    | NBSPalmarReflexFld
    | NBSSteppingReflexCommentFld
    | NBSPlantarReflexFld
    | NBSBabinskiReflexCommentFld
    | NBSBabinskiReflexFld
    | NBSCommentsFld
    | NBSPlantarReflexCommentFld
    | NBSSteppingReflexFld
    | NBSPalmarReflexCommentFld
