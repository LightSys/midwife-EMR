-- Migration: Birth Certificates
-- Created at: 2018-03-09 13:28:54
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `birthCertificate` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  birthOrder VARCHAR(30) NOT NULL,
  motherMaidenLastname VARCHAR(50) NOT NULL,
  motherMiddlename VARCHAR(50) NULL,
  motherFirstname VARCHAR(50) NOT NULL,
  motherCitizenship VARCHAR(50) NOT NULL,
  motherNumChildrenBornAlive INT NOT NULL,
  motherNumChildrenLiving INT NOT NULL,
  motherNumChildrenBornAliveNowDead INT NOT NULL,
  motherAddress VARCHAR(100) NOT NULL,
  motherCity VARCHAR(50) NOT NULL,
  motherProvince VARCHAR(50) NOT NULL,
  motherCountry VARCHAR(50) NOT NULL,
  fatherLastname VARCHAR(50) NULL,
  fatherMiddlename VARCHAR(50) NULL,
  fatherFirstname VARCHAR(50) NULL,
  fatherCitizenship VARCHAR(50) NULL,
  fatherReligion VARCHAR(50) NULL,
  fatherOccupation VARCHAR(50) NULL,
  fatherAgeAtBirth INT NULL,
  fatherAddress VARCHAR(100) NULL,
  fatherCity VARCHAR(50) NULL,
  fatherProvince VARCHAR(50) NULL,
  fatherCountry VARCHAR(50) NULL,
  dateOfMarriage DATE NULL,
  cityOfMarriage VARCHAR(50) NULL,
  provinceOfMarriage VARCHAR(50) NULL,
  countryOfMarriage VARCHAR(50) NULL,
  attendantType ENUM('Physician', 'Nurse', 'Midwife', 'Hilot', 'Other') NOT NULL,
  attendantOther VARCHAR(20) NULL,
  attendantFullname VARCHAR(70) NOT NULL,
  attendantTitle VARCHAR(50) NULL,
  attendantAddr1 VARCHAR(50) NULL,
  attendantAddr2 VARCHAR(50) NULL,
  informantFullname VARCHAR(70) NOT NULL,
  informantRelationToChild VARCHAR(50) NOT NULL,
  informantAddress VARCHAR(50) NOT NULL,
  preparedByFullname VARCHAR(70) NOT NULL,
  preparedByTitle VARCHAR(50) NOT NULL,
  commTaxNumber VARCHAR(50) NULL,
  commTaxDate DATE NULL,
  commTaxPlace VARCHAR(50) NULL,
  comments VARCHAR(300) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  baby_id INT NOT NULL,
  UNIQUE (baby_id),
  FOREIGN KEY (baby_id) REFERENCES baby (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE birthCertificateLog LIKE birthCertificate;
ALTER TABLE birthCertificateLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE birthCertificateLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE birthCertificateLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE birthCertificateLog DROP PRIMARY KEY;
ALTER TABLE birthCertificateLog ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE birthCertificateLog DROP KEY baby_id;

-- ---------------------------------------------------------------
-- Trigger: birthCertificate_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS birthCertificate_after_insert;
CREATE TRIGGER birthCertificate_after_insert AFTER INSERT ON birthCertificate
FOR EACH ROW
BEGIN
  INSERT INTO birthCertificateLog
  (id, birthOrder, motherMaidenLastname, motherMiddlename, motherFirstname, motherCitizenship, motherNumChildrenBornAlive, motherNumChildrenLiving, motherNumChildrenBornAliveNowDead, motherAddress, motherCity, motherProvince, motherCountry, fatherLastname, fatherMiddlename, fatherFirstname, fatherCitizenship, fatherReligion, fatherOccupation, fatherAgeAtBirth, fatherAddress, fatherCity, fatherProvince, fatherCountry, dateOfMarriage, cityOfMarriage, provinceOfMarriage, countryOfMarriage, attendantType, attendantOther, attendantFullname, attendantTitle, attendantAddr1, attendantAddr2, informantFullname, informantRelationToChild, informantAddress, preparedByFullname, preparedByTitle, commTaxNumber, commTaxDate, commTaxPlace, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthOrder, NEW.motherMaidenLastname, NEW.motherMiddlename, NEW.motherFirstname, NEW.motherCitizenship, NEW.motherNumChildrenBornAlive, NEW.motherNumChildrenLiving, NEW.motherNumChildrenBornAliveNowDead, NEW.motherAddress, NEW.motherCity, NEW.motherProvince, NEW.motherCountry, NEW.fatherLastname, NEW.fatherMiddlename, NEW.fatherFirstname, NEW.fatherCitizenship, NEW.fatherReligion, NEW.fatherOccupation, NEW.fatherAgeAtBirth, NEW.fatherAddress, NEW.fatherCity, NEW.fatherProvince, NEW.fatherCountry, NEW.dateOfMarriage, NEW.cityOfMarriage, NEW.provinceOfMarriage, NEW.countryOfMarriage, NEW.attendantType, NEW.attendantOther, NEW.attendantFullname, NEW.attendantTitle, NEW.attendantAddr1, NEW.attendantAddr2, NEW.informantFullname, NEW.informantRelationToChild, NEW.informantAddress, NEW.preparedByFullname, NEW.preparedByTitle, NEW.commTaxNumber, NEW.commTaxDate, NEW.commTaxPlace, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: birthCertificate_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS birthCertificate_after_update;
CREATE TRIGGER birthCertificate_after_update AFTER UPDATE ON birthCertificate
FOR EACH ROW
BEGIN
  INSERT INTO birthCertificateLog
  (id, birthOrder, motherMaidenLastname, motherMiddlename, motherFirstname, motherCitizenship, motherNumChildrenBornAlive, motherNumChildrenLiving, motherNumChildrenBornAliveNowDead, motherAddress, motherCity, motherProvince, motherCountry, fatherLastname, fatherMiddlename, fatherFirstname, fatherCitizenship, fatherReligion, fatherOccupation, fatherAgeAtBirth, fatherAddress, fatherCity, fatherProvince, fatherCountry, dateOfMarriage, cityOfMarriage, provinceOfMarriage, countryOfMarriage, attendantType, attendantOther, attendantFullname, attendantTitle, attendantAddr1, attendantAddr2, informantFullname, informantRelationToChild, informantAddress, preparedByFullname, preparedByTitle, commTaxNumber, commTaxDate, commTaxPlace, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthOrder, NEW.motherMaidenLastname, NEW.motherMiddlename, NEW.motherFirstname, NEW.motherCitizenship, NEW.motherNumChildrenBornAlive, NEW.motherNumChildrenLiving, NEW.motherNumChildrenBornAliveNowDead, NEW.motherAddress, NEW.motherCity, NEW.motherProvince, NEW.motherCountry, NEW.fatherLastname, NEW.fatherMiddlename, NEW.fatherFirstname, NEW.fatherCitizenship, NEW.fatherReligion, NEW.fatherOccupation, NEW.fatherAgeAtBirth, NEW.fatherAddress, NEW.fatherCity, NEW.fatherProvince, NEW.fatherCountry, NEW.dateOfMarriage, NEW.cityOfMarriage, NEW.provinceOfMarriage, NEW.countryOfMarriage, NEW.attendantType, NEW.attendantOther, NEW.attendantFullname, NEW.attendantTitle, NEW.attendantAddr1, NEW.attendantAddr2, NEW.informantFullname, NEW.informantRelationToChild, NEW.informantAddress, NEW.preparedByFullname, NEW.preparedByTitle, NEW.commTaxNumber, NEW.commTaxDate, NEW.commTaxPlace, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;

-- ---------------------------------------------------------------
-- Trigger: birthCertificate_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS birthCertificate_after_delete;
CREATE TRIGGER birthCertificate_after_delete AFTER DELETE ON birthCertificate
FOR EACH ROW
BEGIN
  INSERT INTO birthCertificateLog
  (id, birthOrder, motherMaidenLastname, motherMiddlename, motherFirstname, motherCitizenship, motherNumChildrenBornAlive, motherNumChildrenLiving, motherNumChildrenBornAliveNowDead, motherAddress, motherCity, motherProvince, motherCountry, fatherLastname, fatherMiddlename, fatherFirstname, fatherCitizenship, fatherReligion, fatherOccupation, fatherAgeAtBirth, fatherAddress, fatherCity, fatherProvince, fatherCountry, dateOfMarriage, cityOfMarriage, provinceOfMarriage, countryOfMarriage, attendantType, attendantOther, attendantFullname, attendantTitle, attendantAddr1, attendantAddr2, informantFullname, informantRelationToChild, informantAddress, preparedByFullname, preparedByTitle, commTaxNumber, commTaxDate, commTaxPlace, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.birthOrder, OLD.motherMaidenLastname, OLD.motherMiddlename, OLD.motherFirstname, OLD.motherCitizenship, OLD.motherNumChildrenBornAlive, OLD.motherNumChildrenLiving, OLD.motherNumChildrenBornAliveNowDead, OLD.motherAddress, OLD.motherCity, OLD.motherProvince, OLD.motherCountry, OLD.fatherLastname, OLD.fatherMiddlename, OLD.fatherFirstname, OLD.fatherCitizenship, OLD.fatherReligion, OLD.fatherOccupation, OLD.fatherAgeAtBirth, OLD.fatherAddress, OLD.fatherCity, OLD.fatherProvince, OLD.fatherCountry, OLD.dateOfMarriage, OLD.cityOfMarriage, OLD.provinceOfMarriage, OLD.countryOfMarriage, OLD.attendantType, OLD.attendantOther, OLD.attendantFullname, OLD.attendantTitle, OLD.attendantAddr1, OLD.attendantAddr2, OLD.informantFullname, OLD.informantRelationToChild, OLD.informantAddress, OLD.preparedByFullname, OLD.preparedByTitle, OLD.commTaxNumber, OLD.commTaxDate, OLD.commTaxPlace, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;

INSERT INTO keyValue
  (kvKey, kvValue, description, valueType, acceptableValues, systemOnly)
VALUES
  ('birthCertInstitution', 'YourInstitution', 'Used in the birth certificate form, field #4.', 'text', '', 0),
  ('birthCertProvince', 'YourProvince', 'Used in the birth certificate form, field #4.', 'text', '', 0),
  ('birthCertCity', 'YourCity', 'Used in the birth certificate form, field #4.', 'text', '', 0),
  ('birthCertProvinceTop', 'YourProvince', 'Used at the TOP of the birth certificate form in the Province field.', 'text', '', 0),
  ('birthCertCityTop', 'YourCity', 'Used at the TOP of the birth certificate form in the City/Municipality field.', 'text', '', 0)
;

COMMIT;

-- ==== DOWN ====

BEGIN;

DELETE FROM keyValue
  WHERE kvKey IN
  ('birthCertInstitution', 'birthCertProvince', 'birthCertCity', 'birthCertProvinceTop', 'birthCertCityTop');

DROP TABLE birthCertificateLog;
DROP TABLE birthCertificate;

COMMIT;
