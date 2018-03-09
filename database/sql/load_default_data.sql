SET foreign_key_checks = 0;

-- Load the roles.
SELECT 'role' AS 'Loading' FROM DUAL;
INSERT INTO `role`
  (name, description, updatedBy, updatedAt)
VALUES
  ('administrator', 'Manages users, vaccination and lab types, and the system.', 1, NOW()),
  ('guard', 'Patient check-in and check-out.', 1, NOW()),
  ('clerk', 'No patient care with exception of BP and Wgt. Manages priority list.', 1, NOW()),
  ('attending', 'Patient care but always requires a supervisor.', 1, NOW()),
  ('supervisor', 'Patient care.', 1, NOW())
;


-- Load the default user that can be used to administer the system.
-- Note: password hash is for password 'admin'
SELECT 'user' AS 'Loading' FROM DUAL;
INSERT INTO `user`
  (username, firstname, lastname, password, note, role_id, updatedBy, updatedAt)
VALUES
  ('admin', 'admin', 'admin', '$2a$10$r93uzyhs73Bh88Hco63wTuOyq8rLg2jy2mWnP8g03pu8fkc9mQDb6',
  'This is the default admin account with password of "admin". In production systems, this account should be disabled once another administrator is created.',
  1, 1, NOW())
;

-- Create some basic events
SELECT 'eventType' AS 'Loading' FROM DUAL;
INSERT INTO `eventType`
  (name, description)
VALUES
  ('login', 'A user logged in'),
  ('logout', 'A user logged out'),
  ('supervisor', 'A user set a supervisor'),
  ('history', 'A user viewed changes from log tables'),
  ('prenatalCheckIn', 'Client checkin for a prenatal exam.'),
  ('prenatalCheckOut', 'Client checkout of a prenatal exam.'),
  ('prenatalChartPulled', 'Chart pulled for a prental exam.')
;

-- Create the data for at least one select option.
SELECT 'selectData' AS 'Loading' FROM DUAL;
INSERT INTO `selectData`
  (name, selectKey, label, selected, updatedBy, updatedAt)
VALUES
  ('maritalStatus', '', 'Unknown', 1, 1, NOW()),
  ('maritalStatus', 'Single', 'Single', 0, 1, NOW()),
  ('maritalStatus', 'Live-In', 'Live-In', 0, 1, NOW()),
  ('maritalStatus', 'Married', 'Married', 0, 1, NOW()),
  ('maritalStatus', 'Other', 'Other', 0, 1, NOW()),
  ('religion', '', 'Unknown', 1, 1, NOW()),
  ('religion', 'Christian', 'Christian', 0, 1, NOW()),
  ('religion', 'Roman Catholic', 'Roman Catholic', 0, 1, NOW()),
  ('religion', 'Muslim/Islam', 'Muslim/Islam', 0, 1, NOW()),
  ('religion', 'SDA', 'SDA', 0, 1, NOW()),
  ('religion', 'INC', 'INC', 0, 1, NOW()),
  ('religion', 'LDS', 'LDS', 0, 1, NOW()),
  ('religion', 'Other', 'Other', 0, 1, NOW()),
  ('education', '', 'Unknown', 1, 1, NOW()),
  ('education', 'Elem level', 'Elem level', 0, 1, NOW()),
  ('education', 'Elem grad', 'Elem grad', 0, 1, NOW()),
  ('education', 'HS level', 'HS level', 0, 1, NOW()),
  ('education', 'HS grad', 'HS grad', 0, 1, NOW()),
  ('education', 'Vocational', 'Vocational', 0, 1, NOW()),
  ('education', 'College level', 'College level', 0, 1, NOW()),
  ('education', 'College grad', 'College grad', 0, 1, NOW()),
  ('edema', 'none', 'None', 1, 1, NOW()),
  ('edema', '+1', '+1', 0, 1, NOW()),
  ('edema', '+2', '+2', 0, 1, NOW()),
  ('edema', '+3', '+3', 0, 1, NOW()),
  ('edema', '+4', '+4', 0, 1, NOW()),
  ('incomePeriod', 'Day', 'Day', 0, 1, NOW()),
  ('incomePeriod', 'Week', 'Week', 0, 1, NOW()),
  ('incomePeriod', 'Two Weeks', 'Two Weeks', 0, 1, NOW()),
  ('incomePeriod', 'Twice Monthly', 'Twice Monthly', 0, 1, NOW()),
  ('incomePeriod', 'Month', 'Month', 1, 1, NOW()),
  ('incomePeriod', 'Quarter', 'Quarter', 0, 1, NOW()),
  ('incomePeriod', 'Year', 'Year', 0, 1, NOW()),
  ('yesNoUnanswered', '', '', 1, 1, NOW()),
  ('yesNoUnanswered', 'Y', 'Yes', 0, 1, NOW()),
  ('yesNoUnanswered', 'N', 'No', 0, 1, NOW()),
  ('yesNoUnknown', '', '', 1, 1, NOW()),
  ('yesNoUnknown', 'Y', 'Yes', 0, 1, NOW()),
  ('yesNoUnknown', 'N', 'No', 0, 1, NOW()),
  ('yesNoUnknown', '?', 'Unknown', 0, 1, NOW()),
  ('episTear', '', '', 1, 1, NOW()),
  ('episTear', 'T', 'Tear', 0, 1, NOW()),
  ('episTear', 'E', 'Epis', 0, 1, NOW()),
  ('episTear', 'N', 'No', 0, 1, NOW()),
  ('episTear', '?', 'Unknown', 0, 1, NOW()),
  ('attendant', 'Midwife', 'Midwife', 1, 1, NOW()),
  ('attendant', 'Doctor', 'Doctor', 0, 1, NOW()),
  ('attendant', 'Hilot', 'Hilot', 0, 1, NOW()),
  ('attendant', 'Other', 'Other', 0, 1, NOW()),
  ('wksMthsYrs', '', '', 1, 1, NOW()),
  ('wksMthsYrs', 'Weeks', 'Weeks', 0, 1, NOW()),
  ('wksMthsYrs', 'Months', 'Months', 0, 1, NOW()),
  ('wksMthsYrs', 'Years', 'Years', 0, 1, NOW()),
  ('wksMths', '', '', 1, 1, NOW()),
  ('wksMths', 'Weeks', 'Weeks', 0, 1, NOW()),
  ('wksMths', 'Months', 'Months', 0, 1, NOW()),
  ('maleFemale', '', '', 1, 1, NOW()),
  ('maleFemale', 'F', 'Female', 0, 1, NOW()),
  ('maleFemale', 'M', 'Male', 0, 1, NOW()),
  ('internalExternal', '', '', 1, 1, NOW()),
  ('internalExternal', 'Internal', 'Internal', 0, 1, NOW()),
  ('internalExternal', 'External', 'External', 0, 1, NOW()),
  ('location', 'Mercy', 'Mercy', 1, 1, NOW()),
  ('location', 'Agdao', 'Agdao', 0, 1, NOW()),
  ('location', 'Isla Verda', 'Isla Verda', 0, 1, NOW()),
  ('location', 'Samal', 'Samal', 0, 1, NOW()),
  ('scheduleType', '', '', 1, 1, NOW()),
  ('scheduleType', 'Prenatal', 'Prenatal', 0, 1, NOW()),
  ('dayOfWeek', '', '', 1, 1, NOW()),
  ('dayOfWeek', 'Monday', 'Monday', 0, 1, NOW()),
  ('dayOfWeek', 'Tuesday', 'Tuesday', 0, 1, NOW()),
  ('dayOfWeek', 'Wednesday', 'Wednesday', 0, 1, NOW()),
  ('dayOfWeek', 'Thursday', 'Thursday', 0, 1, NOW()),
  ('dayOfWeek', 'Friday', 'Friday', 0, 1, NOW()),
  ('dayOfWeek', 'Saturday', 'Saturday', 0, 1, NOW()),
  ('dayOfWeek', 'Sunday', 'Sunday', 0, 1, NOW()),
  ('placeOfBirth', '', '', 1, 1, NOW()),
  ('placeOfBirth', 'MMC', 'MMC', 0, 1, NOW()),
  ('placeOfBirth', 'Home', 'Home', 0, 1, NOW()),
  ('placeOfBirth', 'SPMC', 'SPMC', 0, 1, NOW()),
  ('placeOfBirth', 'Hospital', 'Hospital', 0, 1, NOW()),
  ('placeOfBirth', 'Lying-in Clinic', 'Lying-in Clinic', 0, 1, NOW()),
  ('placeOfBirth', 'Other', 'Other', 0, 1, NOW()),
  ('referrals', 'Dr/Dentist', 'Dr/Dentist', 0, 1, NOW()),
  ('referrals', 'U/A', 'U/A', 0, 1, NOW()),
  ('referrals', 'Hgb', 'Hgb', 0, 1, NOW()),
  ('referrals', 'U/A & Hgb', 'U/A & Hgb', 0, 1, NOW()),
  ('referrals', 'All labs', 'All labs', 0, 1, NOW()),
  ('teachingTopics', 'Nutr + FD', 'Nutr + FD', 1, 1, NOW()),
  ('teachingTopics', 'BF', 'BF', 0, 1, NOW()),
  ('teachingTopics', 'FP', 'FP', 0, 1, NOW()),
  ('teachingTopics', 'L & D', 'L & D', 0, 1, NOW()),
  ('teachingTopics', 'PP/NB', 'PP/NB', 0, 1, NOW()),
  ('teachingTopics', 'Cln Catch', 'Cln Catch', 0, 1, NOW()),
  ('teachingTopics', 'Labr/ROM', 'Labr/ROM', 0, 1, NOW()),
  ('teachingTopics', 'Iron/Vit', 'Iron/Vit', 0, 1, NOW()),
  ('stage3TxBloodLoss', 'Oxytocin', 'Oxytocin', 0, 1, NOW()),
  ('stage3TxBloodLoss', 'IV', 'IV', 0, 1, NOW()),
  ('stage3TxBloodLoss', 'Bi-Manual Compression External/Internal', 'Bi-Manual Compression External/Internal', 0, 1, NOW()),
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
  ('newbornExamExtremities', 'Normal creases on hands & feet', 'Normal creases on hands & feet', 0, 1, NOW()),
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
  ('postpartumCheckBabySSInfection', 'Tachycordia', 'Tachycordia', 0, 1, NOW()),
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
  ('postpartumCheckMotherSSInfection', 'Tachycordia', 'Tachycordia', 0, 1, NOW()),
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

SELECT 'vaccinationType' AS 'Loading' FROM DUAL;
INSERT INTO `vaccinationType`
  (name, description, sortOrder, updatedBy, updatedAt)
VALUES
  ('Tetanus Toxoid', 'Tetanus Toxoid', 0, 1, NOW())
;

SELECT 'medicationType' AS 'Loading' FROM DUAL;
INSERT INTO `medicationType`
  (name, description, sortOrder, updatedBy, updatedAt)
VALUES
  ('Mebendazole 500mg PO', 'Mebendazole 500mg PO', 5, 1, NOW()),
  ('Albendazole 400mg PO', 'Albendazole 400mg PO', 0, 1, NOW()),
  ('Ferrous Sulfate', 'Ferrous Sulfate', 1, 1, NOW()),
  ('Ferrous Fumarate', 'Ferrous Fumarate', 2, 1, NOW()),
  ('Multivitamin', 'Multivitamin', 3, 1, NOW()),
  ('Prenatal Vitamin', 'Prenatal Vitamin', 4, 1, NOW())
;

-- Load risk codes.
SELECT 'riskCode' AS 'Loading' FROM DUAL;
INSERT INTO `riskCode`
  (name, riskType, description)
VALUES
  ('A1', 'Present', 'Age > 35'),
  ('A2', 'Present', 'Age < 18'),
  ('B1', 'Present', 'Height < 4\' 9"'),
  ('B2', 'Present', 'Underweight'),
  ('B3', 'Present', 'Overweight'),
  ('C', 'Present', '4 or more children'),
  ('F', 'Present', 'Less than 3 years since last birth'),
  ('D1', 'ObHx', 'Hx C/s'),
  ('D2', 'ObHx', 'Hx stillbirth or neonatal death within 7 days'),
  ('D3', 'ObHx', 'Hx anenatal bleeding'),
  ('D4', 'ObHx', 'Hx hemorrhage'),
  ('D5', 'ObHx', 'Hx convulsions'),
  ('D6', 'ObHx', 'Hx forceps or vacuum'),
  ('D7', 'ObHx', 'Hx malpresentation'),
  ('E1', 'MedHx', 'Hx TB'),
  ('E2', 'MedHx', 'Hx heart disease'),
  ('E3', 'MedHx', 'Hx diabetes'),
  ('E4', 'MedHx', 'Hx dx asthma'),
  ('E5', 'MedHx', 'Hx Goiter'),
  ('E6', 'MedHx', 'Hx hypertension'),
  ('E7', 'MedHx', 'Hx malaria'),
  ('E8', 'MedHx', 'Hx parasites'),
  ('G1', 'Lifestyle', 'Smoking'),
  ('G2', 'Lifestyle', 'Drink alcohol'),
  ('G3', 'Lifestyle', 'Multiple partners'),
  ('G4', 'Lifestyle', 'Living with person with HIV/AIDS'),
  ('G5', 'Lifestyle', 'Exposure to communicable diseases'),
  ('G6', 'Lifestyle', 'Victim of violence')
;

-- Load default tests per client specifications.
SELECT 'labSuite' AS 'Loading' FROM DUAL;
INSERT INTO `labSuite`
  (name, description, category, updatedBy, updatedAt)
VALUES
  ('Blood', '', 'Blood',  1, NOW()),
  ('Urinalysis', '', 'Urinalysis', 1, NOW()),
  ('Wet mount', '', 'Wet mount', 1, NOW()),
  ('Gram stain', '', 'Gram stain', 1, NOW()),
  ('UltraSound', '', 'UltraSound', 1, NOW())
;

SELECT 'labTest' AS 'Loading' FROM DUAL;
INSERT INTO `labTest`
  (name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger,
   maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt)
VALUES
  -- Blood
  ('Hematocrit', 'Hct', '30-40', '%', NULL, NULL, 0, 60, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, NOW()),
  ('Hemoglobin', 'Hgb', '100-140', 'g/L', NULL, NULL, 0, 170, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, NOW()),
  ('Hepatitis B Surface Antigen', 'HBsAg', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, NOW()),
  ('Blood Type', 'Blood type', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, NOW()),
  ('RPR', 'RPR', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, NOW()),
  ('VDRL', 'VDRL', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, NOW()),
  -- Urinalysis
  ('Albumin/Protein', 'Albumin/Protein', NULL, 'mg/dL', NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, NOW()),
  ('Sugar/Glucose', 'Sugar/Glucose', NULL, 'mg/dL', NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, NOW()),
  ('Epithelial Cells-Urine', 'Epithelial Cells-Urine', '0-5', 'hpf', NULL, NULL, 0, 1000, 1, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, NOW()),
  ('White Blood Cells', 'wbc', '0-4', 'hpf', NULL, NULL, 0, 1000, 1, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, NOW()),
  ('Red Blood Cells', 'rbc-urine', NULL, 'hpf', NULL, NULL, 0, 1000, 1, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, NOW()),
  ('Bacteria', 'Bacteria', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, NOW()),
  ('Mucous', 'Mucous', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, NOW()),
  ('Trichomonas-Urine', 'Trichomonas-Urine', '0', 'hpf', NULL, NULL, 0, 1000, 1, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, NOW()),
  ('Trichomonas-WetMount', 'Trichomonas-WetMount', '0', 'hpf', NULL, NULL, 0, 1000, 1, 0,
    (SELECT id FROM labSuite WHERE name = 'Wet mount'), 1, NOW()),
  ('Yeast-Urine', 'Yeast-Urine', NULL, 'hpf', NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Wet mount'), 1, NOW()),
  ('Clue Cells', 'Clue Cells', NULL, 'hpf', NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Wet mount'), 1, NOW()),
  -- Gram stain
  ('Red Blood Cells-Gram', 'rbc-Gram', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Leukocytes', 'Leukocytes', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Epithelial Cells-Gram', 'Epithelial Cells-Gram', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Gram negative (-) cocci', 'Gram negative (-) cocci', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Gram positive (+) cocci', 'Gram positive (+) cocci', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Gram negative (-) coccobacilli', 'Gram negative (-) coccobacilli', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Gram positive (+) cocci in pairs', 'Gram positive (+) cocci in pairs', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Gram negative (-) bacilli', 'Gram negative (-) bacilli', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Gram positive (+) bacilli', 'Gram positive (+) bacilli', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Gram negative (-) extracellular diplococci', 'Gram negative (-) extracellular diplococci', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Gram negative (-) intracellular diplococci', 'Gram negative (-) intracellular diplococci', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Yeast-Gram', 'Yeast-Gram', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Fungi', 'Fungi', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Trichomonads', 'Trichomonads', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  ('Sperm Cells', 'Sperm Cells', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, NOW()),
  -- UltraSound
  ('UltraSound', 'UltraSound', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1,
    (SELECT id FROM labSuite WHERE name = 'UltraSound'), 1, NOW())
;

SELECT 'labTestValue' AS 'Loading' FROM DUAL;
INSERT INTO `labTestValue`
  (value, labTest_id, updatedBy, updatedAt)
VALUES
  -- HBsAg
  ('Reactive', (SELECT id FROM labTest WHERE abbrev = 'HBsAg'), 1, NOW()),
  ('Non-Reactive', (SELECT id FROM labTest WHERE abbrev = 'HBsAg'), 1, NOW()),
  ('A', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('A-', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('A+', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('B', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('B-', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('B+', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('O', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('O-', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('O+', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('AB', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('AB-', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('AB+', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, NOW()),
  ('+', (SELECT id FROM labTest WHERE abbrev = 'RPR'), 1, NOW()),
  ('-', (SELECT id FROM labTest WHERE abbrev = 'RPR'), 1, NOW()),
  ('+', (SELECT id FROM labTest WHERE abbrev = 'VDRL'), 1, NOW()),
  ('-', (SELECT id FROM labTest WHERE abbrev = 'VDRL'), 1, NOW()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, NOW()),
  ('Trace', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, NOW()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, NOW()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, NOW()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, NOW()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, NOW()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, NOW()),
  ('Trace', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, NOW()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, NOW()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, NOW()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, NOW()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Urine'), 1, NOW()),
  ('Moderate', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Urine'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Urine'), 1, NOW()),
  ('TNTC', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Urine'), 1, NOW()),
  ('TNTC', (SELECT id FROM labTest WHERE abbrev = 'wbc'), 1, NOW()),
  ('TNTC', (SELECT id FROM labTest WHERE abbrev = 'rbc-urine'), 1, NOW()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, NOW()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, NOW()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, NOW()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, NOW()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, NOW()),
  ('Abundant', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, NOW()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, NOW()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, NOW()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, NOW()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, NOW()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, NOW()),
  ('Abundant', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, NOW()),
  ('TNTC', (SELECT id FROM labTest WHERE abbrev = 'Trichomonas-Urine'), 1, NOW()),
  ('v. trichomonas seen or noted', (SELECT id FROM labTest WHERE abbrev = 'Trichomonas-Urine'), 1, NOW()),
  ('TNTC', (SELECT id FROM labTest WHERE abbrev = 'Trichomonas-WetMount'), 1, NOW()),
  ('v. trichomonas seen or noted', (SELECT id FROM labTest WHERE abbrev = 'Trichomonas-WetMount'), 1, NOW()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, NOW()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, NOW()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, NOW()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, NOW()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, NOW()),
  ('Abundant', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, NOW()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, NOW()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, NOW()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, NOW()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, NOW()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, NOW()),
  ('Abundant', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, NOW()),
  ('Present', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, NOW()),
  ('Absent', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'rbc-Gram'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'rbc-Gram'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'rbc-Gram'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'rbc-Gram'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Leukocytes'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Leukocytes'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Leukocytes'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Leukocytes'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Gram'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Gram'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Gram'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Gram'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) cocci'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) cocci'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) cocci'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) cocci'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) coccobacilli'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) coccobacilli'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) coccobacilli'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) coccobacilli'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci in pairs'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci in pairs'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci in pairs'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci in pairs'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) bacilli'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) bacilli'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) bacilli'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) bacilli'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) bacilli'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) bacilli'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) bacilli'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) bacilli'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) extracellular diplococci'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) extracellular diplococci'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) extracellular diplococci'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) extracellular diplococci'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) intracellular diplococci'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) intracellular diplococci'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) intracellular diplococci'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) intracellular diplococci'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Gram'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Gram'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Gram'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Gram'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Fungi'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Fungi'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Fungi'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Fungi'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Trichomonads'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Trichomonads'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Trichomonads'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Trichomonads'), 1, NOW()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Sperm Cells'), 1, NOW()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Sperm Cells'), 1, NOW()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Sperm Cells'), 1, NOW()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Sperm Cells'), 1, NOW())
;


SELECT 'customFieldType' AS 'Loading' FROM DUAL;
INSERT INTO `customFieldType`
  (name, title, description, label, valueFieldName)
VALUES
  ('Agdao', 'In Agdao?', 'Does the client reside in Agdao?', 'Agdao?', 'booleanVal');


SELECT 'roFieldsByRole' AS 'Loading' FROM DUAL;
INSERT INTO `roFieldsByRole`
  (roleName, tableName, fieldName)
VALUES
  ('clerk', 'prenatalExam', 'fh'),
  ('clerk', 'prenatalExam', 'fhNote'),
  ('clerk', 'prenatalExam', 'fht'),
  ('clerk', 'prenatalExam', 'fhtNote'),
  ('clerk', 'prenatalExam', 'pos'),
  ('clerk', 'prenatalExam', 'mvmt'),
  ('clerk', 'prenatalExam', 'edema'),
  ('clerk', 'prenatalExam', 'risk'),
  ('clerk', 'prenatalExam', 'vitamin'),
  ('clerk', 'prenatalExam', 'pray'),
  ('clerk', 'prenatalExam', 'note'),
  ('clerk', 'prenatalExam', 'returnDate'),
  ('clerk', 'pregnancy', 'lmp'),
  ('clerk', 'pregnancy', 'sureLMP'),
  ('clerk', 'pregnancy', 'alternateEdd'),
  ('clerk', 'pregnancy', 'useAlternateEdd'),
  ('clerk', 'pregnancy', 'riskNote'),
  ('clerk', 'pregnancy', 'pregnancyEndDate'),
  ('clerk', 'pregnancy', 'pregnancyEndResult'),
  ('clerk', 'risk', 'riskCode');

SELECT 'pregnoteType' AS 'Loading' FROM DUAL;
INSERT INTO `pregnoteType`
  (name, description)
VALUES
  ('prenatalProgress', 'Progress notes for prenatal exams.');

SELECT 'keyValue' AS 'Loading' FROM DUAL;
INSERT INTO keyValue
  (kvKey, kvValue, description, valueType, acceptableValues, systemOnly)
VALUES
  ('siteShortName', 'YourClinic', 'A relatively short name for the clinic, i.e. under 10 characters.', 'text', '', 0),
  ('siteLongName', 'Your Full Clinic Name', 'The full name for the clinic.', 'text', '', 0),
  ('defaultCity', 'Home Town Name', 'The default locality you want to use that most of your patients come from.', 'text', '', 0),
  ('searchRowsPerPage', '20', 'The number of rows of search results to display per page.', 'integer', '', 0),
  ('birthCertInstitution', 'YourInstitution', 'Used in the birth certificate form, field #4.', 'text', '', 0),
  ('birthCertProvince', 'YourProvince', 'Used in the birth certificate form, field #4.', 'text', '', 0),
  ('birthCertCity', 'YourCity', 'Used in the birth certificate form, field #4.', 'text', '', 0),
  ('birthCertProvinceTop', 'YourProvince', 'Used at the TOP of the birth certificate form in the Province field.', 'text', '', 0),
  ('birthCertCityTop', 'YourCity', 'Used at the TOP of the birth certificate form in the City/Municipality field.', 'text', '', 0)
;

SELECT 'babyMedicationType' AS 'Loading' FROM DUAL;
INSERT INTO babyMedicationType
  (name, description, useLocation, updatedBy, updatedAt)
VALUES
  ('Vitamin K', 'Vitamin K', 1, 1, NOW()),
  ('Eye Ointment', 'Eye Ointment', 0, 1, NOW())
;

SELECT 'babyVaccinationType' AS 'Loading' FROM DUAL;
INSERT INTO babyVaccinationType
  (name, description, useLocation, updatedBy, updatedAt)
VALUES
  ('Hep B', 'Hep B', 1, 1, NOW()),
  ('BCG (Bacillus Calmette-Guerin)', 'BCG (Bacillus Calmette-Guerin)', 0, 1, NOW())
;

SELECT 'babyLabType' AS 'Loading' FROM DUAL;
INSERT INTO babyLabType
  (name, description, fld1Name, fld1Type, fld2Name, fld2Type,
  fld3Name, fld3Type, fld4Name, fld4Type, active, updatedBy, updatedAt)
VALUES
  ('Newborn Screening', 'Newborn Screening', 'Filter Card #', 'Integer',
  'Result', 'String', NULL, NULL, NULL, NULL, 1, 1, NOW())
;

SELECT 'motherMedicationType' AS 'Loading' FROM DUAL;
INSERT INTO motherMedicationType
  (name, description, updatedBy, updatedAt)
VALUES
  ('Vitamin A', 'Vitamin A', 1, NOW())
;

