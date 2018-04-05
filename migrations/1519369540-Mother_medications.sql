-- Migration: Mother medications
-- Created at: 2018-02-23 15:05:40
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `motherMedicationType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(100) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `motherMedication` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  motherMedicationType INT NOT NULL,
  medicationDate DATETIME NOT NULL,
  initials VARCHAR(50) NULL,
  comments VARCHAR(100) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  labor_id INT NOT NULL,
  UNIQUE (labor_id, motherMedicationType),
  FOREIGN KEY (labor_id) REFERENCES labor (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (motherMedicationType) REFERENCES motherMedicationType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);


CREATE TABLE motherMedicationTypeLog LIKE motherMedicationType;
ALTER TABLE motherMedicationTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE motherMedicationTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE motherMedicationTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE motherMedicationTypeLog DROP PRIMARY KEY;
ALTER TABLE motherMedicationTypeLog ADD PRIMARY KEY (id, replacedAt);

CREATE TABLE motherMedicationLog LIKE motherMedication;
ALTER TABLE motherMedicationLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE motherMedicationLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE motherMedicationLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE motherMedicationLog DROP PRIMARY KEY;
ALTER TABLE motherMedicationLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE motherMedicationLog DROP KEY labor_id;

-- ---------------------------------------------------------------
-- Trigger: motherMedication_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedication_after_insert;
CREATE TRIGGER motherMedication_after_insert AFTER INSERT ON motherMedication
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationLog
  (id, motherMedicationType, medicationDate, initials, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.motherMedicationType, NEW.medicationDate, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: motherMedication_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedication_after_update;
CREATE TRIGGER motherMedication_after_update AFTER UPDATE ON motherMedication
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationLog
  (id, motherMedicationType, medicationDate, initials, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.motherMedicationType, NEW.medicationDate, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: motherMedication_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedication_after_delete;
CREATE TRIGGER motherMedication_after_delete AFTER DELETE ON motherMedication
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationLog
  (id, motherMedicationType, medicationDate, initials, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.motherMedicationType, OLD.medicationDate, OLD.initials, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: motherMedicationType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedicationType_after_insert;
CREATE TRIGGER motherMedicationType_after_insert AFTER INSERT ON motherMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationTypeLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: motherMedicationType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedicationType_after_update;
CREATE TRIGGER motherMedicationType_after_update AFTER UPDATE ON motherMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationTypeLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: motherMedicationType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedicationType_after_delete;
CREATE TRIGGER motherMedicationType_after_delete AFTER DELETE ON motherMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationTypeLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

INSERT INTO motherMedicationType
  (name, description, updatedBy, updatedAt)
VALUES
  ('Vitamin A', 'Vitamin A', 1, NOW())
;

COMMIT;

-- ==== DOWN ====

BEGIN;

DROP TABLE motherMedicationLog;
DROP TABLE motherMedicationTypeLog;
DROP TABLE motherMedication;
DROP TABLE motherMedicationType;

COMMIT;
