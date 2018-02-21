module Data.TableRecord
    exposing
        ( TableRecord(..)
        , tableRecord
        )

import Json.Decode as JD
import Json.Decode.Pipeline as JDP


-- LOCAL IMPORTS --

import Data.Baby exposing (BabyRecord, babyRecord)
import Data.BabyMedication exposing (BabyMedicationRecord, babyMedicationRecord)
import Data.BabyMedicationType exposing (BabyMedicationTypeRecord, babyMedicationTypeRecord)
import Data.BabyVaccination exposing (BabyVaccinationRecord, babyVaccinationRecord)
import Data.BabyVaccinationType exposing (BabyVaccinationTypeRecord, babyVaccinationTypeRecord)
import Data.ContPostpartumCheck exposing (ContPostpartumCheckRecord, contPostpartumCheckRecord)
import Data.Labor exposing (LaborRecord, laborRecord)
import Data.LaborStage1 exposing (LaborStage1Record, laborStage1Record)
import Data.LaborStage2 exposing (LaborStage2Record, laborStage2Record)
import Data.LaborStage3 exposing (LaborStage3Record, laborStage3Record)
import Data.Membrane exposing (MembraneRecord, membraneRecord)
import Data.NewbornExam exposing (NewbornExamRecord, newbornExamRecord)
import Data.Patient exposing (PatientRecord, patientRecord)
import Data.Pregnancy exposing (PregnancyRecord, pregnancyRecord)
import Data.SelectData exposing (SelectDataRecord, selectDataRecord)
import Data.Table as DT exposing (Table(..))


type TableRecord
    = TableRecordBaby (List BabyRecord)
    | TableRecordBabyMedication (List BabyMedicationRecord)
    | TableRecordBabyMedicationType (List BabyMedicationTypeRecord)
    | TableRecordBabyVaccination (List BabyVaccinationRecord)
    | TableRecordBabyVaccinationType (List BabyVaccinationTypeRecord)
    | TableRecordContPostpartumCheck (List ContPostpartumCheckRecord)
    | TableRecordLabor (List LaborRecord)
    | TableRecordLaborStage1 (List LaborStage1Record)
    | TableRecordLaborStage2 (List LaborStage2Record)
    | TableRecordLaborStage3 (List LaborStage3Record)
    | TableRecordMembrane (List MembraneRecord)
    | TableRecordNewbornExam (List NewbornExamRecord)
    | TableRecordPatient (List PatientRecord)
    | TableRecordPregnancy (List PregnancyRecord)
    | TableRecordSelectData (List SelectDataRecord)


tableRecord : Table -> JD.Decoder TableRecord
tableRecord table =
    case table of
        Baby ->
            JD.map TableRecordBaby (JD.list babyRecord)

        BabyMedication ->
            JD.map TableRecordBabyMedication (JD.list babyMedicationRecord)

        BabyMedicationType ->
            JD.map TableRecordBabyMedicationType (JD.list babyMedicationTypeRecord)

        BabyVaccination ->
            JD.map TableRecordBabyVaccination (JD.list babyVaccinationRecord)

        BabyVaccinationType ->
            JD.map TableRecordBabyVaccinationType (JD.list babyVaccinationTypeRecord)

        ContPostpartumCheck ->
            JD.map TableRecordContPostpartumCheck (JD.list contPostpartumCheckRecord)

        Labor ->
            JD.map TableRecordLabor (JD.list laborRecord)

        LaborStage1 ->
            JD.map TableRecordLaborStage1 (JD.list laborStage1Record)

        LaborStage2 ->
            JD.map TableRecordLaborStage2 (JD.list laborStage2Record)

        LaborStage3 ->
            JD.map TableRecordLaborStage3 (JD.list laborStage3Record)

        Membrane ->
            JD.map TableRecordMembrane (JD.list membraneRecord)

        NewbornExam ->
            JD.map TableRecordNewbornExam (JD.list newbornExamRecord)

        Patient ->
            JD.map TableRecordPatient (JD.list patientRecord)

        Pregnancy ->
            JD.map TableRecordPregnancy (JD.list pregnancyRecord)

        SelectData ->
            JD.map TableRecordSelectData (JD.list selectDataRecord)

        _ ->
            JD.fail <| "Cannot yet handle table of " ++ (DT.tableToString table) ++ " in Data.TableRecord.tableRecord."
