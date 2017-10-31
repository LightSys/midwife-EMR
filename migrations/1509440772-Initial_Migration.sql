-- Migration: Initial Migration
-- Created at: 2017-10-31 17:06:12
-- ====  UP  ====

BEGIN;

SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `keyValue` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kvKey VARCHAR(50) NOT NULL,
  kvValue VARCHAR(200) NULL,
  description VARCHAR(200) NULL,
  valueType ENUM('text', 'list', 'integer', 'decimal', 'date', 'boolean') NOT NULL,
  acceptableValues VARCHAR(500) NULL,
  systemOnly TINYINT NOT NULL DEFAULT 0,
  UNIQUE(kvKey)
);

CREATE TABLE IF NOT EXISTS `user` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  firstname VARCHAR(30) NOT NULL,
  lastname VARCHAR(30) NOT NULL,
  password VARCHAR(60) NOT NULL,
  email VARCHAR(100) NULL,
  lang VARCHAR(10) NULL,
  shortName VARCHAR(100) NULL,
  displayName VARCHAR(100) NULL,
  status BOOLEAN NOT NULL DEFAULT 1,
  note VARCHAR(300) NULL,
  isCurrentTeacher BOOLEAN NULL DEFAULT 0,
  role_id INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (username),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `role` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (name),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

-- Add after the role table has been created.
ALTER TABLE user ADD FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE NO ACTION ON UPDATE NO ACTION;
SHOW WARNINGS;

-- Definition required by the express-mysql-session module.
CREATE TABLE IF NOT EXISTS `sessions` (
  `session_id` VARCHAR(255) COLLATE utf8_bin NOT NULL,
  `expires` INT(11) UNSIGNED NOT NULL,
  `data` text COLLATE utf8_bin,
  PRIMARY KEY (`session_id`)
) CHARACTER SET utf8 COLLATE utf8_bin;
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `dohSeq` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  year CHAR(4) NOT NULL,
  sequence INT NOT NULL
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `patient` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  dohID VARCHAR(10) NULL,
  dob DATE NULL,
  generalInfo VARCHAR(8192) NULL,
  ageOfMenarche TINYINT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE patient_dohid_idx (dohID),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `pregnancy` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(70) NOT NULL,
  lastname VARCHAR(70) NOT NULL,
  maidenname VARCHAR(70) NULL,
  nickname VARCHAR(70) NULL,
  religion VARCHAR(50) NULL,
  maritalStatus VARCHAR(50) NULL,
  telephone VARCHAR(20) NULL,
  work VARCHAR(50) NULL,
  education VARCHAR(70) NULL,
  clientIncome INT NULL,
  clientIncomePeriod VARCHAR(15) NULL,
  address1 varchar(150) DEFAULT NULL,
  address2 varchar(150) DEFAULT NULL,
  address3 varchar(150) DEFAULT NULL,
  address4 varchar(150) DEFAULT NULL,
  city varchar(100) DEFAULT NULL,
  state varchar(150) DEFAULT NULL,
  postalCode varchar(50) DEFAULT NULL,
  country varchar(150) DEFAULT NULL,
  gravidaNumber TINYINT NULL,
  lmp DATE NULL,
  sureLMP BOOLEAN NULL DEFAULT 0,
  warning BOOLEAN NULL DEFAULT 0,
  riskNote VARCHAR(2000) NULL,
  alternateEdd DATE NULL,
  useAlternateEdd BOOLEAN NULL DEFAULT 0,
  doctorConsultDate DATE NULL,
  dentistConsultDate DATE NULL,
  mbBook BOOLEAN NULL,
  whereDeliver VARCHAR(100) NULL,
  fetuses TINYINT NULL,
  monozygotic TINYINT NULL,
  pregnancyEndDate DATE NULL,
  pregnancyEndResult VARCHAR(100) NULL,
  iugr BOOLEAN NULL,
  note VARCHAR(2000) NULL,
  numberRequiredTetanus TINYINT NULL,
  invertedNipples BOOLEAN NULL,
  hasUS BOOLEAN NULL,
  wantsUS BOOLEAN NULL,
  gravida TINYINT NULL,
  stillBirths TINYINT NULL,
  abortions TINYINT NULL,
  living TINYINT NULL,
  para TINYINT NULL,
  term TINYINT NULL,
  preterm TINYINT NULL,
  philHealthMCP BOOLEAN NULL DEFAULT 0,
  philHealthNCP BOOLEAN NULL DEFAULT 0,
  philHealthID VARCHAR(12) NULL,
  philHealthApproved BOOLEAN NULL DEFAULT 0,
  transferOfCare DATETIME NULL,
  transferOfCareNote VARCHAR(1000) NULL DEFAULT '',
  currentlyVomiting BOOLEAN NULL,
  currentlyDizzy BOOLEAN NULL,
  currentlyFainting BOOLEAN NULL,
  currentlyBleeding BOOLEAN NULL,
  currentlyUrinationPain BOOLEAN NULL,
  currentlyBlurryVision BOOLEAN NULL,
  currentlySwelling BOOLEAN NULL,
  currentlyVaginalPain BOOLEAN NULL,
  currentlyVaginalItching BOOLEAN NULL,
  currentlyNone BOOLEAN NULL,
  useIodizedSalt CHAR(1) NULL DEFAULT '',
  takingMedication CHAR(1) NOT NULL DEFAULT '',
  planToBreastFeed CHAR(1) NOT NULL DEFAULT '',
  birthCompanion VARCHAR(30) NULL,
  practiceFamilyPlanning BOOLEAN NULL,
  practiceFamilyPlanningDetails VARCHAR(100) NULL,
  familyHistoryTwins BOOLEAN NULL,
  familyHistoryHighBloodPressure BOOLEAN NULL,
  familyHistoryDiabetes BOOLEAN NULL,
  familyHistoryHeartProblems BOOLEAN NULL,
  familyHistoryTB BOOLEAN NULL,
  familyHistorySmoking BOOLEAN NULL,
  familyHistoryNone BOOLEAN NULL,
  historyFoodAllergy BOOLEAN NULL,
  historyMedicineAllergy BOOLEAN NULL,
  historyAsthma BOOLEAN NULL,
  historyHeartProblems BOOLEAN NULL,
  historyKidneyProblems BOOLEAN NULL,
  historyHepatitis BOOLEAN NULL,
  historyGoiter BOOLEAN NULL,
  historyHighBloodPressure BOOLEAN NULL,
  historyHospitalOperation BOOLEAN NULL,
  historyBloodTransfusion BOOLEAN NULL,
  historySmoking BOOLEAN NULL,
  historyDrinking BOOLEAN NULL,
  historyNone BOOLEAN NULL,
  questionnaireNote VARCHAR(2000) NULL,
  partnerFirstname VARCHAR(70) NULL,
  partnerLastname VARCHAR(70) NULL,
  partnerAge INT NULL,
  partnerWork VARCHAR(70) NULL,
  partnerEducation VARCHAR(70) NULL,
  partnerIncome INT NULL,
  partnerIncomePeriod VARCHAR(15) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  patient_id INT NOT NULL,
  FOREIGN KEY (patient_id) REFERENCES patient (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

-- Look up tables for risk information.
CREATE TABLE IF NOT EXISTS `riskCode` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(40) NOT NULL,
  riskType VARCHAR(20) NOT NULL,
  description VARCHAR(250) NULL,
  UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS `risk` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pregnancy_id INT NOT NULL,
  riskCode INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (pregnancy_id, riskCode),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (riskCode) REFERENCES riskCode (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Look up table for vaccination.
CREATE TABLE IF NOT EXISTS `vaccinationType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(40) NOT NULL,
  description VARCHAR(250) NULL,
  sortOrder TINYINT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (name),
  UNIQUE(sortOrder),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `vaccination` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  vaccinationType INT NOT NULL,
  vacDate DATE NULL,
  vacMonth TINYINT NULL,
  vacYear INT NULL,
  administeredInternally BOOLEAN NOT NULL,
  note VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (vaccinationType) REFERENCES vaccinationType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `healthTeaching` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATE NOT NULL,
  topic VARCHAR(50) NOT NULL,
  teacher INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (teacher) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;


-- Lookup table for medication.
CREATE TABLE IF NOT EXISTS `medicationType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(40) NOT NULL,
  description VARCHAR(250) NULL,
  sortOrder TINYINT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (name),
  UNIQUE(sortOrder),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;


CREATE TABLE IF NOT EXISTS `medication` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATE NOT NULL,
  medicationType INT NOT NULL,
  numberDispensed INT NULL,
  note VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (medicationType) REFERENCES medicationType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;


CREATE TABLE IF NOT EXISTS `pregnancyHistory` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  day VARCHAR(2) NULL,
  month VARCHAR(2) NULL,
  year VARCHAR(4) NOT NULL,
  FT BOOLEAN NULL,
  finalGA INT NULL,
  finalGAPeriod VARCHAR(15) NULL,
  sexOfBaby CHAR(1) NULL,
  placeOfBirth VARCHAR(30) NULL,
  attendant VARCHAR(30) NULL,
  typeOfDelivery VARCHAR(30) NULL DEFAULT "NSD",
  lengthOfLabor TINYINT NULL,
  birthWeight DECIMAL(4,2) NULL,
  episTear CHAR(1) NULL DEFAULT '',
  repaired CHAR(1) NULL DEFAULT '',
  howLongBFed INT NULL,
  howLongBFedPeriod VARCHAR(15) NULL,
  note VARCHAR(2000) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `eventType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(255) NULL,
  UNIQUE (name)
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `event` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  eventType INT NOT NULL,
  eDateTime DATETIME NOT NULL,
  note VARCHAR(255) NULL,
  sid VARCHAR(30) NULL,
  pregnancy_id INT NULL,
  user_id INT NULL,
  FOREIGN KEY (eventType) REFERENCES eventType (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `priority` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  eType INT NOT NULL,
  priority INT NOT NULL,
  barcode INT NOT NULL,
  assigned DATETIME NULL,
  pregnancy_id INT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (priority, eType),
  UNIQUE (barcode),
  FOREIGN KEY (eType) REFERENCES eventType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `prenatalExam` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATE NOT NULL,
  weight DECIMAL(4, 1) NULL,
  systolic INT NULL,
  diastolic INT NULL,
  cr INT NULL,
  temperature DECIMAL(4,1) NULL,
  respiratoryRate INT NULL,
  fh INT NULL,
  fhNote VARCHAR(2000) NULL,
  fht INT NULL,
  fhtNote VARCHAR(2000) NULL,
  pos VARCHAR(10) NULL,
  mvmt BOOLEAN NULL,
  edema VARCHAR(4) NULL,
  risk VARCHAR(2000) NULL,
  vitamin BOOLEAN NULL,
  pray BOOLEAN NULL,
  note VARCHAR(4000) NULL,
  returnDate DATE NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

-- A grouping of tests that belong together. May contain 1 or more labTests.
CREATE TABLE IF NOT EXISTS `labSuite` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(100) NULL,
  category VARCHAR(50) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (name),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;


-- Defines a specific test.
CREATE TABLE IF NOT EXISTS `labTest` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(70) NOT NULL,
  abbrev VARCHAR(70) NULL,
  normal VARCHAR(50) NULL,
  unit VARCHAR(10) NULL,
  minRangeDecimal DECIMAL(7,3) NULL,
  maxRangeDecimal DECIMAL(7,3) NULL,
  minRangeInteger INT NULL,
  maxRangeInteger INT NULL,
  isRange BOOLEAN NOT NULL DEFAULT 0,
  isText BOOLEAN NOT NULL DEFAULT 0,
  labSuite_id INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (name),
  UNIQUE (abbrev),
  FOREIGN KEY (labSuite_id) REFERENCES labSuite (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;


-- Defines additional acceptable values for a specific lab test.
CREATE TABLE IF NOT EXISTS `labTestValue` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  value VARCHAR(50) NOT NULL,
  labTest_id INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (labTest_id, value),
  FOREIGN KEY (labTest_id) REFERENCES labTest (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;


-- Holds the test result for a specific test and patient.
CREATE TABLE IF NOT EXISTS `labTestResult` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  testDate DATE NOT NULL,
  result VARCHAR(4000) NOT NULL,
  result2 VARCHAR(100) NULL,    -- used with labTest.isRange == true
  warn BOOLEAN NULL,
  labTest_id INT NOT NULL,
  pregnancy_id INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (labTest_id) REFERENCES labTest (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `referral` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATE NOT NULL,
  referral VARCHAR(300) NOT NULL,
  reason VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `selectData` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  selectKey VARCHAR(30) NOT NULL,
  label VARCHAR(150) NOT NULL,
  selected BOOLEAN NOT NULL DEFAULT 0,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (name, selectKey),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `schedule` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  scheduleType VARCHAR(20) NOT NULL,
  location VARCHAR(20) NOT NULL,
  day VARCHAR(20) NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  UNIQUE (pregnancy_id, scheduleType),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `customFieldType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  title VARCHAR(30) NULL,
  description VARCHAR(250) NULL,
  label VARCHAR(50) NULL,
  valueFieldName VARCHAR(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS `customField` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customFieldType_id INT NOT NULL,
  pregnancy_id INT NOT NULL,
  booleanVal BOOLEAN NULL,
  intVal INT NULL,
  decimalVal DECIMAL(10, 5) NULL,
  textVAl TEXT NULL,
  dateTimeVal DATETIME NULL,
  UNIQUE (customFieldType_id, pregnancy_id),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `roFieldsByRole` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  roleName VARCHAR(30) NOT NULL,
  tableName VARCHAR(30) NOT NULL,
  fieldName VARCHAR(30) NOT NULL,
  UNIQUE (roleName, tableName, fieldName)
);

CREATE TABLE IF NOT EXISTS `pregnoteType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(20) NOT NULL,
  description VARCHAR(250) NULL,
  UNIQUE(name)
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `pregnote` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  pregnoteType INT NOT NULL,
  noteDate DATE NOT NULL,
  note TEXT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (pregnoteType) REFERENCES pregnoteType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

SET foreign_key_checks = 1;

-- Creating keyValueLog
SELECT 'keyValueLog' AS Creating FROM DUAL;
CREATE TABLE keyValueLog LIKE keyValue;
ALTER TABLE keyValueLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE keyValueLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE keyValueLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE keyValueLog DROP PRIMARY KEY;
ALTER TABLE keyValueLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE keyValueLog DROP KEY kvKey;
--
-- Creating userLog
SELECT 'userLog' AS Creating FROM DUAL;
CREATE TABLE userLog LIKE user;
ALTER TABLE userLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE userLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE userLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE userLog DROP PRIMARY KEY;
ALTER TABLE userLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE userLog DROP KEY username;
--
-- Creating roleLog
SELECT 'roleLog' AS Creating FROM DUAL;
CREATE TABLE roleLog LIKE role;
ALTER TABLE roleLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE roleLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE roleLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE roleLog DROP PRIMARY KEY;
ALTER TABLE roleLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE roleLog DROP KEY name;
--
-- Creating patientLog
SELECT 'patientLog' AS Creating FROM DUAL;
CREATE TABLE patientLog LIKE patient;
ALTER TABLE patientLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE patientLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE patientLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE patientLog DROP PRIMARY KEY;
ALTER TABLE patientLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating pregnancyLog
SELECT 'pregnancyLog' AS Creating FROM DUAL;
CREATE TABLE pregnancyLog LIKE pregnancy;
ALTER TABLE pregnancyLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE pregnancyLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE pregnancyLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE pregnancyLog DROP PRIMARY KEY;
ALTER TABLE pregnancyLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating riskLog
SELECT 'riskLog' AS Creating FROM DUAL;
CREATE TABLE riskLog LIKE risk;
ALTER TABLE riskLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE riskLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE riskLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE riskLog DROP PRIMARY KEY;
ALTER TABLE riskLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE riskLog DROP KEY pregnancy_id;
--
-- Creating vaccinationTypeLog
SELECT 'vaccinationTypeLog' AS Creating FROM DUAL;
CREATE TABLE vaccinationTypeLog LIKE vaccinationType;
ALTER TABLE vaccinationTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE vaccinationTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE vaccinationTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE vaccinationTypeLog DROP PRIMARY KEY;
ALTER TABLE vaccinationTypeLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE vaccinationTypeLog DROP KEY name;
ALTER TABLE vaccinationTypeLog DROP KEY sortOrder;
--
-- Creating vaccinationLog
SELECT 'vaccinationLog' AS Creating FROM DUAL;
CREATE TABLE vaccinationLog LIKE vaccination;
ALTER TABLE vaccinationLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE vaccinationLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE vaccinationLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE vaccinationLog DROP PRIMARY KEY;
ALTER TABLE vaccinationLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating healthTeachingLog
SELECT 'healthTeachingLog' AS Creating FROM DUAL;
CREATE TABLE healthTeachingLog LIKE healthTeaching;
ALTER TABLE healthTeachingLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE healthTeachingLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE healthTeachingLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE healthTeachingLog DROP PRIMARY KEY;
ALTER TABLE healthTeachingLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating medicationTypeLog
SELECT 'medicationTypeLog' AS Creating FROM DUAL;
CREATE TABLE medicationTypeLog LIKE medicationType;
ALTER TABLE medicationTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE medicationTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE medicationTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE medicationTypeLog DROP PRIMARY KEY;
ALTER TABLE medicationTypeLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE medicationTypeLog DROP KEY name;
ALTER TABLE medicationTypeLog DROP KEY sortOrder;
--
-- Creating medicationLog
SELECT 'medicationLog' AS Creating FROM DUAL;
CREATE TABLE medicationLog LIKE medication;
ALTER TABLE medicationLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE medicationLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE medicationLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE medicationLog DROP PRIMARY KEY;
ALTER TABLE medicationLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating pregnancyHistoryLog
SELECT 'pregnancyHistoryLog' AS Creating FROM DUAL;
CREATE TABLE pregnancyHistoryLog LIKE pregnancyHistory;
ALTER TABLE pregnancyHistoryLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE pregnancyHistoryLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE pregnancyHistoryLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE pregnancyHistoryLog DROP PRIMARY KEY;
ALTER TABLE pregnancyHistoryLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating prenatalExamLog
SELECT 'prenatalExamLog' AS Creating FROM DUAL;
CREATE TABLE prenatalExamLog LIKE prenatalExam;
ALTER TABLE prenatalExamLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE prenatalExamLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE prenatalExamLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE prenatalExamLog DROP PRIMARY KEY;
ALTER TABLE prenatalExamLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating labSuiteLog
SELECT 'labSuiteLog' AS Creating FROM DUAL;
CREATE TABLE labSuiteLog LIKE labSuite;
ALTER TABLE labSuiteLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE labSuiteLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE labSuiteLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE labSuiteLog DROP PRIMARY KEY;
ALTER TABLE labSuiteLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE labSuiteLog DROP KEY name;
--
-- Creating labTestLog
SELECT 'labTestLog' AS Creating FROM DUAL;
CREATE TABLE labTestLog LIKE labTest;
ALTER TABLE labTestLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE labTestLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE labTestLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE labTestLog DROP PRIMARY KEY;
ALTER TABLE labTestLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE labTestLog DROP KEY name;
ALTER TABLE labTestLog DROP KEY abbrev;
--
-- Creating labTestValueLog
SELECT 'labTestValueLog' AS Creating FROM DUAL;
CREATE TABLE labTestValueLog LIKE labTestValue;
ALTER TABLE labTestValueLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE labTestValueLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE labTestValueLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE labTestValueLog DROP PRIMARY KEY;
ALTER TABLE labTestValueLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE labTestValueLog DROP KEY labTest_id;
--
-- Creating labTestResultLog
SELECT 'labTestResultLog' AS Creating FROM DUAL;
CREATE TABLE labTestResultLog LIKE labTestResult;
ALTER TABLE labTestResultLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE labTestResultLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE labTestResultLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE labTestResultLog DROP PRIMARY KEY;
ALTER TABLE labTestResultLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating referralLog
SELECT 'referralLog' AS Creating FROM DUAL;
CREATE TABLE referralLog LIKE referral;
ALTER TABLE referralLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE referralLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE referralLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE referralLog DROP PRIMARY KEY;
ALTER TABLE referralLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating selectDataLog
SELECT 'selectDataLog' AS Creating FROM DUAL;
CREATE TABLE selectDataLog LIKE selectData;
ALTER TABLE selectDataLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE selectDataLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE selectDataLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE selectDataLog DROP PRIMARY KEY;
ALTER TABLE selectDataLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE selectDataLog DROP KEY name;
--
-- Creating scheduleLog
SELECT 'scheduleLog' AS Creating FROM DUAL;
CREATE TABLE scheduleLog LIKE schedule;
ALTER TABLE scheduleLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE scheduleLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE scheduleLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE scheduleLog DROP PRIMARY KEY;
ALTER TABLE scheduleLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE scheduleLog DROP KEY pregnancy_id;
--
-- Creating customFieldLog
SELECT 'customFieldLog' AS Creating FROM DUAL;
CREATE TABLE customFieldLog LIKE customField;
ALTER TABLE customFieldLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE customFieldLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE customFieldLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE customFieldLog DROP PRIMARY KEY;
ALTER TABLE customFieldLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE customFieldLog DROP KEY customFieldType_id;
--
-- Creating pregnoteTypeLog
SELECT 'pregnoteTypeLog' AS Creating FROM DUAL;
CREATE TABLE pregnoteTypeLog LIKE pregnoteType;
ALTER TABLE pregnoteTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE pregnoteTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE pregnoteTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE pregnoteTypeLog DROP PRIMARY KEY;
ALTER TABLE pregnoteTypeLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating pregnoteLog
SELECT 'pregnoteLog' AS Creating FROM DUAL;
CREATE TABLE pregnoteLog LIKE pregnote;
ALTER TABLE pregnoteLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE pregnoteLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE pregnoteLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE pregnoteLog DROP PRIMARY KEY;
ALTER TABLE pregnoteLog ADD PRIMARY KEY (id, replacedAt);

-- ---------------------------------------------------------------
-- Trigger: customField_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS customField_after_insert;
CREATE TRIGGER customField_after_insert AFTER INSERT ON customField
FOR EACH ROW
BEGIN
  INSERT INTO customFieldLog
  (id, customFieldType_id, pregnancy_id, booleanVal, intVal, decimalVal, textVAl, dateTimeVal, op, replacedAt)
  VALUES (NEW.id, NEW.customFieldType_id, NEW.pregnancy_id, NEW.booleanVal, NEW.intVal, NEW.decimalVal, NEW.textVAl, NEW.dateTimeVal, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: customField_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS customField_after_update;
CREATE TRIGGER customField_after_update AFTER UPDATE ON customField
FOR EACH ROW
BEGIN
  INSERT INTO customFieldLog
  (id, customFieldType_id, pregnancy_id, booleanVal, intVal, decimalVal, textVAl, dateTimeVal, op, replacedAt)
  VALUES (NEW.id, NEW.customFieldType_id, NEW.pregnancy_id, NEW.booleanVal, NEW.intVal, NEW.decimalVal, NEW.textVAl, NEW.dateTimeVal, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: customField_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS customField_after_delete;
CREATE TRIGGER customField_after_delete AFTER DELETE ON customField
FOR EACH ROW
BEGIN
  INSERT INTO customFieldLog
  (id, customFieldType_id, pregnancy_id, booleanVal, intVal, decimalVal, textVAl, dateTimeVal, op, replacedAt)
  VALUES (OLD.id, OLD.customFieldType_id, OLD.pregnancy_id, OLD.booleanVal, OLD.intVal, OLD.decimalVal, OLD.textVAl, OLD.dateTimeVal, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: healthTeaching_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS healthTeaching_after_insert;
CREATE TRIGGER healthTeaching_after_insert AFTER INSERT ON healthTeaching
FOR EACH ROW
BEGIN
  INSERT INTO healthTeachingLog
  (id, date, topic, teacher, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.topic, NEW.teacher, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: healthTeaching_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS healthTeaching_after_update;
CREATE TRIGGER healthTeaching_after_update AFTER UPDATE ON healthTeaching
FOR EACH ROW
BEGIN
  INSERT INTO healthTeachingLog
  (id, date, topic, teacher, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.topic, NEW.teacher, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: healthTeaching_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS healthTeaching_after_delete;
CREATE TRIGGER healthTeaching_after_delete AFTER DELETE ON healthTeaching
FOR EACH ROW
BEGIN
  INSERT INTO healthTeachingLog
  (id, date, topic, teacher, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.topic, OLD.teacher, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: keyValue_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS keyValue_after_insert;
CREATE TRIGGER keyValue_after_insert AFTER INSERT ON keyValue
FOR EACH ROW
BEGIN
  INSERT INTO keyValueLog
  (id, kvKey, kvValue, description, valueType, acceptableValues, systemOnly, op, replacedAt)
  VALUES (NEW.id, NEW.kvKey, NEW.kvValue, NEW.description, NEW.valueType, NEW.acceptableValues, NEW.systemOnly, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: keyValue_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS keyValue_after_update;
CREATE TRIGGER keyValue_after_update AFTER UPDATE ON keyValue
FOR EACH ROW
BEGIN
  INSERT INTO keyValueLog
  (id, kvKey, kvValue, description, valueType, acceptableValues, systemOnly, op, replacedAt)
  VALUES (NEW.id, NEW.kvKey, NEW.kvValue, NEW.description, NEW.valueType, NEW.acceptableValues, NEW.systemOnly, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: keyValue_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS keyValue_after_delete;
CREATE TRIGGER keyValue_after_delete AFTER DELETE ON keyValue
FOR EACH ROW
BEGIN
  INSERT INTO keyValueLog
  (id, kvKey, kvValue, description, valueType, acceptableValues, systemOnly, op, replacedAt)
  VALUES (OLD.id, OLD.kvKey, OLD.kvValue, OLD.description, OLD.valueType, OLD.acceptableValues, OLD.systemOnly, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labSuite_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labSuite_after_insert;
CREATE TRIGGER labSuite_after_insert AFTER INSERT ON labSuite
FOR EACH ROW
BEGIN
  INSERT INTO labSuiteLog
  (id, name, description, category, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.category, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labSuite_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labSuite_after_update;
CREATE TRIGGER labSuite_after_update AFTER UPDATE ON labSuite
FOR EACH ROW
BEGIN
  INSERT INTO labSuiteLog
  (id, name, description, category, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.category, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labSuite_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labSuite_after_delete;
CREATE TRIGGER labSuite_after_delete AFTER DELETE ON labSuite
FOR EACH ROW
BEGIN
  INSERT INTO labSuiteLog
  (id, name, description, category, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.category, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labTest_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTest_after_insert;
CREATE TRIGGER labTest_after_insert AFTER INSERT ON labTest
FOR EACH ROW
BEGIN
  INSERT INTO labTestLog
  (id, name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger, maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.abbrev, NEW.normal, NEW.unit, NEW.minRangeDecimal, NEW.maxRangeDecimal, NEW.minRangeInteger, NEW.maxRangeInteger, NEW.isRange, NEW.isText, NEW.labSuite_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labTest_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTest_after_update;
CREATE TRIGGER labTest_after_update AFTER UPDATE ON labTest
FOR EACH ROW
BEGIN
  INSERT INTO labTestLog
  (id, name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger, maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.abbrev, NEW.normal, NEW.unit, NEW.minRangeDecimal, NEW.maxRangeDecimal, NEW.minRangeInteger, NEW.maxRangeInteger, NEW.isRange, NEW.isText, NEW.labSuite_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labTest_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTest_after_delete;
CREATE TRIGGER labTest_after_delete AFTER DELETE ON labTest
FOR EACH ROW
BEGIN
  INSERT INTO labTestLog
  (id, name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger, maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.abbrev, OLD.normal, OLD.unit, OLD.minRangeDecimal, OLD.maxRangeDecimal, OLD.minRangeInteger, OLD.maxRangeInteger, OLD.isRange, OLD.isText, OLD.labSuite_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labTestResult_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestResult_after_insert;
CREATE TRIGGER labTestResult_after_insert AFTER INSERT ON labTestResult
FOR EACH ROW
BEGIN
  INSERT INTO labTestResultLog
  (id, testDate, result, result2, warn, labTest_id, pregnancy_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.testDate, NEW.result, NEW.result2, NEW.warn, NEW.labTest_id, NEW.pregnancy_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labTestResult_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestResult_after_update;
CREATE TRIGGER labTestResult_after_update AFTER UPDATE ON labTestResult
FOR EACH ROW
BEGIN
  INSERT INTO labTestResultLog
  (id, testDate, result, result2, warn, labTest_id, pregnancy_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.testDate, NEW.result, NEW.result2, NEW.warn, NEW.labTest_id, NEW.pregnancy_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labTestResult_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestResult_after_delete;
CREATE TRIGGER labTestResult_after_delete AFTER DELETE ON labTestResult
FOR EACH ROW
BEGIN
  INSERT INTO labTestResultLog
  (id, testDate, result, result2, warn, labTest_id, pregnancy_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.testDate, OLD.result, OLD.result2, OLD.warn, OLD.labTest_id, OLD.pregnancy_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labTestValue_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestValue_after_insert;
CREATE TRIGGER labTestValue_after_insert AFTER INSERT ON labTestValue
FOR EACH ROW
BEGIN
  INSERT INTO labTestValueLog
  (id, value, labTest_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.value, NEW.labTest_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labTestValue_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestValue_after_update;
CREATE TRIGGER labTestValue_after_update AFTER UPDATE ON labTestValue
FOR EACH ROW
BEGIN
  INSERT INTO labTestValueLog
  (id, value, labTest_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.value, NEW.labTest_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: labTestValue_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestValue_after_delete;
CREATE TRIGGER labTestValue_after_delete AFTER DELETE ON labTestValue
FOR EACH ROW
BEGIN
  INSERT INTO labTestValueLog
  (id, value, labTest_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.value, OLD.labTest_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: medication_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medication_after_insert;
CREATE TRIGGER medication_after_insert AFTER INSERT ON medication
FOR EACH ROW
BEGIN
  INSERT INTO medicationLog
  (id, date, medicationType, numberDispensed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.medicationType, NEW.numberDispensed, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: medication_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medication_after_update;
CREATE TRIGGER medication_after_update AFTER UPDATE ON medication
FOR EACH ROW
BEGIN
  INSERT INTO medicationLog
  (id, date, medicationType, numberDispensed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.medicationType, NEW.numberDispensed, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: medication_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medication_after_delete;
CREATE TRIGGER medication_after_delete AFTER DELETE ON medication
FOR EACH ROW
BEGIN
  INSERT INTO medicationLog
  (id, date, medicationType, numberDispensed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.medicationType, OLD.numberDispensed, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: medicationType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medicationType_after_insert;
CREATE TRIGGER medicationType_after_insert AFTER INSERT ON medicationType
FOR EACH ROW
BEGIN
  INSERT INTO medicationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: medicationType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medicationType_after_update;
CREATE TRIGGER medicationType_after_update AFTER UPDATE ON medicationType
FOR EACH ROW
BEGIN
  INSERT INTO medicationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: medicationType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medicationType_after_delete;
CREATE TRIGGER medicationType_after_delete AFTER DELETE ON medicationType
FOR EACH ROW
BEGIN
  INSERT INTO medicationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.sortOrder, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: patient_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS patient_after_insert;
CREATE TRIGGER patient_after_insert AFTER INSERT ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.dohID, NEW.dob, NEW.generalInfo, NEW.ageOfMenarche, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: patient_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS patient_after_update;
CREATE TRIGGER patient_after_update AFTER UPDATE ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.dohID, NEW.dob, NEW.generalInfo, NEW.ageOfMenarche, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: patient_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS patient_after_delete;
CREATE TRIGGER patient_after_delete AFTER DELETE ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.dohID, OLD.dob, OLD.generalInfo, OLD.ageOfMenarche, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnancyHistory_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancyHistory_after_insert;
CREATE TRIGGER pregnancyHistory_after_insert AFTER INSERT ON pregnancyHistory
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyHistoryLog
  (id, day, month, year, FT, finalGA, finalGAPeriod, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, howLongBFedPeriod, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.day, NEW.month, NEW.year, NEW.FT, NEW.finalGA, NEW.finalGAPeriod, NEW.sexOfBaby, NEW.placeOfBirth, NEW.attendant, NEW.typeOfDelivery, NEW.lengthOfLabor, NEW.birthWeight, NEW.episTear, NEW.repaired, NEW.howLongBFed, NEW.howLongBFedPeriod, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnancyHistory_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancyHistory_after_update;
CREATE TRIGGER pregnancyHistory_after_update AFTER UPDATE ON pregnancyHistory
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyHistoryLog
  (id, day, month, year, FT, finalGA, finalGAPeriod, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, howLongBFedPeriod, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.day, NEW.month, NEW.year, NEW.FT, NEW.finalGA, NEW.finalGAPeriod, NEW.sexOfBaby, NEW.placeOfBirth, NEW.attendant, NEW.typeOfDelivery, NEW.lengthOfLabor, NEW.birthWeight, NEW.episTear, NEW.repaired, NEW.howLongBFed, NEW.howLongBFedPeriod, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnancyHistory_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancyHistory_after_delete;
CREATE TRIGGER pregnancyHistory_after_delete AFTER DELETE ON pregnancyHistory
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyHistoryLog
  (id, day, month, year, FT, finalGA, finalGAPeriod, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, howLongBFedPeriod, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.day, OLD.month, OLD.year, OLD.FT, OLD.finalGA, OLD.finalGAPeriod, OLD.sexOfBaby, OLD.placeOfBirth, OLD.attendant, OLD.typeOfDelivery, OLD.lengthOfLabor, OLD.birthWeight, OLD.episTear, OLD.repaired, OLD.howLongBFed, OLD.howLongBFedPeriod, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnancy_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancy_after_insert;
CREATE TRIGGER pregnancy_after_insert AFTER INSERT ON pregnancy
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyLog
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, clientIncome, clientIncomePeriod, address1, address2, address3, address4, city, state, postalCode, country, gravidaNumber, lmp, sureLMP, warning, riskNote, alternateEdd, useAlternateEdd, doctorConsultDate, dentistConsultDate, mbBook, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, transferOfCare, transferOfCareNote, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyVaginalPain, currentlyVaginalItching, currentlyNone, useIodizedSalt, takingMedication, planToBreastFeed, birthCompanion, practiceFamilyPlanning, practiceFamilyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryHeartProblems, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyHeartProblems, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, questionnaireNote, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerIncome, partnerIncomePeriod, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (NEW.id, NEW.firstname, NEW.lastname, NEW.maidenname, NEW.nickname, NEW.religion, NEW.maritalStatus, NEW.telephone, NEW.work, NEW.education, NEW.clientIncome, NEW.clientIncomePeriod, NEW.address1, NEW.address2, NEW.address3, NEW.address4, NEW.city, NEW.state, NEW.postalCode, NEW.country, NEW.gravidaNumber, NEW.lmp, NEW.sureLMP, NEW.warning, NEW.riskNote, NEW.alternateEdd, NEW.useAlternateEdd, NEW.doctorConsultDate, NEW.dentistConsultDate, NEW.mbBook, NEW.whereDeliver, NEW.fetuses, NEW.monozygotic, NEW.pregnancyEndDate, NEW.pregnancyEndResult, NEW.iugr, NEW.note, NEW.numberRequiredTetanus, NEW.invertedNipples, NEW.hasUS, NEW.wantsUS, NEW.gravida, NEW.stillBirths, NEW.abortions, NEW.living, NEW.para, NEW.term, NEW.preterm, NEW.philHealthMCP, NEW.philHealthNCP, NEW.philHealthID, NEW.philHealthApproved, NEW.transferOfCare, NEW.transferOfCareNote, NEW.currentlyVomiting, NEW.currentlyDizzy, NEW.currentlyFainting, NEW.currentlyBleeding, NEW.currentlyUrinationPain, NEW.currentlyBlurryVision, NEW.currentlySwelling, NEW.currentlyVaginalPain, NEW.currentlyVaginalItching, NEW.currentlyNone, NEW.useIodizedSalt, NEW.takingMedication, NEW.planToBreastFeed, NEW.birthCompanion, NEW.practiceFamilyPlanning, NEW.practiceFamilyPlanningDetails, NEW.familyHistoryTwins, NEW.familyHistoryHighBloodPressure, NEW.familyHistoryDiabetes, NEW.familyHistoryHeartProblems, NEW.familyHistoryTB, NEW.familyHistorySmoking, NEW.familyHistoryNone, NEW.historyFoodAllergy, NEW.historyMedicineAllergy, NEW.historyAsthma, NEW.historyHeartProblems, NEW.historyKidneyProblems, NEW.historyHepatitis, NEW.historyGoiter, NEW.historyHighBloodPressure, NEW.historyHospitalOperation, NEW.historyBloodTransfusion, NEW.historySmoking, NEW.historyDrinking, NEW.historyNone, NEW.questionnaireNote, NEW.partnerFirstname, NEW.partnerLastname, NEW.partnerAge, NEW.partnerWork, NEW.partnerEducation, NEW.partnerIncome, NEW.partnerIncomePeriod, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.patient_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnancy_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancy_after_update;
CREATE TRIGGER pregnancy_after_update AFTER UPDATE ON pregnancy
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyLog
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, clientIncome, clientIncomePeriod, address1, address2, address3, address4, city, state, postalCode, country, gravidaNumber, lmp, sureLMP, warning, riskNote, alternateEdd, useAlternateEdd, doctorConsultDate, dentistConsultDate, mbBook, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, transferOfCare, transferOfCareNote, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyVaginalPain, currentlyVaginalItching, currentlyNone, useIodizedSalt, takingMedication, planToBreastFeed, birthCompanion, practiceFamilyPlanning, practiceFamilyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryHeartProblems, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyHeartProblems, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, questionnaireNote, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerIncome, partnerIncomePeriod, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (NEW.id, NEW.firstname, NEW.lastname, NEW.maidenname, NEW.nickname, NEW.religion, NEW.maritalStatus, NEW.telephone, NEW.work, NEW.education, NEW.clientIncome, NEW.clientIncomePeriod, NEW.address1, NEW.address2, NEW.address3, NEW.address4, NEW.city, NEW.state, NEW.postalCode, NEW.country, NEW.gravidaNumber, NEW.lmp, NEW.sureLMP, NEW.warning, NEW.riskNote, NEW.alternateEdd, NEW.useAlternateEdd, NEW.doctorConsultDate, NEW.dentistConsultDate, NEW.mbBook, NEW.whereDeliver, NEW.fetuses, NEW.monozygotic, NEW.pregnancyEndDate, NEW.pregnancyEndResult, NEW.iugr, NEW.note, NEW.numberRequiredTetanus, NEW.invertedNipples, NEW.hasUS, NEW.wantsUS, NEW.gravida, NEW.stillBirths, NEW.abortions, NEW.living, NEW.para, NEW.term, NEW.preterm, NEW.philHealthMCP, NEW.philHealthNCP, NEW.philHealthID, NEW.philHealthApproved, NEW.transferOfCare, NEW.transferOfCareNote, NEW.currentlyVomiting, NEW.currentlyDizzy, NEW.currentlyFainting, NEW.currentlyBleeding, NEW.currentlyUrinationPain, NEW.currentlyBlurryVision, NEW.currentlySwelling, NEW.currentlyVaginalPain, NEW.currentlyVaginalItching, NEW.currentlyNone, NEW.useIodizedSalt, NEW.takingMedication, NEW.planToBreastFeed, NEW.birthCompanion, NEW.practiceFamilyPlanning, NEW.practiceFamilyPlanningDetails, NEW.familyHistoryTwins, NEW.familyHistoryHighBloodPressure, NEW.familyHistoryDiabetes, NEW.familyHistoryHeartProblems, NEW.familyHistoryTB, NEW.familyHistorySmoking, NEW.familyHistoryNone, NEW.historyFoodAllergy, NEW.historyMedicineAllergy, NEW.historyAsthma, NEW.historyHeartProblems, NEW.historyKidneyProblems, NEW.historyHepatitis, NEW.historyGoiter, NEW.historyHighBloodPressure, NEW.historyHospitalOperation, NEW.historyBloodTransfusion, NEW.historySmoking, NEW.historyDrinking, NEW.historyNone, NEW.questionnaireNote, NEW.partnerFirstname, NEW.partnerLastname, NEW.partnerAge, NEW.partnerWork, NEW.partnerEducation, NEW.partnerIncome, NEW.partnerIncomePeriod, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.patient_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnancy_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancy_after_delete;
CREATE TRIGGER pregnancy_after_delete AFTER DELETE ON pregnancy
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyLog
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, clientIncome, clientIncomePeriod, address1, address2, address3, address4, city, state, postalCode, country, gravidaNumber, lmp, sureLMP, warning, riskNote, alternateEdd, useAlternateEdd, doctorConsultDate, dentistConsultDate, mbBook, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, transferOfCare, transferOfCareNote, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyVaginalPain, currentlyVaginalItching, currentlyNone, useIodizedSalt, takingMedication, planToBreastFeed, birthCompanion, practiceFamilyPlanning, practiceFamilyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryHeartProblems, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyHeartProblems, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, questionnaireNote, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerIncome, partnerIncomePeriod, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (OLD.id, OLD.firstname, OLD.lastname, OLD.maidenname, OLD.nickname, OLD.religion, OLD.maritalStatus, OLD.telephone, OLD.work, OLD.education, OLD.clientIncome, OLD.clientIncomePeriod, OLD.address1, OLD.address2, OLD.address3, OLD.address4, OLD.city, OLD.state, OLD.postalCode, OLD.country, OLD.gravidaNumber, OLD.lmp, OLD.sureLMP, OLD.warning, OLD.riskNote, OLD.alternateEdd, OLD.useAlternateEdd, OLD.doctorConsultDate, OLD.dentistConsultDate, OLD.mbBook, OLD.whereDeliver, OLD.fetuses, OLD.monozygotic, OLD.pregnancyEndDate, OLD.pregnancyEndResult, OLD.iugr, OLD.note, OLD.numberRequiredTetanus, OLD.invertedNipples, OLD.hasUS, OLD.wantsUS, OLD.gravida, OLD.stillBirths, OLD.abortions, OLD.living, OLD.para, OLD.term, OLD.preterm, OLD.philHealthMCP, OLD.philHealthNCP, OLD.philHealthID, OLD.philHealthApproved, OLD.transferOfCare, OLD.transferOfCareNote, OLD.currentlyVomiting, OLD.currentlyDizzy, OLD.currentlyFainting, OLD.currentlyBleeding, OLD.currentlyUrinationPain, OLD.currentlyBlurryVision, OLD.currentlySwelling, OLD.currentlyVaginalPain, OLD.currentlyVaginalItching, OLD.currentlyNone, OLD.useIodizedSalt, OLD.takingMedication, OLD.planToBreastFeed, OLD.birthCompanion, OLD.practiceFamilyPlanning, OLD.practiceFamilyPlanningDetails, OLD.familyHistoryTwins, OLD.familyHistoryHighBloodPressure, OLD.familyHistoryDiabetes, OLD.familyHistoryHeartProblems, OLD.familyHistoryTB, OLD.familyHistorySmoking, OLD.familyHistoryNone, OLD.historyFoodAllergy, OLD.historyMedicineAllergy, OLD.historyAsthma, OLD.historyHeartProblems, OLD.historyKidneyProblems, OLD.historyHepatitis, OLD.historyGoiter, OLD.historyHighBloodPressure, OLD.historyHospitalOperation, OLD.historyBloodTransfusion, OLD.historySmoking, OLD.historyDrinking, OLD.historyNone, OLD.questionnaireNote, OLD.partnerFirstname, OLD.partnerLastname, OLD.partnerAge, OLD.partnerWork, OLD.partnerEducation, OLD.partnerIncome, OLD.partnerIncomePeriod, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.patient_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnote_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnote_after_insert;
CREATE TRIGGER pregnote_after_insert AFTER INSERT ON pregnote
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteLog
  (id, pregnoteType, noteDate, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.pregnoteType, NEW.noteDate, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnote_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnote_after_update;
CREATE TRIGGER pregnote_after_update AFTER UPDATE ON pregnote
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteLog
  (id, pregnoteType, noteDate, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.pregnoteType, NEW.noteDate, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnote_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnote_after_delete;
CREATE TRIGGER pregnote_after_delete AFTER DELETE ON pregnote
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteLog
  (id, pregnoteType, noteDate, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.pregnoteType, OLD.noteDate, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnoteType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnoteType_after_insert;
CREATE TRIGGER pregnoteType_after_insert AFTER INSERT ON pregnoteType
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteTypeLog
  (id, name, description, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnoteType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnoteType_after_update;
CREATE TRIGGER pregnoteType_after_update AFTER UPDATE ON pregnoteType
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteTypeLog
  (id, name, description, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: pregnoteType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnoteType_after_delete;
CREATE TRIGGER pregnoteType_after_delete AFTER DELETE ON pregnoteType
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteTypeLog
  (id, name, description, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: prenatalExam_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS prenatalExam_after_insert;
CREATE TRIGGER prenatalExam_after_insert AFTER INSERT ON prenatalExam
FOR EACH ROW
BEGIN
  INSERT INTO prenatalExamLog
  (id, date, weight, systolic, diastolic, cr, temperature, respiratoryRate, fh, fhNote, fht, fhtNote, pos, mvmt, edema, risk, vitamin, pray, note, returnDate, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.weight, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temperature, NEW.respiratoryRate, NEW.fh, NEW.fhNote, NEW.fht, NEW.fhtNote, NEW.pos, NEW.mvmt, NEW.edema, NEW.risk, NEW.vitamin, NEW.pray, NEW.note, NEW.returnDate, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: prenatalExam_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS prenatalExam_after_update;
CREATE TRIGGER prenatalExam_after_update AFTER UPDATE ON prenatalExam
FOR EACH ROW
BEGIN
  INSERT INTO prenatalExamLog
  (id, date, weight, systolic, diastolic, cr, temperature, respiratoryRate, fh, fhNote, fht, fhtNote, pos, mvmt, edema, risk, vitamin, pray, note, returnDate, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.weight, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temperature, NEW.respiratoryRate, NEW.fh, NEW.fhNote, NEW.fht, NEW.fhtNote, NEW.pos, NEW.mvmt, NEW.edema, NEW.risk, NEW.vitamin, NEW.pray, NEW.note, NEW.returnDate, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: prenatalExam_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS prenatalExam_after_delete;
CREATE TRIGGER prenatalExam_after_delete AFTER DELETE ON prenatalExam
FOR EACH ROW
BEGIN
  INSERT INTO prenatalExamLog
  (id, date, weight, systolic, diastolic, cr, temperature, respiratoryRate, fh, fhNote, fht, fhtNote, pos, mvmt, edema, risk, vitamin, pray, note, returnDate, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.weight, OLD.systolic, OLD.diastolic, OLD.cr, OLD.temperature, OLD.respiratoryRate, OLD.fh, OLD.fhNote, OLD.fht, OLD.fhtNote, OLD.pos, OLD.mvmt, OLD.edema, OLD.risk, OLD.vitamin, OLD.pray, OLD.note, OLD.returnDate, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: referral_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS referral_after_insert;
CREATE TRIGGER referral_after_insert AFTER INSERT ON referral
FOR EACH ROW
BEGIN
  INSERT INTO referralLog
  (id, date, referral, reason, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.referral, NEW.reason, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: referral_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS referral_after_update;
CREATE TRIGGER referral_after_update AFTER UPDATE ON referral
FOR EACH ROW
BEGIN
  INSERT INTO referralLog
  (id, date, referral, reason, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.referral, NEW.reason, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: referral_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS referral_after_delete;
CREATE TRIGGER referral_after_delete AFTER DELETE ON referral
FOR EACH ROW
BEGIN
  INSERT INTO referralLog
  (id, date, referral, reason, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.referral, OLD.reason, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: risk_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS risk_after_insert;
CREATE TRIGGER risk_after_insert AFTER INSERT ON risk
FOR EACH ROW
BEGIN
  INSERT INTO riskLog
  (id, pregnancy_id, riskCode, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.pregnancy_id, NEW.riskCode, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: risk_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS risk_after_update;
CREATE TRIGGER risk_after_update AFTER UPDATE ON risk
FOR EACH ROW
BEGIN
  INSERT INTO riskLog
  (id, pregnancy_id, riskCode, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.pregnancy_id, NEW.riskCode, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: risk_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS risk_after_delete;
CREATE TRIGGER risk_after_delete AFTER DELETE ON risk
FOR EACH ROW
BEGIN
  INSERT INTO riskLog
  (id, pregnancy_id, riskCode, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.pregnancy_id, OLD.riskCode, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: role_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS role_after_insert;
CREATE TRIGGER role_after_insert AFTER INSERT ON role
FOR EACH ROW
BEGIN
  INSERT INTO roleLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: role_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS role_after_update;
CREATE TRIGGER role_after_update AFTER UPDATE ON role
FOR EACH ROW
BEGIN
  INSERT INTO roleLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: role_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS role_after_delete;
CREATE TRIGGER role_after_delete AFTER DELETE ON role
FOR EACH ROW
BEGIN
  INSERT INTO roleLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: schedule_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS schedule_after_insert;
CREATE TRIGGER schedule_after_insert AFTER INSERT ON schedule
FOR EACH ROW
BEGIN
  INSERT INTO scheduleLog
  (id, scheduleType, location, day, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.scheduleType, NEW.location, NEW.day, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: schedule_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS schedule_after_update;
CREATE TRIGGER schedule_after_update AFTER UPDATE ON schedule
FOR EACH ROW
BEGIN
  INSERT INTO scheduleLog
  (id, scheduleType, location, day, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.scheduleType, NEW.location, NEW.day, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: schedule_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS schedule_after_delete;
CREATE TRIGGER schedule_after_delete AFTER DELETE ON schedule
FOR EACH ROW
BEGIN
  INSERT INTO scheduleLog
  (id, scheduleType, location, day, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.scheduleType, OLD.location, OLD.day, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: selectData_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS selectData_after_insert;
CREATE TRIGGER selectData_after_insert AFTER INSERT ON selectData
FOR EACH ROW
BEGIN
  INSERT INTO selectDataLog
  (id, name, selectKey, label, selected, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.selectKey, NEW.label, NEW.selected, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: selectData_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS selectData_after_update;
CREATE TRIGGER selectData_after_update AFTER UPDATE ON selectData
FOR EACH ROW
BEGIN
  INSERT INTO selectDataLog
  (id, name, selectKey, label, selected, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.selectKey, NEW.label, NEW.selected, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: selectData_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS selectData_after_delete;
CREATE TRIGGER selectData_after_delete AFTER DELETE ON selectData
FOR EACH ROW
BEGIN
  INSERT INTO selectDataLog
  (id, name, selectKey, label, selected, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.selectKey, OLD.label, OLD.selected, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: user_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS user_after_insert;
CREATE TRIGGER user_after_insert AFTER INSERT ON user
FOR EACH ROW
BEGIN
  INSERT INTO userLog
  (id, username, firstname, lastname, password, email, lang, shortName, displayName, status, note, isCurrentTeacher, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.username, NEW.firstname, NEW.lastname, NEW.password, NEW.email, NEW.lang, NEW.shortName, NEW.displayName, NEW.status, NEW.note, NEW.isCurrentTeacher, NEW.role_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: user_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS user_after_update;
CREATE TRIGGER user_after_update AFTER UPDATE ON user
FOR EACH ROW
BEGIN
  INSERT INTO userLog
  (id, username, firstname, lastname, password, email, lang, shortName, displayName, status, note, isCurrentTeacher, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.username, NEW.firstname, NEW.lastname, NEW.password, NEW.email, NEW.lang, NEW.shortName, NEW.displayName, NEW.status, NEW.note, NEW.isCurrentTeacher, NEW.role_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: user_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS user_after_delete;
CREATE TRIGGER user_after_delete AFTER DELETE ON user
FOR EACH ROW
BEGIN
  INSERT INTO userLog
  (id, username, firstname, lastname, password, email, lang, shortName, displayName, status, note, isCurrentTeacher, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.username, OLD.firstname, OLD.lastname, OLD.password, OLD.email, OLD.lang, OLD.shortName, OLD.displayName, OLD.status, OLD.note, OLD.isCurrentTeacher, OLD.role_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: vaccination_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccination_after_insert;
CREATE TRIGGER vaccination_after_insert AFTER INSERT ON vaccination
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationLog
  (id, vaccinationType, vacDate, vacMonth, vacYear, administeredInternally, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.vaccinationType, NEW.vacDate, NEW.vacMonth, NEW.vacYear, NEW.administeredInternally, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: vaccination_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccination_after_update;
CREATE TRIGGER vaccination_after_update AFTER UPDATE ON vaccination
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationLog
  (id, vaccinationType, vacDate, vacMonth, vacYear, administeredInternally, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.vaccinationType, NEW.vacDate, NEW.vacMonth, NEW.vacYear, NEW.administeredInternally, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: vaccination_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccination_after_delete;
CREATE TRIGGER vaccination_after_delete AFTER DELETE ON vaccination
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationLog
  (id, vaccinationType, vacDate, vacMonth, vacYear, administeredInternally, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.vaccinationType, OLD.vacDate, OLD.vacMonth, OLD.vacYear, OLD.administeredInternally, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: vaccinationType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccinationType_after_insert;
CREATE TRIGGER vaccinationType_after_insert AFTER INSERT ON vaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: vaccinationType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccinationType_after_update;
CREATE TRIGGER vaccinationType_after_update AFTER UPDATE ON vaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: vaccinationType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccinationType_after_delete;
CREATE TRIGGER vaccinationType_after_delete AFTER DELETE ON vaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.sortOrder, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;

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
  ('teachingTopics', 'Iron/Vit', 'Iron/Vit', 0, 1, NOW())
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
  ('address1', 'Street Address Line 1', 'The first line of the street address.', 'text', '', 0),
  ('address2', 'Street Address Line 2', 'The second line of the street address.', 'text', '', 0),
  ('address3', 'Street Address Line 3', 'The third line of the street address, if there is one.', 'text', '', 0),
  ('defaultCity', 'Home Town Name', 'The default locality you want to use that most of your patients come from.', 'text', '', 0),
  ('searchRowsPerPage', '20', 'The number of rows of search results to display per page.', 'integer', '', 0),
  ('customField1', 'Custom1', 'The label on the custom field on the general prenatal tab.', 'text', '', 0),
  ('dateFormat', 'YYYY-MM-DD', 'The date format to use.', 'list', 'MM-DD-YYYY|DD-MM-YYYY|YYYY-MM-DD|MM/DD/YYYY|DD/MM/YYYY|YYYY/MM/DD|MM.DD.YYYY|DD.MM.YYYY|YY.MM.DD', 0)
;

COMMIT;

-- ==== DOWN ====

-- NOTE: we purposely do not do anything in DOWN in this initial migration
-- because we do not want all of the contents of the database destroyed in
-- a down migration.

BEGIN;

COMMIT;
