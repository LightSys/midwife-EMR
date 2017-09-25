module Data.TableRecord
    exposing
        ( TableRecord(..)
        , tableRecord
        )

import Json.Decode as JD
import Json.Decode.Pipeline as JDP


-- LOCAL IMPORTS --

import Data.Labor exposing (LaborRecord, laborRecord)
import Data.LaborStage1 exposing (LaborStage1Record, laborStage1Record)
import Data.Patient exposing (PatientRecord, patientRecord)
import Data.Pregnancy exposing (PregnancyRecord, pregnancyRecord)
import Data.Table as DT exposing (Table(..))


type TableRecord
    = TableRecordPatient (List PatientRecord)
    | TableRecordPregnancy (List PregnancyRecord)
    | TableRecordLabor (List LaborRecord)
    | TableRecordLaborStage1 (List LaborStage1Record)


tableRecord : Table -> JD.Decoder TableRecord
tableRecord table =
    case table of
        Labor ->
            JD.map TableRecordLabor (JD.list laborRecord)

        LaborStage1 ->
            JD.map TableRecordLaborStage1 (JD.list laborStage1Record)

        Patient ->
            JD.map TableRecordPatient (JD.list patientRecord)

        Pregnancy ->
            JD.map TableRecordPregnancy (JD.list pregnancyRecord)

        _ ->
            JD.fail <| "Cannot yet handle table of " ++ (DT.tableToString table) ++ " in Data.TableRecord.tableRecord."
