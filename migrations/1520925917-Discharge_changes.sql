-- Migration: Discharge changes
-- Created at: 2018-03-13 15:25:17
-- ====  UP  ====

BEGIN;

ALTER TABLE discharge ADD COLUMN transferBaby BOOLEAN NULL DEFAULT 0 AFTER bible;
ALTER TABLE discharge ADD COLUMN transferMother BOOLEAN NULL DEFAULT 0 AFTER transferBaby;
ALTER TABLE discharge ADD COLUMN transferComment VARCHAR(500) NULL AFTER transferMother;

ALTER TABLE dischargeLog ADD COLUMN transferBaby BOOLEAN NULL DEFAULT 0 AFTER bible;
ALTER TABLE dischargeLog ADD COLUMN transferMother BOOLEAN NULL DEFAULT 0 AFTER transferBaby;
ALTER TABLE dischargeLog ADD COLUMN transferComment VARCHAR(500) NULL AFTER transferMother;

-- ---------------------------------------------------------------
-- Trigger: discharge_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS discharge_after_insert;
CREATE TRIGGER discharge_after_insert AFTER INSERT ON discharge
FOR EACH ROW
BEGIN
  INSERT INTO dischargeLog
  (id, dateTime, motherSystolic, motherDiastolic, motherTemp, motherCR, babyRR, babyTemp, babyCR, ppInstructionsSchedule, birthCertWorksheet, birthRecorded, chartsComplete, logsComplete, billPaid, nbs, immunizationReferral, breastFeedingEstablished, newbornBath, fundusFirmBleedingCtld, motherAteDrank, motherUrinated, placentaGone, prayer, bible, transferBaby, transferMother, transferComment, initials, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.dateTime, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherTemp, NEW.motherCR, NEW.babyRR, NEW.babyTemp, NEW.babyCR, NEW.ppInstructionsSchedule, NEW.birthCertWorksheet, NEW.birthRecorded, NEW.chartsComplete, NEW.logsComplete, NEW.billPaid, NEW.nbs, NEW.immunizationReferral, NEW.breastFeedingEstablished, NEW.newbornBath, NEW.fundusFirmBleedingCtld, NEW.motherAteDrank, NEW.motherUrinated, NEW.placentaGone, NEW.prayer, NEW.bible, NEW.transferBaby, NEW.transferMother, NEW.transferComment, NEW.initials, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: discharge_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS discharge_after_update;
CREATE TRIGGER discharge_after_update AFTER UPDATE ON discharge
FOR EACH ROW
BEGIN
  INSERT INTO dischargeLog
  (id, dateTime, motherSystolic, motherDiastolic, motherTemp, motherCR, babyRR, babyTemp, babyCR, ppInstructionsSchedule, birthCertWorksheet, birthRecorded, chartsComplete, logsComplete, billPaid, nbs, immunizationReferral, breastFeedingEstablished, newbornBath, fundusFirmBleedingCtld, motherAteDrank, motherUrinated, placentaGone, prayer, bible, transferBaby, transferMother, transferComment, initials, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.dateTime, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherTemp, NEW.motherCR, NEW.babyRR, NEW.babyTemp, NEW.babyCR, NEW.ppInstructionsSchedule, NEW.birthCertWorksheet, NEW.birthRecorded, NEW.chartsComplete, NEW.logsComplete, NEW.billPaid, NEW.nbs, NEW.immunizationReferral, NEW.breastFeedingEstablished, NEW.newbornBath, NEW.fundusFirmBleedingCtld, NEW.motherAteDrank, NEW.motherUrinated, NEW.placentaGone, NEW.prayer, NEW.bible, NEW.transferBaby, NEW.transferMother, NEW.transferComment, NEW.initials, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: discharge_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS discharge_after_delete;
CREATE TRIGGER discharge_after_delete AFTER DELETE ON discharge
FOR EACH ROW
BEGIN
  INSERT INTO dischargeLog
  (id, dateTime, motherSystolic, motherDiastolic, motherTemp, motherCR, babyRR, babyTemp, babyCR, ppInstructionsSchedule, birthCertWorksheet, birthRecorded, chartsComplete, logsComplete, billPaid, nbs, immunizationReferral, breastFeedingEstablished, newbornBath, fundusFirmBleedingCtld, motherAteDrank, motherUrinated, placentaGone, prayer, bible, transferBaby, transferMother, transferComment, initials, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.dateTime, OLD.motherSystolic, OLD.motherDiastolic, OLD.motherTemp, OLD.motherCR, OLD.babyRR, OLD.babyTemp, OLD.babyCR, OLD.ppInstructionsSchedule, OLD.birthCertWorksheet, OLD.birthRecorded, OLD.chartsComplete, OLD.logsComplete, OLD.billPaid, OLD.nbs, OLD.immunizationReferral, OLD.breastFeedingEstablished, OLD.newbornBath, OLD.fundusFirmBleedingCtld, OLD.motherAteDrank, OLD.motherUrinated, OLD.placentaGone, OLD.prayer, OLD.bible, OLD.transferBaby, OLD.transferMother, OLD.transferComment, OLD.initials, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;


COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE discharge DROP COLUMN transferBaby;
ALTER TABLE discharge DROP COLUMN transferMother;
ALTER TABLE discharge DROP COLUMN transferComment;

ALTER TABLE dischargeLog DROP COLUMN transferBaby;
ALTER TABLE dischargeLog DROP COLUMN transferMother;
ALTER TABLE dischargeLog DROP COLUMN transferComment;

-- ---------------------------------------------------------------
-- Trigger: discharge_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS discharge_after_insert;
CREATE TRIGGER discharge_after_insert AFTER INSERT ON discharge
FOR EACH ROW
BEGIN
  INSERT INTO dischargeLog
  (id, dateTime, motherSystolic, motherDiastolic, motherTemp, motherCR, babyRR, babyTemp, babyCR, ppInstructionsSchedule, birthCertWorksheet, birthRecorded, chartsComplete, logsComplete, billPaid, nbs, immunizationReferral, breastFeedingEstablished, newbornBath, fundusFirmBleedingCtld, motherAteDrank, motherUrinated, placentaGone, prayer, bible, initials, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.dateTime, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherTemp, NEW.motherCR, NEW.babyRR, NEW.babyTemp, NEW.babyCR, NEW.ppInstructionsSchedule, NEW.birthCertWorksheet, NEW.birthRecorded, NEW.chartsComplete, NEW.logsComplete, NEW.billPaid, NEW.nbs, NEW.immunizationReferral, NEW.breastFeedingEstablished, NEW.newbornBath, NEW.fundusFirmBleedingCtld, NEW.motherAteDrank, NEW.motherUrinated, NEW.placentaGone, NEW.prayer, NEW.bible, NEW.initials, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: discharge_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS discharge_after_update;
CREATE TRIGGER discharge_after_update AFTER UPDATE ON discharge
FOR EACH ROW
BEGIN
  INSERT INTO dischargeLog
  (id, dateTime, motherSystolic, motherDiastolic, motherTemp, motherCR, babyRR, babyTemp, babyCR, ppInstructionsSchedule, birthCertWorksheet, birthRecorded, chartsComplete, logsComplete, billPaid, nbs, immunizationReferral, breastFeedingEstablished, newbornBath, fundusFirmBleedingCtld, motherAteDrank, motherUrinated, placentaGone, prayer, bible, initials, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.dateTime, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherTemp, NEW.motherCR, NEW.babyRR, NEW.babyTemp, NEW.babyCR, NEW.ppInstructionsSchedule, NEW.birthCertWorksheet, NEW.birthRecorded, NEW.chartsComplete, NEW.logsComplete, NEW.billPaid, NEW.nbs, NEW.immunizationReferral, NEW.breastFeedingEstablished, NEW.newbornBath, NEW.fundusFirmBleedingCtld, NEW.motherAteDrank, NEW.motherUrinated, NEW.placentaGone, NEW.prayer, NEW.bible, NEW.initials, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: discharge_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS discharge_after_delete;
CREATE TRIGGER discharge_after_delete AFTER DELETE ON discharge
FOR EACH ROW
BEGIN
  INSERT INTO dischargeLog
  (id, dateTime, motherSystolic, motherDiastolic, motherTemp, motherCR, babyRR, babyTemp, babyCR, ppInstructionsSchedule, birthCertWorksheet, birthRecorded, chartsComplete, logsComplete, billPaid, nbs, immunizationReferral, breastFeedingEstablished, newbornBath, fundusFirmBleedingCtld, motherAteDrank, motherUrinated, placentaGone, prayer, bible, initials, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.dateTime, OLD.motherSystolic, OLD.motherDiastolic, OLD.motherTemp, OLD.motherCR, OLD.babyRR, OLD.babyTemp, OLD.babyCR, OLD.ppInstructionsSchedule, OLD.birthCertWorksheet, OLD.birthRecorded, OLD.chartsComplete, OLD.logsComplete, OLD.billPaid, OLD.nbs, OLD.immunizationReferral, OLD.breastFeedingEstablished, OLD.newbornBath, OLD.fundusFirmBleedingCtld, OLD.motherAteDrank, OLD.motherUrinated, OLD.placentaGone, OLD.prayer, OLD.bible, OLD.initials, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;

COMMIT;
