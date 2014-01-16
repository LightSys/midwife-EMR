/*
create_tables.sql

Create the tables that do not already exist.
*/


CREATE TABLE IF NOT EXISTS `user` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  password VARCHAR(60) NOT NULL,
  email VARCHAR(100) NULL,
  lang VARCHAR(10) NULL,
  status BOOLEAN NOT NULL DEFAULT 1,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS `role` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);

-- Many-to-many join table for user and role.
CREATE TABLE IF NOT EXISTS `user_role` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  role_id INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (user_id) REFERENCES user (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (role_id) REFERENCES role (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);

-- Definition required by the connect-mysql Nodejs module.
CREATE TABLE IF NOT EXISTS `session` (
  `sid` VARCHAR(255) NOT NULL,
  `session` TEXT NOT NULL,
  `expires` INT,
  PRIMARY KEY (`sid`)
) CHARACTER SET utf8 COLLATE utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS `dohSeq` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  year CHAR(4) NOT NULL,
  sequence INT NOT NULL
);

CREATE TABLE IF NOT EXISTS `history` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  updatedAt TIMESTAMP,
  tablename VARCHAR(50) NOT NULL,
  op VARCHAR(10) NOT NULL,
  json BLOB NOT NULL
);

CREATE TABLE IF NOT EXISTS `patient` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(70) NOT NULL,
  lastname VARCHAR(70) NOT NULL,
  nickname VARCHAR(70) NULL,
  dohID VARCHAR(10) NULL,
  dob DATE NULL,
  generalInfo VARCHAR(8192) NULL,
  gravida TINYINT NULL,
  stillBirths TINYINT NULL,
  abortions TINYINT NULL,
  living TINYINT NULL,
  para TINYINT NULL,
  term TINYINT NULL,
  preterm TINYINT NULL,
  ageOfMenarche TINYINT NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);

-- Look up table for vaccination.
CREATE TABLE IF NOT EXISTS `vaccinationType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(40) NOT NULL,
  description VARCHAR(250) NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS `vaccination` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  vaccinationType INT NOT NULL,
  vacDate DATE NULL,
  vacMonth TINYINT NULL,
  vacYEAR INT NULL,
  administeredInternally BOOLEAN NOT NULL,
  comment VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (vaccinationType) REFERENCES vaccinationType (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS `pregnancy` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  gravida TINYINT NOT NULL,
  lmp DATE NULL,
  warning BOOLEAN NULL DEFAULT 0,
  edd DATE NULL,
  additionalEdd DATE NULL,
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
  comment VARCHAR(2000) NULL,
  numberRequiredTetanus TINYINT NULL,
  invertedNipples BOOLEAN NULL,
  hasUS BOOLEAN NULL,
  wantsUS BOOLEAN NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  patient_id INT NOT NULL,
  address_id INT NULL,
  partner_id INT NULL,
  pregnancyExtra_id INT NULL,
  pregnancyQuestionnaire_id INT NULL,
  FOREIGN KEY (patient_id) REFERENCES patient (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);

-- One-to-one with pregnancy.
CREATE TABLE IF NOT EXISTS `address` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  address VARCHAR(150) NOT NULL,
  barangay VARCHAR(50) NULL,
  city VARCHAR(100) NULL,
  postalCode VARCHAR(20) NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


-- One-to-one with pregnancy.
CREATE TABLE IF NOT EXISTS `partner` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  firstname VARCHAR(70) NOT NULL,
  lastname VARCHAR(70) NOT NULL,
  education VARCHAR(70) NULL,
  monthlyIncome INT NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


-- One-to-one with pregnancy.
CREATE TABLE IF NOT EXISTS `healthTeaching` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATE NOT NULL,
  topic VARCHAR(50) NOT NULL,
  teacher INT NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (teacher) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


-- Lookup table for medication.
CREATE TABLE IF NOT EXISTS `medicationType` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(40) NOT NULL,
  description VARCHAR(250) NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS `medication` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATE NOT NULL,
  medicationType INT NOT NULL,
  numberDispensed INT NULL,
  comment VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (medicationType) REFERENCES medicationType (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


-- One-to-one with pregnancy.
CREATE TABLE IF NOT EXISTS `pregnancyExtra` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  religion VARCHAR(50) NULL,
  maritalStatus VARCHAR(50) NULL,
  telephone VARCHAR(20) NULL,
  work VARCHAR(50) NULL,
  education VARCHAR(70) NULL,
  monthlyIncome INT NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


-- One-to-one with pregnancy.
CREATE TABLE IF NOT EXISTS `pregnancyQuestionnaire` (
  id INT AUTO_INCREMENT PRIMARY KEY,
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
  whereDeliver VARCHAR(30) NULL,
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
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);



CREATE TABLE IF NOT EXISTS `pregnancyHistory` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  monthYear VARCHAR(6) NOT NULL,
  sexOfBaby CHAR(1) NULL,
  placeOfBirth VARCHAR(30) NULL,
  attendant VARCHAR(30) NULL,
  typeOfDelivery VARCHAR(30) NULL,
  lengthOfLabor TINYINT NULL,
  birthWeight FLOAT(2,2) NULL,
  episTear BOOLEAN NULL,
  repaired BOOLEAN NULL,
  howLongBFed VARCHAR(20) NULL,
  comment VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS `prenatalExam` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATE NOT NULL,
  weight FLOAT(3, 1) NULL,
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
  comment VARCHAR(100) NULL,
  returnDate DATE NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


-- Consider storing expected result format as JSON in the blob field.
CREATE TABLE IF NOT EXISTS `labTest` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL,
  description VARCHAR(300) NULL,
  resultFormat BLOB NOT NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


-- Consider storing results as JSON in the blob field.
CREATE TABLE IF NOT EXISTS `labResult` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  labTest_id INT NOT NULL,
  date DATE NOT NULL,
  result BLOB NOT NULL,
  warn BOOLEAN NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS `referral` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  date DATE NOT NULL,
  referral VARCHAR(300) NOT NULL,
  reason VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt TIMESTAMP,
  supervisor INT NULL,
  pregnancy_id INT NOT NULL,
  FOREIGN KEY (pregnancy_id) REFERENCES pregnancy (id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE,
  FOREIGN KEY (supervisor) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE CASCADE
);




