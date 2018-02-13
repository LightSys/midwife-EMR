-- Migration: Continued postpartum motherbaby
-- Created at: 2018-02-12 06:56:55
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `contPostpartumCheck` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  checkDatetime DATETIME NOT NULL,
  motherSystolic INT NULL,
  motherDiastolic INT NULL,
  motherCR INT NULL,
  motherTemp DECIMAL(4,1) NULL,
  motherFundus VARCHAR(200) NULL,
  motherEBL INT NULL,
  babyBFed BOOLEAN NULL,
  babyTemp DECIMAL(4,1) NULL,
  babyRR INT NULL,
  babyCR INT NULL,
  comments VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  labor_id INT NOT NULL,
  FOREIGN KEY (labor_id) REFERENCES labor (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE contPostpartumCheckLog LIKE contPostpartumCheck;
ALTER TABLE contPostpartumCheckLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE contPostpartumCheckLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE contPostpartumCheckLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE contPostpartumCheckLog DROP PRIMARY KEY;
ALTER TABLE contPostpartumCheckLog ADD PRIMARY KEY (id, replacedAt);

-- ---------------------------------------------------------------
-- Trigger: contPostpartumCheck_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS contPostpartumCheck_after_insert;
CREATE TRIGGER contPostpartumCheck_after_insert AFTER INSERT ON contPostpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO contPostpartumCheckLog
  (id, checkDatetime, motherSystolic, motherDiastolic, motherCR, motherTemp, motherFundus, motherEBL, babyBFed, babyTemp, babyRR, babyCR, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.checkDatetime, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherCR, NEW.motherTemp, NEW.motherFundus, NEW.motherEBL, NEW.babyBFed, NEW.babyTemp, NEW.babyRR, NEW.babyCR, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: contPostpartumCheck_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS contPostpartumCheck_after_update;
CREATE TRIGGER contPostpartumCheck_after_update AFTER UPDATE ON contPostpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO contPostpartumCheckLog
  (id, checkDatetime, motherSystolic, motherDiastolic, motherCR, motherTemp, motherFundus, motherEBL, babyBFed, babyTemp, babyRR, babyCR, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.checkDatetime, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherCR, NEW.motherTemp, NEW.motherFundus, NEW.motherEBL, NEW.babyBFed, NEW.babyTemp, NEW.babyRR, NEW.babyCR, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: contPostpartumCheck_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS contPostpartumCheck_after_delete;
CREATE TRIGGER contPostpartumCheck_after_delete AFTER DELETE ON contPostpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO contPostpartumCheckLog
  (id, checkDatetime, motherSystolic, motherDiastolic, motherCR, motherTemp, motherFundus, motherEBL, babyBFed, babyTemp, babyRR, babyCR, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.checkDatetime, OLD.motherSystolic, OLD.motherDiastolic, OLD.motherCR, OLD.motherTemp, OLD.motherFundus, OLD.motherEBL, OLD.babyBFed, OLD.babyTemp, OLD.babyRR, OLD.babyCR, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;


COMMIT;

-- ==== DOWN ====

BEGIN;

DROP TABLE contPostpartumCheckLog;
DROP TABLE contPostpartumCheck;

COMMIT;
