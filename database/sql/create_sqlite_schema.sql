-- ----------------------------------------------------
-- create_sqlite_schema.sql
-- Creates the tables, log tables, and the triggers.
-- Note: double dollar signs are used as statement delimiters.
-- ----------------------------------------------------
PRAGMA foreign_keys = ON$$

-- ----------------------------------------------------
-- Tables
-- ----------------------------------------------------

CREATE TABLE IF NOT EXISTS `user` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username VARCHAR(50) NOT NULL,
  firstname VARCHAR(30) NOT NULL,
  lastname VARCHAR(30) NOT NULL,
  password VARCHAR(60) NULL,
  email VARCHAR(100) NULL,
  lang VARCHAR(10) NULL,
  shortName VARCHAR(100) NULL,
  displayName VARCHAR(100) NULL,
  status BOOLEAN NOT NULL DEFAULT 1,
  note VARCHAR(300) NULL,
  isCurrentTeacher BOOLEAN NULL DEFAULT 0,
  role_id INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (username),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
  FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `userLog` (
  id INTEGER DEFAULT 0,
  username VARCHAR(50) NOT NULL,
  firstname VARCHAR(30) NOT NULL,
  lastname VARCHAR(30) NOT NULL,
  password VARCHAR(60) NULL,
  email VARCHAR(100) NULL,
  lang VARCHAR(10) NULL,
  shortName VARCHAR(100) NULL,
  displayName VARCHAR(100) NULL,
  status BOOLEAN NOT NULL DEFAULT 1,
  note VARCHAR(300) NULL,
  isCurrentTeacher BOOLEAN NULL DEFAULT 0,
  role_id INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
  FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `role` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(300) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (name),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `roleLog` (
  id INTEGER DEFAULT 0,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(300) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `dohSeq` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  year CHAR(4) NOT NULL,
  sequence INTEGER NOT NULL
)$$

CREATE TABLE IF NOT EXISTS `patient` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dohID VARCHAR(10) NULL,
  dob DATE NULL,
  generalInfo VARCHAR(8192) NULL,
  ageOfMenarche TINYINT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (dohID),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `patientLog` (
  id INTEGER DEFAULT 0,
  dohID VARCHAR(10) NULL,
  dob DATE NULL,
  generalInfo VARCHAR(8192) NULL,
  ageOfMenarche TINYINT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `pregnancy` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  firstname VARCHAR(70) NOT NULL,
  lastname VARCHAR(70) NOT NULL,
  maidenname VARCHAR(70) NULL,
  nickname VARCHAR(70) NULL,
  religion VARCHAR(50) NULL,
  maritalStatus VARCHAR(50) NULL,
  telephone VARCHAR(20) NULL,
  work VARCHAR(50) NULL,
  education VARCHAR(70) NULL,
  clientIncome INTEGER NULL,
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
  partnerAge INTEGER NULL,
  partnerWork VARCHAR(70) NULL,
  partnerEducation VARCHAR(70) NULL,
  partnerIncome INTEGER NULL,
  partnerIncomePeriod VARCHAR(15) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  patient_id INTEGER NOT NULL,
  FOREIGN KEY (patient_id) REFERENCES patient (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `pregnancyLog` (
  id INTEGER DEFAULT 0,
  firstname VARCHAR(70) NOT NULL,
  lastname VARCHAR(70) NOT NULL,
  maidenname VARCHAR(70) NULL,
  nickname VARCHAR(70) NULL,
  religion VARCHAR(50) NULL,
  maritalStatus VARCHAR(50) NULL,
  telephone VARCHAR(20) NULL,
  work VARCHAR(50) NULL,
  education VARCHAR(70) NULL,
  clientIncome INTEGER NULL,
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
  partnerAge INTEGER NULL,
  partnerWork VARCHAR(70) NULL,
  partnerEducation VARCHAR(70) NULL,
  partnerIncome INTEGER NULL,
  partnerIncomePeriod VARCHAR(15) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  patient_id INTEGER NOT NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (patient_id) REFERENCES patient (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `riskCode` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(40) NOT NULL,
  riskType VARCHAR(20) NOT NULL,
  description VARCHAR(250) NULL,
  UNIQUE (name)
)$$

CREATE TABLE IF NOT EXISTS `risk` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pregnancy_id INTEGER NOT NULL,
  riskCode INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (pregnancy_id, riskCode),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (riskCode) REFERENCES riskCode (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `riskLog` (
  id INTEGER DEFAULT 0,
  pregnancy_id INTEGER NOT NULL,
  riskCode INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (riskCode) REFERENCES riskCode (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `vaccinationType` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(40) NOT NULL,
  description VARCHAR(250) NULL,
  sortOrder TINYINT NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (name),
  UNIQUE(sortOrder),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `vaccinationTypeLog` (
  id INTEGER DEFAULT 0,
  name VARCHAR(40) NOT NULL,
  description VARCHAR(250) NULL,
  sortOrder TINYINT NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `vaccination` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vaccinationType INTEGER NOT NULL,
  vacDate DATE NULL,
  vacMonth TINYINT NULL,
  vacYear INTEGER NULL,
  administeredInternally BOOLEAN NOT NULL,
  note VARCHAR(300) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (vaccinationType) REFERENCES vaccinationType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `vaccinationLog` (
  id INTEGER DEFAULT 0,
  vaccinationType INTEGER NOT NULL,
  vacDate DATE NULL,
  vacMonth TINYINT NULL,
  vacYear INTEGER NULL,
  administeredInternally BOOLEAN NOT NULL,
  note VARCHAR(300) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (vaccinationType) REFERENCES vaccinationType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `healthTeaching` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL,
  topic VARCHAR(50) NOT NULL,
  teacher INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (teacher) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `healthTeachingLog` (
  id INTEGER DEFAULT 0,
  date DATE NOT NULL,
  topic VARCHAR(50) NOT NULL,
  teacher INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (teacher) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `medicationType` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(40) NOT NULL,
  description VARCHAR(250) NULL,
  sortOrder TINYINT NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (name),
  UNIQUE(sortOrder),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `medicationTypeLog` (
  id INTEGER DEFAULT 0,
  name VARCHAR(40) NOT NULL,
  description VARCHAR(250) NULL,
  sortOrder TINYINT NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `medication` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL,
  medicationType INTEGER NOT NULL,
  numberDispensed INTEGER NULL,
  note VARCHAR(300) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (medicationType) REFERENCES medicationType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `medicationLog` (
  id INTEGER DEFAULT 0,
  date DATE NOT NULL,
  medicationType INTEGER NOT NULL,
  numberDispensed INTEGER NULL,
  note VARCHAR(300) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (medicationType) REFERENCES medicationType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$


CREATE TABLE IF NOT EXISTS `pregnancyHistory` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  day VARCHAR(2) NULL,
  month VARCHAR(2) NULL,
  year VARCHAR(4) NOT NULL,
  FT BOOLEAN NULL,
  finalGA INTEGER NULL,
  finalGAPeriod VARCHAR(15) NULL,
  sexOfBaby CHAR(1) NULL,
  placeOfBirth VARCHAR(30) NULL,
  attendant VARCHAR(30) NULL,
  typeOfDelivery VARCHAR(30) NULL DEFAULT "NSD",
  lengthOfLabor TINYINT NULL,
  birthWeight DECIMAL(4,2) NULL,
  episTear CHAR(1) NULL DEFAULT '',
  repaired CHAR(1) NULL DEFAULT '',
  howLongBFed INTEGER NULL,
  howLongBFedPeriod VARCHAR(15) NULL,
  note VARCHAR(2000) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `pregnancyHistoryLog` (
  id INTEGER DEFAULT 0,
  day VARCHAR(2) NULL,
  month VARCHAR(2) NULL,
  year VARCHAR(4) NOT NULL,
  FT BOOLEAN NULL,
  finalGA INTEGER NULL,
  finalGAPeriod VARCHAR(15) NULL,
  sexOfBaby CHAR(1) NULL,
  placeOfBirth VARCHAR(30) NULL,
  attendant VARCHAR(30) NULL,
  typeOfDelivery VARCHAR(30) NULL DEFAULT "NSD",
  lengthOfLabor TINYINT NULL,
  birthWeight DECIMAL(4,2) NULL,
  episTear CHAR(1) NULL DEFAULT '',
  repaired CHAR(1) NULL DEFAULT '',
  howLongBFed INTEGER NULL,
  howLongBFedPeriod VARCHAR(15) NULL,
  note VARCHAR(2000) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `eventType` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(255) NULL,
  UNIQUE (name)
)$$

CREATE TABLE IF NOT EXISTS `event` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  eventType INTEGER NOT NULL,
  eDateTime DATETIME NOT NULL,
  note VARCHAR(255) NULL,
  sid VARCHAR(30) NULL,
  pregnancy_id INTEGER NULL,
  user_id INTEGER NULL,
  FOREIGN KEY (eventType) REFERENCES eventType (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `priority` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  eType INTEGER NOT NULL,
  priority INTEGER NOT NULL,
  barcode INTEGER NOT NULL,
  assigned DATETIME NULL,
  pregnancy_id INTEGER NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (priority, eType),
  UNIQUE (barcode),
  FOREIGN KEY (eType) REFERENCES eventType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `prenatalExam` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL,
  weight DECIMAL(4, 1) NULL,
  systolic INTEGER NULL,
  diastolic INTEGER NULL,
  cr INTEGER NULL,
  temperature DECIMAL(4,1) NULL,
  respiratoryRate INTEGER NULL,
  fh INTEGER NULL,
  fhNote VARCHAR(2000) NULL,
  fht INTEGER NULL,
  fhtNote VARCHAR(2000) NULL,
  pos VARCHAR(10) NULL,
  mvmt BOOLEAN NULL,
  edema VARCHAR(4) NULL,
  risk VARCHAR(2000) NULL,
  vitamin BOOLEAN NULL,
  pray BOOLEAN NULL,
  note VARCHAR(4000) NULL,
  returnDate DATE NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `prenatalExamLog` (
  id INTEGER DEFAULT 0,
  date DATE NOT NULL,
  weight DECIMAL(4, 1) NULL,
  systolic INTEGER NULL,
  diastolic INTEGER NULL,
  cr INTEGER NULL,
  temperature DECIMAL(4,1) NULL,
  respiratoryRate INTEGER NULL,
  fh INTEGER NULL,
  fhNote VARCHAR(2000) NULL,
  fht INTEGER NULL,
  fhtNote VARCHAR(2000) NULL,
  pos VARCHAR(10) NULL,
  mvmt BOOLEAN NULL,
  edema VARCHAR(4) NULL,
  risk VARCHAR(2000) NULL,
  vitamin BOOLEAN NULL,
  pray BOOLEAN NULL,
  note VARCHAR(4000) NULL,
  returnDate DATE NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `labSuite` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(100) NULL,
  category VARCHAR(50) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (name),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `labSuiteLog` (
  id INTEGER DEFAULT 0,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(100) NULL,
  category VARCHAR(50) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$


CREATE TABLE IF NOT EXISTS `labTest` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(70) NOT NULL,
  abbrev VARCHAR(70) NULL,
  normal VARCHAR(50) NULL,
  unit VARCHAR(10) NULL,
  minRangeDecimal DECIMAL(7,3) NULL,
  maxRangeDecimal DECIMAL(7,3) NULL,
  minRangeInteger INTEGER NULL,
  maxRangeInteger INTEGER NULL,
  isRange BOOLEAN NOT NULL DEFAULT 0,
  isText BOOLEAN NOT NULL DEFAULT 0,
  labSuite_id INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (name),
  UNIQUE (abbrev),
  FOREIGN KEY (labSuite_id) REFERENCES labSuite (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `labTestLog` (
  id INTEGER DEFAULT 0,
  name VARCHAR(70) NOT NULL,
  abbrev VARCHAR(70) NULL,
  normal VARCHAR(50) NULL,
  unit VARCHAR(10) NULL,
  minRangeDecimal DECIMAL(7,3) NULL,
  maxRangeDecimal DECIMAL(7,3) NULL,
  minRangeInteger INTEGER NULL,
  maxRangeInteger INTEGER NULL,
  isRange BOOLEAN NOT NULL DEFAULT 0,
  isText BOOLEAN NOT NULL DEFAULT 0,
  labSuite_id INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (labSuite_id) REFERENCES labSuite (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$


CREATE TABLE IF NOT EXISTS `labTestValue` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  value VARCHAR(50) NOT NULL,
  labTest_id INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (labTest_id, value),
  FOREIGN KEY (labTest_id) REFERENCES labTest (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `labTestValueLog` (
  id INTEGER DEFAULT 0,
  value VARCHAR(50) NOT NULL,
  labTest_id INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (labTest_id) REFERENCES labTest (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$


CREATE TABLE IF NOT EXISTS `labTestResult` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  testDate DATE NOT NULL,
  result VARCHAR(4000) NOT NULL,
  result2 VARCHAR(100) NULL,
  warn BOOLEAN NULL,
  labTest_id INTEGER NOT NULL,
  pregnancy_id INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (labTest_id) REFERENCES labTest (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `labTestResultLog` (
  id INTEGER DEFAULT 0,
  testDate DATE NOT NULL,
  result VARCHAR(4000) NOT NULL,
  result2 VARCHAR(100) NULL,
  warn BOOLEAN NULL,
  labTest_id INTEGER NOT NULL,
  pregnancy_id INTEGER NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (labTest_id) REFERENCES labTest (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `referral` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL,
  referral VARCHAR(300) NOT NULL,
  reason VARCHAR(300) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `referralLog` (
  id INTEGER DEFAULT 0,
  date DATE NOT NULL,
  referral VARCHAR(300) NOT NULL,
  reason VARCHAR(300) NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `selectData` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(30) NOT NULL,
  selectKey VARCHAR(30) NOT NULL,
  label VARCHAR(150) NOT NULL,
  selected BOOLEAN NOT NULL DEFAULT 0,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  UNIQUE (name, selectKey),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `selectDataLog` (
  id INTEGER DEFAULT 0,
  name VARCHAR(30) NOT NULL,
  selectKey VARCHAR(30) NOT NULL,
  label VARCHAR(150) NOT NULL,
  selected BOOLEAN NOT NULL DEFAULT 0,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `schedule` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  scheduleType VARCHAR(20) NOT NULL,
  location VARCHAR(20) NOT NULL,
  day VARCHAR(20) NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  UNIQUE (pregnancy_id, scheduleType),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `scheduleLog` (
  id INTEGER DEFAULT 0,
  scheduleType VARCHAR(20) NOT NULL,
  location VARCHAR(20) NOT NULL,
  day VARCHAR(20) NOT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `customFieldType` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(20) NOT NULL,
  title VARCHAR(30) NULL,
  description VARCHAR(250) NULL,
  label VARCHAR(50) NULL,
  valueFieldName VARCHAR(30) NOT NULL
)$$

CREATE TABLE IF NOT EXISTS `customField` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customFieldType_id INTEGER NOT NULL,
  pregnancy_id INTEGER NOT NULL,
  booleanVal BOOLEAN NULL,
  intVal INTEGER NULL,
  decimalVal DECIMAL(10, 5) NULL,
  textVAl TEXT NULL,
  dateTimeVal DATETIME NULL,
  UNIQUE (customFieldType_id, pregnancy_id),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `customFieldLog` (
  id INTEGER DEFAULT 0,
  customFieldType_id INTEGER NOT NULL,
  pregnancy_id INTEGER NOT NULL,
  booleanVal BOOLEAN NULL,
  intVal INTEGER NULL,
  decimalVal DECIMAL(10, 5) NULL,
  textVAl TEXT NULL,
  dateTimeVal DATETIME NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `roFieldsByRole` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  roleName VARCHAR(30) NOT NULL,
  tableName VARCHAR(30) NOT NULL,
  fieldName VARCHAR(30) NOT NULL,
  UNIQUE (roleName, tableName, fieldName)
)$$

CREATE TABLE IF NOT EXISTS `pregnoteType` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name VARCHAR(20) NOT NULL,
  description VARCHAR(250) NULL,
  UNIQUE(name)
)$$

CREATE TABLE IF NOT EXISTS `pregnoteTypeLog` (
  id INTEGER DEFAULT 0,
  name VARCHAR(20) NOT NULL,
  description VARCHAR(250) NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt)
)$$

CREATE TABLE IF NOT EXISTS `pregnote` (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pregnoteType INTEGER NOT NULL,
  noteDate DATE NOT NULL,
  note TEXT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (pregnoteType) REFERENCES pregnoteType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

CREATE TABLE IF NOT EXISTS `pregnoteLog` (
  id INTEGER DEFAULT 0,
  pregnoteType INTEGER NOT NULL,
  noteDate DATE NOT NULL,
  note TEXT NULL,
  updatedBy INTEGER NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INTEGER NULL,
  pregnancy_id INTEGER NOT NULL,
  op CHAR(1) DEFAULT '',
  replacedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id, replacedAt),
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (pregnoteType) REFERENCES pregnoteType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
)$$

-- ----------------------------------------------------
-- Triggers
-- ----------------------------------------------------

DROP TRIGGER IF EXISTS customField_after_insert$$
CREATE TRIGGER customField_after_insert AFTER INSERT ON customField
FOR EACH ROW
BEGIN
  INSERT INTO customFieldLog
  (id, customFieldType_id, pregnancy_id, booleanVal, intVal, decimalVal, textVAl, dateTimeVal, op, replacedAt)
  VALUES (NEW.id, NEW.customFieldType_id, NEW.pregnancy_id, NEW.booleanVal, NEW.intVal, NEW.decimalVal, NEW.textVAl, NEW.dateTimeVal, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: customField_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS customField_after_update$$
CREATE TRIGGER customField_after_update AFTER UPDATE ON customField
FOR EACH ROW
BEGIN
  INSERT INTO customFieldLog
  (id, customFieldType_id, pregnancy_id, booleanVal, intVal, decimalVal, textVAl, dateTimeVal, op, replacedAt)
  VALUES (NEW.id, NEW.customFieldType_id, NEW.pregnancy_id, NEW.booleanVal, NEW.intVal, NEW.decimalVal, NEW.textVAl, NEW.dateTimeVal, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: customField_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS customField_after_delete$$
CREATE TRIGGER customField_after_delete AFTER DELETE ON customField
FOR EACH ROW
BEGIN
  INSERT INTO customFieldLog
  (id, customFieldType_id, pregnancy_id, booleanVal, intVal, decimalVal, textVAl, dateTimeVal, op, replacedAt)
  VALUES (OLD.id, OLD.customFieldType_id, OLD.pregnancy_id, OLD.booleanVal, OLD.intVal, OLD.decimalVal, OLD.textVAl, OLD.dateTimeVal, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: healthTeaching_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS healthTeaching_after_insert$$
CREATE TRIGGER healthTeaching_after_insert AFTER INSERT ON healthTeaching
FOR EACH ROW
BEGIN
  INSERT INTO healthTeachingLog
  (id, date, topic, teacher, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.topic, NEW.teacher, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: healthTeaching_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS healthTeaching_after_update$$
CREATE TRIGGER healthTeaching_after_update AFTER UPDATE ON healthTeaching
FOR EACH ROW
BEGIN
  INSERT INTO healthTeachingLog
  (id, date, topic, teacher, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.topic, NEW.teacher, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: healthTeaching_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS healthTeaching_after_delete$$
CREATE TRIGGER healthTeaching_after_delete AFTER DELETE ON healthTeaching
FOR EACH ROW
BEGIN
  INSERT INTO healthTeachingLog
  (id, date, topic, teacher, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.topic, OLD.teacher, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labSuite_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labSuite_after_insert$$
CREATE TRIGGER labSuite_after_insert AFTER INSERT ON labSuite
FOR EACH ROW
BEGIN
  INSERT INTO labSuiteLog
  (id, name, description, category, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.category, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labSuite_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labSuite_after_update$$
CREATE TRIGGER labSuite_after_update AFTER UPDATE ON labSuite
FOR EACH ROW
BEGIN
  INSERT INTO labSuiteLog
  (id, name, description, category, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.category, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labSuite_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labSuite_after_delete$$
CREATE TRIGGER labSuite_after_delete AFTER DELETE ON labSuite
FOR EACH ROW
BEGIN
  INSERT INTO labSuiteLog
  (id, name, description, category, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.category, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labTest_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labTest_after_insert$$
CREATE TRIGGER labTest_after_insert AFTER INSERT ON labTest
FOR EACH ROW
BEGIN
  INSERT INTO labTestLog
  (id, name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger, maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.abbrev, NEW.normal, NEW.unit, NEW.minRangeDecimal, NEW.maxRangeDecimal, NEW.minRangeInteger, NEW.maxRangeInteger, NEW.isRange, NEW.isText, NEW.labSuite_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labTest_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labTest_after_update$$
CREATE TRIGGER labTest_after_update AFTER UPDATE ON labTest
FOR EACH ROW
BEGIN
  INSERT INTO labTestLog
  (id, name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger, maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.abbrev, NEW.normal, NEW.unit, NEW.minRangeDecimal, NEW.maxRangeDecimal, NEW.minRangeInteger, NEW.maxRangeInteger, NEW.isRange, NEW.isText, NEW.labSuite_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labTest_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labTest_after_delete$$
CREATE TRIGGER labTest_after_delete AFTER DELETE ON labTest
FOR EACH ROW
BEGIN
  INSERT INTO labTestLog
  (id, name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger, maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.abbrev, OLD.normal, OLD.unit, OLD.minRangeDecimal, OLD.maxRangeDecimal, OLD.minRangeInteger, OLD.maxRangeInteger, OLD.isRange, OLD.isText, OLD.labSuite_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labTestResult_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labTestResult_after_insert$$
CREATE TRIGGER labTestResult_after_insert AFTER INSERT ON labTestResult
FOR EACH ROW
BEGIN
  INSERT INTO labTestResultLog
  (id, testDate, result, result2, warn, labTest_id, pregnancy_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.testDate, NEW.result, NEW.result2, NEW.warn, NEW.labTest_id, NEW.pregnancy_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labTestResult_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labTestResult_after_update$$
CREATE TRIGGER labTestResult_after_update AFTER UPDATE ON labTestResult
FOR EACH ROW
BEGIN
  INSERT INTO labTestResultLog
  (id, testDate, result, result2, warn, labTest_id, pregnancy_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.testDate, NEW.result, NEW.result2, NEW.warn, NEW.labTest_id, NEW.pregnancy_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labTestResult_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labTestResult_after_delete$$
CREATE TRIGGER labTestResult_after_delete AFTER DELETE ON labTestResult
FOR EACH ROW
BEGIN
  INSERT INTO labTestResultLog
  (id, testDate, result, result2, warn, labTest_id, pregnancy_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.testDate, OLD.result, OLD.result2, OLD.warn, OLD.labTest_id, OLD.pregnancy_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labTestValue_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labTestValue_after_insert$$
CREATE TRIGGER labTestValue_after_insert AFTER INSERT ON labTestValue
FOR EACH ROW
BEGIN
  INSERT INTO labTestValueLog
  (id, value, labTest_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.value, NEW.labTest_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labTestValue_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labTestValue_after_update$$
CREATE TRIGGER labTestValue_after_update AFTER UPDATE ON labTestValue
FOR EACH ROW
BEGIN
  INSERT INTO labTestValueLog
  (id, value, labTest_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.value, NEW.labTest_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: labTestValue_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS labTestValue_after_delete$$
CREATE TRIGGER labTestValue_after_delete AFTER DELETE ON labTestValue
FOR EACH ROW
BEGIN
  INSERT INTO labTestValueLog
  (id, value, labTest_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.value, OLD.labTest_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: medication_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS medication_after_insert$$
CREATE TRIGGER medication_after_insert AFTER INSERT ON medication
FOR EACH ROW
BEGIN
  INSERT INTO medicationLog
  (id, date, medicationType, numberDispensed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.medicationType, NEW.numberDispensed, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: medication_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS medication_after_update$$
CREATE TRIGGER medication_after_update AFTER UPDATE ON medication
FOR EACH ROW
BEGIN
  INSERT INTO medicationLog
  (id, date, medicationType, numberDispensed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.medicationType, NEW.numberDispensed, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: medication_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS medication_after_delete$$
CREATE TRIGGER medication_after_delete AFTER DELETE ON medication
FOR EACH ROW
BEGIN
  INSERT INTO medicationLog
  (id, date, medicationType, numberDispensed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.medicationType, OLD.numberDispensed, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: medicationType_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS medicationType_after_insert$$
CREATE TRIGGER medicationType_after_insert AFTER INSERT ON medicationType
FOR EACH ROW
BEGIN
  INSERT INTO medicationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: medicationType_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS medicationType_after_update$$
CREATE TRIGGER medicationType_after_update AFTER UPDATE ON medicationType
FOR EACH ROW
BEGIN
  INSERT INTO medicationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: medicationType_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS medicationType_after_delete$$
CREATE TRIGGER medicationType_after_delete AFTER DELETE ON medicationType
FOR EACH ROW
BEGIN
  INSERT INTO medicationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.sortOrder, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: patient_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS patient_after_insert$$
CREATE TRIGGER patient_after_insert AFTER INSERT ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.dohID, NEW.dob, NEW.generalInfo, NEW.ageOfMenarche, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: patient_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS patient_after_update$$
CREATE TRIGGER patient_after_update AFTER UPDATE ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.dohID, NEW.dob, NEW.generalInfo, NEW.ageOfMenarche, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: patient_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS patient_after_delete$$
CREATE TRIGGER patient_after_delete AFTER DELETE ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.dohID, OLD.dob, OLD.generalInfo, OLD.ageOfMenarche, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnancyHistory_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnancyHistory_after_insert$$
CREATE TRIGGER pregnancyHistory_after_insert AFTER INSERT ON pregnancyHistory
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyHistoryLog
  (id, day, month, year, FT, finalGA, finalGAPeriod, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, howLongBFedPeriod, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.day, NEW.month, NEW.year, NEW.FT, NEW.finalGA, NEW.finalGAPeriod, NEW.sexOfBaby, NEW.placeOfBirth, NEW.attendant, NEW.typeOfDelivery, NEW.lengthOfLabor, NEW.birthWeight, NEW.episTear, NEW.repaired, NEW.howLongBFed, NEW.howLongBFedPeriod, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnancyHistory_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnancyHistory_after_update$$
CREATE TRIGGER pregnancyHistory_after_update AFTER UPDATE ON pregnancyHistory
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyHistoryLog
  (id, day, month, year, FT, finalGA, finalGAPeriod, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, howLongBFedPeriod, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.day, NEW.month, NEW.year, NEW.FT, NEW.finalGA, NEW.finalGAPeriod, NEW.sexOfBaby, NEW.placeOfBirth, NEW.attendant, NEW.typeOfDelivery, NEW.lengthOfLabor, NEW.birthWeight, NEW.episTear, NEW.repaired, NEW.howLongBFed, NEW.howLongBFedPeriod, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnancyHistory_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnancyHistory_after_delete$$
CREATE TRIGGER pregnancyHistory_after_delete AFTER DELETE ON pregnancyHistory
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyHistoryLog
  (id, day, month, year, FT, finalGA, finalGAPeriod, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, howLongBFedPeriod, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.day, OLD.month, OLD.year, OLD.FT, OLD.finalGA, OLD.finalGAPeriod, OLD.sexOfBaby, OLD.placeOfBirth, OLD.attendant, OLD.typeOfDelivery, OLD.lengthOfLabor, OLD.birthWeight, OLD.episTear, OLD.repaired, OLD.howLongBFed, OLD.howLongBFedPeriod, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnancy_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnancy_after_insert$$
CREATE TRIGGER pregnancy_after_insert AFTER INSERT ON pregnancy
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyLog
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, clientIncome, clientIncomePeriod, address1, address2, address3, address4, city, state, postalCode, country, gravidaNumber, lmp, sureLMP, warning, riskNote, alternateEdd, useAlternateEdd, doctorConsultDate, dentistConsultDate, mbBook, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, transferOfCare, transferOfCareNote, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyVaginalPain, currentlyVaginalItching, currentlyNone, useIodizedSalt, takingMedication, planToBreastFeed, birthCompanion, practiceFamilyPlanning, practiceFamilyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryHeartProblems, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyHeartProblems, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, questionnaireNote, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerIncome, partnerIncomePeriod, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (NEW.id, NEW.firstname, NEW.lastname, NEW.maidenname, NEW.nickname, NEW.religion, NEW.maritalStatus, NEW.telephone, NEW.work, NEW.education, NEW.clientIncome, NEW.clientIncomePeriod, NEW.address1, NEW.address2, NEW.address3, NEW.address4, NEW.city, NEW.state, NEW.postalCode, NEW.country, NEW.gravidaNumber, NEW.lmp, NEW.sureLMP, NEW.warning, NEW.riskNote, NEW.alternateEdd, NEW.useAlternateEdd, NEW.doctorConsultDate, NEW.dentistConsultDate, NEW.mbBook, NEW.whereDeliver, NEW.fetuses, NEW.monozygotic, NEW.pregnancyEndDate, NEW.pregnancyEndResult, NEW.iugr, NEW.note, NEW.numberRequiredTetanus, NEW.invertedNipples, NEW.hasUS, NEW.wantsUS, NEW.gravida, NEW.stillBirths, NEW.abortions, NEW.living, NEW.para, NEW.term, NEW.preterm, NEW.philHealthMCP, NEW.philHealthNCP, NEW.philHealthID, NEW.philHealthApproved, NEW.transferOfCare, NEW.transferOfCareNote, NEW.currentlyVomiting, NEW.currentlyDizzy, NEW.currentlyFainting, NEW.currentlyBleeding, NEW.currentlyUrinationPain, NEW.currentlyBlurryVision, NEW.currentlySwelling, NEW.currentlyVaginalPain, NEW.currentlyVaginalItching, NEW.currentlyNone, NEW.useIodizedSalt, NEW.takingMedication, NEW.planToBreastFeed, NEW.birthCompanion, NEW.practiceFamilyPlanning, NEW.practiceFamilyPlanningDetails, NEW.familyHistoryTwins, NEW.familyHistoryHighBloodPressure, NEW.familyHistoryDiabetes, NEW.familyHistoryHeartProblems, NEW.familyHistoryTB, NEW.familyHistorySmoking, NEW.familyHistoryNone, NEW.historyFoodAllergy, NEW.historyMedicineAllergy, NEW.historyAsthma, NEW.historyHeartProblems, NEW.historyKidneyProblems, NEW.historyHepatitis, NEW.historyGoiter, NEW.historyHighBloodPressure, NEW.historyHospitalOperation, NEW.historyBloodTransfusion, NEW.historySmoking, NEW.historyDrinking, NEW.historyNone, NEW.questionnaireNote, NEW.partnerFirstname, NEW.partnerLastname, NEW.partnerAge, NEW.partnerWork, NEW.partnerEducation, NEW.partnerIncome, NEW.partnerIncomePeriod, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.patient_id, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnancy_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnancy_after_update$$
CREATE TRIGGER pregnancy_after_update AFTER UPDATE ON pregnancy
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyLog
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, clientIncome, clientIncomePeriod, address1, address2, address3, address4, city, state, postalCode, country, gravidaNumber, lmp, sureLMP, warning, riskNote, alternateEdd, useAlternateEdd, doctorConsultDate, dentistConsultDate, mbBook, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, transferOfCare, transferOfCareNote, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyVaginalPain, currentlyVaginalItching, currentlyNone, useIodizedSalt, takingMedication, planToBreastFeed, birthCompanion, practiceFamilyPlanning, practiceFamilyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryHeartProblems, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyHeartProblems, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, questionnaireNote, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerIncome, partnerIncomePeriod, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (NEW.id, NEW.firstname, NEW.lastname, NEW.maidenname, NEW.nickname, NEW.religion, NEW.maritalStatus, NEW.telephone, NEW.work, NEW.education, NEW.clientIncome, NEW.clientIncomePeriod, NEW.address1, NEW.address2, NEW.address3, NEW.address4, NEW.city, NEW.state, NEW.postalCode, NEW.country, NEW.gravidaNumber, NEW.lmp, NEW.sureLMP, NEW.warning, NEW.riskNote, NEW.alternateEdd, NEW.useAlternateEdd, NEW.doctorConsultDate, NEW.dentistConsultDate, NEW.mbBook, NEW.whereDeliver, NEW.fetuses, NEW.monozygotic, NEW.pregnancyEndDate, NEW.pregnancyEndResult, NEW.iugr, NEW.note, NEW.numberRequiredTetanus, NEW.invertedNipples, NEW.hasUS, NEW.wantsUS, NEW.gravida, NEW.stillBirths, NEW.abortions, NEW.living, NEW.para, NEW.term, NEW.preterm, NEW.philHealthMCP, NEW.philHealthNCP, NEW.philHealthID, NEW.philHealthApproved, NEW.transferOfCare, NEW.transferOfCareNote, NEW.currentlyVomiting, NEW.currentlyDizzy, NEW.currentlyFainting, NEW.currentlyBleeding, NEW.currentlyUrinationPain, NEW.currentlyBlurryVision, NEW.currentlySwelling, NEW.currentlyVaginalPain, NEW.currentlyVaginalItching, NEW.currentlyNone, NEW.useIodizedSalt, NEW.takingMedication, NEW.planToBreastFeed, NEW.birthCompanion, NEW.practiceFamilyPlanning, NEW.practiceFamilyPlanningDetails, NEW.familyHistoryTwins, NEW.familyHistoryHighBloodPressure, NEW.familyHistoryDiabetes, NEW.familyHistoryHeartProblems, NEW.familyHistoryTB, NEW.familyHistorySmoking, NEW.familyHistoryNone, NEW.historyFoodAllergy, NEW.historyMedicineAllergy, NEW.historyAsthma, NEW.historyHeartProblems, NEW.historyKidneyProblems, NEW.historyHepatitis, NEW.historyGoiter, NEW.historyHighBloodPressure, NEW.historyHospitalOperation, NEW.historyBloodTransfusion, NEW.historySmoking, NEW.historyDrinking, NEW.historyNone, NEW.questionnaireNote, NEW.partnerFirstname, NEW.partnerLastname, NEW.partnerAge, NEW.partnerWork, NEW.partnerEducation, NEW.partnerIncome, NEW.partnerIncomePeriod, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.patient_id, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnancy_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnancy_after_delete$$
CREATE TRIGGER pregnancy_after_delete AFTER DELETE ON pregnancy
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyLog
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, clientIncome, clientIncomePeriod, address1, address2, address3, address4, city, state, postalCode, country, gravidaNumber, lmp, sureLMP, warning, riskNote, alternateEdd, useAlternateEdd, doctorConsultDate, dentistConsultDate, mbBook, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, transferOfCare, transferOfCareNote, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyVaginalPain, currentlyVaginalItching, currentlyNone, useIodizedSalt, takingMedication, planToBreastFeed, birthCompanion, practiceFamilyPlanning, practiceFamilyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryHeartProblems, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyHeartProblems, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, questionnaireNote, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerIncome, partnerIncomePeriod, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (OLD.id, OLD.firstname, OLD.lastname, OLD.maidenname, OLD.nickname, OLD.religion, OLD.maritalStatus, OLD.telephone, OLD.work, OLD.education, OLD.clientIncome, OLD.clientIncomePeriod, OLD.address1, OLD.address2, OLD.address3, OLD.address4, OLD.city, OLD.state, OLD.postalCode, OLD.country, OLD.gravidaNumber, OLD.lmp, OLD.sureLMP, OLD.warning, OLD.riskNote, OLD.alternateEdd, OLD.useAlternateEdd, OLD.doctorConsultDate, OLD.dentistConsultDate, OLD.mbBook, OLD.whereDeliver, OLD.fetuses, OLD.monozygotic, OLD.pregnancyEndDate, OLD.pregnancyEndResult, OLD.iugr, OLD.note, OLD.numberRequiredTetanus, OLD.invertedNipples, OLD.hasUS, OLD.wantsUS, OLD.gravida, OLD.stillBirths, OLD.abortions, OLD.living, OLD.para, OLD.term, OLD.preterm, OLD.philHealthMCP, OLD.philHealthNCP, OLD.philHealthID, OLD.philHealthApproved, OLD.transferOfCare, OLD.transferOfCareNote, OLD.currentlyVomiting, OLD.currentlyDizzy, OLD.currentlyFainting, OLD.currentlyBleeding, OLD.currentlyUrinationPain, OLD.currentlyBlurryVision, OLD.currentlySwelling, OLD.currentlyVaginalPain, OLD.currentlyVaginalItching, OLD.currentlyNone, OLD.useIodizedSalt, OLD.takingMedication, OLD.planToBreastFeed, OLD.birthCompanion, OLD.practiceFamilyPlanning, OLD.practiceFamilyPlanningDetails, OLD.familyHistoryTwins, OLD.familyHistoryHighBloodPressure, OLD.familyHistoryDiabetes, OLD.familyHistoryHeartProblems, OLD.familyHistoryTB, OLD.familyHistorySmoking, OLD.familyHistoryNone, OLD.historyFoodAllergy, OLD.historyMedicineAllergy, OLD.historyAsthma, OLD.historyHeartProblems, OLD.historyKidneyProblems, OLD.historyHepatitis, OLD.historyGoiter, OLD.historyHighBloodPressure, OLD.historyHospitalOperation, OLD.historyBloodTransfusion, OLD.historySmoking, OLD.historyDrinking, OLD.historyNone, OLD.questionnaireNote, OLD.partnerFirstname, OLD.partnerLastname, OLD.partnerAge, OLD.partnerWork, OLD.partnerEducation, OLD.partnerIncome, OLD.partnerIncomePeriod, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.patient_id, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnote_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnote_after_insert$$
CREATE TRIGGER pregnote_after_insert AFTER INSERT ON pregnote
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteLog
  (id, pregnoteType, noteDate, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.pregnoteType, NEW.noteDate, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnote_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnote_after_update$$
CREATE TRIGGER pregnote_after_update AFTER UPDATE ON pregnote
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteLog
  (id, pregnoteType, noteDate, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.pregnoteType, NEW.noteDate, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnote_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnote_after_delete$$
CREATE TRIGGER pregnote_after_delete AFTER DELETE ON pregnote
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteLog
  (id, pregnoteType, noteDate, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.pregnoteType, OLD.noteDate, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnoteType_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnoteType_after_insert$$
CREATE TRIGGER pregnoteType_after_insert AFTER INSERT ON pregnoteType
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteTypeLog
  (id, name, description, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnoteType_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnoteType_after_update$$
CREATE TRIGGER pregnoteType_after_update AFTER UPDATE ON pregnoteType
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteTypeLog
  (id, name, description, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: pregnoteType_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS pregnoteType_after_delete$$
CREATE TRIGGER pregnoteType_after_delete AFTER DELETE ON pregnoteType
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteTypeLog
  (id, name, description, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: prenatalExam_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS prenatalExam_after_insert$$
CREATE TRIGGER prenatalExam_after_insert AFTER INSERT ON prenatalExam
FOR EACH ROW
BEGIN
  INSERT INTO prenatalExamLog
  (id, date, weight, systolic, diastolic, cr, temperature, respiratoryRate, fh, fhNote, fht, fhtNote, pos, mvmt, edema, risk, vitamin, pray, note, returnDate, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.weight, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temperature, NEW.respiratoryRate, NEW.fh, NEW.fhNote, NEW.fht, NEW.fhtNote, NEW.pos, NEW.mvmt, NEW.edema, NEW.risk, NEW.vitamin, NEW.pray, NEW.note, NEW.returnDate, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: prenatalExam_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS prenatalExam_after_update$$
CREATE TRIGGER prenatalExam_after_update AFTER UPDATE ON prenatalExam
FOR EACH ROW
BEGIN
  INSERT INTO prenatalExamLog
  (id, date, weight, systolic, diastolic, cr, temperature, respiratoryRate, fh, fhNote, fht, fhtNote, pos, mvmt, edema, risk, vitamin, pray, note, returnDate, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.weight, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temperature, NEW.respiratoryRate, NEW.fh, NEW.fhNote, NEW.fht, NEW.fhtNote, NEW.pos, NEW.mvmt, NEW.edema, NEW.risk, NEW.vitamin, NEW.pray, NEW.note, NEW.returnDate, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: prenatalExam_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS prenatalExam_after_delete$$
CREATE TRIGGER prenatalExam_after_delete AFTER DELETE ON prenatalExam
FOR EACH ROW
BEGIN
  INSERT INTO prenatalExamLog
  (id, date, weight, systolic, diastolic, cr, temperature, respiratoryRate, fh, fhNote, fht, fhtNote, pos, mvmt, edema, risk, vitamin, pray, note, returnDate, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.weight, OLD.systolic, OLD.diastolic, OLD.cr, OLD.temperature, OLD.respiratoryRate, OLD.fh, OLD.fhNote, OLD.fht, OLD.fhtNote, OLD.pos, OLD.mvmt, OLD.edema, OLD.risk, OLD.vitamin, OLD.pray, OLD.note, OLD.returnDate, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: referral_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS referral_after_insert$$
CREATE TRIGGER referral_after_insert AFTER INSERT ON referral
FOR EACH ROW
BEGIN
  INSERT INTO referralLog
  (id, date, referral, reason, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.referral, NEW.reason, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: referral_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS referral_after_update$$
CREATE TRIGGER referral_after_update AFTER UPDATE ON referral
FOR EACH ROW
BEGIN
  INSERT INTO referralLog
  (id, date, referral, reason, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.referral, NEW.reason, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: referral_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS referral_after_delete$$
CREATE TRIGGER referral_after_delete AFTER DELETE ON referral
FOR EACH ROW
BEGIN
  INSERT INTO referralLog
  (id, date, referral, reason, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.referral, OLD.reason, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: risk_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS risk_after_insert$$
CREATE TRIGGER risk_after_insert AFTER INSERT ON risk
FOR EACH ROW
BEGIN
  INSERT INTO riskLog
  (id, pregnancy_id, riskCode, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.pregnancy_id, NEW.riskCode, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: risk_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS risk_after_update$$
CREATE TRIGGER risk_after_update AFTER UPDATE ON risk
FOR EACH ROW
BEGIN
  INSERT INTO riskLog
  (id, pregnancy_id, riskCode, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.pregnancy_id, NEW.riskCode, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: risk_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS risk_after_delete$$
CREATE TRIGGER risk_after_delete AFTER DELETE ON risk
FOR EACH ROW
BEGIN
  INSERT INTO riskLog
  (id, pregnancy_id, riskCode, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.pregnancy_id, OLD.riskCode, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: role_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS role_after_insert$$
CREATE TRIGGER role_after_insert AFTER INSERT ON role
FOR EACH ROW
BEGIN
  INSERT INTO roleLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: role_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS role_after_update$$
CREATE TRIGGER role_after_update AFTER UPDATE ON role
FOR EACH ROW
BEGIN
  INSERT INTO roleLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: role_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS role_after_delete$$
CREATE TRIGGER role_after_delete AFTER DELETE ON role
FOR EACH ROW
BEGIN
  INSERT INTO roleLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: schedule_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS schedule_after_insert$$
CREATE TRIGGER schedule_after_insert AFTER INSERT ON schedule
FOR EACH ROW
BEGIN
  INSERT INTO scheduleLog
  (id, scheduleType, location, day, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.scheduleType, NEW.location, NEW.day, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: schedule_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS schedule_after_update$$
CREATE TRIGGER schedule_after_update AFTER UPDATE ON schedule
FOR EACH ROW
BEGIN
  INSERT INTO scheduleLog
  (id, scheduleType, location, day, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.scheduleType, NEW.location, NEW.day, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: schedule_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS schedule_after_delete$$
CREATE TRIGGER schedule_after_delete AFTER DELETE ON schedule
FOR EACH ROW
BEGIN
  INSERT INTO scheduleLog
  (id, scheduleType, location, day, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.scheduleType, OLD.location, OLD.day, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: selectData_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS selectData_after_insert$$
CREATE TRIGGER selectData_after_insert AFTER INSERT ON selectData
FOR EACH ROW
BEGIN
  INSERT INTO selectDataLog
  (id, name, selectKey, label, selected, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.selectKey, NEW.label, NEW.selected, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: selectData_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS selectData_after_update$$
CREATE TRIGGER selectData_after_update AFTER UPDATE ON selectData
FOR EACH ROW
BEGIN
  INSERT INTO selectDataLog
  (id, name, selectKey, label, selected, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.selectKey, NEW.label, NEW.selected, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: selectData_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS selectData_after_delete$$
CREATE TRIGGER selectData_after_delete AFTER DELETE ON selectData
FOR EACH ROW
BEGIN
  INSERT INTO selectDataLog
  (id, name, selectKey, label, selected, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.selectKey, OLD.label, OLD.selected, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: user_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS user_after_insert$$
CREATE TRIGGER user_after_insert AFTER INSERT ON user
FOR EACH ROW
BEGIN
  INSERT INTO userLog
  (id, username, firstname, lastname, password, email, lang, shortName, displayName, status, note, isCurrentTeacher, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.username, NEW.firstname, NEW.lastname, NEW.password, NEW.email, NEW.lang, NEW.shortName, NEW.displayName, NEW.status, NEW.note, NEW.isCurrentTeacher, NEW.role_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: user_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS user_after_update$$
CREATE TRIGGER user_after_update AFTER UPDATE ON user
FOR EACH ROW
BEGIN
  INSERT INTO userLog
  (id, username, firstname, lastname, password, email, lang, shortName, displayName, status, note, isCurrentTeacher, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.username, NEW.firstname, NEW.lastname, NEW.password, NEW.email, NEW.lang, NEW.shortName, NEW.displayName, NEW.status, NEW.note, NEW.isCurrentTeacher, NEW.role_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: user_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS user_after_delete$$
CREATE TRIGGER user_after_delete AFTER DELETE ON user
FOR EACH ROW
BEGIN
  INSERT INTO userLog
  (id, username, firstname, lastname, password, email, lang, shortName, displayName, status, note, isCurrentTeacher, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.username, OLD.firstname, OLD.lastname, OLD.password, OLD.email, OLD.lang, OLD.shortName, OLD.displayName, OLD.status, OLD.note, OLD.isCurrentTeacher, OLD.role_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: vaccination_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS vaccination_after_insert$$
CREATE TRIGGER vaccination_after_insert AFTER INSERT ON vaccination
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationLog
  (id, vaccinationType, vacDate, vacMonth, vacYear, administeredInternally, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.vaccinationType, NEW.vacDate, NEW.vacMonth, NEW.vacYear, NEW.administeredInternally, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: vaccination_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS vaccination_after_update$$
CREATE TRIGGER vaccination_after_update AFTER UPDATE ON vaccination
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationLog
  (id, vaccinationType, vacDate, vacMonth, vacYear, administeredInternally, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.vaccinationType, NEW.vacDate, NEW.vacMonth, NEW.vacYear, NEW.administeredInternally, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: vaccination_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS vaccination_after_delete$$
CREATE TRIGGER vaccination_after_delete AFTER DELETE ON vaccination
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationLog
  (id, vaccinationType, vacDate, vacMonth, vacYear, administeredInternally, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.vaccinationType, OLD.vacDate, OLD.vacMonth, OLD.vacYear, OLD.administeredInternally, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: vaccinationType_after_insert
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS vaccinationType_after_insert$$
CREATE TRIGGER vaccinationType_after_insert AFTER INSERT ON vaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: vaccinationType_after_update
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS vaccinationType_after_update$$
CREATE TRIGGER vaccinationType_after_update AFTER UPDATE ON vaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", datetime());
END$$

-- ---------------------------------------------------------------
-- Trigger: vaccinationType_after_delete
-- ---------------------------------------------------------------
DROP TRIGGER IF EXISTS vaccinationType_after_delete$$
CREATE TRIGGER vaccinationType_after_delete AFTER DELETE ON vaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.sortOrder, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", datetime());
END$$

