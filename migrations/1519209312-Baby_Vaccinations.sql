-- Migration: Baby Vaccinations
-- Created at: 2018-02-21 18:35:12
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `babyVaccinationType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(100) NULL,
  useLocation BOOLEAN NOT NULL DEFAULT 0,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `babyVaccination` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  babyVaccinationType INT NOT NULL,
  vaccinationDate DATETIME NOT NULL,
  location VARCHAR(50) NULL,
  initials VARCHAR(50) NULL,
  comments VARCHAR(100) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  baby_id INT NOT NULL,
  UNIQUE (baby_id, babyVaccinationType),
  FOREIGN KEY (baby_id) REFERENCES baby (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (babyVaccinationType) REFERENCES babyVaccinationType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE babyVaccinationTypeLog LIKE babyVaccinationType;
ALTER TABLE babyVaccinationTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyVaccinationTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyVaccinationTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyVaccinationTypeLog DROP PRIMARY KEY;
ALTER TABLE babyVaccinationTypeLog ADD PRIMARY KEY (id, replacedAt);

CREATE TABLE babyVaccinationLog LIKE babyVaccination;
ALTER TABLE babyVaccinationLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyVaccinationLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyVaccinationLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyVaccinationLog DROP PRIMARY KEY;
ALTER TABLE babyVaccinationLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE babyVaccinationLog DROP KEY baby_id;

-- ---------------------------------------------------------------
-- Trigger: babyVaccination_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccination_after_insert;
CREATE TRIGGER babyVaccination_after_insert AFTER INSERT ON babyVaccination
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationLog
  (id, babyVaccinationType, vaccinationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyVaccinationType, NEW.vaccinationDate, NEW.location, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyVaccination_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccination_after_update;
CREATE TRIGGER babyVaccination_after_update AFTER UPDATE ON babyVaccination
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationLog
  (id, babyVaccinationType, vaccinationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyVaccinationType, NEW.vaccinationDate, NEW.location, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyVaccination_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccination_after_delete;
CREATE TRIGGER babyVaccination_after_delete AFTER DELETE ON babyVaccination
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationLog
  (id, babyVaccinationType, vaccinationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.babyVaccinationType, OLD.vaccinationDate, OLD.location, OLD.initials, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyVaccinationType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccinationType_after_insert;
CREATE TRIGGER babyVaccinationType_after_insert AFTER INSERT ON babyVaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.useLocation, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyVaccinationType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccinationType_after_update;
CREATE TRIGGER babyVaccinationType_after_update AFTER UPDATE ON babyVaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.useLocation, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyVaccinationType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccinationType_after_delete;
CREATE TRIGGER babyVaccinationType_after_delete AFTER DELETE ON babyVaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.useLocation, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

INSERT INTO babyVaccinationType
  (name, description, useLocation, updatedBy, updatedAt)
VALUES
  ('Hep B', 'Hep B', 1, 1, NOW()),
  ('BCG (Bacillus Calmette-Guerin)', 'BCG (Bacillus Calmette-Guerin)', 0, 1, NOW())
;


COMMIT;

-- ==== DOWN ====

BEGIN;

DROP TABLE babyVaccinationLog;
DROP TABLE babyVaccinationTypeLog;
DROP TABLE babyVaccination;
DROP TABLE babyVaccinationType;

COMMIT;
