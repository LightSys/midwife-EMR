-- Migration: Discharge
-- Created at: 2018-02-27 10:14:29
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `discharge` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  dateTime DATETIME NULL,
  motherSystolic INT NULL,
  motherDiastolic INT NULL,
  motherTemp Float NULL,
  motherCR INT NULL,
  babyRR INT NULL,
  babyTemp Float NULL,
  babyCR INT NULL,
  ppInstructionsSchedule BOOLEAN NULL DEFAULT 0,
  birthCertWorksheet BOOLEAN NULL DEFAULT 0,
  birthRecorded BOOLEAN NULL DEFAULT 0,
  chartsComplete BOOLEAN NULL DEFAULT 0,
  logsComplete BOOLEAN NULL DEFAULT 0,
  billPaid BOOLEAN NULL DEFAULT 0,
  nbs ENUM('Waived', 'Scheduled') NULL,
  immunizationReferral BOOLEAN NULL DEFAULT 0,
  breastFeedingEstablished BOOLEAN NULL DEFAULT 0,
  newbornBath BOOLEAN NULL DEFAULT 0,
  fundusFirmBleedingCtld BOOLEAN NULL DEFAULT 0,
  motherAteDrank BOOLEAN NULL DEFAULT 0,
  motherUrinated BOOLEAN NULL DEFAULT 0,
  placentaGone BOOLEAN NULL DEFAULT 0,
  prayer BOOLEAN NULL DEFAULT 0,
  bible BOOLEAN NULL DEFAULT 0,
  initials VARCHAR(50) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  labor_id INT NOT NULL,
  UNIQUE (labor_id),
  FOREIGN KEY (labor_id) REFERENCES labor (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE dischargeLog LIKE discharge;
ALTER TABLE dischargeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE dischargeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE dischargeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE dischargeLog DROP PRIMARY KEY;
ALTER TABLE dischargeLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE dischargeLog DROP KEY labor_id;

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

-- ==== DOWN ====

BEGIN;

DROP TABLE dischargeLog;
DROP TABLE discharge;

COMMIT;
