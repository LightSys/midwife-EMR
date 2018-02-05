/*
create_tables.sql

Create the tables that do not already exist.
*/

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

CREATE TABLE IF NOT EXISTS `labor` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  admittanceDate DATETIME NOT NULL,
  startLaborDate DATETIME NOT NULL,
  dischargeDate DATETIME NULL,
  falseLabor TINYINT NOT NULL DEFAULT 0,
  pos VARCHAR(10) NULL,
  fh INT NULL,
  fht INT NULL,
  systolic INT NULL,
  diastolic INT NULL,
  cr INT NULL,
  temp DECIMAL(4,1) NULL,
  comments VARCHAR(300),
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `laborStage1` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  fullDialation DATETIME NULL,
  mobility VARCHAR(200) NULL,
  durationLatent INT NULL,
  durationActive INT NULL,
  comments VARCHAR(500) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  labor_id INT NOT NULL,
  UNIQUE(labor_id),
  FOREIGN KEY (labor_id) REFERENCES labor (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `laborStage2` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  birthDatetime DATETIME NULL,
  birthType VARCHAR(50) NULL,
  birthPosition VARCHAR(100) NULL,
  durationPushing INT NULL,
  birthPresentation VARCHAR(100) NULL,
  cordWrap BOOLEAN NULL,
  cordWrapType VARCHAR(50) NULL,
  deliveryType VARCHAR(100) NULL,
  shoulderDystocia BOOLEAN NULL,
  shoulderDystociaMinutes INT NULL,
  laceration BOOLEAN NULL,
  episiotomy BOOLEAN NULL,
  repair BOOLEAN NULL,
  degree VARCHAR(50) NULL,
  lacerationRepairedBy VARCHAR(100) NULL,
  birthEBL INT NULL,
  meconium VARCHAR(50) NULL,
  comments VARCHAR(500) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  labor_id INT NOT NULL,
  UNIQUE(labor_id),
  FOREIGN KEY (labor_id) REFERENCES labor (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `laborStage3` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  placentaDatetime DATETIME NULL,
  placentaDeliverySpontaneous BOOLEAN NULL,
  placentaDeliveryAMTSL BOOLEAN NULL,
  placentaDeliveryCCT BOOLEAN NULL,
  placentaDeliveryManual BOOLEAN NULL,
  maternalPosition VARCHAR(50) NULL,
  txBloodLoss1 VARCHAR(50) NULL,
  txBloodLoss2 VARCHAR(50) NULL,
  txBloodLoss3 VARCHAR(50) NULL,
  txBloodLoss4 VARCHAR(50) NULL,
  txBloodLoss5 VARCHAR(50) NULL,
  placentaShape VARCHAR(50) NULL,
  placentaInsertion VARCHAR(50) NULL,
  placentaNumVessels INT NULL,
  schultzDuncan ENUM('Schultz', 'Duncan') NULL,
  placentaMembranesComplete BOOLEAN NULL,
  placentaOther VARCHAR(100) NULL,
  comments VARCHAR(500) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  labor_id INT NOT NULL,
  UNIQUE(labor_id),
  FOREIGN KEY (labor_id) REFERENCES labor (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;

CREATE TABLE IF NOT EXISTS `baby` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  birthNbr INT NOT NULL,
  lastname VARCHAR(50) NULL,
  firstname VARCHAR(50) NULL,
  middlename VARCHAR(50) NULL,
  sex ENUM('M', 'F') NOT NULL,
  birthWeight INT NULL,
  bFedEstablished DATETIME NULL,
  nbsDate DATETIME NULL,
  nbsResult VARCHAR(50) NULL,
  bcgDate DATETIME NULL,
  comments VARCHAR(500) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  labor_id INT NOT NULL,
  UNIQUE(labor_id, birthNbr),
  FOREIGN KEY (labor_id) REFERENCES labor (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS `apgar` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  minute INT NOT NULL,
  score INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  baby_id INT NOT NULL,
  UNIQUE(baby_id, minute),
  FOREIGN KEY (baby_id) REFERENCES baby (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

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

SET foreign_key_checks = 1;


