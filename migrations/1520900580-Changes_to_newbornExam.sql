-- Migration: Changes to newbornExam
-- Created at: 2018-03-13 08:23:00
-- ====  UP  ====

BEGIN;

ALTER TABLE newbornExam
  MODIFY COLUMN appearance VARCHAR(250),
  MODIFY COLUMN color VARCHAR(250),
  MODIFY COLUMN skin VARCHAR(250),
  MODIFY COLUMN head VARCHAR(250),
  MODIFY COLUMN eyes VARCHAR(250),
  MODIFY COLUMN ears VARCHAR(250),
  MODIFY COLUMN nose VARCHAR(250),
  MODIFY COLUMN mouth VARCHAR(250),
  MODIFY COLUMN neck VARCHAR(250),
  MODIFY COLUMN chest VARCHAR(250),
  MODIFY COLUMN lungs VARCHAR(250),
  MODIFY COLUMN heart VARCHAR(250),
  MODIFY COLUMN abdomen VARCHAR(250),
  MODIFY COLUMN hips VARCHAR(250),
  MODIFY COLUMN cord VARCHAR(250),
  MODIFY COLUMN femoralPulses VARCHAR(250),
  MODIFY COLUMN genitalia VARCHAR(250),
  MODIFY COLUMN anus VARCHAR(250),
  MODIFY COLUMN back VARCHAR(250),
  MODIFY COLUMN extremities VARCHAR(250);

ALTER TABLE newbornExamLog
  MODIFY COLUMN appearance VARCHAR(250),
  MODIFY COLUMN color VARCHAR(250),
  MODIFY COLUMN skin VARCHAR(250),
  MODIFY COLUMN head VARCHAR(250),
  MODIFY COLUMN eyes VARCHAR(250),
  MODIFY COLUMN ears VARCHAR(250),
  MODIFY COLUMN nose VARCHAR(250),
  MODIFY COLUMN mouth VARCHAR(250),
  MODIFY COLUMN neck VARCHAR(250),
  MODIFY COLUMN chest VARCHAR(250),
  MODIFY COLUMN lungs VARCHAR(250),
  MODIFY COLUMN heart VARCHAR(250),
  MODIFY COLUMN abdomen VARCHAR(250),
  MODIFY COLUMN hips VARCHAR(250),
  MODIFY COLUMN cord VARCHAR(250),
  MODIFY COLUMN femoralPulses VARCHAR(250),
  MODIFY COLUMN genitalia VARCHAR(250),
  MODIFY COLUMN anus VARCHAR(250),
  MODIFY COLUMN back VARCHAR(250),
  MODIFY COLUMN extremities VARCHAR(250);

ALTER TABLE newbornExam ADD COLUMN appearanceComment VARCHAR(250) NULL AFTER appearance;
ALTER TABLE newbornExam ADD COLUMN colorComment VARCHAR(250) NULL AFTER color;
ALTER TABLE newbornExam ADD COLUMN skinComment VARCHAR(250) NULL AFTER skin;
ALTER TABLE newbornExam ADD COLUMN headComment VARCHAR(250) NULL AFTER head;
ALTER TABLE newbornExam ADD COLUMN eyesComment VARCHAR(250) NULL AFTER eyes;
ALTER TABLE newbornExam ADD COLUMN earsComment VARCHAR(250) NULL AFTER ears;
ALTER TABLE newbornExam ADD COLUMN noseComment VARCHAR(250) NULL AFTER nose;
ALTER TABLE newbornExam ADD COLUMN mouthComment VARCHAR(250) NULL AFTER mouth;
ALTER TABLE newbornExam ADD COLUMN neckComment VARCHAR(250) NULL AFTER neck;
ALTER TABLE newbornExam ADD COLUMN chestComment VARCHAR(250) NULL AFTER chest;
ALTER TABLE newbornExam ADD COLUMN lungsComment VARCHAR(250) NULL AFTER lungs;
ALTER TABLE newbornExam ADD COLUMN heartComment VARCHAR(250) NULL AFTER heart;
ALTER TABLE newbornExam ADD COLUMN abdomenComment VARCHAR(250) NULL AFTER abdomen;
ALTER TABLE newbornExam ADD COLUMN hipsComment VARCHAR(250) NULL AFTER hips;
ALTER TABLE newbornExam ADD COLUMN cordComment VARCHAR(250) NULL AFTER cord;
ALTER TABLE newbornExam ADD COLUMN femoralPulsesComment VARCHAR(250) NULL AFTER femoralPulses;
ALTER TABLE newbornExam ADD COLUMN genitaliaComment VARCHAR(250) NULL AFTER genitalia;
ALTER TABLE newbornExam ADD COLUMN anusComment VARCHAR(250) NULL AFTER anus;
ALTER TABLE newbornExam ADD COLUMN backComment VARCHAR(250) NULL AFTER back;
ALTER TABLE newbornExam ADD COLUMN extremitiesComment VARCHAR(250) NULL AFTER extremities;

ALTER TABLE newbornExamLog ADD COLUMN appearanceComment VARCHAR(250) NULL AFTER appearance;
ALTER TABLE newbornExamLog ADD COLUMN colorComment VARCHAR(250) NULL AFTER color;
ALTER TABLE newbornExamLog ADD COLUMN skinComment VARCHAR(250) NULL AFTER skin;
ALTER TABLE newbornExamLog ADD COLUMN headComment VARCHAR(250) NULL AFTER head;
ALTER TABLE newbornExamLog ADD COLUMN eyesComment VARCHAR(250) NULL AFTER eyes;
ALTER TABLE newbornExamLog ADD COLUMN earsComment VARCHAR(250) NULL AFTER ears;
ALTER TABLE newbornExamLog ADD COLUMN noseComment VARCHAR(250) NULL AFTER nose;
ALTER TABLE newbornExamLog ADD COLUMN mouthComment VARCHAR(250) NULL AFTER mouth;
ALTER TABLE newbornExamLog ADD COLUMN neckComment VARCHAR(250) NULL AFTER neck;
ALTER TABLE newbornExamLog ADD COLUMN chestComment VARCHAR(250) NULL AFTER chest;
ALTER TABLE newbornExamLog ADD COLUMN lungsComment VARCHAR(250) NULL AFTER lungs;
ALTER TABLE newbornExamLog ADD COLUMN heartComment VARCHAR(250) NULL AFTER heart;
ALTER TABLE newbornExamLog ADD COLUMN abdomenComment VARCHAR(250) NULL AFTER abdomen;
ALTER TABLE newbornExamLog ADD COLUMN hipsComment VARCHAR(250) NULL AFTER hips;
ALTER TABLE newbornExamLog ADD COLUMN cordComment VARCHAR(250) NULL AFTER cord;
ALTER TABLE newbornExamLog ADD COLUMN femoralPulsesComment VARCHAR(250) NULL AFTER femoralPulses;
ALTER TABLE newbornExamLog ADD COLUMN genitaliaComment VARCHAR(250) NULL AFTER genitalia;
ALTER TABLE newbornExamLog ADD COLUMN anusComment VARCHAR(250) NULL AFTER anus;
ALTER TABLE newbornExamLog ADD COLUMN backComment VARCHAR(250) NULL AFTER back;
ALTER TABLE newbornExamLog ADD COLUMN extremitiesComment VARCHAR(250) NULL AFTER extremities;

-- ---------------------------------------------------------------
-- Trigger: newbornExam_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS newbornExam_after_insert;
CREATE TRIGGER newbornExam_after_insert AFTER INSERT ON newbornExam
FOR EACH ROW
BEGIN
  INSERT INTO newbornExamLog
  (id, examDatetime, examiners, rr, hr, temperature, length, headCir, chestCir, appearance, appearanceComment, color, colorComment, skin, skinComment, head, headComment, eyes, eyesComment, ears, earsComment, nose, noseComment, mouth, mouthComment, neck, neckComment, chest, chestComment, lungs, lungsComment, heart, heartComment, abdomen, abdomenComment, hips, hipsComment, cord, cordComment, femoralPulses, femoralPulsesComment, genitalia, genitaliaComment, anus, anusComment, back, backComment, extremities, extremitiesComment, estGA, moroReflex, moroReflexComment, palmarReflex, palmarReflexComment, steppingReflex, steppingReflexComment, plantarReflex, plantarReflexComment, babinskiReflex, babinskiReflexComment, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.examDatetime, NEW.examiners, NEW.rr, NEW.hr, NEW.temperature, NEW.length, NEW.headCir, NEW.chestCir, NEW.appearance, NEW.appearanceComment, NEW.color, NEW.colorComment, NEW.skin, NEW.skinComment, NEW.head, NEW.headComment, NEW.eyes, NEW.eyesComment, NEW.ears, NEW.earsComment, NEW.nose, NEW.noseComment, NEW.mouth, NEW.mouthComment, NEW.neck, NEW.neckComment, NEW.chest, NEW.chestComment, NEW.lungs, NEW.lungsComment, NEW.heart, NEW.heartComment, NEW.abdomen, NEW.abdomenComment, NEW.hips, NEW.hipsComment, NEW.cord, NEW.cordComment, NEW.femoralPulses, NEW.femoralPulsesComment, NEW.genitalia, NEW.genitaliaComment, NEW.anus, NEW.anusComment, NEW.back, NEW.backComment, NEW.extremities, NEW.extremitiesComment, NEW.estGA, NEW.moroReflex, NEW.moroReflexComment, NEW.palmarReflex, NEW.palmarReflexComment, NEW.steppingReflex, NEW.steppingReflexComment, NEW.plantarReflex, NEW.plantarReflexComment, NEW.babinskiReflex, NEW.babinskiReflexComment, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: newbornExam_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS newbornExam_after_update;
CREATE TRIGGER newbornExam_after_update AFTER UPDATE ON newbornExam
FOR EACH ROW
BEGIN
  INSERT INTO newbornExamLog
  (id, examDatetime, examiners, rr, hr, temperature, length, headCir, chestCir, appearance, appearanceComment, color, colorComment, skin, skinComment, head, headComment, eyes, eyesComment, ears, earsComment, nose, noseComment, mouth, mouthComment, neck, neckComment, chest, chestComment, lungs, lungsComment, heart, heartComment, abdomen, abdomenComment, hips, hipsComment, cord, cordComment, femoralPulses, femoralPulsesComment, genitalia, genitaliaComment, anus, anusComment, back, backComment, extremities, extremitiesComment, estGA, moroReflex, moroReflexComment, palmarReflex, palmarReflexComment, steppingReflex, steppingReflexComment, plantarReflex, plantarReflexComment, babinskiReflex, babinskiReflexComment, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.examDatetime, NEW.examiners, NEW.rr, NEW.hr, NEW.temperature, NEW.length, NEW.headCir, NEW.chestCir, NEW.appearance, NEW.appearanceComment, NEW.color, NEW.colorComment, NEW.skin, NEW.skinComment, NEW.head, NEW.headComment, NEW.eyes, NEW.eyesComment, NEW.ears, NEW.earsComment, NEW.nose, NEW.noseComment, NEW.mouth, NEW.mouthComment, NEW.neck, NEW.neckComment, NEW.chest, NEW.chestComment, NEW.lungs, NEW.lungsComment, NEW.heart, NEW.heartComment, NEW.abdomen, NEW.abdomenComment, NEW.hips, NEW.hipsComment, NEW.cord, NEW.cordComment, NEW.femoralPulses, NEW.femoralPulsesComment, NEW.genitalia, NEW.genitaliaComment, NEW.anus, NEW.anusComment, NEW.back, NEW.backComment, NEW.extremities, NEW.extremitiesComment, NEW.estGA, NEW.moroReflex, NEW.moroReflexComment, NEW.palmarReflex, NEW.palmarReflexComment, NEW.steppingReflex, NEW.steppingReflexComment, NEW.plantarReflex, NEW.plantarReflexComment, NEW.babinskiReflex, NEW.babinskiReflexComment, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: newbornExam_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS newbornExam_after_delete;
CREATE TRIGGER newbornExam_after_delete AFTER DELETE ON newbornExam
FOR EACH ROW
BEGIN
  INSERT INTO newbornExamLog
  (id, examDatetime, examiners, rr, hr, temperature, length, headCir, chestCir, appearance, appearanceComment, color, colorComment, skin, skinComment, head, headComment, eyes, eyesComment, ears, earsComment, nose, noseComment, mouth, mouthComment, neck, neckComment, chest, chestComment, lungs, lungsComment, heart, heartComment, abdomen, abdomenComment, hips, hipsComment, cord, cordComment, femoralPulses, femoralPulsesComment, genitalia, genitaliaComment, anus, anusComment, back, backComment, extremities, extremitiesComment, estGA, moroReflex, moroReflexComment, palmarReflex, palmarReflexComment, steppingReflex, steppingReflexComment, plantarReflex, plantarReflexComment, babinskiReflex, babinskiReflexComment, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.examDatetime, OLD.examiners, OLD.rr, OLD.hr, OLD.temperature, OLD.length, OLD.headCir, OLD.chestCir, OLD.appearance, OLD.appearanceComment, OLD.color, OLD.colorComment, OLD.skin, OLD.skinComment, OLD.head, OLD.headComment, OLD.eyes, OLD.eyesComment, OLD.ears, OLD.earsComment, OLD.nose, OLD.noseComment, OLD.mouth, OLD.mouthComment, OLD.neck, OLD.neckComment, OLD.chest, OLD.chestComment, OLD.lungs, OLD.lungsComment, OLD.heart, OLD.heartComment, OLD.abdomen, OLD.abdomenComment, OLD.hips, OLD.hipsComment, OLD.cord, OLD.cordComment, OLD.femoralPulses, OLD.femoralPulsesComment, OLD.genitalia, OLD.genitaliaComment, OLD.anus, OLD.anusComment, OLD.back, OLD.backComment, OLD.extremities, OLD.extremitiesComment, OLD.estGA, OLD.moroReflex, OLD.moroReflexComment, OLD.palmarReflex, OLD.palmarReflexComment, OLD.steppingReflex, OLD.steppingReflexComment, OLD.plantarReflex, OLD.plantarReflexComment, OLD.babinskiReflex, OLD.babinskiReflexComment, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;

DELETE FROM selectData WHERE name LIKE 'newbornExam%';

INSERT INTO selectData
  (name, selectKey, label, selected, updatedBy, updatedAt)
  VALUES
  ('newbornExamAppearance', 'Active', 'Active', 0, 1, NOW()),
  ('newbornExamAppearance', 'Crying', 'Crying', 0, 1, NOW()),
  ('newbornExamAppearance', 'Good tone', 'Good tone', 0, 1, NOW()),
  ('newbornExamAppearance', 'Sleeping', 'Sleeping', 0, 1, NOW()),
  ('newbornExamAppearance', 'Alert', 'Alert', 0, 1, NOW()),
  ('newbornExamAppearance', 'Lethargic', 'Lethargic', 0, 1, NOW()),
  ('newbornExamAppearance', 'Poor tone', 'Poor tone', 0, 1, NOW()),
  ('newbornExamColor', 'Pink', 'Pink', 0, 1, NOW()),
  ('newbornExamColor', 'Jaundice', 'Jaundice', 0, 1, NOW()),
  ('newbornExamColor', 'Acrocyanosis', 'Acrocyanosis', 0, 1, NOW()),
  ('newbornExamColor', 'Cyanotic', 'Cyanotic', 0, 1, NOW()),
  ('newbornExamSkin', 'Soft and moist', 'Soft and moist', 0, 1, NOW()),
  ('newbornExamSkin', 'Dry', 'Dry', 0, 1, NOW()),
  ('newbornExamSkin', 'Peeling', 'Peeling', 0, 1, NOW()),
  ('newbornExamSkin', 'Vernix', 'Vernix', 0, 1, NOW()),
  ('newbornExamSkin', 'Lanugo', 'Lanugo', 0, 1, NOW()),
  ('newbornExamSkin', 'Mongolian spot', 'Mongolian spot', 0, 1, NOW()),
  ('newbornExamSkin', 'Milia', 'Milia', 0, 1, NOW()),
  ('newbornExamHead', 'Molding', 'Molding', 0, 1, NOW()),
  ('newbornExamHead', 'Caput', 'Caput', 0, 1, NOW()),
  ('newbornExamHead', 'Ant fontanelle', 'Ant fontanelle', 0, 1, NOW()),
  ('newbornExamHead', 'Post fontanelle', 'Post fontanelle', 0, 1, NOW()),
  ('newbornExamHead', 'Cephalohematoma', 'Cephalohematoma', 0, 1, NOW()),
  ('newbornExamHead', 'Sutures', 'Sutures', 0, 1, NOW()),
  ('newbornExamEyes', 'Clear', 'Clear', 0, 1, NOW()),
  ('newbornExamEyes', 'Tracking with movement', 'Tracking with movement', 0, 1, NOW()),
  ('newbornExamEyes', 'In line with ears', 'In line with ears', 0, 1, NOW()),
  ('newbornExamEyes', 'Jaundice', 'Jaundice', 0, 1, NOW()),
  ('newbornExamEyes', 'Conjunctival hemorrhage', 'Conjunctival hemorrhage', 0, 1, NOW()),
  ('newbornExamEars', 'Tags', 'Tags', 0, 1, NOW()),
  ('newbornExamEars', 'Pina well formed', 'Pina well formed', 0, 1, NOW()),
  ('newbornExamEars', 'Good recoil', 'Good recoil', 0, 1, NOW()),
  ('newbornExamEars', 'Good alignment', 'Good alignment', 0, 1, NOW()),
  ('newbornExamEars', 'Low set', 'Low set', 0, 1, NOW()),
  ('newbornExamNose', 'Midline', 'Midline', 0, 1, NOW()),
  ('newbornExamNose', 'Patent bilateral', 'Patent bilateral', 0, 1, NOW()),
  ('newbornExamNose', 'Septum deviated', 'Septum deviated', 0, 1, NOW()),
  ('newbornExamNose', 'Nostrils patent', 'Nostrils patent', 0, 1, NOW()),
  ('newbornExamNose', 'Flaring', 'Flaring', 0, 1, NOW()),
  ('newbornExamMouth', 'Good suck', 'Good suck', 0, 1, NOW()),
  ('newbornExamMouth', 'Hard & soft palates intact', 'Hard & soft palates intact', 0, 1, NOW()),
  ('newbornExamMouth', 'Rooting reflex', 'Rooting reflex', 0, 1, NOW()),
  ('newbornExamMouth', 'Tongue-tie', 'Tongue-tie', 0, 1, NOW()),
  ('newbornExamMouth', 'Small chin', 'Small chin', 0, 1, NOW()),
  ('newbornExamMouth', 'Large tongue', 'Large tongue', 0, 1, NOW()),
  ('newbornExamMouth', 'Epstein pearls', 'Epstein pearls', 0, 1, NOW()),
  ('newbornExamNeck', 'FROM', 'FROM', 0, 1, NOW()),
  ('newbornExamNeck', 'Webbing', 'Webbing', 0, 1, NOW()),
  ('newbornExamNeck', 'No masses', 'No masses', 0, 1, NOW()),
  ('newbornExamNeck', 'No swelling', 'No swelling', 0, 1, NOW()),
  ('newbornExamChest', 'Symmetrical breathing', 'Symmetrical breathing', 0, 1, NOW()),
  ('newbornExamChest', 'Ribs intact', 'Ribs intact', 0, 1, NOW()),
  ('newbornExamChest', 'Breast buds present', 'Breast buds present', 0, 1, NOW()),
  ('newbornExamChest', 'Retractions', 'Retractions', 0, 1, NOW()),
  ('newbornExamChest', 'Clavicles intact', 'Clavicles intact', 0, 1, NOW()),
  ('newbornExamChest', 'Bilateral breast buds present', 'Bilateral breast buds present', 0, 1, NOW()),
  ('newbornExamLungs', 'Lungs clear bilaterally', 'Lungs clear bilaterally', 0, 1, NOW()),
  ('newbornExamLungs', 'Crackles present', 'Crackles present', 0, 1, NOW()),
  ('newbornExamHeart', 'Regular heart rate & rhythm', 'Regular heart rate & rhythm', 0, 1, NOW()),
  ('newbornExamHeart', 'Murmur present', 'Murmur present', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Round', 'Round', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Soft', 'Soft', 0, 1, NOW()),
  ('newbornExamAbdomen', 'No masses', 'No masses', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Bowel sounds present', 'Bowel sounds present', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Bowel sounds absent', 'Bowel sounds absent', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Distended', 'Distended', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Hernia', 'Hernia', 0, 1, NOW()),
  ('newbornExamHips', 'FROM', 'FROM', 0, 1, NOW()),
  ('newbornExamHips', 'No clicks', 'No clicks', 0, 1, NOW()),
  ('newbornExamHips', 'Hip dysplasia', 'Hip dysplasia', 0, 1, NOW()),
  ('newbornExamCord', '3 vessel', '3 vessel', 0, 1, NOW()),
  ('newbornExamCord', 'Mec stained', 'Mec stained', 0, 1, NOW()),
  ('newbornExamCord', 'White', 'White', 0, 1, NOW()),
  ('newbornExamCord', 'Hernia', 'Hernia', 0, 1, NOW()),
  ('newbornExamFemoralPulses', 'Strong', 'Strong', 0, 1, NOW()),
  ('newbornExamFemoralPulses', 'Present bilaterally', 'Present bilaterally', 0, 1, NOW()),
  ('newbornExamGenitaliaFemale', 'Labia majora covering minora', 'Labia majora covering minora', 0, 1, NOW()),
  ('newbornExamGenitaliaFemale', 'Prominent clitoris', 'Prominent clitoris', 0, 1, NOW()),
  ('newbornExamGenitaliaFemale', 'White discharge', 'White discharge', 0, 1, NOW()),
  ('newbornExamGenitaliaMale', 'Penis urethra midline', 'Penis urethra midline', 0, 1, NOW()),
  ('newbornExamGenitaliaMale', 'Testes descended bilaterally', 'Testes descended bilaterally', 0, 1, NOW()),
  ('newbornExamGenitaliaMale', 'Testes right descended', 'Testes right descended', 0, 1, NOW()),
  ('newbornExamGenitaliaMale', 'Testes left descended', 'Testes left descended', 0, 1, NOW()),
  ('newbornExamGenitaliaMale', 'Scotum rugae present', 'Scotum rugae present', 0, 1, NOW()),
  ('newbornExamAnus', 'Midline', 'Midline', 0, 1, NOW()),
  ('newbornExamAnus', 'Patent', 'Patent', 0, 1, NOW()),
  ('newbornExamAnus', 'Appears Patent', 'Appears Patent', 0, 1, NOW()),
  ('newbornExamBack', 'Straight', 'Straight', 0, 1, NOW()),
  ('newbornExamBack', 'No swelling', 'No swelling', 0, 1, NOW()),
  ('newbornExamBack', 'No dimples', 'No dimples', 0, 1, NOW()),
  ('newbornExamBack', 'No tufts of hair', 'No tufts of hair', 0, 1, NOW()),
  ('newbornExamExtremities', 'Symmetrical', 'Symmetrical', 0, 1, NOW()),
  ('newbornExamExtremities', 'Skin folds symmetrical', 'Skin folds symmetrical', 0, 1, NOW()),
  ('newbornExamExtremities', 'Movement', 'Movement', 0, 1, NOW()),
  ('newbornExamExtremities', 'Digits all present', 'Digits all present', 0, 1, NOW()),
  ('newbornExamExtremities', 'No webbing', 'No webbing', 0, 1, NOW()),
  ('newbornExamExtremities', 'Extra digits', 'Extra digits', 0, 1, NOW()),
  ('newbornExamExtremities', 'Normal creases on hands & feet', 'Normal creases on hands & feet', 0, 1, NOW())
  ;


-- NOTE: we do not have any data in production yet, so we will delete data in the
-- newbornExam table that is invalidated by the above selectData changes.
UPDATE newbornExam SET head = '', chest = '', anus = '', nose = '', abdomen = '';

COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE newbornExam DROP COLUMN appearanceComment;
ALTER TABLE newbornExam DROP COLUMN colorComment;
ALTER TABLE newbornExam DROP COLUMN skinComment;
ALTER TABLE newbornExam DROP COLUMN headComment;
ALTER TABLE newbornExam DROP COLUMN eyesComment;
ALTER TABLE newbornExam DROP COLUMN earsComment;
ALTER TABLE newbornExam DROP COLUMN noseComment;
ALTER TABLE newbornExam DROP COLUMN mouthComment;
ALTER TABLE newbornExam DROP COLUMN neckComment;
ALTER TABLE newbornExam DROP COLUMN chestComment;
ALTER TABLE newbornExam DROP COLUMN lungsComment;
ALTER TABLE newbornExam DROP COLUMN heartComment;
ALTER TABLE newbornExam DROP COLUMN abdomenComment;
ALTER TABLE newbornExam DROP COLUMN hipsComment;
ALTER TABLE newbornExam DROP COLUMN cordComment;
ALTER TABLE newbornExam DROP COLUMN femoralPulsesComment;
ALTER TABLE newbornExam DROP COLUMN genitaliaComment;
ALTER TABLE newbornExam DROP COLUMN anusComment;
ALTER TABLE newbornExam DROP COLUMN backComment;
ALTER TABLE newbornExam DROP COLUMN extremitiesComment;

ALTER TABLE newbornExamLog DROP COLUMN appearanceComment;
ALTER TABLE newbornExamLog DROP COLUMN colorComment;
ALTER TABLE newbornExamLog DROP COLUMN skinComment;
ALTER TABLE newbornExamLog DROP COLUMN headComment;
ALTER TABLE newbornExamLog DROP COLUMN eyesComment;
ALTER TABLE newbornExamLog DROP COLUMN earsComment;
ALTER TABLE newbornExamLog DROP COLUMN noseComment;
ALTER TABLE newbornExamLog DROP COLUMN mouthComment;
ALTER TABLE newbornExamLog DROP COLUMN neckComment;
ALTER TABLE newbornExamLog DROP COLUMN chestComment;
ALTER TABLE newbornExamLog DROP COLUMN lungsComment;
ALTER TABLE newbornExamLog DROP COLUMN heartComment;
ALTER TABLE newbornExamLog DROP COLUMN abdomenComment;
ALTER TABLE newbornExamLog DROP COLUMN hipsComment;
ALTER TABLE newbornExamLog DROP COLUMN cordComment;
ALTER TABLE newbornExamLog DROP COLUMN femoralPulsesComment;
ALTER TABLE newbornExamLog DROP COLUMN genitaliaComment;
ALTER TABLE newbornExamLog DROP COLUMN anusComment;
ALTER TABLE newbornExamLog DROP COLUMN backComment;
ALTER TABLE newbornExamLog DROP COLUMN extremitiesComment;

-- ---------------------------------------------------------------
-- Trigger: newbornExam_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS newbornExam_after_insert;
CREATE TRIGGER newbornExam_after_insert AFTER INSERT ON newbornExam
FOR EACH ROW
BEGIN
  INSERT INTO newbornExamLog
  (id, examDatetime, examiners, rr, hr, temperature, length, headCir, chestCir, appearance, color, skin, head, eyes, ears, nose, mouth, neck, chest, lungs, heart, abdomen, hips, cord, femoralPulses, genitalia, anus, back, extremities, estGA, moroReflex, moroReflexComment, palmarReflex, palmarReflexComment, steppingReflex, steppingReflexComment, plantarReflex, plantarReflexComment, babinskiReflex, babinskiReflexComment, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.examDatetime, NEW.examiners, NEW.rr, NEW.hr, NEW.temperature, NEW.length, NEW.headCir, NEW.chestCir, NEW.appearance, NEW.color, NEW.skin, NEW.head, NEW.eyes, NEW.ears, NEW.nose, NEW.mouth, NEW.neck, NEW.chest, NEW.lungs, NEW.heart, NEW.abdomen, NEW.hips, NEW.cord, NEW.femoralPulses, NEW.genitalia, NEW.anus, NEW.back, NEW.extremities, NEW.estGA, NEW.moroReflex, NEW.moroReflexComment, NEW.palmarReflex, NEW.palmarReflexComment, NEW.steppingReflex, NEW.steppingReflexComment, NEW.plantarReflex, NEW.plantarReflexComment, NEW.babinskiReflex, NEW.babinskiReflexComment, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: newbornExam_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS newbornExam_after_update;
CREATE TRIGGER newbornExam_after_update AFTER UPDATE ON newbornExam
FOR EACH ROW
BEGIN
  INSERT INTO newbornExamLog
  (id, examDatetime, examiners, rr, hr, temperature, length, headCir, chestCir, appearance, color, skin, head, eyes, ears, nose, mouth, neck, chest, lungs, heart, abdomen, hips, cord, femoralPulses, genitalia, anus, back, extremities, estGA, moroReflex, moroReflexComment, palmarReflex, palmarReflexComment, steppingReflex, steppingReflexComment, plantarReflex, plantarReflexComment, babinskiReflex, babinskiReflexComment, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.examDatetime, NEW.examiners, NEW.rr, NEW.hr, NEW.temperature, NEW.length, NEW.headCir, NEW.chestCir, NEW.appearance, NEW.color, NEW.skin, NEW.head, NEW.eyes, NEW.ears, NEW.nose, NEW.mouth, NEW.neck, NEW.chest, NEW.lungs, NEW.heart, NEW.abdomen, NEW.hips, NEW.cord, NEW.femoralPulses, NEW.genitalia, NEW.anus, NEW.back, NEW.extremities, NEW.estGA, NEW.moroReflex, NEW.moroReflexComment, NEW.palmarReflex, NEW.palmarReflexComment, NEW.steppingReflex, NEW.steppingReflexComment, NEW.plantarReflex, NEW.plantarReflexComment, NEW.babinskiReflex, NEW.babinskiReflexComment, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: newbornExam_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS newbornExam_after_delete;
CREATE TRIGGER newbornExam_after_delete AFTER DELETE ON newbornExam
FOR EACH ROW
BEGIN
  INSERT INTO newbornExamLog
  (id, examDatetime, examiners, rr, hr, temperature, length, headCir, chestCir, appearance, color, skin, head, eyes, ears, nose, mouth, neck, chest, lungs, heart, abdomen, hips, cord, femoralPulses, genitalia, anus, back, extremities, estGA, moroReflex, moroReflexComment, palmarReflex, palmarReflexComment, steppingReflex, steppingReflexComment, plantarReflex, plantarReflexComment, babinskiReflex, babinskiReflexComment, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.examDatetime, OLD.examiners, OLD.rr, OLD.hr, OLD.temperature, OLD.length, OLD.headCir, OLD.chestCir, OLD.appearance, OLD.color, OLD.skin, OLD.head, OLD.eyes, OLD.ears, OLD.nose, OLD.mouth, OLD.neck, OLD.chest, OLD.lungs, OLD.heart, OLD.abdomen, OLD.hips, OLD.cord, OLD.femoralPulses, OLD.genitalia, OLD.anus, OLD.back, OLD.extremities, OLD.estGA, OLD.moroReflex, OLD.moroReflexComment, OLD.palmarReflex, OLD.palmarReflexComment, OLD.steppingReflex, OLD.steppingReflexComment, OLD.plantarReflex, OLD.plantarReflexComment, OLD.babinskiReflex, OLD.babinskiReflexComment, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;

DELETE FROM selectData WHERE name LIKE 'newbornExam%';

INSERT INTO `selectData`
  (name, selectKey, label, selected, updatedBy, updatedAt)
VALUES
  ('newbornExamAppearance', 'Active', 'Active', 0, 1, NOW()),
  ('newbornExamAppearance', 'Crying', 'Crying', 0, 1, NOW()),
  ('newbornExamAppearance', 'Good tone', 'Good tone', 0, 1, NOW()),
  ('newbornExamAppearance', 'Sleeping', 'Sleeping', 0, 1, NOW()),
  ('newbornExamAppearance', 'Alert', 'Alert', 0, 1, NOW()),
  ('newbornExamAppearance', 'Lethargic', 'Lethargic', 0, 1, NOW()),
  ('newbornExamAppearance', 'Poor tone', 'Poor tone', 0, 1, NOW()),
  ('newbornExamColor', 'Pink', 'Pink', 0, 1, NOW()),
  ('newbornExamColor', 'Jaundice', 'Jaundice', 0, 1, NOW()),
  ('newbornExamColor', 'Acrocyanosis', 'Acrocyanosis', 0, 1, NOW()),
  ('newbornExamColor', 'Cyanotic', 'Cyanotic', 0, 1, NOW()),
  ('newbornExamSkin', 'Soft and moist', 'Soft and moist', 0, 1, NOW()),
  ('newbornExamSkin', 'Dry', 'Dry', 0, 1, NOW()),
  ('newbornExamSkin', 'Peeling', 'Peeling', 0, 1, NOW()),
  ('newbornExamSkin', 'Vernix', 'Vernix', 0, 1, NOW()),
  ('newbornExamSkin', 'Lanugo', 'Lanugo', 0, 1, NOW()),
  ('newbornExamSkin', 'Mongolian spot', 'Mongolian spot', 0, 1, NOW()),
  ('newbornExamSkin', 'Milia', 'Milia', 0, 1, NOW()),
  ('newbornExamHead', 'Molding', 'Molding', 0, 1, NOW()),
  ('newbornExamHead', 'Caput', 'Caput', 0, 1, NOW()),
  ('newbornExamHead', 'Normal fontanes', 'Normal fontanes', 0, 1, NOW()),
  ('newbornExamHead', 'Cephalohematoma', 'Cephalohematoma', 0, 1, NOW()),
  ('newbornExamEyes', 'Clear', 'Clear', 0, 1, NOW()),
  ('newbornExamEyes', 'Tracking with movement', 'Tracking with movement', 0, 1, NOW()),
  ('newbornExamEyes', 'In line with ears', 'In line with ears', 0, 1, NOW()),
  ('newbornExamEyes', 'Jaundice', 'Jaundice', 0, 1, NOW()),
  ('newbornExamEyes', 'Conjunctival hemorrhage', 'Conjunctival hemorrhage', 0, 1, NOW()),
  ('newbornExamEars', 'Tags', 'Tags', 0, 1, NOW()),
  ('newbornExamEars', 'Pina well formed', 'Pina well formed', 0, 1, NOW()),
  ('newbornExamEars', 'Good recoil', 'Good recoil', 0, 1, NOW()),
  ('newbornExamEars', 'Good alignment', 'Good alignment', 0, 1, NOW()),
  ('newbornExamEars', 'Low set', 'Low set', 0, 1, NOW()),
  ('newbornExamNose', 'Midline', 'Midline', 0, 1, NOW()),
  ('newbornExamNose', 'Septum intact', 'Septum intact', 0, 1, NOW()),
  ('newbornExamNose', 'Septum deviated', 'Septum deviated', 0, 1, NOW()),
  ('newbornExamNose', 'Nostrils patent', 'Nostrils patent', 0, 1, NOW()),
  ('newbornExamNose', 'Flaring', 'Flaring', 0, 1, NOW()),
  ('newbornExamMouth', 'Good suck', 'Good suck', 0, 1, NOW()),
  ('newbornExamMouth', 'Hard & soft palates intact', 'Hard & soft palates intact', 0, 1, NOW()),
  ('newbornExamMouth', 'Rooting reflex', 'Rooting reflex', 0, 1, NOW()),
  ('newbornExamMouth', 'Tongue-tie', 'Tongue-tie', 0, 1, NOW()),
  ('newbornExamMouth', 'Small chin', 'Small chin', 0, 1, NOW()),
  ('newbornExamMouth', 'Large tongue', 'Large tongue', 0, 1, NOW()),
  ('newbornExamMouth', 'Epstein pearls', 'Epstein pearls', 0, 1, NOW()),
  ('newbornExamNeck', 'FROM', 'FROM', 0, 1, NOW()),
  ('newbornExamNeck', 'Webbing', 'Webbing', 0, 1, NOW()),
  ('newbornExamNeck', 'No masses', 'No masses', 0, 1, NOW()),
  ('newbornExamNeck', 'No swelling', 'No swelling', 0, 1, NOW()),
  ('newbornExamChest', 'Symmetrical breathing', 'Symmetrical breathing', 0, 1, NOW()),
  ('newbornExamChest', 'Ribs intact', 'Ribs intact', 0, 1, NOW()),
  ('newbornExamChest', 'Breast buds present', 'Breast buds present', 0, 1, NOW()),
  ('newbornExamChest', 'Retractions', 'Retractions', 0, 1, NOW()),
  ('newbornExamLungs', 'Lungs clear bilaterally', 'Lungs clear bilaterally', 0, 1, NOW()),
  ('newbornExamLungs', 'Crackles present', 'Crackles present', 0, 1, NOW()),
  ('newbornExamLungs', 'Clavicles intact', 'Clavicles intact', 0, 1, NOW()),
  ('newbornExamHeart', 'Regular heart rate & rhythm', 'Regular heart rate & rhythm', 0, 1, NOW()),
  ('newbornExamHeart', 'Murmur present', 'Murmur present', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Round', 'Round', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Soft', 'Soft', 0, 1, NOW()),
  ('newbornExamAbdomen', 'No masses', 'No masses', 0, 1, NOW()),
  ('newbornExamAbdomen', 'No tenderness', 'No tenderness', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Bowel sounds present', 'Bowel sounds present', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Bowel sounds absent', 'Bowel sounds absent', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Distended', 'Distended', 0, 1, NOW()),
  ('newbornExamAbdomen', 'Hernia', 'Hernia', 0, 1, NOW()),
  ('newbornExamHips', 'FROM', 'FROM', 0, 1, NOW()),
  ('newbornExamHips', 'No clicks', 'No clicks', 0, 1, NOW()),
  ('newbornExamHips', 'Hip dysplasia', 'Hip dysplasia', 0, 1, NOW()),
  ('newbornExamCord', '3 vessel', '3 vessel', 0, 1, NOW()),
  ('newbornExamCord', 'Mec stained', 'Mec stained', 0, 1, NOW()),
  ('newbornExamCord', 'White', 'White', 0, 1, NOW()),
  ('newbornExamCord', 'Hernia', 'Hernia', 0, 1, NOW()),
  ('newbornExamFemoralPulses', 'Strong', 'Strong', 0, 1, NOW()),
  ('newbornExamFemoralPulses', 'Present bilaterally', 'Present bilaterally', 0, 1, NOW()),
  ('newbornExamGenitaliaFemale', 'Labia majora covering minora', 'Labia majora covering minora', 0, 1, NOW()),
  ('newbornExamGenitaliaFemale', 'Prominent clitoris', 'Prominent clitoris', 0, 1, NOW()),
  ('newbornExamGenitaliaFemale', 'White discharge', 'White discharge', 0, 1, NOW()),
  ('newbornExamGenitaliaMale', 'Penis urethra midline', 'Penis urethra midline', 0, 1, NOW()),
  ('newbornExamGenitaliaMale', 'Testes descended bilaterally', 'Testes descended bilaterally', 0, 1, NOW()),
  ('newbornExamGenitaliaMale', 'Testes right descended', 'Testes right descended', 0, 1, NOW()),
  ('newbornExamGenitaliaMale', 'Testes left descended', 'Testes left descended', 0, 1, NOW()),
  ('newbornExamGenitaliaMale', 'Scotum rugae present', 'Scotum rugae present', 0, 1, NOW()),
  ('newbornExamAnus', 'Midline', 'Midline', 0, 1, NOW()),
  ('newbornExamAnus', 'Patent', 'Patent', 0, 1, NOW()),
  ('newbornExamBack', 'Straight', 'Straight', 0, 1, NOW()),
  ('newbornExamBack', 'No swelling', 'No swelling', 0, 1, NOW()),
  ('newbornExamBack', 'No dimples', 'No dimples', 0, 1, NOW()),
  ('newbornExamBack', 'No tufts of hair', 'No tufts of hair', 0, 1, NOW()),
  ('newbornExamExtremities', 'Symmetrical', 'Symmetrical', 0, 1, NOW()),
  ('newbornExamExtremities', 'Skin folds symmetrical', 'Skin folds symmetrical', 0, 1, NOW()),
  ('newbornExamExtremities', 'Movement', 'Movement', 0, 1, NOW()),
  ('newbornExamExtremities', 'Digits all present', 'Digits all present', 0, 1, NOW()),
  ('newbornExamExtremities', 'No webbing', 'No webbing', 0, 1, NOW()),
  ('newbornExamExtremities', 'Extra digits', 'Extra digits', 0, 1, NOW()),
  ('newbornExamExtremities', 'Normal creases on hands & feet', 'Normal creases on hands & feet', 0, 1, NOW()) ;

-- NOTE: we do not have any data in production yet, so we will delete data in the
-- newbornExam table that is invalidated by the above selectData changes.
UPDATE newbornExam SET head = '', chest = '', anus = '', nose = '', abdomen = '';

COMMIT;
