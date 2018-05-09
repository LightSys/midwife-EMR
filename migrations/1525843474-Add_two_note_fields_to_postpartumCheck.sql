-- Migration: Add two note fields to postpartumCheck
-- Created at: 2018-05-09 13:24:34
-- ====  UP  ====

BEGIN;

ALTER TABLE postpartumCheck
  ADD COLUMN motherFundusNote VARCHAR(200) AFTER motherFundus,
  ADD COLUMN motherPerineumNote VARCHAR(200) AFTER motherPerineum;

ALTER TABLE postpartumCheckLog
  ADD COLUMN motherFundusNote VARCHAR(200) AFTER motherFundus,
  ADD COLUMN motherPerineumNote VARCHAR(200) AFTER motherPerineum;

-- ---------------------------------------------------------------
-- Trigger: postpartumCheck_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS postpartumCheck_after_insert;
CREATE TRIGGER postpartumCheck_after_insert AFTER INSERT ON postpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO postpartumCheckLog
  (id, checkDatetime, babyWeight, babyTemp, babyCR, babyRR, babyLungs, babyColor, babySkin, babyCord, babyUrine, babyStool, babySSInfection, babyFeeding, babyFeedingDaily, motherTemp, motherSystolic, motherDiastolic, motherCR, motherBreasts, motherFundus, motherFundusNote, motherPerineum, motherPerineumNote, motherLochia, motherUrine, motherStool, motherSSInfection, motherFamilyPlanning, birthCertReq, hgbRequested, hgbTestDate, hgbTestResult, ironGiven, comments, nextScheduledCheck, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.checkDatetime, NEW.babyWeight, NEW.babyTemp, NEW.babyCR, NEW.babyRR, NEW.babyLungs, NEW.babyColor, NEW.babySkin, NEW.babyCord, NEW.babyUrine, NEW.babyStool, NEW.babySSInfection, NEW.babyFeeding, NEW.babyFeedingDaily, NEW.motherTemp, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherCR, NEW.motherBreasts, NEW.motherFundus, NEW.motherFundusNote, NEW.motherPerineum, NEW.motherPerineumNote, NEW.motherLochia, NEW.motherUrine, NEW.motherStool, NEW.motherSSInfection, NEW.motherFamilyPlanning, NEW.birthCertReq, NEW.hgbRequested, NEW.hgbTestDate, NEW.hgbTestResult, NEW.ironGiven, NEW.comments, NEW.nextScheduledCheck, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: postpartumCheck_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS postpartumCheck_after_update;
CREATE TRIGGER postpartumCheck_after_update AFTER UPDATE ON postpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO postpartumCheckLog
  (id, checkDatetime, babyWeight, babyTemp, babyCR, babyRR, babyLungs, babyColor, babySkin, babyCord, babyUrine, babyStool, babySSInfection, babyFeeding, babyFeedingDaily, motherTemp, motherSystolic, motherDiastolic, motherCR, motherBreasts, motherFundus, motherFundusNote, motherPerineum, motherPerineumNote, motherLochia, motherUrine, motherStool, motherSSInfection, motherFamilyPlanning, birthCertReq, hgbRequested, hgbTestDate, hgbTestResult, ironGiven, comments, nextScheduledCheck, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.checkDatetime, NEW.babyWeight, NEW.babyTemp, NEW.babyCR, NEW.babyRR, NEW.babyLungs, NEW.babyColor, NEW.babySkin, NEW.babyCord, NEW.babyUrine, NEW.babyStool, NEW.babySSInfection, NEW.babyFeeding, NEW.babyFeedingDaily, NEW.motherTemp, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherCR, NEW.motherBreasts, NEW.motherFundus, NEW.motherFundusNote, NEW.motherPerineum, NEW.motherPerineumNote, NEW.motherLochia, NEW.motherUrine, NEW.motherStool, NEW.motherSSInfection, NEW.motherFamilyPlanning, NEW.birthCertReq, NEW.hgbRequested, NEW.hgbTestDate, NEW.hgbTestResult, NEW.ironGiven, NEW.comments, NEW.nextScheduledCheck, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: postpartumCheck_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS postpartumCheck_after_delete;
CREATE TRIGGER postpartumCheck_after_delete AFTER DELETE ON postpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO postpartumCheckLog
  (id, checkDatetime, babyWeight, babyTemp, babyCR, babyRR, babyLungs, babyColor, babySkin, babyCord, babyUrine, babyStool, babySSInfection, babyFeeding, babyFeedingDaily, motherTemp, motherSystolic, motherDiastolic, motherCR, motherBreasts, motherFundus, motherFundusNote, motherPerineum, motherPerineumNote, motherLochia, motherUrine, motherStool, motherSSInfection, motherFamilyPlanning, birthCertReq, hgbRequested, hgbTestDate, hgbTestResult, ironGiven, comments, nextScheduledCheck, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.checkDatetime, OLD.babyWeight, OLD.babyTemp, OLD.babyCR, OLD.babyRR, OLD.babyLungs, OLD.babyColor, OLD.babySkin, OLD.babyCord, OLD.babyUrine, OLD.babyStool, OLD.babySSInfection, OLD.babyFeeding, OLD.babyFeedingDaily, OLD.motherTemp, OLD.motherSystolic, OLD.motherDiastolic, OLD.motherCR, OLD.motherBreasts, OLD.motherFundus, OLD.motherFundusNote, OLD.motherPerineum, OLD.motherPerineumNote, OLD.motherLochia, OLD.motherUrine, OLD.motherStool, OLD.motherSSInfection, OLD.motherFamilyPlanning, OLD.birthCertReq, OLD.hgbRequested, OLD.hgbTestDate, OLD.hgbTestResult, OLD.ironGiven, OLD.comments, OLD.nextScheduledCheck, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;


COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE postpartumCheck
  DROP COLUMN motherFundusNote,
  DROP COLUMN motherPerineumNote;

ALTER TABLE postpartumCheckLog
  DROP COLUMN motherFundusNote,
  DROP COLUMN motherPerineumNote;

-- ---------------------------------------------------------------
-- Trigger: postpartumCheck_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS postpartumCheck_after_insert;
CREATE TRIGGER postpartumCheck_after_insert AFTER INSERT ON postpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO postpartumCheckLog
  (id, checkDatetime, babyWeight, babyTemp, babyCR, babyRR, babyLungs, babyColor, babySkin, babyCord, babyUrine, babyStool, babySSInfection, babyFeeding, babyFeedingDaily, motherTemp, motherSystolic, motherDiastolic, motherCR, motherBreasts, motherFundus, motherPerineum, motherLochia, motherUrine, motherStool, motherSSInfection, motherFamilyPlanning, birthCertReq, hgbRequested, hgbTestDate, hgbTestResult, ironGiven, comments, nextScheduledCheck, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.checkDatetime, NEW.babyWeight, NEW.babyTemp, NEW.babyCR, NEW.babyRR, NEW.babyLungs, NEW.babyColor, NEW.babySkin, NEW.babyCord, NEW.babyUrine, NEW.babyStool, NEW.babySSInfection, NEW.babyFeeding, NEW.babyFeedingDaily, NEW.motherTemp, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherCR, NEW.motherBreasts, NEW.motherFundus, NEW.motherPerineum, NEW.motherLochia, NEW.motherUrine, NEW.motherStool, NEW.motherSSInfection, NEW.motherFamilyPlanning, NEW.birthCertReq, NEW.hgbRequested, NEW.hgbTestDate, NEW.hgbTestResult, NEW.ironGiven, NEW.comments, NEW.nextScheduledCheck, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: postpartumCheck_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS postpartumCheck_after_update;
CREATE TRIGGER postpartumCheck_after_update AFTER UPDATE ON postpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO postpartumCheckLog
  (id, checkDatetime, babyWeight, babyTemp, babyCR, babyRR, babyLungs, babyColor, babySkin, babyCord, babyUrine, babyStool, babySSInfection, babyFeeding, babyFeedingDaily, motherTemp, motherSystolic, motherDiastolic, motherCR, motherBreasts, motherFundus, motherPerineum, motherLochia, motherUrine, motherStool, motherSSInfection, motherFamilyPlanning, birthCertReq, hgbRequested, hgbTestDate, hgbTestResult, ironGiven, comments, nextScheduledCheck, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.checkDatetime, NEW.babyWeight, NEW.babyTemp, NEW.babyCR, NEW.babyRR, NEW.babyLungs, NEW.babyColor, NEW.babySkin, NEW.babyCord, NEW.babyUrine, NEW.babyStool, NEW.babySSInfection, NEW.babyFeeding, NEW.babyFeedingDaily, NEW.motherTemp, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherCR, NEW.motherBreasts, NEW.motherFundus, NEW.motherPerineum, NEW.motherLochia, NEW.motherUrine, NEW.motherStool, NEW.motherSSInfection, NEW.motherFamilyPlanning, NEW.birthCertReq, NEW.hgbRequested, NEW.hgbTestDate, NEW.hgbTestResult, NEW.ironGiven, NEW.comments, NEW.nextScheduledCheck, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: postpartumCheck_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS postpartumCheck_after_delete;
CREATE TRIGGER postpartumCheck_after_delete AFTER DELETE ON postpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO postpartumCheckLog
  (id, checkDatetime, babyWeight, babyTemp, babyCR, babyRR, babyLungs, babyColor, babySkin, babyCord, babyUrine, babyStool, babySSInfection, babyFeeding, babyFeedingDaily, motherTemp, motherSystolic, motherDiastolic, motherCR, motherBreasts, motherFundus, motherPerineum, motherLochia, motherUrine, motherStool, motherSSInfection, motherFamilyPlanning, birthCertReq, hgbRequested, hgbTestDate, hgbTestResult, ironGiven, comments, nextScheduledCheck, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.checkDatetime, OLD.babyWeight, OLD.babyTemp, OLD.babyCR, OLD.babyRR, OLD.babyLungs, OLD.babyColor, OLD.babySkin, OLD.babyCord, OLD.babyUrine, OLD.babyStool, OLD.babySSInfection, OLD.babyFeeding, OLD.babyFeedingDaily, OLD.motherTemp, OLD.motherSystolic, OLD.motherDiastolic, OLD.motherCR, OLD.motherBreasts, OLD.motherFundus, OLD.motherPerineum, OLD.motherLochia, OLD.motherUrine, OLD.motherStool, OLD.motherSSInfection, OLD.motherFamilyPlanning, OLD.birthCertReq, OLD.hgbRequested, OLD.hgbTestDate, OLD.hgbTestResult, OLD.ironGiven, OLD.comments, OLD.nextScheduledCheck, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;


COMMIT;
