module Data.ContPP
    exposing
        ( Field(..)
        , MedVacLab(..)
        , SubMsg(..)
        )

import Const exposing (Dialog(..), FldChgValue)
import Data.ContPostpartumCheck exposing (ContPostpartumCheckId)
import Data.DataCache exposing (DataCache)
import Data.DatePicker exposing (DateFieldMessage)
import Data.PregnancyHeader exposing (PregHeaderContentMsg)
import Data.Table exposing (Table)
import Dict exposing (Dict)
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
    | HandleNewbornExamModal Dialog
    | HandleBabyMedVacLabModal Dialog (Maybe MedVacLab)
    | HandleMotherMedicationModal Dialog (Maybe Int)
    | HandleDischargeModal Dialog
    | HandleContPostpartumCheckModal Dialog (Maybe ContPostpartumCheckId)
      -- These two are used for browsers that do not support the
      -- input date type and require the use of jQueryUI datepicker.
    | OpenDatePickerSubMsg String
    | DateFieldSubMsg DateFieldMessage
    | FldChgSubMsg Field FldChgValue
    | CloseAllDialogs
    | ContPPTick Time


{-| The Int parameter refers to the respective
medication, vaccination, or lab id.
-}
type MedVacLab
    = MedMVL Int
    | VacMVL Int
    | LabMVL Int


{-| The fields we use. NotUsed is a special case for handling a MedVacLab
when we have not started working with Labs yet.
-}
type Field
    = NotUsed
    | NBSDateFld
    | NBSTimeFld
    | NBSExaminersFld
    | NBSRRFld
    | NBSHRFld
    | NBSTemperatureFld
    | NBSLengthFld
    | NBSHeadCirFld
    | NBSChestCirFld
    | NBSAppearanceFld
    | NBSAppearanceCommentFld
    | NBSColorFld
    | NBSColorCommentFld
    | NBSSkinFld
    | NBSSkinCommentFld
    | NBSHeadFld
    | NBSHeadCommentFld
    | NBSEyesFld
    | NBSEyesCommentFld
    | NBSEarsFld
    | NBSEarsCommentFld
    | NBSNoseFld
    | NBSNoseCommentFld
    | NBSMouthFld
    | NBSMouthCommentFld
    | NBSNeckFld
    | NBSNeckCommentFld
    | NBSChestFld
    | NBSChestCommentFld
    | NBSLungsFld
    | NBSLungsCommentFld
    | NBSHeartFld
    | NBSHeartCommentFld
    | NBSAbdomenFld
    | NBSAbdomenCommentFld
    | NBSHipsFld
    | NBSHipsCommentFld
    | NBSCordFld
    | NBSCordCommentFld
    | NBSFemoralPulsesFld
    | NBSFemoralPulsesCommentFld
    | NBSGenitaliaFld
    | NBSGenitaliaCommentFld
    | NBSAnusFld
    | NBSAnusCommentFld
    | NBSBackFld
    | NBSBackCommentFld
    | NBSExtremitiesFld
    | NBSExtremitiesCommentFld
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
    | CPCCheckDateFld
    | CPCCheckTimeFld
    | CPCMotherSystolicFld
    | CPCMotherDiastolicFld
    | CPCMotherCRFld
    | CPCMotherTempFld
    | CPCMotherFundusFld
    | CPCMotherEBLFld
    | CPCBabyBFedFld
    | CPCBabyTempFld
    | CPCBabyRRFld
    | CPCBabyCRFld
    | CPCCommentsFld
    | BabyMedDateFld
    | BabyMedTimeFld
    | BabyMedLocationFld
    | BabyMedInitialsFld
    | BabyMedCommentsFld
    | BabyVacDateFld
    | BabyVacTimeFld
    | BabyVacLocationFld
    | BabyVacInitialsFld
    | BabyVacCommentsFld
    | BabyLabDateFld
    | BabyLabTimeFld
    | BabyLabFld1ValueFld
    | BabyLabFld2ValueFld
    | BabyLabFld3ValueFld
    | BabyLabFld4ValueFld
    | BabyLabInitialsFld
    | MotherMedDateFld
    | MotherMedTimeFld
    | MotherMedInitialsFld
    | MotherMedCommentsFld
    | DischargeDateFld
    | DischargeTimeFld
    | DischargeMotherSystolicFld
    | DischargeMotherDiastolicFld
    | DischargeMotherTempFld
    | DischargeMotherCRFld
    | DischargeBabyRRFld
    | DischargeBabyTempFld
    | DischargeBabyCRFld
    | DischargePpInstructionsScheduleFld
    | DischargeBirthCertWorksheetFld
    | DischargeBirthRecordedFld
    | DischargeChartsCompleteFld
    | DischargeLogsCompleteFld
    | DischargeBillPaidFld
    | DischargeNbsFld
    | DischargeImmunizationReferralFld
    | DischargeBreastFeedingEstablishedFld
    | DischargeNewbornBathFld
    | DischargeFundusFirmBleedingCtldFld
    | DischargeMotherAteDrankFld
    | DischargeMotherUrinatedFld
    | DischargePlacentaGoneFld
    | DischargePrayerFld
    | DischargeBibleFld
    | DischargeTransferBabyFld
    | DischargeTransferMotherFld
    | DischargeTransferCommentFld
    | DischargeInitialsFld
