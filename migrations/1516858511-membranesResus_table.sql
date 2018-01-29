-- Migration: membranesResus table
-- Created at: 2018-01-25 13:35:11
-- ====  UP  ====

BEGIN;

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

-- ==== DOWN ====

BEGIN;

DROP TABLE membranesResusLog;
DROP TABLE membranesResus;

COMMIT;
