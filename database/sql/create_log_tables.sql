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
-- Creating user_roleLog
SELECT 'user_roleLog' AS Creating FROM DUAL;
CREATE TABLE user_roleLog LIKE user_role;
ALTER TABLE user_roleLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE user_roleLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE user_roleLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE user_roleLog DROP PRIMARY KEY;
ALTER TABLE user_roleLog ADD PRIMARY KEY (id, replacedAt);
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
