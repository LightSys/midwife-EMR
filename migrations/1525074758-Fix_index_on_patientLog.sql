-- Migration: Fix index on patientLog
-- Created at: 2018-04-30 15:52:38
-- ====  UP  ====

BEGIN;

DROP INDEX `patient_dohid_idx` ON patientLog;

COMMIT;

-- ==== DOWN ====

BEGIN;

-- Note: we do not put the index back because it should not be there
-- in the first place.

COMMIT;
