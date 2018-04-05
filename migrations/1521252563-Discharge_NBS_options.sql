-- Migration: Discharge NBS options
-- Created at: 2018-03-17 10:09:23
-- ====  UP  ====

BEGIN;

UPDATE discharge SET nbs = NULL WHERE nbs = 'Scheduled';
ALTER TABLE discharge MODIFY COLUMN nbs ENUM('Done', 'Waived') NULL;
ALTER TABLE dischargeLog MODIFY COLUMN nbs ENUM('Done', 'Waived') NULL;

COMMIT;

-- ==== DOWN ====

BEGIN;


UPDATE discharge SET nbs = NULL WHERE nbs = 'Done';
ALTER TABLE discharge MODIFY COLUMN nbs ENUM('Waived', 'Scheduled') NULL;
ALTER TABLE dischargeLog MODIFY COLUMN nbs ENUM('Waived', 'Scheduled') NULL;

COMMIT;
