module Data.LaborDelIpp
    exposing
        ( AddOtherApgar(..)
        , Field(..)
        , SubMsg(..)
        )

import Dict exposing (Dict)
import Time exposing (Time)


-- LOCAL IMPORTS --

import Const exposing (Dialog(..), FldChgValue)
import Data.Baby exposing (ApgarScore)
import Data.DataCache exposing (DataCache)
import Data.DatePicker exposing (DateFieldMessage)
import Data.Labor exposing (LaborId, LaborRecordNew)
import Data.LaborStage1 exposing (LaborStage1Id, LaborStage1Record, LaborStage1RecordNew)
import Data.Table exposing (Table)
import Data.PregnancyHeader exposing (PregHeaderContentMsg)


type SubMsg
    = PageNoop
      -- DataCache is the mechanism used to retrieve records from
      -- the top-level that it has received from the server. The
      -- top-level intercepts this message and creates a new message
      -- with the latest DataCache that it has and sends it down to
      -- us again. We, in turn, populate our page Model based on the
      -- list of tables passed through.
    | DataCache (Maybe (Dict String DataCache)) (Maybe (List Table))
      -- These two are used for browsers that do not support the
      -- input date type and require the use of jQueryUI datepicker.
    | OpenDatePickerSubMsg String
    | DateFieldSubMsg DateFieldMessage
      -- This is for all fields other than those requiring the
      -- datepicker above.
    | FldChgSubMsg Field FldChgValue
      -- The view that the pregnancy header is currently showing.
    | RotatePregHeaderContent PregHeaderContentMsg
      -- Modals for date/time and summary for the stages and baby records.
    | HandleStage1DateTimeModal Dialog
    | HandleStage1SummaryModal Dialog
    | HandleStage2DateTimeModal Dialog
    | HandleStage2SummaryModal Dialog
    | HandleStage3DateTimeModal Dialog
    | HandleStage3SummaryModal Dialog
    | HandleMembraneSummaryModal Dialog
    | HandleBabySummaryModal Dialog
    | AddApgarWizard AddOtherApgar
    | DeleteApgar Int
      -- Clearing date/time fields.
    | ClearStage1DateTime
    | ClearStage2DateTime
    | ClearStage3DateTime
      -- We are supplied date/time so we can prefill date/time fields.
    | LaborDelIppTick Time
      -- Our labor records have been loaded from the server.
    | LaborDetailsLoaded
      -- Our current labor record.
    | ViewLaborRecord LaborId
    | CloseAllDialogs


type AddOtherApgar
    = NotStartedAddOtherApgar
    | MinuteAddOtherApgar
    | ScoreAddOtherApgar
    | FinishedAddOtherApgar

type Field
    = AdmittanceDateFld
    | AdmittanceTimeFld
    | LaborDateFld
    | LaborTimeFld
    | PosFld
    | FhFld
    | FhtFld
    | SystolicFld
    | DiastolicFld
    | CrFld
    | TempFld
    | CommentsFld
    | Stage1DateFld
    | Stage1TimeFld
    | Stage1MobilityFld
    | Stage1DurationLatentHoursFld
    | Stage1DurationLatentMinutesFld
    | Stage1DurationActiveHoursFld
    | Stage1DurationActiveMinutesFld
    | Stage1CommentsFld
    | Stage2DateFld
    | Stage2TimeFld
    | Stage2BirthDatetimeFld
    | Stage2BirthTypeFld
    | Stage2BirthPositionFld
    | Stage2DurationPushingFld
    | Stage2BirthPresentationFld
    | Stage2TerminalMecFld
    | Stage2CordWrapTypeFld
    | Stage2DeliveryTypeFld
    | Stage2ShoulderDystociaFld
    | Stage2ShoulderDystociaMinutesFld
    | Stage2DegreeFld
    | Stage2LacerationFld
    | Stage2EpisiotomyFld
    | Stage2RepairFld
    | Stage2LacerationRepairedByFld
    | Stage2BirthEBLFld
    | Stage2MeconiumFld
    | Stage2CommentsFld
    | Stage3DateFld
    | Stage3TimeFld
    | Stage3PlacentaDeliverySpontaneousFld
    | Stage3PlacentaDeliveryAMTSLFld
    | Stage3PlacentaDeliveryCCTFld
    | Stage3PlacentaDeliveryManualFld
    | Stage3MaternalPositionFld
    | Stage3TxBloodLoss1Fld
    | Stage3TxBloodLoss2Fld
    | Stage3TxBloodLoss3Fld
    | Stage3TxBloodLoss4Fld
    | Stage3TxBloodLoss5Fld
    | Stage3PlacentaShapeFld
    | Stage3PlacentaInsertionFld
    | Stage3PlacentaNumVesselsFld
    | Stage3SchultzDuncanFld
    | Stage3CotyledonsFld
    | Stage3MembranesFld
    | Stage3CommentsFld
    | BabyLastnameFld
    | BabyFirstnameFld
    | BabyMiddlenameFld
    | BabySexFld
    | BabyBirthWeightFld
    | BabyBFedEstablishedDateFld
    | BabyBFedEstablishedTimeFld
    | BabyBulbFld
    | BabyMachineFld
    | BabyFreeFlowO2Fld
    | BabyChestCompressionsFld
    | BabyPpvFld
    | BabyCommentsFld
    | ApgarStandardFld
    | ApgarOtherMinuteFld
    | ApgarOtherScoreFld
    | MembraneRuptureDateFld
    | MembraneRuptureTimeFld
    | MembraneRuptureFld
    | MembraneRuptureCommentFld
    | MembraneAmnioticFld
    | MembraneAmnioticCommentFld
    | MembraneCommentsFld
