-- Migration: Labor field rename
-- Created at: 2017-12-01 10:03:31
-- ====  UP  ====

BEGIN;

ALTER TABLE labor CHANGE endLaborDate dischargeDate DATETIME NULL;
ALTER TABLE laborLog CHANGE endLaborDate dischargeDate DATETIME NULL;

-- ---------------------------------------------------------------
-- Trigger: labor_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_insert;
CREATE TRIGGER labor_after_insert AFTER INSERT ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, dischargeDate, falseLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.admittanceDate, NEW.startLaborDate, NEW.dischargeDate, NEW.falseLabor, NEW.pos, NEW.fh, NEW.fht, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temp, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
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
  (id, admittanceDate, startLaborDate, dischargeDate, falseLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.admittanceDate, NEW.startLaborDate, NEW.dischargeDate, NEW.falseLabor, NEW.pos, NEW.fh, NEW.fht, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temp, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
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
  (id, admittanceDate, startLaborDate, dischargeDate, falseLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.admittanceDate, OLD.startLaborDate, OLD.dischargeDate, OLD.falseLabor, OLD.pos, OLD.fh, OLD.fht, OLD.systolic, OLD.diastolic, OLD.cr, OLD.temp, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;
COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE labor CHANGE dischargeDate endLaborDate DATETIME NULL;
ALTER TABLE laborLog CHANGE dischargeDate endLaborDate DATETIME NULL;

-- ---------------------------------------------------------------
-- Trigger: labor_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_insert;
CREATE TRIGGER labor_after_insert AFTER INSERT ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, endLaborDate, falseLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.admittanceDate, NEW.startLaborDate, NEW.endLaborDate, NEW.falseLabor, NEW.pos, NEW.fh, NEW.fht, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temp, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
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
  (id, admittanceDate, startLaborDate, endLaborDate, falseLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.admittanceDate, NEW.startLaborDate, NEW.endLaborDate, NEW.falseLabor, NEW.pos, NEW.fh, NEW.fht, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temp, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
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
  (id, admittanceDate, startLaborDate, endLaborDate, falseLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.admittanceDate, OLD.startLaborDate, OLD.endLaborDate, OLD.falseLabor, OLD.pos, OLD.fh, OLD.fht, OLD.systolic, OLD.diastolic, OLD.cr, OLD.temp, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;


COMMIT;
