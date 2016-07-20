-- ----------------------------------------------------
-- load_default_data_sqlite.sql
-- Loads the default data.
-- Note: double dollar signs are used as statement delimiters.
-- ----------------------------------------------------
PRAGMA foreign_keys = OFF$$

-- Load the roles.
INSERT INTO `role`
  (name, description, updatedBy, updatedAt)
VALUES
  ('administrator', 'Manages users, vaccination and lab types, and the system.', 1, datetime()),
  ('guard', 'Patient check-in and check-out.', 1, datetime()),
  ('clerk', 'No patient care with exception of BP and Wgt. Manages priority list.', 1, datetime()),
  ('attending', 'Patient care but always requires a supervisor.', 1, datetime()),
  ('supervisor', 'Patient care.', 1, datetime())
$$


-- Load the default user that can be used to administer the system.
-- Note: password hash is for password 'admin'
INSERT INTO `user`
  (username, firstname, lastname, password, note, role_id, updatedBy, updatedAt)
VALUES
  ('admin', 'admin', 'admin', '$2a$10$r93uzyhs73Bh88Hco63wTuOyq8rLg2jy2mWnP8g03pu8fkc9mQDb6',
  'This is the default admin account with password of "admin". In production systems, this account should be disabled once another administrator is created.',
  1, 1, datetime())
$$

-- Create some basic events
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
$$

-- Create the data for at least one select option.
INSERT INTO `selectData`
  (name, selectKey, label, selected, updatedBy, updatedAt)
VALUES
  ('maritalStatus', '', 'Unknown', 1, 1, datetime()),
  ('maritalStatus', 'Single', 'Single', 0, 1, datetime()),
  ('maritalStatus', 'Live-In', 'Live-In', 0, 1, datetime()),
  ('maritalStatus', 'Married', 'Married', 0, 1, datetime()),
  ('maritalStatus', 'Other', 'Other', 0, 1, datetime()),
  ('religion', '', 'Unknown', 1, 1, datetime()),
  ('religion', 'Christian', 'Christian', 0, 1, datetime()),
  ('religion', 'Roman Catholic', 'Roman Catholic', 0, 1, datetime()),
  ('religion', 'Muslim/Islam', 'Muslim/Islam', 0, 1, datetime()),
  ('religion', 'SDA', 'SDA', 0, 1, datetime()),
  ('religion', 'INC', 'INC', 0, 1, datetime()),
  ('religion', 'LDS', 'LDS', 0, 1, datetime()),
  ('religion', 'Other', 'Other', 0, 1, datetime()),
  ('education', '', 'Unknown', 1, 1, datetime()),
  ('education', 'Elem level', 'Elem level', 0, 1, datetime()),
  ('education', 'Elem grad', 'Elem grad', 0, 1, datetime()),
  ('education', 'HS level', 'HS level', 0, 1, datetime()),
  ('education', 'HS grad', 'HS grad', 0, 1, datetime()),
  ('education', 'Vocational', 'Vocational', 0, 1, datetime()),
  ('education', 'College level', 'College level', 0, 1, datetime()),
  ('education', 'College grad', 'College grad', 0, 1, datetime()),
  ('edema', 'none', 'None', 1, 1, datetime()),
  ('edema', '+1', '+1', 0, 1, datetime()),
  ('edema', '+2', '+2', 0, 1, datetime()),
  ('edema', '+3', '+3', 0, 1, datetime()),
  ('edema', '+4', '+4', 0, 1, datetime()),
  ('incomePeriod', 'Day', 'Day', 0, 1, datetime()),
  ('incomePeriod', 'Week', 'Week', 0, 1, datetime()),
  ('incomePeriod', 'Two Weeks', 'Two Weeks', 0, 1, datetime()),
  ('incomePeriod', 'Twice Monthly', 'Twice Monthly', 0, 1, datetime()),
  ('incomePeriod', 'Month', 'Month', 1, 1, datetime()),
  ('incomePeriod', 'Quarter', 'Quarter', 0, 1, datetime()),
  ('incomePeriod', 'Year', 'Year', 0, 1, datetime()),
  ('yesNoUnanswered', '', '', 1, 1, datetime()),
  ('yesNoUnanswered', 'Y', 'Yes', 0, 1, datetime()),
  ('yesNoUnanswered', 'N', 'No', 0, 1, datetime()),
  ('yesNoUnknown', '', '', 1, 1, datetime()),
  ('yesNoUnknown', 'Y', 'Yes', 0, 1, datetime()),
  ('yesNoUnknown', 'N', 'No', 0, 1, datetime()),
  ('yesNoUnknown', '?', 'Unknown', 0, 1, datetime()),
  ('episTear', '', '', 1, 1, datetime()),
  ('episTear', 'T', 'Tear', 0, 1, datetime()),
  ('episTear', 'E', 'Epis', 0, 1, datetime()),
  ('episTear', 'N', 'No', 0, 1, datetime()),
  ('episTear', '?', 'Unknown', 0, 1, datetime()),
  ('attendant', 'Midwife', 'Midwife', 1, 1, datetime()),
  ('attendant', 'Doctor', 'Doctor', 0, 1, datetime()),
  ('attendant', 'Hilot', 'Hilot', 0, 1, datetime()),
  ('attendant', 'Other', 'Other', 0, 1, datetime()),
  ('wksMthsYrs', '', '', 1, 1, datetime()),
  ('wksMthsYrs', 'Weeks', 'Weeks', 0, 1, datetime()),
  ('wksMthsYrs', 'Months', 'Months', 0, 1, datetime()),
  ('wksMthsYrs', 'Years', 'Years', 0, 1, datetime()),
  ('wksMths', '', '', 1, 1, datetime()),
  ('wksMths', 'Weeks', 'Weeks', 0, 1, datetime()),
  ('wksMths', 'Months', 'Months', 0, 1, datetime()),
  ('maleFemale', '', '', 1, 1, datetime()),
  ('maleFemale', 'F', 'Female', 0, 1, datetime()),
  ('maleFemale', 'M', 'Male', 0, 1, datetime()),
  ('internalExternal', '', '', 1, 1, datetime()),
  ('internalExternal', 'Internal', 'Internal', 0, 1, datetime()),
  ('internalExternal', 'External', 'External', 0, 1, datetime()),
  ('location', 'Mercy', 'Mercy', 1, 1, datetime()),
  ('location', 'Agdao', 'Agdao', 0, 1, datetime()),
  ('location', 'Isla Verda', 'Isla Verda', 0, 1, datetime()),
  ('location', 'Samal', 'Samal', 0, 1, datetime()),
  ('scheduleType', '', '', 1, 1, datetime()),
  ('scheduleType', 'Prenatal', 'Prenatal', 0, 1, datetime()),
  ('dayOfWeek', '', '', 1, 1, datetime()),
  ('dayOfWeek', 'Monday', 'Monday', 0, 1, datetime()),
  ('dayOfWeek', 'Tuesday', 'Tuesday', 0, 1, datetime()),
  ('dayOfWeek', 'Wednesday', 'Wednesday', 0, 1, datetime()),
  ('dayOfWeek', 'Thursday', 'Thursday', 0, 1, datetime()),
  ('dayOfWeek', 'Friday', 'Friday', 0, 1, datetime()),
  ('dayOfWeek', 'Saturday', 'Saturday', 0, 1, datetime()),
  ('dayOfWeek', 'Sunday', 'Sunday', 0, 1, datetime()),
  ('placeOfBirth', '', '', 1, 1, datetime()),
  ('placeOfBirth', 'MMC', 'MMC', 0, 1, datetime()),
  ('placeOfBirth', 'Home', 'Home', 0, 1, datetime()),
  ('placeOfBirth', 'SPMC', 'SPMC', 0, 1, datetime()),
  ('placeOfBirth', 'Hospital', 'Hospital', 0, 1, datetime()),
  ('placeOfBirth', 'Lying-in Clinic', 'Lying-in Clinic', 0, 1, datetime()),
  ('placeOfBirth', 'Other', 'Other', 0, 1, datetime()),
  ('referrals', 'Dr/Dentist', 'Dr/Dentist', 0, 1, datetime()),
  ('referrals', 'U/A', 'U/A', 0, 1, datetime()),
  ('referrals', 'Hgb', 'Hgb', 0, 1, datetime()),
  ('referrals', 'U/A & Hgb', 'U/A & Hgb', 0, 1, datetime()),
  ('referrals', 'All labs', 'All labs', 0, 1, datetime()),
  ('teachingTopics', 'Nutr + FD', 'Nutr + FD', 1, 1, datetime()),
  ('teachingTopics', 'BF', 'BF', 0, 1, datetime()),
  ('teachingTopics', 'FP', 'FP', 0, 1, datetime()),
  ('teachingTopics', 'L & D', 'L & D', 0, 1, datetime()),
  ('teachingTopics', 'PP/NB', 'PP/NB', 0, 1, datetime()),
  ('teachingTopics', 'Cln Catch', 'Cln Catch', 0, 1, datetime()),
  ('teachingTopics', 'Labr/ROM', 'Labr/ROM', 0, 1, datetime()),
  ('teachingTopics', 'Iron/Vit', 'Iron/Vit', 0, 1, datetime())
$$

INSERT INTO `vaccinationType`
  (name, description, sortOrder, updatedBy, updatedAt)
VALUES
  ('Tetanus Toxoid', 'Tetanus Toxoid', 0, 1, datetime())
$$

INSERT INTO `medicationType`
  (name, description, sortOrder, updatedBy, updatedAt)
VALUES
  ('Mebendazole 500mg PO', 'Mebendazole 500mg PO', 5, 1, datetime()),
  ('Albendazole 400mg PO', 'Albendazole 400mg PO', 0, 1, datetime()),
  ('Ferrous Sulfate', 'Ferrous Sulfate', 1, 1, datetime()),
  ('Ferrous Fumarate', 'Ferrous Fumarate', 2, 1, datetime()),
  ('Multivitamin', 'Multivitamin', 3, 1, datetime()),
  ('Prenatal Vitamin', 'Prenatal Vitamin', 4, 1, datetime())
$$

-- Load risk codes.
INSERT INTO `riskCode`
  (name, riskType, description)
VALUES
  ('A1', 'Present', 'Age > 35'),
  ('A2', 'Present', 'Age < 18'),
  ('B1', 'Present', 'Height < 4'' 9"'),
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
$$

-- Load default tests per client specifications.
INSERT INTO `labSuite`
  (name, description, category, updatedBy, updatedAt)
VALUES
  ('Blood', '', 'Blood',  1, datetime()),
  ('Urinalysis', '', 'Urinalysis', 1, datetime()),
  ('Wet mount', '', 'Wet mount', 1, datetime()),
  ('Gram stain', '', 'Gram stain', 1, datetime()),
  ('UltraSound', '', 'UltraSound', 1, datetime())
$$

INSERT INTO `labTest`
  (name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger,
   maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt)
VALUES
  ('Hematocrit', 'Hct', '30-40', '%', NULL, NULL, 0, 60, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, datetime()),
  ('Hemoglobin', 'Hgb', '100-140', 'g/L', NULL, NULL, 0, 170, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, datetime()),
  ('Hepatitis B Surface Antigen', 'HBsAg', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, datetime()),
  ('Blood Type', 'Blood type', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, datetime()),
  ('RPR', 'RPR', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, datetime()),
  ('VDRL', 'VDRL', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Blood'), 1, datetime()),
  ('Albumin/Protein', 'Albumin/Protein', NULL, 'mg/dL', NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, datetime()),
  ('Sugar/Glucose', 'Sugar/Glucose', NULL, 'mg/dL', NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, datetime()),
  ('Epithelial Cells-Urine', 'Epithelial Cells-Urine', '0-5', 'hpf', NULL, NULL, 0, 1000, 1, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, datetime()),
  ('White Blood Cells', 'wbc', '0-4', 'hpf', NULL, NULL, 0, 1000, 1, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, datetime()),
  ('Red Blood Cells', 'rbc-urine', NULL, 'hpf', NULL, NULL, 0, 1000, 1, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, datetime()),
  ('Bacteria', 'Bacteria', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, datetime()),
  ('Mucous', 'Mucous', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, datetime()),
  ('Trichomonas-Urine', 'Trichomonas-Urine', '0', 'hpf', NULL, NULL, 0, 1000, 1, 0,
    (SELECT id FROM labSuite WHERE name = 'Urinalysis'), 1, datetime()),
  ('Trichomonas-WetMount', 'Trichomonas-WetMount', '0', 'hpf', NULL, NULL, 0, 1000, 1, 0,
    (SELECT id FROM labSuite WHERE name = 'Wet mount'), 1, datetime()),
  ('Yeast-Urine', 'Yeast-Urine', NULL, 'hpf', NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Wet mount'), 1, datetime()),
  ('Clue Cells', 'Clue Cells', NULL, 'hpf', NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Wet mount'), 1, datetime()),
  ('Red Blood Cells-Gram', 'rbc-Gram', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Leukocytes', 'Leukocytes', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Epithelial Cells-Gram', 'Epithelial Cells-Gram', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Gram negative (-) cocci', 'Gram negative (-) cocci', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Gram positive (+) cocci', 'Gram positive (+) cocci', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Gram negative (-) coccobacilli', 'Gram negative (-) coccobacilli', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Gram positive (+) cocci in pairs', 'Gram positive (+) cocci in pairs', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Gram negative (-) bacilli', 'Gram negative (-) bacilli', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Gram positive (+) bacilli', 'Gram positive (+) bacilli', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Gram negative (-) extracellular diplococci', 'Gram negative (-) extracellular diplococci', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Gram negative (-) intracellular diplococci', 'Gram negative (-) intracellular diplococci', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Yeast-Gram', 'Yeast-Gram', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Fungi', 'Fungi', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Trichomonads', 'Trichomonads', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('Sperm Cells', 'Sperm Cells', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0,
    (SELECT id FROM labSuite WHERE name = 'Gram stain'), 1, datetime()),
  ('UltraSound', 'UltraSound', NULL, NULL, NULL, NULL, NULL, NULL, 0, 1,
    (SELECT id FROM labSuite WHERE name = 'UltraSound'), 1, datetime())
$$

INSERT INTO `labTestValue`
  (value, labTest_id, updatedBy, updatedAt)
VALUES
  ('Reactive', (SELECT id FROM labTest WHERE abbrev = 'HBsAg'), 1, datetime()),
  ('Non-Reactive', (SELECT id FROM labTest WHERE abbrev = 'HBsAg'), 1, datetime()),
  ('A', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('A-', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('A+', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('B', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('B-', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('B+', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('O', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('O-', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('O+', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('AB', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('AB-', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('AB+', (SELECT id FROM labTest WHERE abbrev = 'Blood type'), 1, datetime()),
  ('+', (SELECT id FROM labTest WHERE abbrev = 'RPR'), 1, datetime()),
  ('-', (SELECT id FROM labTest WHERE abbrev = 'RPR'), 1, datetime()),
  ('+', (SELECT id FROM labTest WHERE abbrev = 'VDRL'), 1, datetime()),
  ('-', (SELECT id FROM labTest WHERE abbrev = 'VDRL'), 1, datetime()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, datetime()),
  ('Trace', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, datetime()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, datetime()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, datetime()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, datetime()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Albumin/Protein'), 1, datetime()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, datetime()),
  ('Trace', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, datetime()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, datetime()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, datetime()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, datetime()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Sugar/Glucose'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Urine'), 1, datetime()),
  ('Moderate', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Urine'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Urine'), 1, datetime()),
  ('TNTC', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Urine'), 1, datetime()),
  ('TNTC', (SELECT id FROM labTest WHERE abbrev = 'wbc'), 1, datetime()),
  ('TNTC', (SELECT id FROM labTest WHERE abbrev = 'rbc-urine'), 1, datetime()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, datetime()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, datetime()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, datetime()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, datetime()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, datetime()),
  ('Abundant', (SELECT id FROM labTest WHERE abbrev = 'Bacteria'), 1, datetime()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, datetime()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, datetime()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, datetime()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, datetime()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, datetime()),
  ('Abundant', (SELECT id FROM labTest WHERE abbrev = 'Mucous'), 1, datetime()),
  ('TNTC', (SELECT id FROM labTest WHERE abbrev = 'Trichomonas-Urine'), 1, datetime()),
  ('v. trichomonas seen or noted', (SELECT id FROM labTest WHERE abbrev = 'Trichomonas-Urine'), 1, datetime()),
  ('TNTC', (SELECT id FROM labTest WHERE abbrev = 'Trichomonas-WetMount'), 1, datetime()),
  ('v. trichomonas seen or noted', (SELECT id FROM labTest WHERE abbrev = 'Trichomonas-WetMount'), 1, datetime()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, datetime()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, datetime()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, datetime()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, datetime()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, datetime()),
  ('Abundant', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Urine'), 1, datetime()),
  ('0', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, datetime()),
  ('+1', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, datetime()),
  ('+2', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, datetime()),
  ('+3', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, datetime()),
  ('+4', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, datetime()),
  ('Abundant', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, datetime()),
  ('Present', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, datetime()),
  ('Absent', (SELECT id FROM labTest WHERE abbrev = 'Clue Cells'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'rbc-Gram'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'rbc-Gram'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'rbc-Gram'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'rbc-Gram'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Leukocytes'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Leukocytes'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Leukocytes'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Leukocytes'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Gram'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Gram'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Gram'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Epithelial Cells-Gram'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) cocci'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) cocci'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) cocci'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) cocci'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) coccobacilli'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) coccobacilli'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) coccobacilli'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) coccobacilli'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci in pairs'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci in pairs'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci in pairs'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) cocci in pairs'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) bacilli'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) bacilli'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) bacilli'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) bacilli'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) bacilli'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) bacilli'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) bacilli'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram positive (+) bacilli'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) extracellular diplococci'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) extracellular diplococci'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) extracellular diplococci'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) extracellular diplococci'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) intracellular diplococci'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) intracellular diplococci'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) intracellular diplococci'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Gram negative (-) intracellular diplococci'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Gram'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Gram'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Gram'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Yeast-Gram'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Fungi'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Fungi'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Fungi'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Fungi'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Trichomonads'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Trichomonads'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Trichomonads'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Trichomonads'), 1, datetime()),
  ('Rare', (SELECT id FROM labTest WHERE abbrev = 'Sperm Cells'), 1, datetime()),
  ('Few', (SELECT id FROM labTest WHERE abbrev = 'Sperm Cells'), 1, datetime()),
  ('Mod', (SELECT id FROM labTest WHERE abbrev = 'Sperm Cells'), 1, datetime()),
  ('Many', (SELECT id FROM labTest WHERE abbrev = 'Sperm Cells'), 1, datetime())
$$


INSERT INTO `customFieldType`
  (name, title, description, label, valueFieldName)
VALUES
  ('Agdao', 'In Agdao?', 'Does the client reside in Agdao?', 'Agdao?', 'booleanVal')$$


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
  ('clerk', 'risk', 'riskCode')$$

INSERT INTO `pregnoteType`
  (name, description)
VALUES
  ('prenatalProgress', 'Progress notes for prenatal exams.')$$

PRAGMA foreign_keys = ON$$
