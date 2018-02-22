-- Migration: Baby Labs
-- Created at: 2018-02-22 17:31:24
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `babyLabType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(200) NULL,
  fld1Name VARCHAR(50) NOT NULL,
  fld1Type ENUM('String', 'Integer', 'Float', 'Bool') NOT NULL DEFAULT 'String',
  fld2Name VARCHAR(50) NULL,
  fld2Type ENUM('String', 'Integer', 'Float', 'Bool') NULL,
  fld3Name VARCHAR(50) NULL,
  fld3Type ENUM('String', 'Integer', 'Float', 'Bool') NULL,
  fld4Name VARCHAR(50) NULL,
  fld4Type ENUM('String', 'Integer', 'Float', 'Bool') NULL,
  active BOOLEAN NOT NULL DEFAULT 1,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `babyLab` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  babyLabType INT NOT NULL,
  dateTime DATETIME NOT NULL,
  fld1Value VARCHAR(300) NULL,
  fld2Value VARCHAR(300) NULL,
  fld3Value VARCHAR(300) NULL,
  fld4Value VARCHAR(300) NULL,
  initials VARCHAR(50) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  baby_id INT NOT NULL,
  FOREIGN KEY (baby_id) REFERENCES baby (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (babyLabType) REFERENCES babyLabType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE babyLabTypeLog LIKE babyLabType;
ALTER TABLE babyLabTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyLabTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyLabTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyLabTypeLog DROP PRIMARY KEY;
ALTER TABLE babyLabTypeLog ADD PRIMARY KEY (id, replacedAt);

CREATE TABLE babyLabLog LIKE babyLab;
ALTER TABLE babyLabLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyLabLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyLabLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyLabLog DROP PRIMARY KEY;
ALTER TABLE babyLabLog ADD PRIMARY KEY (id, replacedAt);

-- ---------------------------------------------------------------
-- Trigger: babyLab_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLab_after_insert;
CREATE TRIGGER babyLab_after_insert AFTER INSERT ON babyLab
FOR EACH ROW
BEGIN
  INSERT INTO babyLabLog
  (id, babyLabType, dateTime, fld1Value, fld2Value, fld3Value, fld4Value, initials, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyLabType, NEW.dateTime, NEW.fld1Value, NEW.fld2Value, NEW.fld3Value, NEW.fld4Value, NEW.initials, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyLab_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLab_after_update;
CREATE TRIGGER babyLab_after_update AFTER UPDATE ON babyLab
FOR EACH ROW
BEGIN
  INSERT INTO babyLabLog
  (id, babyLabType, dateTime, fld1Value, fld2Value, fld3Value, fld4Value, initials, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyLabType, NEW.dateTime, NEW.fld1Value, NEW.fld2Value, NEW.fld3Value, NEW.fld4Value, NEW.initials, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyLab_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLab_after_delete;
CREATE TRIGGER babyLab_after_delete AFTER DELETE ON babyLab
FOR EACH ROW
BEGIN
  INSERT INTO babyLabLog
  (id, babyLabType, dateTime, fld1Value, fld2Value, fld3Value, fld4Value, initials, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.babyLabType, OLD.dateTime, OLD.fld1Value, OLD.fld2Value, OLD.fld3Value, OLD.fld4Value, OLD.initials, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyLabType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLabType_after_insert;
CREATE TRIGGER babyLabType_after_insert AFTER INSERT ON babyLabType
FOR EACH ROW
BEGIN
  INSERT INTO babyLabTypeLog
  (id, name, description, fld1Name, fld1Type, fld2Name, fld2Type, fld3Name, fld3Type, fld4Name, fld4Type, active, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.fld1Name, NEW.fld1Type, NEW.fld2Name, NEW.fld2Type, NEW.fld3Name, NEW.fld3Type, NEW.fld4Name, NEW.fld4Type, NEW.active, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyLabType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLabType_after_update;
CREATE TRIGGER babyLabType_after_update AFTER UPDATE ON babyLabType
FOR EACH ROW
BEGIN
  INSERT INTO babyLabTypeLog
  (id, name, description, fld1Name, fld1Type, fld2Name, fld2Type, fld3Name, fld3Type, fld4Name, fld4Type, active, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.fld1Name, NEW.fld1Type, NEW.fld2Name, NEW.fld2Type, NEW.fld3Name, NEW.fld3Type, NEW.fld4Name, NEW.fld4Type, NEW.active, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: babyLabType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLabType_after_delete;
CREATE TRIGGER babyLabType_after_delete AFTER DELETE ON babyLabType
FOR EACH ROW
BEGIN
  INSERT INTO babyLabTypeLog
  (id, name, description, fld1Name, fld1Type, fld2Name, fld2Type, fld3Name, fld3Type, fld4Name, fld4Type, active, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.fld1Name, OLD.fld1Type, OLD.fld2Name, OLD.fld2Type, OLD.fld3Name, OLD.fld3Type, OLD.fld4Name, OLD.fld4Type, OLD.active, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

INSERT INTO babyLabType
  (name, description, fld1Name, fld1Type, fld2Name, fld2Type,
  fld3Name, fld3Type, fld4Name, fld4Type, active, updatedBy, updatedAt)
VALUES
  ('Newborn Screening', 'Newborn Screening', 'Filter Card #', 'Integer',
  'Result', 'String', NULL, NULL, NULL, NULL, 1, 1, NOW())
;

COMMIT;

-- ==== DOWN ====

BEGIN;

DROP TABLE babyLabLog;
DROP TABLE babyLabTypeLog;
DROP TABLE babyLab;
DROP TABLE babyLabType;

COMMIT;
