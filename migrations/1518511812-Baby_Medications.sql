-- Migration: Baby Medications
-- Created at: 2018-02-13 16:50:12
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `babyMedicationType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(100) NULL,
  useLocation BOOLEAN NOT NULL DEFAULT 0,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `babyMedication` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  babyMedicationType INT NOT NULL,
  medicationDate DATETIME NOT NULL,
  location VARCHAR(50) NULL,
  initials VARCHAR(50) NULL,
  comments VARCHAR(100) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  baby_id INT NOT NULL,
  UNIQUE (baby_id, babyMedicationType),
  FOREIGN KEY (baby_id) REFERENCES baby (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (babyMedicationType) REFERENCES babyMedicationType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE babyMedicationTypeLog LIKE babyMedicationType;
ALTER TABLE babyMedicationTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyMedicationTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyMedicationTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyMedicationTypeLog DROP PRIMARY KEY;
ALTER TABLE babyMedicationTypeLog ADD PRIMARY KEY (id, replacedAt);

CREATE TABLE babyMedicationLog LIKE babyMedication;
ALTER TABLE babyMedicationLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyMedicationLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyMedicationLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyMedicationLog DROP PRIMARY KEY;
ALTER TABLE babyMedicationLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE babyMedicationLog DROP KEY baby_id;

-- ---------------------------------------------------------------
-- Trigger: babyMedication_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedication_after_insert;
CREATE TRIGGER babyMedication_after_insert AFTER INSERT ON babyMedication
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationLog
  (id, babyMedicationType, medicationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyMedicationType, NEW.medicationDate, NEW.location, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyMedication_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedication_after_update;
CREATE TRIGGER babyMedication_after_update AFTER UPDATE ON babyMedication
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationLog
  (id, babyMedicationType, medicationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyMedicationType, NEW.medicationDate, NEW.location, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyMedication_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedication_after_delete;
CREATE TRIGGER babyMedication_after_delete AFTER DELETE ON babyMedication
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationLog
  (id, babyMedicationType, medicationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.babyMedicationType, OLD.medicationDate, OLD.location, OLD.initials, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyMedicationType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedicationType_after_insert;
CREATE TRIGGER babyMedicationType_after_insert AFTER INSERT ON babyMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.useLocation, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyMedicationType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedicationType_after_update;
CREATE TRIGGER babyMedicationType_after_update AFTER UPDATE ON babyMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.useLocation, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyMedicationType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedicationType_after_delete;
CREATE TRIGGER babyMedicationType_after_delete AFTER DELETE ON babyMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.useLocation, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

INSERT INTO babyMedicationType
  (name, description, useLocation, updatedBy, updatedAt)
VALUES
  ('Vitamin K', 'Vitamin K', 1, 1, NOW()),
  ('Eye Ointment', 'Eye Ointment', 0, 1, NOW())
;

COMMIT;

-- ==== DOWN ====

BEGIN;

DROP TABLE babyMedicationLog;
DROP TABLE babyMedicationTypeLog;
DROP TABLE babyMedication;
DROP TABLE babyMedicationType;

COMMIT;
