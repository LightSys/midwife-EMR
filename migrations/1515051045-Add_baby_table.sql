-- Migration: Add baby table
-- Created at: 2018-01-04 15:30:45
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `baby` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  birthNbr INT NOT NULL,
  lastname VARCHAR(50) NULL,
  firstname VARCHAR(50) NULL,
  middlename VARCHAR(50) NULL,
  sex ENUM('M', 'F') NOT NULL,
  birthWeight INT NULL,
  bFedEstablished DATETIME NULL,
  nbsDate DATETIME NULL,
  nbsResult VARCHAR(50) NULL,
  bcgDate DATETIME NULL,
  comments VARCHAR(500) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  labor_id INT NOT NULL,
  UNIQUE(labor_id, birthNbr),
  FOREIGN KEY (labor_id) REFERENCES labor (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `apgar` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  minute INT NOT NULL,
  score INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  baby_id INT NOT NULL,
  UNIQUE(baby_id, minute),
  FOREIGN KEY (baby_id) REFERENCES baby (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE babyLog LIKE baby;
ALTER TABLE babyLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyLog DROP PRIMARY KEY;
ALTER TABLE babyLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE babyLog DROP KEY labor_id;

CREATE TABLE apgarLog LIKE apgar;
ALTER TABLE apgarLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE apgarLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE apgarLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE apgarLog DROP PRIMARY KEY;
ALTER TABLE apgarLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE apgarLog DROP KEY baby_id;


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

-- ---------------------------------------------------------------
-- Trigger: apgar_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS apgar_after_insert;
CREATE TRIGGER apgar_after_insert AFTER INSERT ON apgar
FOR EACH ROW
BEGIN
  INSERT INTO apgarLog
  (id, minute, score, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.minute, NEW.score, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: apgar_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS apgar_after_update;
CREATE TRIGGER apgar_after_update AFTER UPDATE ON apgar
FOR EACH ROW
BEGIN
  INSERT INTO apgarLog
  (id, minute, score, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.minute, NEW.score, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: apgar_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS apgar_after_delete;
CREATE TRIGGER apgar_after_delete AFTER DELETE ON apgar
FOR EACH ROW
BEGIN
  INSERT INTO apgarLog
  (id, minute, score, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.minute, OLD.score, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;

COMMIT;

-- ==== DOWN ====

BEGIN;

DROP TABLE apgarLog;
DROP TABLE apgar;
DROP TABLE babyLog;
DROP TABLE baby;

COMMIT;
