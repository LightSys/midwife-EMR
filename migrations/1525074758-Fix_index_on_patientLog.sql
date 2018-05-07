-- Migration: Fix index on patientLog
-- Created at: 2018-04-30 15:52:38
-- ====  UP  ====

BEGIN;

-- Drop a patientLog index if it exists. This is so that shmig does not
-- record this as an error if the index does not exist.
-- Adapted from: https://dba.stackexchange.com/a/62997
SELECT IF(
  EXISTS(
    SELECT DISTINCT index_name FROM information_schema.statistics
    WHERE table_schema = (SELECT DATABASE())
    AND table_name = 'patientLog'
    AND index_name LIKE 'patient_dohid_idx'
  )
  , 'DROP INDEX `patient_dohid_idx` ON patientLog;'
  , 'SELECT ''Unnecessary ... Skipping'' AS ''Drop PatientLog Index'';'
) INTO @a;
PREPARE stmt1 FROM @a;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

COMMIT;

-- ==== DOWN ====

BEGIN;

-- Note: we do not put the index back because it should not be there
-- in the first place.

COMMIT;
