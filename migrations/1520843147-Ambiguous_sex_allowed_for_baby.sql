-- Migration: Ambiguous sex allowed for baby
-- Created at: 2018-03-12 16:25:47
-- ====  UP  ====

BEGIN;

ALTER TABLE baby modify COLUMN sex ENUM('M', 'F', 'A') NOT NULL;
ALTER TABLE babyLog modify COLUMN sex ENUM('M', 'F', 'A') NOT NULL;

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

ALTER TABLE babyLog modify COLUMN sex ENUM('M', 'F') NOT NULL;
ALTER TABLE baby modify COLUMN sex ENUM('M', 'F') NOT NULL;

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
