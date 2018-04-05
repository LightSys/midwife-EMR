-- Migration: Alter baby table.
-- Created at: 2018-02-22 18:07:49
-- ====  UP  ====

BEGIN;

ALTER TABLE babyLog DROP COLUMN nbsDate;
ALTER TABLE babyLog DROP COLUMN nbsResult;
ALTER TABLE babyLog DROP COLUMN bcgDate;

ALTER TABLE baby DROP COLUMN nbsDate;
ALTER TABLE baby DROP COLUMN nbsResult;
ALTER TABLE baby DROP COLUMN bcgDate;

-- ---------------------------------------------------------------
-- Trigger: baby_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS baby_after_insert;
CREATE TRIGGER baby_after_insert AFTER INSERT ON baby
FOR EACH ROW
BEGIN
  INSERT INTO babyLog
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthNbr, NEW.lastname, NEW.firstname, NEW.middlename, NEW.sex, NEW.birthWeight, NEW.bFedEstablished, NEW.bulb, NEW.machine, NEW.freeFlowO2, NEW.chestCompressions, NEW.ppv, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: baby_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS baby_after_update;
CREATE TRIGGER baby_after_update AFTER UPDATE ON baby
FOR EACH ROW
BEGIN
  INSERT INTO babyLog
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthNbr, NEW.lastname, NEW.firstname, NEW.middlename, NEW.sex, NEW.birthWeight, NEW.bFedEstablished, NEW.bulb, NEW.machine, NEW.freeFlowO2, NEW.chestCompressions, NEW.ppv, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: baby_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS baby_after_delete;
CREATE TRIGGER baby_after_delete AFTER DELETE ON baby
FOR EACH ROW
BEGIN
  INSERT INTO babyLog
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.birthNbr, OLD.lastname, OLD.firstname, OLD.middlename, OLD.sex, OLD.birthWeight, OLD.bFedEstablished, OLD.bulb, OLD.machine, OLD.freeFlowO2, OLD.chestCompressions, OLD.ppv, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;

COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE baby ADD COLUMN nbsDate DATETIME NULL;
ALTER TABLE baby ADD COLUMN nbsResult VARCHAR(50) NULL;
ALTER TABLE baby ADD COLUMN bcgDate DATETIME NULL;
ALTER TABLE baby MODIFY COLUMN nbsDate DATETIME NULL After bFedEstablished;
ALTER TABLE baby MODIFY COLUMN nbsResult VARCHAR(50) NULL After nbsDate;
ALTER TABLE baby MODIFY COLUMN bcgDate DATETIME NULL After nbsResult;

ALTER TABLE babyLog ADD COLUMN nbsDate DATETIME NULL;
ALTER TABLE babyLog ADD COLUMN nbsResult VARCHAR(50) NULL;
ALTER TABLE babyLog ADD COLUMN bcgDate DATETIME NULL;
ALTER TABLE babyLog MODIFY COLUMN nbsDate DATETIME NULL After bFedEstablished;
ALTER TABLE babyLog MODIFY COLUMN nbsResult VARCHAR(50) NULL After nbsDate;
ALTER TABLE babyLog MODIFY COLUMN bcgDate DATETIME NULL After nbsResult;

-- ---------------------------------------------------------------
-- Trigger: baby_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS baby_after_insert;
CREATE TRIGGER baby_after_insert AFTER INSERT ON baby
FOR EACH ROW
BEGIN
  INSERT INTO babyLog
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, nbsDate, nbsResult, bcgDate, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthNbr, NEW.lastname, NEW.firstname, NEW.middlename, NEW.sex, NEW.birthWeight, NEW.bFedEstablished, NEW.nbsDate, NEW.nbsResult, NEW.bcgDate, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: baby_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS baby_after_update;
CREATE TRIGGER baby_after_update AFTER UPDATE ON baby
FOR EACH ROW
BEGIN
  INSERT INTO babyLog
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, nbsDate, nbsResult, bcgDate, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthNbr, NEW.lastname, NEW.firstname, NEW.middlename, NEW.sex, NEW.birthWeight, NEW.bFedEstablished, NEW.nbsDate, NEW.nbsResult, NEW.bcgDate, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: baby_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS baby_after_delete;
CREATE TRIGGER baby_after_delete AFTER DELETE ON baby
FOR EACH ROW
BEGIN
  INSERT INTO babyLog
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, nbsDate, nbsResult, bcgDate, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.birthNbr, OLD.lastname, OLD.firstname, OLD.middlename, OLD.sex, OLD.birthWeight, OLD.bFedEstablished, OLD.nbsDate, OLD.nbsResult, OLD.bcgDate, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;

COMMIT;
