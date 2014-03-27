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
  status BOOLEAN NOT NULL DEFAULT 1,
  note VARCHAR(300) NULL,
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
  vacYEAR INT NULL,
  administeredInternally BOOLEAN NOT NULL,
  note VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  FOREIGN KEY (vaccinationType) REFERENCES vaccinationType (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
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
  monthlyIncome INT NULL,
  address VARCHAR(150) NOT NULL,
  barangay VARCHAR(50) NULL,
  city VARCHAR(100) NULL,
  postalCode VARCHAR(20) NULL,
  gravidaNumber TINYINT NULL,
  lmp DATE NULL,
  sureLMP BOOLEAN NULL DEFAULT 0,
  warning BOOLEAN NULL DEFAULT 0,
  riskPresent BOOLEAN NULL DEFAULT 0,
  riskObHx BOOLEAN NULL DEFAULT 0,
  riskMedHx BOOLEAN NULL DEFAULT 0,
  riskNote VARCHAR(250) NULL,
  edd DATE NULL,
  alternateEdd DATE NULL,
  useAlternateEdd BOOLEAN NULL DEFAULT 0,
  doctorConsultDate DATE NULL,
  dentistConsultDate DATE NULL,
  mbBook BOOLEAN NULL,
  iodizedSalt BOOLEAN NULL,
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
  currentlyBirthCanalPain BOOLEAN NULL,
  currentlyNone BOOLEAN NULL,
  useIodizedSalt BOOLEAN NULL,
  canDrinkMedicine BOOLEAN NULL,
  planToBreastFeed BOOLEAN NULL,
  birthCompanion VARCHAR(30) NULL,
  practiceFamilyPlanning BOOLEAN NULL,
  familyPlanningDetails VARCHAR(100) NULL,
  familyHistoryTwins BOOLEAN NULL,
  familyHistoryHighBloodPressure BOOLEAN NULL,
  familyHistoryDiabetes BOOLEAN NULL,
  familyHistoryChestPains BOOLEAN NULL,
  familyHistoryTB BOOLEAN NULL,
  familyHistorySmoking BOOLEAN NULL,
  familyHistoryNone BOOLEAN NULL,
  historyFoodAllergy BOOLEAN NULL,
  historyMedicineAllergy BOOLEAN NULL,
  historyAsthma BOOLEAN NULL,
  historyChestPains BOOLEAN NULL,
  historyKidneyProblems BOOLEAN NULL,
  historyHepatitis BOOLEAN NULL,
  historyGoiter BOOLEAN NULL,
  historyHighBloodPressure BOOLEAN NULL,
  historyHospitalOperation BOOLEAN NULL,
  historyBloodTransfusion BOOLEAN NULL,
  historySmoking BOOLEAN NULL,
  historyDrinking BOOLEAN NULL,
  historyNone BOOLEAN NULL,
  partnerFirstname VARCHAR(70) NULL,
  partnerLastname VARCHAR(70) NULL,
  partnerAge INT NULL,
  partnerWork VARCHAR(70) NULL,
  partnerEducation VARCHAR(70) NULL,
  partnerMonthlyIncome INT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  patient_id INT NOT NULL,
  FOREIGN KEY (patient_id) REFERENCES patient (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
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
  month VARCHAR(2) NULL,
  year VARCHAR(4) NOT NULL,
  weeksGA INT NULL,
  sexOfBaby CHAR(1) NULL,
  placeOfBirth VARCHAR(30) NULL,
  attendant VARCHAR(30) NULL,
  typeOfDelivery VARCHAR(30) NULL,
  lengthOfLabor TINYINT NULL,
  birthWeight DECIMAL(4,2) NULL,
  episTear BOOLEAN NULL,
  repaired BOOLEAN NULL,
  howLongBFed VARCHAR(20) NULL,
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

CREATE TABLE IF NOT EXISTS `priorityType` (
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

CREATE TABLE IF NOT EXISTS `priority` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  priority INT NOT NULL,
  ptype INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  prenatalExam_id INT NOT NULL,
  UNIQUE (priority, ptype),
  FOREIGN KEY (prenatalExam_id) REFERENCES prenatalExam (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
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
  fh INT NULL,
  fht INT NULL,
  fhtNote VARCHAR(20) NULL,
  pos VARCHAR(10) NULL,
  mvmt BOOLEAN NULL,
  edma BOOLEAN NULL,
  risk BOOLEAN NULL,
  vitamin BOOLEAN NULL,
  pray BOOLEAN NULL,
  note VARCHAR(100) NULL,
  returnDate DATE NULL,
  checkin DATETIME NULL,
  checkout DATETIME NULL,
  chartPulled BOOLEAN NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;


-- Consider storing expected result format as JSON in the blob field.
CREATE TABLE IF NOT EXISTS `labTest` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(300) NULL,
  resultFormat BLOB NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  UNIQUE (name),
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);
SHOW WARNINGS;


-- Consider storing results as JSON in the blob field.
CREATE TABLE IF NOT EXISTS `labResult` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  labTest_id INT NOT NULL,
  date DATE NOT NULL,
  result BLOB NOT NULL,
  warn BOOLEAN NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
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
  at DATETIME NOT NULL,
  note VARCHAR(255) NULL,
  user_id INT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (eventType) REFERENCES eventType (id) ON DELETE NO ACTION ON UPDATE NO ACTION
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

SET foreign_key_checks = 1;


