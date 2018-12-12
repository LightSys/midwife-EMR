module Data.TableRecord
    exposing
        ( TableRecord(..)
        , tableRecord
        )

import Data.Baby exposing (BabyRecord, babyRecord)
import Data.BabyLab exposing (BabyLabRecord, babyLabRecord)
import Data.BabyLabType exposing (BabyLabTypeRecord, babyLabTypeRecord)
import Data.BabyMedication exposing (BabyMedicationRecord, babyMedicationRecord)
import Data.BabyMedicationType exposing (BabyMedicationTypeRecord, babyMedicationTypeRecord)
import Data.BabyVaccination exposing (BabyVaccinationRecord, babyVaccinationRecord)
import Data.BabyVaccinationType exposing (BabyVaccinationTypeRecord, babyVaccinationTypeRecord)
import Data.BirthCertificate exposing (BirthCertificateRecord, birthCertificateRecord)
import Data.ContPostpartumCheck exposing (ContPostpartumCheckRecord, contPostpartumCheckRecord)
import Data.Discharge exposing (DischargeRecord, dischargeRecord)
import Data.KeyValue exposing (KeyValueRecord, keyValueRecord)
import Data.Labor exposing (LaborRecord, laborRecord)
import Data.LaborStage1 exposing (LaborStage1Record, laborStage1Record)
import Data.LaborStage2 exposing (LaborStage2Record, laborStage2Record)
import Data.LaborStage3 exposing (LaborStage3Record, laborStage3Record)
import Data.Membrane exposing (MembraneRecord, membraneRecord)
import Data.MotherMedication exposing (MotherMedicationRecord, motherMedicationRecord)
import Data.MotherMedicationType exposing (MotherMedicationTypeRecord, motherMedicationTypeRecord)
import Data.NewbornExam exposing (NewbornExamRecord, newbornExamRecord)
import Data.Patient exposing (PatientRecord, patientRecord)
import Data.PostpartumCheck exposing (PostpartumCheckRecord, postpartumCheckRecord)
import Data.Pregnancy exposing (PregnancyRecord, pregnancyRecord)
import Data.SelectData exposing (SelectDataRecord, selectDataRecord)
import Data.Table as DT exposing (Table(..))
import Data.TableMeta exposing (TableMeta, tableMetaForTable)
import Json.Decode as JD
import Json.Decode.Pipeline as JDP


type TableRecord
    = TableRecordBaby (List BabyRecord)
    | TableRecordBabyLab (List BabyLabRecord)
    | TableRecordBabyLabType (List BabyLabTypeRecord)
    | TableRecordBabyMedication (List BabyMedicationRecord)
    | TableRecordBabyMedicationType (List BabyMedicationTypeRecord)
    | TableRecordBabyVaccination (List BabyVaccinationRecord)
    | TableRecordBabyVaccinationType (List BabyVaccinationTypeRecord)
    | TableRecordBirthCertificate (List BirthCertificateRecord)
    | TableRecordContPostpartumCheck (List ContPostpartumCheckRecord) (List TableMeta)
    | TableRecordDischarge (List DischargeRecord)
    | TableRecordKeyValue (List KeyValueRecord)
    | TableRecordLabor (List LaborRecord)
    | TableRecordLaborStage1 (List LaborStage1Record)
    | TableRecordLaborStage2 (List LaborStage2Record)
    | TableRecordLaborStage3 (List LaborStage3Record)
    | TableRecordMembrane (List MembraneRecord)
    | TableRecordMotherMedication (List MotherMedicationRecord)
    | TableRecordMotherMedicationType (List MotherMedicationTypeRecord)
    | TableRecordNewbornExam (List NewbornExamRecord)
    | TableRecordPatient (List PatientRecord) (List TableMeta)
    | TableRecordPostpartumCheck (List PostpartumCheckRecord) (List TableMeta)
    | TableRecordPregnancy (List PregnancyRecord)
    | TableRecordSelectData (List SelectDataRecord)


tableRecord : Table -> JD.Decoder TableRecord
tableRecord table =
    case table of
        Baby ->
            JD.map TableRecordBaby (JD.list babyRecord)

        BabyLab ->
            JD.map TableRecordBabyLab (JD.list babyLabRecord)

        BabyLabType ->
            JD.map TableRecordBabyLabType (JD.list babyLabTypeRecord)

        BabyMedication ->
            JD.map TableRecordBabyMedication (JD.list babyMedicationRecord)

        BabyMedicationType ->
            JD.map TableRecordBabyMedicationType (JD.list babyMedicationTypeRecord)

        BabyVaccination ->
            JD.map TableRecordBabyVaccination (JD.list babyVaccinationRecord)

        BabyVaccinationType ->
            JD.map TableRecordBabyVaccinationType (JD.list babyVaccinationTypeRecord)

        BirthCertificate ->
            JD.map TableRecordBirthCertificate (JD.list birthCertificateRecord)

        ContPostpartumCheck ->
            JD.map2 TableRecordContPostpartumCheck (JD.list contPostpartumCheckRecord) (JD.list (tableMetaForTable ContPostpartumCheck))

        Discharge ->
            JD.map TableRecordDischarge (JD.list dischargeRecord)

        KeyValue ->
            JD.map TableRecordKeyValue (JD.list keyValueRecord)

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

        MotherMedication ->
            JD.map TableRecordMotherMedication (JD.list motherMedicationRecord)

        MotherMedicationType ->
            JD.map TableRecordMotherMedicationType (JD.list motherMedicationTypeRecord)

        NewbornExam ->
            JD.map TableRecordNewbornExam (JD.list newbornExamRecord)

        Patient ->
            JD.map2 TableRecordPatient (JD.list patientRecord) (JD.list (tableMetaForTable Patient))

        PostpartumCheck ->
            JD.map2 TableRecordPostpartumCheck (JD.list postpartumCheckRecord) (JD.list (tableMetaForTable PostpartumCheck))

        Pregnancy ->
            JD.map TableRecordPregnancy (JD.list pregnancyRecord)

        SelectData ->
            JD.map TableRecordSelectData (JD.list selectDataRecord)

        _ ->
            JD.fail <| "Cannot yet handle table of " ++ DT.tableToString table ++ " in Data.TableRecord.tableRecord."
