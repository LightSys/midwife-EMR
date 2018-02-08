-- Migration: Newborn exam
-- Created at: 2018-02-08 16:10:51
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `newbornExam` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  examDatetime DATETIME NOT NULL,
  examiners VARCHAR(50) NOT NULL,
  rr INT NULL,
  hr INT NULL,
  temperature DECIMAL(4,1) NULL,
  length INT NULL,
  headCir INT NULL,
  chestCir INT NULL,
  appearance VARCHAR(500) NULL,
  color VARCHAR(500) NULL,
  skin VARCHAR(500) NULL,
  head VARCHAR(500) NULL,
  eyes VARCHAR(500) NULL,
  ears VARCHAR(500) NULL,
  nose VARCHAR(500) NULL,
  mouth VARCHAR(500) NULL,
  neck VARCHAR(500) NULL,
  chest VARCHAR(500) NULL,
  lungs VARCHAR(500) NULL,
  heart VARCHAR(500) NULL,
  abdomen VARCHAR(500) NULL,
  hips VARCHAR(500) NULL,
  cord VARCHAR(500) NULL,
  femoralPulses VARCHAR(500) NULL,
  genitalia VARCHAR(500) NULL,
  anus VARCHAR(500) NULL,
  back VARCHAR(500) NULL,
  extremities VARCHAR(500) NULL,
  estGA VARCHAR(50) NULL,
  moroReflex BOOLEAN NULL,
  moroReflexComment VARCHAR(50) NULL,
  palmarReflex BOOLEAN NULL,
  palmarReflexComment VARCHAR(50) NULL,
  steppingReflex BOOLEAN NULL,
  steppingReflexComment VARCHAR(50) NULL,
  plantarReflex BOOLEAN NULL,
  plantarReflexComment VARCHAR(50) NULL,
  babinskiReflex BOOLEAN NULL,
  babinskiReflexComment VARCHAR(50) NULL,
  comments VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  baby_id INT NOT NULL,
  UNIQUE(baby_id),
  FOREIGN KEY (baby_id) REFERENCES baby (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE newbornExamLog LIKE newbornExam;
ALTER TABLE newbornExamLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE newbornExamLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE newbornExamLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE newbornExamLog DROP PRIMARY KEY;
ALTER TABLE newbornExamLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE newbornExamLog DROP KEY baby_id;

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


COMMIT;

-- ==== DOWN ====

BEGIN;

DELETE FROM selectData
WHERE name IN
('newbornExamAppearance', 'newbornExamColor', 'newbornExamSkin', 'newbornExamHead', 'newbornExamEyes',
 'newbornExamEars', 'newbornExamNose', 'newbornExamMouth', 'newbornExamNeck', 'newbornExamChest',
 'newbornExamLungs', 'newbornExamHeart', 'newbornExamAbdomen', 'newbornExamHips', 'newbornExamCord',
 'newbornExamFemoralPulses', 'newbornExamGenitaliaFemale', 'newbornExamGenitaliaMale', 'newbornExamAnus',
 'newbornExamBack', 'newbornExamExtremities');

DROP TABLE newbornExamLog;
DROP TABLE newbornExam;

COMMIT;
