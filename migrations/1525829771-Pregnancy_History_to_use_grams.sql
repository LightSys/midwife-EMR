-- Migration: Pregnancy History to use grams
-- Created at: 2018-05-09 09:36:11
-- ====  UP  ====

BEGIN;

-- Alter the table to allow room in the birthWeight field for the conversion.
ALTER TABLE pregnancyHistory
  MODIFY COLUMN birthWeight DECIMAL(6,2) NULL;

ALTER TABLE pregnancyHistoryLog
  MODIFY COLUMN birthWeight DECIMAL(6,2) NULL;

-- Clear any birthWeights in the pregnancyHistory table that have a value of 99.99.
-- This is indicative of the midwife entering the weight in grams instead of kg and
-- the system storing the value at the maximum it was able to in a DECIMAL(4,2)
-- field definition. But this is completely wrong and we just need to clear this
-- field value since the actual value cannot be recovered.
--
-- But for field values that are not abnormal, convert to grams.
UPDATE pregnancyHistoryLog
  SET birthWeight = IF(birthWeight = 99.99, 0.0, birthWeight * 1000);

UPDATE pregnancyHistory
  SET birthWeight = IF(birthWeight = 99.99, 0.0, birthWeight * 1000);

-- Alter the table to the final field definition of an INT.
ALTER TABLE pregnancyHistory
  MODIFY COLUMN birthWeight INT NULL;

ALTER TABLE pregnancyHistoryLog
  MODIFY COLUMN birthWeight INT NULL;

COMMIT;

-- ==== DOWN ====

BEGIN;

-- Alter the field temporarily to allow conversion back to decimal.
ALTER TABLE pregnancyHistory
  MODIFY COLUMN birthWeight DECIMAL(6,2) NULL;

ALTER TABLE pregnancyHistoryLog
  MODIFY COLUMN birthWeight DECIMAL(6,2) NULL;

-- Convert from INT in grams to DECIMAL in kg.
UPDATE pregnancyHistory
  SET birthWeight = birthWeight / 1000
  WHERE birthWeight IS NOT NULL;

UPDATE pregnancyHistoryLog
  SET birthWeight = birthWeight / 1000
  WHERE birthWeight IS NOT NULL;

-- Alter the field to the proper size.
ALTER TABLE pregnancyHistory
  MODIFY COLUMN birthWeight DECIMAL(4,2) NULL;

ALTER TABLE pregnancyHistoryLog
  MODIFY COLUMN birthWeight DECIMAL(4,2) NULL;

COMMIT;
