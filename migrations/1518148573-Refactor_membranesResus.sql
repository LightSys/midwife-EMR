-- Migration: Refactor membranesResus
-- Created at: 2018-02-09 11:56:13
-- ====  UP  ====

BEGIN;

DROP TRIGGER baby_after_insert;
DROP TRIGGER baby_after_update;
DROP TRIGGER baby_after_delete;

ALTER TABLE baby ADD COLUMN bulb BOOLEAN NULL AFTER bcgDate;
ALTER TABLE baby ADD COLUMN machine BOOLEAN NULL AFTER bulb;
ALTER TABLE baby ADD COLUMN freeFlowO2 BOOLEAN NULL AFTER machine;
ALTER TABLE baby ADD COLUMN chestCompressions BOOLEAN NULL AFTER freeFlowO2;
ALTER TABLE baby ADD COLUMN ppv BOOLEAN NULL AFTER chestCompressions;

ALTER TABLE babyLog ADD COLUMN bulb BOOLEAN NULL AFTER bcgDate;
ALTER TABLE babyLog ADD COLUMN machine BOOLEAN NULL AFTER bulb;
ALTER TABLE babyLog ADD COLUMN freeFlowO2 BOOLEAN NULL AFTER machine;
ALTER TABLE babyLog ADD COLUMN chestCompressions BOOLEAN NULL AFTER freeFlowO2;
ALTER TABLE babyLog ADD COLUMN ppv BOOLEAN NULL AFTER chestCompressions;

-- ---------------------------------------------------------------
-- Trigger: baby_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS baby_after_insert;
CREATE TRIGGER baby_after_insert AFTER INSERT ON baby
FOR EACH ROW
BEGIN
  INSERT INTO babyLog
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, nbsDate, nbsResult, bcgDate, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthNbr, NEW.lastname, NEW.firstname, NEW.middlename, NEW.sex, NEW.birthWeight, NEW.bFedEstablished, NEW.nbsDate, NEW.nbsResult, NEW.bcgDate, NEW.bulb, NEW.machine, NEW.freeFlowO2, NEW.chestCompressions, NEW.ppv, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
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
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, nbsDate, nbsResult, bcgDate, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthNbr, NEW.lastname, NEW.firstname, NEW.middlename, NEW.sex, NEW.birthWeight, NEW.bFedEstablished, NEW.nbsDate, NEW.nbsResult, NEW.bcgDate, NEW.bulb, NEW.machine, NEW.freeFlowO2, NEW.chestCompressions, NEW.ppv, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
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
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, nbsDate, nbsResult, bcgDate, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.birthNbr, OLD.lastname, OLD.firstname, OLD.middlename, OLD.sex, OLD.birthWeight, OLD.bFedEstablished, OLD.nbsDate, OLD.nbsResult, OLD.bcgDate, OLD.bulb, OLD.machine, OLD.freeFlowO2, OLD.chestCompressions, OLD.ppv, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;

CREATE TABLE IF NOT EXISTS `membrane` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ruptureDatetime DATETIME NULL,
  rupture ENUM('AROM', 'SROM', 'Other') NULL,
  ruptureComment VARCHAR(300) NULL,
  amniotic ENUM('Clear', 'Lt Stain', 'Mod Stain', 'Thick Stain', 'Other') NULL,
  amnioticComment VARCHAR(300) NULL,
  comments VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  labor_id INT NOT NULL,
  UNIQUE(labor_id),
  FOREIGN KEY (labor_id) REFERENCES labor (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE membraneLog LIKE membrane;
ALTER TABLE membraneLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE membraneLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE membraneLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE membraneLog DROP PRIMARY KEY;
ALTER TABLE membraneLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE membraneLog DROP KEY labor_id;

-- ---------------------------------------------------------------
-- Trigger: membrane_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS membrane_after_insert;
CREATE TRIGGER membrane_after_insert AFTER INSERT ON membrane
FOR EACH ROW
BEGIN
  INSERT INTO membraneLog
  (id, ruptureDatetime, rupture, ruptureComment, amniotic, amnioticComment, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.ruptureDatetime, NEW.rupture, NEW.ruptureComment, NEW.amniotic, NEW.amnioticComment, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: membrane_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS membrane_after_update;
CREATE TRIGGER membrane_after_update AFTER UPDATE ON membrane
FOR EACH ROW
BEGIN
  INSERT INTO membraneLog
  (id, ruptureDatetime, rupture, ruptureComment, amniotic, amnioticComment, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.ruptureDatetime, NEW.rupture, NEW.ruptureComment, NEW.amniotic, NEW.amnioticComment, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: membrane_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS membrane_after_delete;
CREATE TRIGGER membrane_after_delete AFTER DELETE ON membrane
FOR EACH ROW
BEGIN
  INSERT INTO membraneLog
  (id, ruptureDatetime, rupture, ruptureComment, amniotic, amnioticComment, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.ruptureDatetime, OLD.rupture, OLD.ruptureComment, OLD.amniotic, OLD.amnioticComment, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;

DROP TABLE membranesResusLog;
DROP TABLE membranesResus;

COMMIT;

-- ==== DOWN ====

BEGIN;

DROP TABLE membraneLog;
DROP TABLE membrane;

DROP TRIGGER baby_after_insert;
DROP TRIGGER baby_after_update;
DROP TRIGGER baby_after_delete;

ALTER TABLE baby DROP COLUMN ppv;
ALTER TABLE baby DROP COLUMN chestCompressions;
ALTER TABLE baby DROP COLUMN freeFlowO2;
ALTER TABLE baby DROP COLUMN machine;
ALTER TABLE baby DROP COLUMN bulb;

ALTER TABLE babyLog DROP COLUMN ppv;
ALTER TABLE babyLog DROP COLUMN chestCompressions;
ALTER TABLE babyLog DROP COLUMN freeFlowO2;
ALTER TABLE babyLog DROP COLUMN machine;
ALTER TABLE babyLog DROP COLUMN bulb;

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

CREATE TABLE IF NOT EXISTS `membranesResus` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ruptureDatetime DATETIME NULL,
  rupture ENUM('AROM', 'SROM', 'Other') NULL,
  ruptureComment VARCHAR(300) NULL,
  amniotic ENUM('Clear', 'Lt Stain', 'Mod Stain', 'Thick Stain', 'Other') NULL,
  amnioticComment VARCHAR(300) NULL,
  bulb BOOLEAN NULL,
  machine BOOLEAN NULL,
  freeFlowO2 BOOLEAN NULL,
  chestCompressions BOOLEAN NULL,
  ppv BOOLEAN NULL,
  comments VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  baby_id INT NOT NULL,
  UNIQUE(baby_id),
  FOREIGN KEY (baby_id) REFERENCES baby (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE membranesResusLog LIKE membranesResus;
ALTER TABLE membranesResusLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE membranesResusLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE membranesResusLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE membranesResusLog DROP PRIMARY KEY;
ALTER TABLE membranesResusLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE membranesResusLog DROP KEY baby_id;

-- ---------------------------------------------------------------
-- Trigger: membranesResus_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS membranesResus_after_insert;
CREATE TRIGGER membranesResus_after_insert AFTER INSERT ON membranesResus
FOR EACH ROW
BEGIN
  INSERT INTO membranesResusLog
  (id, ruptureDatetime, rupture, ruptureComment, amniotic, amnioticComment, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.ruptureDatetime, NEW.rupture, NEW.ruptureComment, NEW.amniotic, NEW.amnioticComment, NEW.bulb, NEW.machine, NEW.freeFlowO2, NEW.chestCompressions, NEW.ppv, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: membranesResus_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS membranesResus_after_update;
CREATE TRIGGER membranesResus_after_update AFTER UPDATE ON membranesResus
FOR EACH ROW
BEGIN
  INSERT INTO membranesResusLog
  (id, ruptureDatetime, rupture, ruptureComment, amniotic, amnioticComment, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.ruptureDatetime, NEW.rupture, NEW.ruptureComment, NEW.amniotic, NEW.amnioticComment, NEW.bulb, NEW.machine, NEW.freeFlowO2, NEW.chestCompressions, NEW.ppv, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: membranesResus_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS membranesResus_after_delete;
CREATE TRIGGER membranesResus_after_delete AFTER DELETE ON membranesResus
FOR EACH ROW
BEGIN
  INSERT INTO membranesResusLog
  (id, ruptureDatetime, rupture, ruptureComment, amniotic, amnioticComment, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.ruptureDatetime, OLD.rupture, OLD.ruptureComment, OLD.amniotic, OLD.amnioticComment, OLD.bulb, OLD.machine, OLD.freeFlowO2, OLD.chestCompressions, OLD.ppv, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;

COMMIT;
