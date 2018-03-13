-- Migration: Postpartum changes
-- Created at: 2018-03-13 16:21:44
-- ====  UP  ====

BEGIN;

ALTER TABLE postpartumCheck MODIFY COLUMN babyUrine VARCHAR(100) NULL;
ALTER TABLE postpartumCheck MODIFY COLUMN babyStool VARCHAR(100) NULL;
ALTER TABLE postpartumCheck MODIFY COLUMN babyFeedingDaily VARCHAR(100) NULL;

ALTER TABLE postpartumCheckLog MODIFY COLUMN babyUrine VARCHAR(100) NULL;
ALTER TABLE postpartumCheckLog MODIFY COLUMN babyStool VARCHAR(100) NULL;
ALTER TABLE postpartumCheckLog MODIFY COLUMN babyFeedingDaily VARCHAR(100) NULL;

DELETE FROM selectData WHERE name LIKE 'postpartumCheck%';

INSERT INTO `selectData`
  (name, selectKey, label, selected, updatedBy, updatedAt)
VALUES
  ('postpartumCheckBabyLungs', 'Clear bilaterally', 'Clear bilaterally', 0, 1, NOW()),
  ('postpartumCheckBabyLungs', 'Crackles present', 'Crackles present', 0, 1, NOW()),
  ('postpartumCheckBabyLungs', 'Wheezes present', 'Wheezes present', 0, 1, NOW()),
  ('postpartumCheckBabyColor', 'Pink', 'Pink', 0, 1, NOW()),
  ('postpartumCheckBabyColor', 'Mild jaundice', 'Mild jaundice', 0, 1, NOW()),
  ('postpartumCheckBabyColor', 'Moderate jaundice', 'Moderate jaundice', 0, 1, NOW()),
  ('postpartumCheckBabyColor', 'Severe jaundice', 'Severe jaundice', 0, 1, NOW()),
  ('postpartumCheckBabyColor', 'No jaundice', 'No jaundice', 0, 1, NOW()),
  ('postpartumCheckBabyColor', 'Pale', 'Pale', 0, 1, NOW()),
  ('postpartumCheckBabySkin', 'Peeling', 'Peeling', 0, 1, NOW()),
  ('postpartumCheckBabySkin', 'Rash', 'Rash', 0, 1, NOW()),
  ('postpartumCheckBabySkin', 'Smooth and moist', 'Smooth and moist', 0, 1, NOW()),
  ('postpartumCheckBabySkin', 'Cradle cap', 'Cradle cap', 0, 1, NOW()),
  ('postpartumCheckBabyCord', 'Dry', 'Dry', 0, 1, NOW()),
  ('postpartumCheckBabyCord', 'Healing', 'Healing', 0, 1, NOW()),
  ('postpartumCheckBabyCord', 'Clamp removed', 'Clamp removed', 0, 1, NOW()),
  ('postpartumCheckBabyCord', 'No reddness', 'No reddness', 0, 1, NOW()),
  ('postpartumCheckBabyCord', 'No odor', 'No odor', 0, 1, NOW()),
  ('postpartumCheckBabyCord', 'No discharge', 'No discharge', 0, 1, NOW()),
  ('postpartumCheckBabyCord', 'Stump absent', 'Stump absent', 0, 1, NOW()),
  ('postpartumCheckBabyCord', 'Glanuloma', 'Glanuloma', 0, 1, NOW()),
  ('postpartumCheckBabyCord', 'Bleeding', 'Bleeding', 0, 1, NOW()),
  ('postpartumCheckBabySSInfection', 'Absent', 'Absent', 0, 1, NOW()),
  ('postpartumCheckBabySSInfection', 'Fever', 'Fever', 0, 1, NOW()),
  ('postpartumCheckBabySSInfection', 'Cough', 'Cough', 0, 1, NOW()),
  ('postpartumCheckBabySSInfection', 'Retractions', 'Retractions', 0, 1, NOW()),
  ('postpartumCheckBabySSInfection', 'Tachycardia', 'Tachycardia', 0, 1, NOW()),
  ('postpartumCheckBabySSInfection', 'Tachypnea', 'Tachypnea', 0, 1, NOW()),
  ('postpartumCheckBabyFeeding', 'Breastfeeding only', 'Breastfeeding only', 0, 1, NOW()),
  ('postpartumCheckBabyFeeding', 'Mixed', 'Mixed', 0, 1, NOW()),
  ('postpartumCheckBabyFeeding', 'Bottlefeeding', 'Bottlefeeding', 0, 1, NOW()),
  ('postpartumCheckMotherBreasts', 'Soft', 'Soft', 0, 1, NOW()),
  ('postpartumCheckMotherBreasts', 'Filling', 'Filling', 0, 1, NOW()),
  ('postpartumCheckMotherBreasts', 'Milk in', 'Milk in', 0, 1, NOW()),
  ('postpartumCheckMotherBreasts', 'Engorged', 'Engorged', 0, 1, NOW()),
  ('postpartumCheckMotherBreasts', 'Inflammed', 'Inflammed', 0, 1, NOW()),
  ('postpartumCheckMotherBreasts', 'Painful', 'Painful', 0, 1, NOW()),
  ('postpartumCheckMotherBreasts', 'Mastitis', 'Mastitis', 0, 1, NOW()),
  ('postpartumCheckMotherBreasts', 'Cracked nipple left', 'Cracked nipple left', 0, 1, NOW()),
  ('postpartumCheckMotherBreasts', 'Cracked nipple right', 'Cracked nipple right', 0, 1, NOW()),
  ('postpartumCheckMotherBreasts', 'Sores', 'Sores', 0, 1, NOW()),
  ('postpartumCheckMotherFundus', 'Firm', 'Firm', 0, 1, NOW()),
  ('postpartumCheckMotherFundus', 'Boggy', 'Boggy', 0, 1, NOW()),
  ('postpartumCheckMotherFundus', 'Nonpalpable', 'Nonpalpable', 0, 1, NOW()),
  ('postpartumCheckMotherFundus', 'At level of umbilicus', 'At level of umbilicus', 0, 1, NOW()),
  ('postpartumCheckMotherFundus', 'Below umbilicus', 'Below umbilicus', 0, 1, NOW()),
  ('postpartumCheckMotherFundus', 'Above umbilicus', 'Above umbilicus', 0, 1, NOW()),
  ('postpartumCheckMotherFundus', 'Cramping pain', 'Cramping pain', 0, 1, NOW()),
  ('postpartumCheckMotherPerineum', 'Intact', 'Intact', 0, 1, NOW()),
  ('postpartumCheckMotherPerineum', 'Healing well', 'Healing well', 0, 1, NOW()),
  ('postpartumCheckMotherPerineum', 'Swollen', 'Swollen', 0, 1, NOW()),
  ('postpartumCheckMotherPerineum', 'Red', 'Red', 0, 1, NOW()),
  ('postpartumCheckMotherPerineum', 'Discharge', 'Discharge', 0, 1, NOW()),
  ('postpartumCheckMotherPerineum', 'Odor', 'Odor', 0, 1, NOW()),
  ('postpartumCheckMotherPerineum', 'Laceration well approximated', 'Laceration well approximated', 0, 1, NOW()),
  ('postpartumCheckMotherLochia', 'Red', 'Red', 0, 1, NOW()),
  ('postpartumCheckMotherLochia', 'Pink', 'Pink', 0, 1, NOW()),
  ('postpartumCheckMotherLochia', 'White', 'White', 0, 1, NOW()),
  ('postpartumCheckMotherLochia', 'Abundant', 'Abundant', 0, 1, NOW()),
  ('postpartumCheckMotherLochia', 'Moderate', 'Moderate', 0, 1, NOW()),
  ('postpartumCheckMotherLochia', 'Scant', 'Scant', 0, 1, NOW()),
  ('postpartumCheckMotherLochia', 'None', 'None', 0, 1, NOW()),
  ('postpartumCheckMotherLochia', 'Odor', 'Odor', 0, 1, NOW()),
  ('postpartumCheckMotherLochia', 'Clots', 'Clots', 0, 1, NOW()),
  ('postpartumCheckMotherUrine', 'Normal', 'Normal', 0, 1, NOW()),
  ('postpartumCheckMotherUrine', 'Painful', 'Painful', 0, 1, NOW()),
  ('postpartumCheckMotherStool', 'Yes', 'Yes', 0, 1, NOW()),
  ('postpartumCheckMotherStool', 'No', 'No', 0, 1, NOW()),
  ('postpartumCheckMotherStool', 'Painful', 'Painful', 0, 1, NOW()),
  ('postpartumCheckMotherStool', 'Hemorrhoids', 'Hemorrhoids', 0, 1, NOW()),
  ('postpartumCheckMotherSSInfection', 'None', 'None', 0, 1, NOW()),
  ('postpartumCheckMotherSSInfection', 'Fever', 'Fever', 0, 1, NOW()),
  ('postpartumCheckMotherSSInfection', 'Tachycardia', 'Tachycardia', 0, 1, NOW()),
  ('postpartumCheckMotherSSInfection', 'Breast symptoms', 'Breast symptoms', 0, 1, NOW()),
  ('postpartumCheckMotherSSInfection', 'Perineum', 'Perineum', 0, 1, NOW()),
  ('postpartumCheckMotherSSInfection', 'Uterus', 'Uterus', 0, 1, NOW()),
  ('postpartumCheckMotherFamilyPlanning', 'Pills', 'Pills', 0, 1, NOW()),
  ('postpartumCheckMotherFamilyPlanning', 'IUD', 'IUD', 0, 1, NOW()),
  ('postpartumCheckMotherFamilyPlanning', 'Natural', 'Natural', 0, 1, NOW()),
  ('postpartumCheckMotherFamilyPlanning', 'Condoms', 'Condoms', 0, 1, NOW()),
  ('postpartumCheckMotherFamilyPlanning', 'Implanon', 'Implanon', 0, 1, NOW()),
  ('postpartumCheckMotherFamilyPlanning', 'Tubal ligation', 'Tubal ligation', 0, 1, NOW()),
  ('postpartumCheckMotherFamilyPlanning', 'Depo', 'Depo', 0, 1, NOW())
;

COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE postpartumCheck MODIFY COLUMN babyUrine INT NULL;
ALTER TABLE postpartumCheck MODIFY COLUMN babyStool INT NULL;
ALTER TABLE postpartumCheck MODIFY COLUMN babyFeedingDaily INT NULL;

ALTER TABLE postpartumCheckLog MODIFY COLUMN babyUrine INT NULL;
ALTER TABLE postpartumCheckLog MODIFY COLUMN babyStool INT NULL;
ALTER TABLE postpartumCheckLog MODIFY COLUMN babyFeedingDaily INT NULL;

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

-- Note that we do not undo the selectData change since there is no need to undo
-- the spelling correction.

COMMIT;
