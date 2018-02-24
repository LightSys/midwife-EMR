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
--
-- Creating laborLog
SELECT 'laborLog' AS Creating FROM DUAL;
CREATE TABLE laborLog LIKE labor;
ALTER TABLE laborLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE laborLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE laborLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE laborLog DROP PRIMARY KEY;
ALTER TABLE laborLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating laborStage1Log
SELECT 'laborStage1Log' AS Creating FROM DUAL;
CREATE TABLE laborStage1Log LIKE laborStage1;
ALTER TABLE laborStage1Log ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE laborStage1Log ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE laborStage1Log MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE laborStage1Log DROP PRIMARY KEY;
ALTER TABLE laborStage1Log ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE laborStage1Log DROP KEY labor_id;
--
-- Creating laborStage2Log
SELECT 'laborStage2Log' AS Creating FROM DUAL;
CREATE TABLE laborStage2Log LIKE laborStage2;
ALTER TABLE laborStage2Log ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE laborStage2Log ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE laborStage2Log MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE laborStage2Log DROP PRIMARY KEY;
ALTER TABLE laborStage2Log ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE laborStage2Log DROP KEY labor_id;
--
-- Creating laborStage3Log
SELECT 'laborStage3Log' AS Creating FROM DUAL;
CREATE TABLE laborStage3Log LIKE laborStage3;
ALTER TABLE laborStage3Log ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE laborStage3Log ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE laborStage3Log MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE laborStage3Log DROP PRIMARY KEY;
ALTER TABLE laborStage3Log ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE laborStage3Log DROP KEY labor_id;
--
-- Creating babyLog
SELECT 'babyLog' AS Creating FROM DUAL;
CREATE TABLE babyLog LIKE baby;
ALTER TABLE babyLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyLog DROP PRIMARY KEY;
ALTER TABLE babyLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE babyLog DROP KEY labor_id;
--
-- Creating apgarLog
SELECT 'apgarLog' AS Creating FROM DUAL;
CREATE TABLE apgarLog LIKE apgar;
ALTER TABLE apgarLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE apgarLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE apgarLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE apgarLog DROP PRIMARY KEY;
ALTER TABLE apgarLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE apgarLog DROP KEY baby_id;
--
-- Creating newbornExamLog
SELECT 'newbornExamLog' AS Creating FROM DUAL;
CREATE TABLE newbornExamLog LIKE newbornExam;
ALTER TABLE newbornExamLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE newbornExamLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE newbornExamLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE newbornExamLog DROP PRIMARY KEY;
ALTER TABLE newbornExamLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE newbornExamLog DROP KEY baby_id;
--
-- Creating membraneLog
SELECT 'membraneLog' AS Creating FROM DUAL;
CREATE TABLE membraneLog LIKE membrane;
ALTER TABLE membraneLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE membraneLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE membraneLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE membraneLog DROP PRIMARY KEY;
ALTER TABLE membraneLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE membraneLog DROP KEY labor_id;
--
-- Creating contPostpartumCheckLog
SELECT 'contPostpartumCheckLog' AS Creating FROM DUAL;
CREATE TABLE contPostpartumCheckLog LIKE contPostpartumCheck;
ALTER TABLE contPostpartumCheckLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE contPostpartumCheckLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE contPostpartumCheckLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE contPostpartumCheckLog DROP PRIMARY KEY;
ALTER TABLE contPostpartumCheckLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating babyMedicationTypeLog
SELECT 'babyMedicationTypeLog' AS Creating FROM DUAL;
CREATE TABLE babyMedicationTypeLog LIKE babyMedicationType;
ALTER TABLE babyMedicationTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyMedicationTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyMedicationTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyMedicationTypeLog DROP PRIMARY KEY;
ALTER TABLE babyMedicationTypeLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating babyMedicationLog
SELECT 'babyMedicationLog' AS Creating FROM DUAL;
CREATE TABLE babyMedicationLog LIKE babyMedication;
ALTER TABLE babyMedicationLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyMedicationLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyMedicationLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyMedicationLog DROP PRIMARY KEY;
ALTER TABLE babyMedicationLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE babyMedicationLog DROP KEY baby_id;
--
-- Creating babyVaccinationTypeLog
SELECT 'babyVaccinationTypeLog' AS Creating FROM DUAL;
CREATE TABLE babyVaccinationTypeLog LIKE babyVaccinationType;
ALTER TABLE babyVaccinationTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyVaccinationTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyVaccinationTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyVaccinationTypeLog DROP PRIMARY KEY;
ALTER TABLE babyVaccinationTypeLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating babyVaccinationLog
SELECT 'babyVaccinationLog' AS Creating FROM DUAL;
CREATE TABLE babyVaccinationLog LIKE babyVaccination;
ALTER TABLE babyVaccinationLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyVaccinationLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyVaccinationLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyVaccinationLog DROP PRIMARY KEY;
ALTER TABLE babyVaccinationLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE babyVaccinationLog DROP KEY baby_id;
--
-- Creating babyLabTypeLog
SELECT 'babyLabTypeLog' AS Creating FROM DUAL;
CREATE TABLE babyLabTypeLog LIKE babyLabType;
ALTER TABLE babyLabTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyLabTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyLabTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyLabTypeLog DROP PRIMARY KEY;
ALTER TABLE babyLabTypeLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating babyLabLog
SELECT 'babyLabLog' AS Creating FROM DUAL;
CREATE TABLE babyLabLog LIKE babyLab;
ALTER TABLE babyLabLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE babyLabLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE babyLabLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE babyLabLog DROP PRIMARY KEY;
ALTER TABLE babyLabLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating motherMedicationTypeLog
SELECT 'motherMedicationTypeLog' AS Creating FROM DUAL;
CREATE TABLE motherMedicationTypeLog LIKE motherMedicationType;
ALTER TABLE motherMedicationTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE motherMedicationTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE motherMedicationTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE motherMedicationTypeLog DROP PRIMARY KEY;
ALTER TABLE motherMedicationTypeLog ADD PRIMARY KEY (id, replacedAt);
--
-- Creating motherMedicationLog
SELECT 'motherMedicationLog' AS Creating FROM DUAL;
CREATE TABLE motherMedicationLog LIKE motherMedication;
ALTER TABLE motherMedicationLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE motherMedicationLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE motherMedicationLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE motherMedicationLog DROP PRIMARY KEY;
ALTER TABLE motherMedicationLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE motherMedicationLog DROP KEY labor_id;
--
