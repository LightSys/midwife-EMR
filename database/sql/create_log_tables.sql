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
-- Creating pregnancyLog
SELECT 'pregnancyLog' AS Creating FROM DUAL;
CREATE TABLE pregnancyLog LIKE pregnancy;
ALTER TABLE pregnancyLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE pregnancyLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE pregnancyLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE pregnancyLog DROP PRIMARY KEY;
ALTER TABLE pregnancyLog ADD PRIMARY KEY (id, replacedAt);
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
-- Creating priorityTypeLog
SELECT 'priorityTypeLog' AS Creating FROM DUAL;
CREATE TABLE priorityTypeLog LIKE priorityType;
ALTER TABLE priorityTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE priorityTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE priorityTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE priorityTypeLog DROP PRIMARY KEY;
ALTER TABLE priorityTypeLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE priorityTypeLog DROP KEY name;
--
-- Creating priorityLog
SELECT 'priorityLog' AS Creating FROM DUAL;
CREATE TABLE priorityLog LIKE priority;
ALTER TABLE priorityLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE priorityLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE priorityLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE priorityLog DROP PRIMARY KEY;
ALTER TABLE priorityLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE priorityLog DROP KEY priority;
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
-- Creating labTestLog
SELECT 'labTestLog' AS Creating FROM DUAL;
CREATE TABLE labTestLog LIKE labTest;
ALTER TABLE labTestLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE labTestLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE labTestLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE labTestLog DROP PRIMARY KEY;
ALTER TABLE labTestLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE labTestLog DROP KEY name;
--
-- Creating labResultLog
SELECT 'labResultLog' AS Creating FROM DUAL;
CREATE TABLE labResultLog LIKE labResult;
ALTER TABLE labResultLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE labResultLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE labResultLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE labResultLog DROP PRIMARY KEY;
ALTER TABLE labResultLog ADD PRIMARY KEY (id, replacedAt);
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
