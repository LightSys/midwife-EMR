-- Migration: Removed early labor features
-- Created at: 2018-03-20 14:33:39
-- ====  UP  ====

BEGIN;

SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `laborNew` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  admittanceDate DATETIME NOT NULL,
  startLaborDate DATETIME NOT NULL,
  dischargeDate DATETIME NULL,
  pos VARCHAR(10) NULL,
  fh INT NULL,
  fht VARCHAR(50) NULL,
  systolic INT NULL,
  diastolic INT NULL,
  cr INT NULL,
  temp DECIMAL(4,1) NULL,
  comments VARCHAR(300),
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  UNIQUE(pregnancy_id),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

DELETE FROM laborNew;

INSERT INTO laborNew
  (id, admittanceDate, startLaborDate, dischargeDate, pos, fh, fht, systolic,
   diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id)
  SELECT id, admittanceDate, startLaborDate, dischargeDate, pos, fh, fht, systolic,
  diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id
  FROM labor WHERE earlyLabor <> 1;

DROP TABLE labor;

ALTER TABLE laborNew RENAME AS labor;

-- Since we do not have any sites in production using this code,
-- we are not attempting to preserve the log.
DROP TABLE laborLog;

CREATE TABLE laborLog LIKE labor;
ALTER TABLE laborLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE laborLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE laborLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE laborLog DROP PRIMARY KEY;
ALTER TABLE laborLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE laborLog DROP KEY pregnancy_id;

-- ---------------------------------------------------------------
-- Trigger: labor_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_insert;
CREATE TRIGGER labor_after_insert AFTER INSERT ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, dischargeDate, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.admittanceDate, NEW.startLaborDate, NEW.dischargeDate, NEW.pos, NEW.fh, NEW.fht, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temp, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labor_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_update;
CREATE TRIGGER labor_after_update AFTER UPDATE ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, dischargeDate, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.admittanceDate, NEW.startLaborDate, NEW.dischargeDate, NEW.pos, NEW.fh, NEW.fht, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temp, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labor_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_delete;
CREATE TRIGGER labor_after_delete AFTER DELETE ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, dischargeDate, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.admittanceDate, OLD.startLaborDate, OLD.dischargeDate, OLD.pos, OLD.fh, OLD.fht, OLD.systolic, OLD.diastolic, OLD.cr, OLD.temp, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;

SET foreign_key_checks = 1;

COMMIT;

-- ==== DOWN ====

BEGIN;

SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `laborNew` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  admittanceDate DATETIME NOT NULL,
  startLaborDate DATETIME NOT NULL,
  dischargeDate DATETIME NULL,
  earlyLabor TINYINT NOT NULL DEFAULT 0,
  pos VARCHAR(10) NULL,
  fh INT NULL,
  fht VARCHAR(50) NULL,
  systolic INT NULL,
  diastolic INT NULL,
  cr INT NULL,
  temp DECIMAL(4,1) NULL,
  comments VARCHAR(300),
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

DELETE FROM laborNew;

INSERT INTO laborNew
  (id, admittanceDate, startLaborDate, dischargeDate, pos, fh, fht, systolic,
  diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id)
  SELECT id, admittanceDate, startLaborDate, dischargeDate, pos, fh, fht, systolic,
  diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id
  FROM labor;

DROP TABLE labor;

ALTER TABLE laborNew RENAME AS labor;

DROP TABLE laborLog;

CREATE TABLE laborLog LIKE labor;
ALTER TABLE laborLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE laborLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE laborLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE laborLog DROP PRIMARY KEY;
ALTER TABLE laborLog ADD PRIMARY KEY (id, replacedAt);

-- ---------------------------------------------------------------
-- Trigger: labor_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_insert;
CREATE TRIGGER labor_after_insert AFTER INSERT ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, dischargeDate, earlyLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.admittanceDate, NEW.startLaborDate, NEW.dischargeDate, NEW.earlyLabor, NEW.pos, NEW.fh, NEW.fht, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temp, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labor_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_update;
CREATE TRIGGER labor_after_update AFTER UPDATE ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, dischargeDate, earlyLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.admittanceDate, NEW.startLaborDate, NEW.dischargeDate, NEW.earlyLabor, NEW.pos, NEW.fh, NEW.fht, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temp, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labor_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_delete;
CREATE TRIGGER labor_after_delete AFTER DELETE ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, dischargeDate, earlyLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.admittanceDate, OLD.startLaborDate, OLD.dischargeDate, OLD.earlyLabor, OLD.pos, OLD.fh, OLD.fht, OLD.systolic, OLD.diastolic, OLD.cr, OLD.temp, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;

SET foreign_key_checks = 1;

COMMIT;
