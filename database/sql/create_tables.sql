/*
create_tables.sql

Create the tables that do not already exist.
*/

SET foreign_key_checks = 0;

CREATE TABLE IF NOT EXISTS `user` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  firstname VARCHAR(30) NOT NULL,
  lastname VARCHAR(30) NOT NULL,
  password VARCHAR(60) NOT NULL,
  email VARCHAR(100) NULL,
  lang VARCHAR(10) NULL,
  displayName VARCHAR(100) NULL,
  status BOOLEAN NOT NULL DEFAULT 1,
  note VARCHAR(300) NULL,
  isCurrentTeacher BOOLEAN NULL DEFAULT 0,
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

-- Many-to-many join table for user and role.
-- Notes:
-- 2014-01-22: updatedBy field allows NULL because the orm (Bookshelf)
-- presently cannot handle updating an extra field in a many-to-many join table.
CREATE TABLE IF NOT EXISTS `user_role` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  role_id INT NOT NULL,
  updatedBy INT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

-- Definition required by the connect-mysql Nodejs module.
CREATE TABLE IF NOT EXISTS `session` (
  `sid` VARCHAR(255) NOT NULL,
  `session` TEXT NOT NULL,
  `expires` INT,
  PRIMARY KEY (`sid`)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;
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
  address VARCHAR(150) NOT NULL,
  barangay VARCHAR(50) NULL,
  city VARCHAR(100) NULL,
  postalCode VARCHAR(20) NULL,
  gravidaNumber TINYINT NULL,
  lmp DATE NULL,
  sureLMP BOOLEAN NULL DEFAULT 0,
  warning BOOLEAN NULL DEFAULT 0,
  riskNote VARCHAR(250) NULL,
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
  takingMedication BOOLEAN NULL,
  planToBreastFeed BOOLEAN NULL,
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
  questionnaireNote VARCHAR(300) NULL,
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
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (name),
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
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (name),
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
  note VARCHAR(300) NULL,
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
  fhNote VARCHAR(30) NULL,
  fht INT NULL,
  fhtNote VARCHAR(20) NULL,
  pos VARCHAR(10) NULL,
  mvmt BOOLEAN NULL,
  edema VARCHAR(4) NULL,
  risk VARCHAR(100) NULL,
  vitamin BOOLEAN NULL,
  pray BOOLEAN NULL,
  note VARCHAR(1000) NULL,
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
  result VARCHAR(500) NOT NULL,
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

SET foreign_key_checks = 1;


