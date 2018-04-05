-- Migration: ContinuedPP bFed field change
-- Created at: 2018-03-13 15:05:24
-- ====  UP  ====

BEGIN;

ALTER TABLE contPostpartumCheck MODIFY COLUMN babyBFed VARCHAR(200) NULL;
ALTER TABLE contPostpartumCheckLog MODIFY COLUMN babyBFed VARCHAR(200) NULL;

COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE contPostpartumCheck MODIFY COLUMN babyBFed BOOLEAN NULL;
ALTER TABLE contPostpartumCheckLog MODIFY COLUMN babyBFed BOOLEAN NULL;

COMMIT;
