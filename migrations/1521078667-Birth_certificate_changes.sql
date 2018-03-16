-- Migration: Birth certificate changes
-- Created at: 2018-03-15 09:51:07
-- ====  UP  ====

BEGIN;

ALTER TABLE birthCertificate ADD COLUMN receivedByName VARCHAR(100) NULL AFTER commTaxPlace;
ALTER TABLE birthCertificate ADD COLUMN receivedByTitle VARCHAR(100) NULL AFTER receivedByName;
ALTER TABLE birthCertificate ADD COLUMN affiateName VARCHAR(100) NULL AFTER receivedByTitle;
ALTER TABLE birthCertificate ADD COLUMN affiateAddress VARCHAR(100) NULL AFTER affiateName;
ALTER TABLE birthCertificate ADD COLUMN affiateCitizenshipCountry VARCHAR(100) NULL AFTER affiateAddress;
ALTER TABLE birthCertificate ADD COLUMN affiateReason VARCHAR(100) NULL AFTER affiateCitizenshipCountry;
ALTER TABLE birthCertificate ADD COLUMN affiateIAm VARCHAR(100) NULL AFTER affiateReason;
ALTER TABLE birthCertificate ADD COLUMN affiateCommTaxNumber VARCHAR(100) NULL AFTER affiateIAm;
ALTER TABLE birthCertificate ADD COLUMN affiateCommTaxDate VARCHAR(100) NULL AFTER affiateCommTaxNumber;
ALTER TABLE birthCertificate ADD COLUMN affiateCommTaxPlace VARCHAR(100) NULL AFTER affiateCommTaxDate;

ALTER TABLE birthCertificateLog ADD COLUMN receivedByName VARCHAR(100) NULL AFTER commTaxPlace;
ALTER TABLE birthCertificateLog ADD COLUMN receivedByTitle VARCHAR(100) NULL AFTER receivedByName;
ALTER TABLE birthCertificateLog ADD COLUMN affiateName VARCHAR(100) NULL AFTER receivedByTitle;
ALTER TABLE birthCertificateLog ADD COLUMN affiateAddress VARCHAR(100) NULL AFTER affiateName;
ALTER TABLE birthCertificateLog ADD COLUMN affiateCitizenshipCountry VARCHAR(100) NULL AFTER affiateAddress;
ALTER TABLE birthCertificateLog ADD COLUMN affiateReason VARCHAR(100) NULL AFTER affiateCitizenshipCountry;
ALTER TABLE birthCertificateLog ADD COLUMN affiateIAm VARCHAR(100) NULL AFTER affiateReason;
ALTER TABLE birthCertificateLog ADD COLUMN affiateCommTaxNumber VARCHAR(100) NULL AFTER affiateIAm;
ALTER TABLE birthCertificateLog ADD COLUMN affiateCommTaxDate VARCHAR(100) NULL AFTER affiateCommTaxNumber;
ALTER TABLE birthCertificateLog ADD COLUMN affiateCommTaxPlace VARCHAR(100) NULL AFTER affiateCommTaxDate;

-- ---------------------------------------------------------------
-- Trigger: birthCertificate_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS birthCertificate_after_insert;
CREATE TRIGGER birthCertificate_after_insert AFTER INSERT ON birthCertificate
FOR EACH ROW
BEGIN
  INSERT INTO birthCertificateLog
  (id, birthOrder, motherMaidenLastname, motherMiddlename, motherFirstname, motherCitizenship, motherNumChildrenBornAlive, motherNumChildrenLiving, motherNumChildrenBornAliveNowDead, motherAddress, motherCity, motherProvince, motherCountry, fatherLastname, fatherMiddlename, fatherFirstname, fatherCitizenship, fatherReligion, fatherOccupation, fatherAgeAtBirth, fatherAddress, fatherCity, fatherProvince, fatherCountry, dateOfMarriage, cityOfMarriage, provinceOfMarriage, countryOfMarriage, attendantType, attendantOther, attendantFullname, attendantTitle, attendantAddr1, attendantAddr2, informantFullname, informantRelationToChild, informantAddress, preparedByFullname, preparedByTitle, commTaxNumber, commTaxDate, commTaxPlace, receivedByName, receivedByTitle, affiateName, affiateAddress, affiateCitizenshipCountry, affiateReason, affiateIAm, affiateCommTaxNumber, affiateCommTaxDate, affiateCommTaxPlace, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthOrder, NEW.motherMaidenLastname, NEW.motherMiddlename, NEW.motherFirstname, NEW.motherCitizenship, NEW.motherNumChildrenBornAlive, NEW.motherNumChildrenLiving, NEW.motherNumChildrenBornAliveNowDead, NEW.motherAddress, NEW.motherCity, NEW.motherProvince, NEW.motherCountry, NEW.fatherLastname, NEW.fatherMiddlename, NEW.fatherFirstname, NEW.fatherCitizenship, NEW.fatherReligion, NEW.fatherOccupation, NEW.fatherAgeAtBirth, NEW.fatherAddress, NEW.fatherCity, NEW.fatherProvince, NEW.fatherCountry, NEW.dateOfMarriage, NEW.cityOfMarriage, NEW.provinceOfMarriage, NEW.countryOfMarriage, NEW.attendantType, NEW.attendantOther, NEW.attendantFullname, NEW.attendantTitle, NEW.attendantAddr1, NEW.attendantAddr2, NEW.informantFullname, NEW.informantRelationToChild, NEW.informantAddress, NEW.preparedByFullname, NEW.preparedByTitle, NEW.commTaxNumber, NEW.commTaxDate, NEW.commTaxPlace, NEW.receivedByName, NEW.receivedByTitle, NEW.affiateName, NEW.affiateAddress, NEW.affiateCitizenshipCountry, NEW.affiateReason, NEW.affiateIAm, NEW.affiateCommTaxNumber, NEW.affiateCommTaxDate, NEW.affiateCommTaxPlace, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
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
  (id, birthOrder, motherMaidenLastname, motherMiddlename, motherFirstname, motherCitizenship, motherNumChildrenBornAlive, motherNumChildrenLiving, motherNumChildrenBornAliveNowDead, motherAddress, motherCity, motherProvince, motherCountry, fatherLastname, fatherMiddlename, fatherFirstname, fatherCitizenship, fatherReligion, fatherOccupation, fatherAgeAtBirth, fatherAddress, fatherCity, fatherProvince, fatherCountry, dateOfMarriage, cityOfMarriage, provinceOfMarriage, countryOfMarriage, attendantType, attendantOther, attendantFullname, attendantTitle, attendantAddr1, attendantAddr2, informantFullname, informantRelationToChild, informantAddress, preparedByFullname, preparedByTitle, commTaxNumber, commTaxDate, commTaxPlace, receivedByName, receivedByTitle, affiateName, affiateAddress, affiateCitizenshipCountry, affiateReason, affiateIAm, affiateCommTaxNumber, affiateCommTaxDate, affiateCommTaxPlace, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthOrder, NEW.motherMaidenLastname, NEW.motherMiddlename, NEW.motherFirstname, NEW.motherCitizenship, NEW.motherNumChildrenBornAlive, NEW.motherNumChildrenLiving, NEW.motherNumChildrenBornAliveNowDead, NEW.motherAddress, NEW.motherCity, NEW.motherProvince, NEW.motherCountry, NEW.fatherLastname, NEW.fatherMiddlename, NEW.fatherFirstname, NEW.fatherCitizenship, NEW.fatherReligion, NEW.fatherOccupation, NEW.fatherAgeAtBirth, NEW.fatherAddress, NEW.fatherCity, NEW.fatherProvince, NEW.fatherCountry, NEW.dateOfMarriage, NEW.cityOfMarriage, NEW.provinceOfMarriage, NEW.countryOfMarriage, NEW.attendantType, NEW.attendantOther, NEW.attendantFullname, NEW.attendantTitle, NEW.attendantAddr1, NEW.attendantAddr2, NEW.informantFullname, NEW.informantRelationToChild, NEW.informantAddress, NEW.preparedByFullname, NEW.preparedByTitle, NEW.commTaxNumber, NEW.commTaxDate, NEW.commTaxPlace, NEW.receivedByName, NEW.receivedByTitle, NEW.affiateName, NEW.affiateAddress, NEW.affiateCitizenshipCountry, NEW.affiateReason, NEW.affiateIAm, NEW.affiateCommTaxNumber, NEW.affiateCommTaxDate, NEW.affiateCommTaxPlace, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
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
  (id, birthOrder, motherMaidenLastname, motherMiddlename, motherFirstname, motherCitizenship, motherNumChildrenBornAlive, motherNumChildrenLiving, motherNumChildrenBornAliveNowDead, motherAddress, motherCity, motherProvince, motherCountry, fatherLastname, fatherMiddlename, fatherFirstname, fatherCitizenship, fatherReligion, fatherOccupation, fatherAgeAtBirth, fatherAddress, fatherCity, fatherProvince, fatherCountry, dateOfMarriage, cityOfMarriage, provinceOfMarriage, countryOfMarriage, attendantType, attendantOther, attendantFullname, attendantTitle, attendantAddr1, attendantAddr2, informantFullname, informantRelationToChild, informantAddress, preparedByFullname, preparedByTitle, commTaxNumber, commTaxDate, commTaxPlace, receivedByName, receivedByTitle, affiateName, affiateAddress, affiateCitizenshipCountry, affiateReason, affiateIAm, affiateCommTaxNumber, affiateCommTaxDate, affiateCommTaxPlace, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.birthOrder, OLD.motherMaidenLastname, OLD.motherMiddlename, OLD.motherFirstname, OLD.motherCitizenship, OLD.motherNumChildrenBornAlive, OLD.motherNumChildrenLiving, OLD.motherNumChildrenBornAliveNowDead, OLD.motherAddress, OLD.motherCity, OLD.motherProvince, OLD.motherCountry, OLD.fatherLastname, OLD.fatherMiddlename, OLD.fatherFirstname, OLD.fatherCitizenship, OLD.fatherReligion, OLD.fatherOccupation, OLD.fatherAgeAtBirth, OLD.fatherAddress, OLD.fatherCity, OLD.fatherProvince, OLD.fatherCountry, OLD.dateOfMarriage, OLD.cityOfMarriage, OLD.provinceOfMarriage, OLD.countryOfMarriage, OLD.attendantType, OLD.attendantOther, OLD.attendantFullname, OLD.attendantTitle, OLD.attendantAddr1, OLD.attendantAddr2, OLD.informantFullname, OLD.informantRelationToChild, OLD.informantAddress, OLD.preparedByFullname, OLD.preparedByTitle, OLD.commTaxNumber, OLD.commTaxDate, OLD.commTaxPlace, OLD.receivedByName, OLD.receivedByTitle, OLD.affiateName, OLD.affiateAddress, OLD.affiateCitizenshipCountry, OLD.affiateReason, OLD.affiateIAm, OLD.affiateCommTaxNumber, OLD.affiateCommTaxDate, OLD.affiateCommTaxPlace, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;

INSERT INTO keyValue
  (kvKey, kvValue, description, valueType, acceptableValues, systemOnly)
VALUES
  ('birthCertDefaultCitizenship', 'TheDefaultCitizenship', 'Birth certificate form, fields: 8, 15.', 'text', '', 0),
  ('birthCertDefaultCountry', 'TheDefaultCountry', 'Birth certificate form, fields: 13, 19, 20b.', 'text', '', 0),
  ('birthCertDefaultAttendantTitle', 'TheDefaultAttendantTitle', 'Birth certificate form, field: 21a.', 'text', '', 0),
  ('birthCertDefaultAttendantAddr1', 'TheDefaultAttendantAddr1', 'Birth certificate form, field: 21b, line 1', 'text', '', 0),
  ('birthCertDefaultAttendantAddr2', 'TheDefaultAttendantAddr2', 'Birth certificate form, field: 21b, line 2', 'text', '', 0),
  ('birthCertDefaultReceivedByName', 'TheDefaultReceivedByName', 'Birth certificate form, field: 24.', 'text', '', 0),
  ('birthCertDefaultReceivedByTitle', 'TheDefaultReceivedByTitle', 'Birth certificate form, field: 24.', 'text', '', 0)
  ;


COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE birthCertificate DROP COLUMN receivedByName;
ALTER TABLE birthCertificate DROP COLUMN receivedByTitle;
ALTER TABLE birthCertificate DROP COLUMN affiateName;
ALTER TABLE birthCertificate DROP COLUMN affiateAddress;
ALTER TABLE birthCertificate DROP COLUMN affiateCitizenshipCountry;
ALTER TABLE birthCertificate DROP COLUMN affiateReason;
ALTER TABLE birthCertificate DROP COLUMN affiateIAm;
ALTER TABLE birthCertificate DROP COLUMN affiateCommTaxNumber;
ALTER TABLE birthCertificate DROP COLUMN affiateCommTaxDate;
ALTER TABLE birthCertificate DROP COLUMN affiateCommTaxPlace;

ALTER TABLE birthCertificateLog DROP COLUMN receivedByName;
ALTER TABLE birthCertificateLog DROP COLUMN receivedByTitle;
ALTER TABLE birthCertificateLog DROP COLUMN affiateName;
ALTER TABLE birthCertificateLog DROP COLUMN affiateAddress;
ALTER TABLE birthCertificateLog DROP COLUMN affiateCitizenshipCountry;
ALTER TABLE birthCertificateLog DROP COLUMN affiateReason;
ALTER TABLE birthCertificateLog DROP COLUMN affiateIAm;
ALTER TABLE birthCertificateLog DROP COLUMN affiateCommTaxNumber;
ALTER TABLE birthCertificateLog DROP COLUMN affiateCommTaxDate;
ALTER TABLE birthCertificateLog DROP COLUMN affiateCommTaxPlace;

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

DELETE FROM keyValue
  WHERE kvKey IN
  ( 'birthCertDefaultCitizenship'
  , 'birthCertDefaultCountry'
  , 'birthCertDefaultAttendantTitle'
  , 'birthCertDefaultAttendantAddr1'
  , 'birthCertDefaultAttendantAddr2'
  , 'birthCertDefaultReceivedByName'
  , 'birthCertDefaultReceivedByTitle'
  );

COMMIT;
