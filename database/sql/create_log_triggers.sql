 
-- ---------------------------------------------------------------
-- Trigger: apgar_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS apgar_after_insert;
CREATE TRIGGER apgar_after_insert AFTER INSERT ON apgar
FOR EACH ROW
BEGIN
  INSERT INTO apgarLog
  (id, minute, score, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.minute, NEW.score, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: apgar_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS apgar_after_update;
CREATE TRIGGER apgar_after_update AFTER UPDATE ON apgar
FOR EACH ROW
BEGIN
  INSERT INTO apgarLog
  (id, minute, score, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.minute, NEW.score, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: apgar_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS apgar_after_delete;
CREATE TRIGGER apgar_after_delete AFTER DELETE ON apgar
FOR EACH ROW
BEGIN
  INSERT INTO apgarLog
  (id, minute, score, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.minute, OLD.score, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyLab_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLab_after_insert;
CREATE TRIGGER babyLab_after_insert AFTER INSERT ON babyLab
FOR EACH ROW
BEGIN
  INSERT INTO babyLabLog
  (id, babyLabType, dateTime, fld1Value, fld2Value, fld3Value, fld4Value, initials, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyLabType, NEW.dateTime, NEW.fld1Value, NEW.fld2Value, NEW.fld3Value, NEW.fld4Value, NEW.initials, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyLab_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLab_after_update;
CREATE TRIGGER babyLab_after_update AFTER UPDATE ON babyLab
FOR EACH ROW
BEGIN
  INSERT INTO babyLabLog
  (id, babyLabType, dateTime, fld1Value, fld2Value, fld3Value, fld4Value, initials, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyLabType, NEW.dateTime, NEW.fld1Value, NEW.fld2Value, NEW.fld3Value, NEW.fld4Value, NEW.initials, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyLab_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLab_after_delete;
CREATE TRIGGER babyLab_after_delete AFTER DELETE ON babyLab
FOR EACH ROW
BEGIN
  INSERT INTO babyLabLog
  (id, babyLabType, dateTime, fld1Value, fld2Value, fld3Value, fld4Value, initials, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.babyLabType, OLD.dateTime, OLD.fld1Value, OLD.fld2Value, OLD.fld3Value, OLD.fld4Value, OLD.initials, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyLabType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLabType_after_insert;
CREATE TRIGGER babyLabType_after_insert AFTER INSERT ON babyLabType
FOR EACH ROW
BEGIN
  INSERT INTO babyLabTypeLog
  (id, name, description, fld1Name, fld1Type, fld2Name, fld2Type, fld3Name, fld3Type, fld4Name, fld4Type, active, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.fld1Name, NEW.fld1Type, NEW.fld2Name, NEW.fld2Type, NEW.fld3Name, NEW.fld3Type, NEW.fld4Name, NEW.fld4Type, NEW.active, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyLabType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLabType_after_update;
CREATE TRIGGER babyLabType_after_update AFTER UPDATE ON babyLabType
FOR EACH ROW
BEGIN
  INSERT INTO babyLabTypeLog
  (id, name, description, fld1Name, fld1Type, fld2Name, fld2Type, fld3Name, fld3Type, fld4Name, fld4Type, active, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.fld1Name, NEW.fld1Type, NEW.fld2Name, NEW.fld2Type, NEW.fld3Name, NEW.fld3Type, NEW.fld4Name, NEW.fld4Type, NEW.active, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyLabType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyLabType_after_delete;
CREATE TRIGGER babyLabType_after_delete AFTER DELETE ON babyLabType
FOR EACH ROW
BEGIN
  INSERT INTO babyLabTypeLog
  (id, name, description, fld1Name, fld1Type, fld2Name, fld2Type, fld3Name, fld3Type, fld4Name, fld4Type, active, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.fld1Name, OLD.fld1Type, OLD.fld2Name, OLD.fld2Type, OLD.fld3Name, OLD.fld3Type, OLD.fld4Name, OLD.fld4Type, OLD.active, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: baby_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS baby_after_insert;
CREATE TRIGGER baby_after_insert AFTER INSERT ON baby
FOR EACH ROW
BEGIN
  INSERT INTO babyLog
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthNbr, NEW.lastname, NEW.firstname, NEW.middlename, NEW.sex, NEW.birthWeight, NEW.bFedEstablished, NEW.bulb, NEW.machine, NEW.freeFlowO2, NEW.chestCompressions, NEW.ppv, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: baby_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS baby_after_update;
CREATE TRIGGER baby_after_update AFTER UPDATE ON baby
FOR EACH ROW
BEGIN
  INSERT INTO babyLog
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthNbr, NEW.lastname, NEW.firstname, NEW.middlename, NEW.sex, NEW.birthWeight, NEW.bFedEstablished, NEW.bulb, NEW.machine, NEW.freeFlowO2, NEW.chestCompressions, NEW.ppv, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: baby_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS baby_after_delete;
CREATE TRIGGER baby_after_delete AFTER DELETE ON baby
FOR EACH ROW
BEGIN
  INSERT INTO babyLog
  (id, birthNbr, lastname, firstname, middlename, sex, birthWeight, bFedEstablished, bulb, machine, freeFlowO2, chestCompressions, ppv, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.birthNbr, OLD.lastname, OLD.firstname, OLD.middlename, OLD.sex, OLD.birthWeight, OLD.bFedEstablished, OLD.bulb, OLD.machine, OLD.freeFlowO2, OLD.chestCompressions, OLD.ppv, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyMedication_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedication_after_insert;
CREATE TRIGGER babyMedication_after_insert AFTER INSERT ON babyMedication
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationLog
  (id, babyMedicationType, medicationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyMedicationType, NEW.medicationDate, NEW.location, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyMedication_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedication_after_update;
CREATE TRIGGER babyMedication_after_update AFTER UPDATE ON babyMedication
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationLog
  (id, babyMedicationType, medicationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyMedicationType, NEW.medicationDate, NEW.location, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyMedication_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedication_after_delete;
CREATE TRIGGER babyMedication_after_delete AFTER DELETE ON babyMedication
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationLog
  (id, babyMedicationType, medicationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.babyMedicationType, OLD.medicationDate, OLD.location, OLD.initials, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyMedicationType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedicationType_after_insert;
CREATE TRIGGER babyMedicationType_after_insert AFTER INSERT ON babyMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.useLocation, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyMedicationType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedicationType_after_update;
CREATE TRIGGER babyMedicationType_after_update AFTER UPDATE ON babyMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.useLocation, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyMedicationType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyMedicationType_after_delete;
CREATE TRIGGER babyMedicationType_after_delete AFTER DELETE ON babyMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO babyMedicationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.useLocation, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyVaccination_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccination_after_insert;
CREATE TRIGGER babyVaccination_after_insert AFTER INSERT ON babyVaccination
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationLog
  (id, babyVaccinationType, vaccinationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyVaccinationType, NEW.vaccinationDate, NEW.location, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyVaccination_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccination_after_update;
CREATE TRIGGER babyVaccination_after_update AFTER UPDATE ON babyVaccination
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationLog
  (id, babyVaccinationType, vaccinationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.babyVaccinationType, NEW.vaccinationDate, NEW.location, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyVaccination_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccination_after_delete;
CREATE TRIGGER babyVaccination_after_delete AFTER DELETE ON babyVaccination
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationLog
  (id, babyVaccinationType, vaccinationDate, location, initials, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.babyVaccinationType, OLD.vaccinationDate, OLD.location, OLD.initials, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyVaccinationType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccinationType_after_insert;
CREATE TRIGGER babyVaccinationType_after_insert AFTER INSERT ON babyVaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.useLocation, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyVaccinationType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccinationType_after_update;
CREATE TRIGGER babyVaccinationType_after_update AFTER UPDATE ON babyVaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.useLocation, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: babyVaccinationType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS babyVaccinationType_after_delete;
CREATE TRIGGER babyVaccinationType_after_delete AFTER DELETE ON babyVaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO babyVaccinationTypeLog
  (id, name, description, useLocation, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.useLocation, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
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
 
-- ---------------------------------------------------------------
-- Trigger: contPostpartumCheck_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS contPostpartumCheck_after_insert;
CREATE TRIGGER contPostpartumCheck_after_insert AFTER INSERT ON contPostpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO contPostpartumCheckLog
  (id, checkDatetime, motherSystolic, motherDiastolic, motherCR, motherTemp, motherFundus, motherEBL, babyBFed, babyTemp, babyRR, babyCR, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.checkDatetime, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherCR, NEW.motherTemp, NEW.motherFundus, NEW.motherEBL, NEW.babyBFed, NEW.babyTemp, NEW.babyRR, NEW.babyCR, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: contPostpartumCheck_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS contPostpartumCheck_after_update;
CREATE TRIGGER contPostpartumCheck_after_update AFTER UPDATE ON contPostpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO contPostpartumCheckLog
  (id, checkDatetime, motherSystolic, motherDiastolic, motherCR, motherTemp, motherFundus, motherEBL, babyBFed, babyTemp, babyRR, babyCR, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.checkDatetime, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherCR, NEW.motherTemp, NEW.motherFundus, NEW.motherEBL, NEW.babyBFed, NEW.babyTemp, NEW.babyRR, NEW.babyCR, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: contPostpartumCheck_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS contPostpartumCheck_after_delete;
CREATE TRIGGER contPostpartumCheck_after_delete AFTER DELETE ON contPostpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO contPostpartumCheckLog
  (id, checkDatetime, motherSystolic, motherDiastolic, motherCR, motherTemp, motherFundus, motherEBL, babyBFed, babyTemp, babyRR, babyCR, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.checkDatetime, OLD.motherSystolic, OLD.motherDiastolic, OLD.motherCR, OLD.motherTemp, OLD.motherFundus, OLD.motherEBL, OLD.babyBFed, OLD.babyTemp, OLD.babyRR, OLD.babyCR, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: customField_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS customField_after_insert;
CREATE TRIGGER customField_after_insert AFTER INSERT ON customField
FOR EACH ROW
BEGIN
  INSERT INTO customFieldLog
  (id, customFieldType_id, pregnancy_id, booleanVal, intVal, decimalVal, textVAl, dateTimeVal, op, replacedAt)
  VALUES (NEW.id, NEW.customFieldType_id, NEW.pregnancy_id, NEW.booleanVal, NEW.intVal, NEW.decimalVal, NEW.textVAl, NEW.dateTimeVal, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: customField_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS customField_after_update;
CREATE TRIGGER customField_after_update AFTER UPDATE ON customField
FOR EACH ROW
BEGIN
  INSERT INTO customFieldLog
  (id, customFieldType_id, pregnancy_id, booleanVal, intVal, decimalVal, textVAl, dateTimeVal, op, replacedAt)
  VALUES (NEW.id, NEW.customFieldType_id, NEW.pregnancy_id, NEW.booleanVal, NEW.intVal, NEW.decimalVal, NEW.textVAl, NEW.dateTimeVal, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: customField_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS customField_after_delete;
CREATE TRIGGER customField_after_delete AFTER DELETE ON customField
FOR EACH ROW
BEGIN
  INSERT INTO customFieldLog
  (id, customFieldType_id, pregnancy_id, booleanVal, intVal, decimalVal, textVAl, dateTimeVal, op, replacedAt)
  VALUES (OLD.id, OLD.customFieldType_id, OLD.pregnancy_id, OLD.booleanVal, OLD.intVal, OLD.decimalVal, OLD.textVAl, OLD.dateTimeVal, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: discharge_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS discharge_after_insert;
CREATE TRIGGER discharge_after_insert AFTER INSERT ON discharge
FOR EACH ROW
BEGIN
  INSERT INTO dischargeLog
  (id, dateTime, motherSystolic, motherDiastolic, motherTemp, motherCR, babyRR, babyTemp, babyCR, ppInstructionsSchedule, birthCertWorksheet, birthRecorded, chartsComplete, logsComplete, billPaid, nbs, immunizationReferral, breastFeedingEstablished, newbornBath, fundusFirmBleedingCtld, motherAteDrank, motherUrinated, placentaGone, prayer, bible, transferBaby, transferMother, transferComment, initials, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.dateTime, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherTemp, NEW.motherCR, NEW.babyRR, NEW.babyTemp, NEW.babyCR, NEW.ppInstructionsSchedule, NEW.birthCertWorksheet, NEW.birthRecorded, NEW.chartsComplete, NEW.logsComplete, NEW.billPaid, NEW.nbs, NEW.immunizationReferral, NEW.breastFeedingEstablished, NEW.newbornBath, NEW.fundusFirmBleedingCtld, NEW.motherAteDrank, NEW.motherUrinated, NEW.placentaGone, NEW.prayer, NEW.bible, NEW.transferBaby, NEW.transferMother, NEW.transferComment, NEW.initials, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: discharge_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS discharge_after_update;
CREATE TRIGGER discharge_after_update AFTER UPDATE ON discharge
FOR EACH ROW
BEGIN
  INSERT INTO dischargeLog
  (id, dateTime, motherSystolic, motherDiastolic, motherTemp, motherCR, babyRR, babyTemp, babyCR, ppInstructionsSchedule, birthCertWorksheet, birthRecorded, chartsComplete, logsComplete, billPaid, nbs, immunizationReferral, breastFeedingEstablished, newbornBath, fundusFirmBleedingCtld, motherAteDrank, motherUrinated, placentaGone, prayer, bible, transferBaby, transferMother, transferComment, initials, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.dateTime, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherTemp, NEW.motherCR, NEW.babyRR, NEW.babyTemp, NEW.babyCR, NEW.ppInstructionsSchedule, NEW.birthCertWorksheet, NEW.birthRecorded, NEW.chartsComplete, NEW.logsComplete, NEW.billPaid, NEW.nbs, NEW.immunizationReferral, NEW.breastFeedingEstablished, NEW.newbornBath, NEW.fundusFirmBleedingCtld, NEW.motherAteDrank, NEW.motherUrinated, NEW.placentaGone, NEW.prayer, NEW.bible, NEW.transferBaby, NEW.transferMother, NEW.transferComment, NEW.initials, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: discharge_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS discharge_after_delete;
CREATE TRIGGER discharge_after_delete AFTER DELETE ON discharge
FOR EACH ROW
BEGIN
  INSERT INTO dischargeLog
  (id, dateTime, motherSystolic, motherDiastolic, motherTemp, motherCR, babyRR, babyTemp, babyCR, ppInstructionsSchedule, birthCertWorksheet, birthRecorded, chartsComplete, logsComplete, billPaid, nbs, immunizationReferral, breastFeedingEstablished, newbornBath, fundusFirmBleedingCtld, motherAteDrank, motherUrinated, placentaGone, prayer, bible, transferBaby, transferMother, transferComment, initials, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.dateTime, OLD.motherSystolic, OLD.motherDiastolic, OLD.motherTemp, OLD.motherCR, OLD.babyRR, OLD.babyTemp, OLD.babyCR, OLD.ppInstructionsSchedule, OLD.birthCertWorksheet, OLD.birthRecorded, OLD.chartsComplete, OLD.logsComplete, OLD.billPaid, OLD.nbs, OLD.immunizationReferral, OLD.breastFeedingEstablished, OLD.newbornBath, OLD.fundusFirmBleedingCtld, OLD.motherAteDrank, OLD.motherUrinated, OLD.placentaGone, OLD.prayer, OLD.bible, OLD.transferBaby, OLD.transferMother, OLD.transferComment, OLD.initials, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: healthTeaching_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS healthTeaching_after_insert;
CREATE TRIGGER healthTeaching_after_insert AFTER INSERT ON healthTeaching
FOR EACH ROW
BEGIN
  INSERT INTO healthTeachingLog
  (id, date, topic, teacher, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.topic, NEW.teacher, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: healthTeaching_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS healthTeaching_after_update;
CREATE TRIGGER healthTeaching_after_update AFTER UPDATE ON healthTeaching
FOR EACH ROW
BEGIN
  INSERT INTO healthTeachingLog
  (id, date, topic, teacher, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.topic, NEW.teacher, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: healthTeaching_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS healthTeaching_after_delete;
CREATE TRIGGER healthTeaching_after_delete AFTER DELETE ON healthTeaching
FOR EACH ROW
BEGIN
  INSERT INTO healthTeachingLog
  (id, date, topic, teacher, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.topic, OLD.teacher, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: keyValue_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS keyValue_after_insert;
CREATE TRIGGER keyValue_after_insert AFTER INSERT ON keyValue
FOR EACH ROW
BEGIN
  INSERT INTO keyValueLog
  (id, kvKey, kvValue, description, valueType, acceptableValues, systemOnly, op, replacedAt)
  VALUES (NEW.id, NEW.kvKey, NEW.kvValue, NEW.description, NEW.valueType, NEW.acceptableValues, NEW.systemOnly, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: keyValue_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS keyValue_after_update;
CREATE TRIGGER keyValue_after_update AFTER UPDATE ON keyValue
FOR EACH ROW
BEGIN
  INSERT INTO keyValueLog
  (id, kvKey, kvValue, description, valueType, acceptableValues, systemOnly, op, replacedAt)
  VALUES (NEW.id, NEW.kvKey, NEW.kvValue, NEW.description, NEW.valueType, NEW.acceptableValues, NEW.systemOnly, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: keyValue_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS keyValue_after_delete;
CREATE TRIGGER keyValue_after_delete AFTER DELETE ON keyValue
FOR EACH ROW
BEGIN
  INSERT INTO keyValueLog
  (id, kvKey, kvValue, description, valueType, acceptableValues, systemOnly, op, replacedAt)
  VALUES (OLD.id, OLD.kvKey, OLD.kvValue, OLD.description, OLD.valueType, OLD.acceptableValues, OLD.systemOnly, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labSuite_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labSuite_after_insert;
CREATE TRIGGER labSuite_after_insert AFTER INSERT ON labSuite
FOR EACH ROW
BEGIN
  INSERT INTO labSuiteLog
  (id, name, description, category, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.category, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labSuite_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labSuite_after_update;
CREATE TRIGGER labSuite_after_update AFTER UPDATE ON labSuite
FOR EACH ROW
BEGIN
  INSERT INTO labSuiteLog
  (id, name, description, category, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.category, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labSuite_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labSuite_after_delete;
CREATE TRIGGER labSuite_after_delete AFTER DELETE ON labSuite
FOR EACH ROW
BEGIN
  INSERT INTO labSuiteLog
  (id, name, description, category, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.category, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labTest_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTest_after_insert;
CREATE TRIGGER labTest_after_insert AFTER INSERT ON labTest
FOR EACH ROW
BEGIN
  INSERT INTO labTestLog
  (id, name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger, maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.abbrev, NEW.normal, NEW.unit, NEW.minRangeDecimal, NEW.maxRangeDecimal, NEW.minRangeInteger, NEW.maxRangeInteger, NEW.isRange, NEW.isText, NEW.labSuite_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labTest_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTest_after_update;
CREATE TRIGGER labTest_after_update AFTER UPDATE ON labTest
FOR EACH ROW
BEGIN
  INSERT INTO labTestLog
  (id, name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger, maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.abbrev, NEW.normal, NEW.unit, NEW.minRangeDecimal, NEW.maxRangeDecimal, NEW.minRangeInteger, NEW.maxRangeInteger, NEW.isRange, NEW.isText, NEW.labSuite_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labTest_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTest_after_delete;
CREATE TRIGGER labTest_after_delete AFTER DELETE ON labTest
FOR EACH ROW
BEGIN
  INSERT INTO labTestLog
  (id, name, abbrev, normal, unit, minRangeDecimal, maxRangeDecimal, minRangeInteger, maxRangeInteger, isRange, isText, labSuite_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.abbrev, OLD.normal, OLD.unit, OLD.minRangeDecimal, OLD.maxRangeDecimal, OLD.minRangeInteger, OLD.maxRangeInteger, OLD.isRange, OLD.isText, OLD.labSuite_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labTestResult_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestResult_after_insert;
CREATE TRIGGER labTestResult_after_insert AFTER INSERT ON labTestResult
FOR EACH ROW
BEGIN
  INSERT INTO labTestResultLog
  (id, testDate, result, result2, warn, labTest_id, pregnancy_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.testDate, NEW.result, NEW.result2, NEW.warn, NEW.labTest_id, NEW.pregnancy_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labTestResult_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestResult_after_update;
CREATE TRIGGER labTestResult_after_update AFTER UPDATE ON labTestResult
FOR EACH ROW
BEGIN
  INSERT INTO labTestResultLog
  (id, testDate, result, result2, warn, labTest_id, pregnancy_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.testDate, NEW.result, NEW.result2, NEW.warn, NEW.labTest_id, NEW.pregnancy_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labTestResult_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestResult_after_delete;
CREATE TRIGGER labTestResult_after_delete AFTER DELETE ON labTestResult
FOR EACH ROW
BEGIN
  INSERT INTO labTestResultLog
  (id, testDate, result, result2, warn, labTest_id, pregnancy_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.testDate, OLD.result, OLD.result2, OLD.warn, OLD.labTest_id, OLD.pregnancy_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labTestValue_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestValue_after_insert;
CREATE TRIGGER labTestValue_after_insert AFTER INSERT ON labTestValue
FOR EACH ROW
BEGIN
  INSERT INTO labTestValueLog
  (id, value, labTest_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.value, NEW.labTest_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labTestValue_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestValue_after_update;
CREATE TRIGGER labTestValue_after_update AFTER UPDATE ON labTestValue
FOR EACH ROW
BEGIN
  INSERT INTO labTestValueLog
  (id, value, labTest_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.value, NEW.labTest_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labTestValue_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labTestValue_after_delete;
CREATE TRIGGER labTestValue_after_delete AFTER DELETE ON labTestValue
FOR EACH ROW
BEGIN
  INSERT INTO labTestValueLog
  (id, value, labTest_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.value, OLD.labTest_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labor_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_insert;
CREATE TRIGGER labor_after_insert AFTER INSERT ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, dischargeDate, earlyLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.admittanceDate, NEW.startLaborDate, NEW.dischargeDate, NEW.earlyLabor, NEW.pos, NEW.fh, NEW.fht, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temp, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labor_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_update;
CREATE TRIGGER labor_after_update AFTER UPDATE ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, dischargeDate, earlyLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.admittanceDate, NEW.startLaborDate, NEW.dischargeDate, NEW.earlyLabor, NEW.pos, NEW.fh, NEW.fht, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temp, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: labor_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labor_after_delete;
CREATE TRIGGER labor_after_delete AFTER DELETE ON labor
FOR EACH ROW
BEGIN
  INSERT INTO laborLog
  (id, admittanceDate, startLaborDate, dischargeDate, earlyLabor, pos, fh, fht, systolic, diastolic, cr, temp, comments, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.admittanceDate, OLD.startLaborDate, OLD.dischargeDate, OLD.earlyLabor, OLD.pos, OLD.fh, OLD.fht, OLD.systolic, OLD.diastolic, OLD.cr, OLD.temp, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: laborStage1_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage1_after_insert;
CREATE TRIGGER laborStage1_after_insert AFTER INSERT ON laborStage1
FOR EACH ROW
BEGIN
  INSERT INTO laborStage1Log
  (id, fullDialation, mobility, durationLatent, durationActive, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.fullDialation, NEW.mobility, NEW.durationLatent, NEW.durationActive, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: laborStage1_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage1_after_update;
CREATE TRIGGER laborStage1_after_update AFTER UPDATE ON laborStage1
FOR EACH ROW
BEGIN
  INSERT INTO laborStage1Log
  (id, fullDialation, mobility, durationLatent, durationActive, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.fullDialation, NEW.mobility, NEW.durationLatent, NEW.durationActive, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: laborStage1_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage1_after_delete;
CREATE TRIGGER laborStage1_after_delete AFTER DELETE ON laborStage1
FOR EACH ROW
BEGIN
  INSERT INTO laborStage1Log
  (id, fullDialation, mobility, durationLatent, durationActive, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.fullDialation, OLD.mobility, OLD.durationLatent, OLD.durationActive, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: laborStage2_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage2_after_insert;
CREATE TRIGGER laborStage2_after_insert AFTER INSERT ON laborStage2
FOR EACH ROW
BEGIN
  INSERT INTO laborStage2Log
  (id, birthDatetime, birthType, birthPosition, durationPushing, birthPresentation, terminalMec, cordWrapType, deliveryType, shoulderDystocia, shoulderDystociaMinutes, laceration, episiotomy, repair, degree, lacerationRepairedBy, birthEBL, meconium, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthDatetime, NEW.birthType, NEW.birthPosition, NEW.durationPushing, NEW.birthPresentation, NEW.terminalMec, NEW.cordWrapType, NEW.deliveryType, NEW.shoulderDystocia, NEW.shoulderDystociaMinutes, NEW.laceration, NEW.episiotomy, NEW.repair, NEW.degree, NEW.lacerationRepairedBy, NEW.birthEBL, NEW.meconium, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: laborStage2_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage2_after_update;
CREATE TRIGGER laborStage2_after_update AFTER UPDATE ON laborStage2
FOR EACH ROW
BEGIN
  INSERT INTO laborStage2Log
  (id, birthDatetime, birthType, birthPosition, durationPushing, birthPresentation, terminalMec, cordWrapType, deliveryType, shoulderDystocia, shoulderDystociaMinutes, laceration, episiotomy, repair, degree, lacerationRepairedBy, birthEBL, meconium, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthDatetime, NEW.birthType, NEW.birthPosition, NEW.durationPushing, NEW.birthPresentation, NEW.terminalMec, NEW.cordWrapType, NEW.deliveryType, NEW.shoulderDystocia, NEW.shoulderDystociaMinutes, NEW.laceration, NEW.episiotomy, NEW.repair, NEW.degree, NEW.lacerationRepairedBy, NEW.birthEBL, NEW.meconium, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: laborStage2_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage2_after_delete;
CREATE TRIGGER laborStage2_after_delete AFTER DELETE ON laborStage2
FOR EACH ROW
BEGIN
  INSERT INTO laborStage2Log
  (id, birthDatetime, birthType, birthPosition, durationPushing, birthPresentation, terminalMec, cordWrapType, deliveryType, shoulderDystocia, shoulderDystociaMinutes, laceration, episiotomy, repair, degree, lacerationRepairedBy, birthEBL, meconium, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.birthDatetime, OLD.birthType, OLD.birthPosition, OLD.durationPushing, OLD.birthPresentation, OLD.terminalMec, OLD.cordWrapType, OLD.deliveryType, OLD.shoulderDystocia, OLD.shoulderDystociaMinutes, OLD.laceration, OLD.episiotomy, OLD.repair, OLD.degree, OLD.lacerationRepairedBy, OLD.birthEBL, OLD.meconium, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: laborStage3_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage3_after_insert;
CREATE TRIGGER laborStage3_after_insert AFTER INSERT ON laborStage3
FOR EACH ROW
BEGIN
  INSERT INTO laborStage3Log
  (id, placentaDatetime, placentaDeliverySpontaneous, placentaDeliveryAMTSL, placentaDeliveryCCT, placentaDeliveryManual, maternalPosition, txBloodLoss1, txBloodLoss2, txBloodLoss3, txBloodLoss4, txBloodLoss5, placentaShape, placentaInsertion, placentaNumVessels, schultzDuncan, cotyledons, membranes, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.placentaDatetime, NEW.placentaDeliverySpontaneous, NEW.placentaDeliveryAMTSL, NEW.placentaDeliveryCCT, NEW.placentaDeliveryManual, NEW.maternalPosition, NEW.txBloodLoss1, NEW.txBloodLoss2, NEW.txBloodLoss3, NEW.txBloodLoss4, NEW.txBloodLoss5, NEW.placentaShape, NEW.placentaInsertion, NEW.placentaNumVessels, NEW.schultzDuncan, NEW.cotyledons, NEW.membranes, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: laborStage3_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage3_after_update;
CREATE TRIGGER laborStage3_after_update AFTER UPDATE ON laborStage3
FOR EACH ROW
BEGIN
  INSERT INTO laborStage3Log
  (id, placentaDatetime, placentaDeliverySpontaneous, placentaDeliveryAMTSL, placentaDeliveryCCT, placentaDeliveryManual, maternalPosition, txBloodLoss1, txBloodLoss2, txBloodLoss3, txBloodLoss4, txBloodLoss5, placentaShape, placentaInsertion, placentaNumVessels, schultzDuncan, cotyledons, membranes, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.placentaDatetime, NEW.placentaDeliverySpontaneous, NEW.placentaDeliveryAMTSL, NEW.placentaDeliveryCCT, NEW.placentaDeliveryManual, NEW.maternalPosition, NEW.txBloodLoss1, NEW.txBloodLoss2, NEW.txBloodLoss3, NEW.txBloodLoss4, NEW.txBloodLoss5, NEW.placentaShape, NEW.placentaInsertion, NEW.placentaNumVessels, NEW.schultzDuncan, NEW.cotyledons, NEW.membranes, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: laborStage3_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage3_after_delete;
CREATE TRIGGER laborStage3_after_delete AFTER DELETE ON laborStage3
FOR EACH ROW
BEGIN
  INSERT INTO laborStage3Log
  (id, placentaDatetime, placentaDeliverySpontaneous, placentaDeliveryAMTSL, placentaDeliveryCCT, placentaDeliveryManual, maternalPosition, txBloodLoss1, txBloodLoss2, txBloodLoss3, txBloodLoss4, txBloodLoss5, placentaShape, placentaInsertion, placentaNumVessels, schultzDuncan, cotyledons, membranes, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.placentaDatetime, OLD.placentaDeliverySpontaneous, OLD.placentaDeliveryAMTSL, OLD.placentaDeliveryCCT, OLD.placentaDeliveryManual, OLD.maternalPosition, OLD.txBloodLoss1, OLD.txBloodLoss2, OLD.txBloodLoss3, OLD.txBloodLoss4, OLD.txBloodLoss5, OLD.placentaShape, OLD.placentaInsertion, OLD.placentaNumVessels, OLD.schultzDuncan, OLD.cotyledons, OLD.membranes, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: medication_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medication_after_insert;
CREATE TRIGGER medication_after_insert AFTER INSERT ON medication
FOR EACH ROW
BEGIN
  INSERT INTO medicationLog
  (id, date, medicationType, numberDispensed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.medicationType, NEW.numberDispensed, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: medication_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medication_after_update;
CREATE TRIGGER medication_after_update AFTER UPDATE ON medication
FOR EACH ROW
BEGIN
  INSERT INTO medicationLog
  (id, date, medicationType, numberDispensed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.medicationType, NEW.numberDispensed, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: medication_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medication_after_delete;
CREATE TRIGGER medication_after_delete AFTER DELETE ON medication
FOR EACH ROW
BEGIN
  INSERT INTO medicationLog
  (id, date, medicationType, numberDispensed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.medicationType, OLD.numberDispensed, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: medicationType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medicationType_after_insert;
CREATE TRIGGER medicationType_after_insert AFTER INSERT ON medicationType
FOR EACH ROW
BEGIN
  INSERT INTO medicationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: medicationType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medicationType_after_update;
CREATE TRIGGER medicationType_after_update AFTER UPDATE ON medicationType
FOR EACH ROW
BEGIN
  INSERT INTO medicationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: medicationType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS medicationType_after_delete;
CREATE TRIGGER medicationType_after_delete AFTER DELETE ON medicationType
FOR EACH ROW
BEGIN
  INSERT INTO medicationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.sortOrder, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: membrane_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS membrane_after_insert;
CREATE TRIGGER membrane_after_insert AFTER INSERT ON membrane
FOR EACH ROW
BEGIN
  INSERT INTO membraneLog
  (id, ruptureDatetime, rupture, ruptureComment, amniotic, amnioticComment, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.ruptureDatetime, NEW.rupture, NEW.ruptureComment, NEW.amniotic, NEW.amnioticComment, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: membrane_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS membrane_after_update;
CREATE TRIGGER membrane_after_update AFTER UPDATE ON membrane
FOR EACH ROW
BEGIN
  INSERT INTO membraneLog
  (id, ruptureDatetime, rupture, ruptureComment, amniotic, amnioticComment, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.ruptureDatetime, NEW.rupture, NEW.ruptureComment, NEW.amniotic, NEW.amnioticComment, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: membrane_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS membrane_after_delete;
CREATE TRIGGER membrane_after_delete AFTER DELETE ON membrane
FOR EACH ROW
BEGIN
  INSERT INTO membraneLog
  (id, ruptureDatetime, rupture, ruptureComment, amniotic, amnioticComment, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.ruptureDatetime, OLD.rupture, OLD.ruptureComment, OLD.amniotic, OLD.amnioticComment, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: motherMedication_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedication_after_insert;
CREATE TRIGGER motherMedication_after_insert AFTER INSERT ON motherMedication
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationLog
  (id, motherMedicationType, medicationDate, initials, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.motherMedicationType, NEW.medicationDate, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: motherMedication_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedication_after_update;
CREATE TRIGGER motherMedication_after_update AFTER UPDATE ON motherMedication
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationLog
  (id, motherMedicationType, medicationDate, initials, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.motherMedicationType, NEW.medicationDate, NEW.initials, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: motherMedication_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedication_after_delete;
CREATE TRIGGER motherMedication_after_delete AFTER DELETE ON motherMedication
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationLog
  (id, motherMedicationType, medicationDate, initials, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.motherMedicationType, OLD.medicationDate, OLD.initials, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: motherMedicationType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedicationType_after_insert;
CREATE TRIGGER motherMedicationType_after_insert AFTER INSERT ON motherMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationTypeLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: motherMedicationType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedicationType_after_update;
CREATE TRIGGER motherMedicationType_after_update AFTER UPDATE ON motherMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationTypeLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: motherMedicationType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS motherMedicationType_after_delete;
CREATE TRIGGER motherMedicationType_after_delete AFTER DELETE ON motherMedicationType
FOR EACH ROW
BEGIN
  INSERT INTO motherMedicationTypeLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: newbornExam_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS newbornExam_after_insert;
CREATE TRIGGER newbornExam_after_insert AFTER INSERT ON newbornExam
FOR EACH ROW
BEGIN
  INSERT INTO newbornExamLog
  (id, examDatetime, examiners, rr, hr, temperature, length, headCir, chestCir, appearance, appearanceComment, color, colorComment, skin, skinComment, head, headComment, eyes, eyesComment, ears, earsComment, nose, noseComment, mouth, mouthComment, neck, neckComment, chest, chestComment, lungs, lungsComment, heart, heartComment, abdomen, abdomenComment, hips, hipsComment, cord, cordComment, femoralPulses, femoralPulsesComment, genitalia, genitaliaComment, anus, anusComment, back, backComment, extremities, extremitiesComment, estGA, moroReflex, moroReflexComment, palmarReflex, palmarReflexComment, steppingReflex, steppingReflexComment, plantarReflex, plantarReflexComment, babinskiReflex, babinskiReflexComment, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.examDatetime, NEW.examiners, NEW.rr, NEW.hr, NEW.temperature, NEW.length, NEW.headCir, NEW.chestCir, NEW.appearance, NEW.appearanceComment, NEW.color, NEW.colorComment, NEW.skin, NEW.skinComment, NEW.head, NEW.headComment, NEW.eyes, NEW.eyesComment, NEW.ears, NEW.earsComment, NEW.nose, NEW.noseComment, NEW.mouth, NEW.mouthComment, NEW.neck, NEW.neckComment, NEW.chest, NEW.chestComment, NEW.lungs, NEW.lungsComment, NEW.heart, NEW.heartComment, NEW.abdomen, NEW.abdomenComment, NEW.hips, NEW.hipsComment, NEW.cord, NEW.cordComment, NEW.femoralPulses, NEW.femoralPulsesComment, NEW.genitalia, NEW.genitaliaComment, NEW.anus, NEW.anusComment, NEW.back, NEW.backComment, NEW.extremities, NEW.extremitiesComment, NEW.estGA, NEW.moroReflex, NEW.moroReflexComment, NEW.palmarReflex, NEW.palmarReflexComment, NEW.steppingReflex, NEW.steppingReflexComment, NEW.plantarReflex, NEW.plantarReflexComment, NEW.babinskiReflex, NEW.babinskiReflexComment, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: newbornExam_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS newbornExam_after_update;
CREATE TRIGGER newbornExam_after_update AFTER UPDATE ON newbornExam
FOR EACH ROW
BEGIN
  INSERT INTO newbornExamLog
  (id, examDatetime, examiners, rr, hr, temperature, length, headCir, chestCir, appearance, appearanceComment, color, colorComment, skin, skinComment, head, headComment, eyes, eyesComment, ears, earsComment, nose, noseComment, mouth, mouthComment, neck, neckComment, chest, chestComment, lungs, lungsComment, heart, heartComment, abdomen, abdomenComment, hips, hipsComment, cord, cordComment, femoralPulses, femoralPulsesComment, genitalia, genitaliaComment, anus, anusComment, back, backComment, extremities, extremitiesComment, estGA, moroReflex, moroReflexComment, palmarReflex, palmarReflexComment, steppingReflex, steppingReflexComment, plantarReflex, plantarReflexComment, babinskiReflex, babinskiReflexComment, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (NEW.id, NEW.examDatetime, NEW.examiners, NEW.rr, NEW.hr, NEW.temperature, NEW.length, NEW.headCir, NEW.chestCir, NEW.appearance, NEW.appearanceComment, NEW.color, NEW.colorComment, NEW.skin, NEW.skinComment, NEW.head, NEW.headComment, NEW.eyes, NEW.eyesComment, NEW.ears, NEW.earsComment, NEW.nose, NEW.noseComment, NEW.mouth, NEW.mouthComment, NEW.neck, NEW.neckComment, NEW.chest, NEW.chestComment, NEW.lungs, NEW.lungsComment, NEW.heart, NEW.heartComment, NEW.abdomen, NEW.abdomenComment, NEW.hips, NEW.hipsComment, NEW.cord, NEW.cordComment, NEW.femoralPulses, NEW.femoralPulsesComment, NEW.genitalia, NEW.genitaliaComment, NEW.anus, NEW.anusComment, NEW.back, NEW.backComment, NEW.extremities, NEW.extremitiesComment, NEW.estGA, NEW.moroReflex, NEW.moroReflexComment, NEW.palmarReflex, NEW.palmarReflexComment, NEW.steppingReflex, NEW.steppingReflexComment, NEW.plantarReflex, NEW.plantarReflexComment, NEW.babinskiReflex, NEW.babinskiReflexComment, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.baby_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: newbornExam_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS newbornExam_after_delete;
CREATE TRIGGER newbornExam_after_delete AFTER DELETE ON newbornExam
FOR EACH ROW
BEGIN
  INSERT INTO newbornExamLog
  (id, examDatetime, examiners, rr, hr, temperature, length, headCir, chestCir, appearance, appearanceComment, color, colorComment, skin, skinComment, head, headComment, eyes, eyesComment, ears, earsComment, nose, noseComment, mouth, mouthComment, neck, neckComment, chest, chestComment, lungs, lungsComment, heart, heartComment, abdomen, abdomenComment, hips, hipsComment, cord, cordComment, femoralPulses, femoralPulsesComment, genitalia, genitaliaComment, anus, anusComment, back, backComment, extremities, extremitiesComment, estGA, moroReflex, moroReflexComment, palmarReflex, palmarReflexComment, steppingReflex, steppingReflexComment, plantarReflex, plantarReflexComment, babinskiReflex, babinskiReflexComment, comments, updatedBy, updatedAt, supervisor, baby_id, op, replacedAt)
  VALUES (OLD.id, OLD.examDatetime, OLD.examiners, OLD.rr, OLD.hr, OLD.temperature, OLD.length, OLD.headCir, OLD.chestCir, OLD.appearance, OLD.appearanceComment, OLD.color, OLD.colorComment, OLD.skin, OLD.skinComment, OLD.head, OLD.headComment, OLD.eyes, OLD.eyesComment, OLD.ears, OLD.earsComment, OLD.nose, OLD.noseComment, OLD.mouth, OLD.mouthComment, OLD.neck, OLD.neckComment, OLD.chest, OLD.chestComment, OLD.lungs, OLD.lungsComment, OLD.heart, OLD.heartComment, OLD.abdomen, OLD.abdomenComment, OLD.hips, OLD.hipsComment, OLD.cord, OLD.cordComment, OLD.femoralPulses, OLD.femoralPulsesComment, OLD.genitalia, OLD.genitaliaComment, OLD.anus, OLD.anusComment, OLD.back, OLD.backComment, OLD.extremities, OLD.extremitiesComment, OLD.estGA, OLD.moroReflex, OLD.moroReflexComment, OLD.palmarReflex, OLD.palmarReflexComment, OLD.steppingReflex, OLD.steppingReflexComment, OLD.plantarReflex, OLD.plantarReflexComment, OLD.babinskiReflex, OLD.babinskiReflexComment, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.baby_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: patient_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS patient_after_insert;
CREATE TRIGGER patient_after_insert AFTER INSERT ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.dohID, NEW.dob, NEW.generalInfo, NEW.ageOfMenarche, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: patient_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS patient_after_update;
CREATE TRIGGER patient_after_update AFTER UPDATE ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.dohID, NEW.dob, NEW.generalInfo, NEW.ageOfMenarche, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: patient_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS patient_after_delete;
CREATE TRIGGER patient_after_delete AFTER DELETE ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.dohID, OLD.dob, OLD.generalInfo, OLD.ageOfMenarche, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: postpartumCheck_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS postpartumCheck_after_insert;
CREATE TRIGGER postpartumCheck_after_insert AFTER INSERT ON postpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO postpartumCheckLog
  (id, checkDatetime, babyWeight, babyTemp, babyCR, babyRR, babyLungs, babyColor, babySkin, babyCord, babyUrine, babyStool, babySSInfection, babyFeeding, babyFeedingDaily, motherTemp, motherSystolic, motherDiastolic, motherCR, motherBreasts, motherFundus, motherPerineum, motherLochia, motherUrine, motherStool, motherSSInfection, motherFamilyPlanning, birthCertReq, hgbRequested, hgbTestDate, hgbTestResult, ironGiven, comments, nextScheduledCheck, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.checkDatetime, NEW.babyWeight, NEW.babyTemp, NEW.babyCR, NEW.babyRR, NEW.babyLungs, NEW.babyColor, NEW.babySkin, NEW.babyCord, NEW.babyUrine, NEW.babyStool, NEW.babySSInfection, NEW.babyFeeding, NEW.babyFeedingDaily, NEW.motherTemp, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherCR, NEW.motherBreasts, NEW.motherFundus, NEW.motherPerineum, NEW.motherLochia, NEW.motherUrine, NEW.motherStool, NEW.motherSSInfection, NEW.motherFamilyPlanning, NEW.birthCertReq, NEW.hgbRequested, NEW.hgbTestDate, NEW.hgbTestResult, NEW.ironGiven, NEW.comments, NEW.nextScheduledCheck, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: postpartumCheck_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS postpartumCheck_after_update;
CREATE TRIGGER postpartumCheck_after_update AFTER UPDATE ON postpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO postpartumCheckLog
  (id, checkDatetime, babyWeight, babyTemp, babyCR, babyRR, babyLungs, babyColor, babySkin, babyCord, babyUrine, babyStool, babySSInfection, babyFeeding, babyFeedingDaily, motherTemp, motherSystolic, motherDiastolic, motherCR, motherBreasts, motherFundus, motherPerineum, motherLochia, motherUrine, motherStool, motherSSInfection, motherFamilyPlanning, birthCertReq, hgbRequested, hgbTestDate, hgbTestResult, ironGiven, comments, nextScheduledCheck, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.checkDatetime, NEW.babyWeight, NEW.babyTemp, NEW.babyCR, NEW.babyRR, NEW.babyLungs, NEW.babyColor, NEW.babySkin, NEW.babyCord, NEW.babyUrine, NEW.babyStool, NEW.babySSInfection, NEW.babyFeeding, NEW.babyFeedingDaily, NEW.motherTemp, NEW.motherSystolic, NEW.motherDiastolic, NEW.motherCR, NEW.motherBreasts, NEW.motherFundus, NEW.motherPerineum, NEW.motherLochia, NEW.motherUrine, NEW.motherStool, NEW.motherSSInfection, NEW.motherFamilyPlanning, NEW.birthCertReq, NEW.hgbRequested, NEW.hgbTestDate, NEW.hgbTestResult, NEW.ironGiven, NEW.comments, NEW.nextScheduledCheck, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: postpartumCheck_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS postpartumCheck_after_delete;
CREATE TRIGGER postpartumCheck_after_delete AFTER DELETE ON postpartumCheck
FOR EACH ROW
BEGIN
  INSERT INTO postpartumCheckLog
  (id, checkDatetime, babyWeight, babyTemp, babyCR, babyRR, babyLungs, babyColor, babySkin, babyCord, babyUrine, babyStool, babySSInfection, babyFeeding, babyFeedingDaily, motherTemp, motherSystolic, motherDiastolic, motherCR, motherBreasts, motherFundus, motherPerineum, motherLochia, motherUrine, motherStool, motherSSInfection, motherFamilyPlanning, birthCertReq, hgbRequested, hgbTestDate, hgbTestResult, ironGiven, comments, nextScheduledCheck, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.checkDatetime, OLD.babyWeight, OLD.babyTemp, OLD.babyCR, OLD.babyRR, OLD.babyLungs, OLD.babyColor, OLD.babySkin, OLD.babyCord, OLD.babyUrine, OLD.babyStool, OLD.babySSInfection, OLD.babyFeeding, OLD.babyFeedingDaily, OLD.motherTemp, OLD.motherSystolic, OLD.motherDiastolic, OLD.motherCR, OLD.motherBreasts, OLD.motherFundus, OLD.motherPerineum, OLD.motherLochia, OLD.motherUrine, OLD.motherStool, OLD.motherSSInfection, OLD.motherFamilyPlanning, OLD.birthCertReq, OLD.hgbRequested, OLD.hgbTestDate, OLD.hgbTestResult, OLD.ironGiven, OLD.comments, OLD.nextScheduledCheck, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnancyHistory_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancyHistory_after_insert;
CREATE TRIGGER pregnancyHistory_after_insert AFTER INSERT ON pregnancyHistory
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyHistoryLog
  (id, day, month, year, FT, finalGA, finalGAPeriod, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, howLongBFedPeriod, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.day, NEW.month, NEW.year, NEW.FT, NEW.finalGA, NEW.finalGAPeriod, NEW.sexOfBaby, NEW.placeOfBirth, NEW.attendant, NEW.typeOfDelivery, NEW.lengthOfLabor, NEW.birthWeight, NEW.episTear, NEW.repaired, NEW.howLongBFed, NEW.howLongBFedPeriod, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnancyHistory_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancyHistory_after_update;
CREATE TRIGGER pregnancyHistory_after_update AFTER UPDATE ON pregnancyHistory
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyHistoryLog
  (id, day, month, year, FT, finalGA, finalGAPeriod, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, howLongBFedPeriod, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.day, NEW.month, NEW.year, NEW.FT, NEW.finalGA, NEW.finalGAPeriod, NEW.sexOfBaby, NEW.placeOfBirth, NEW.attendant, NEW.typeOfDelivery, NEW.lengthOfLabor, NEW.birthWeight, NEW.episTear, NEW.repaired, NEW.howLongBFed, NEW.howLongBFedPeriod, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnancyHistory_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancyHistory_after_delete;
CREATE TRIGGER pregnancyHistory_after_delete AFTER DELETE ON pregnancyHistory
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyHistoryLog
  (id, day, month, year, FT, finalGA, finalGAPeriod, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, howLongBFedPeriod, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.day, OLD.month, OLD.year, OLD.FT, OLD.finalGA, OLD.finalGAPeriod, OLD.sexOfBaby, OLD.placeOfBirth, OLD.attendant, OLD.typeOfDelivery, OLD.lengthOfLabor, OLD.birthWeight, OLD.episTear, OLD.repaired, OLD.howLongBFed, OLD.howLongBFedPeriod, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnancy_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancy_after_insert;
CREATE TRIGGER pregnancy_after_insert AFTER INSERT ON pregnancy
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyLog
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, clientIncome, clientIncomePeriod, address1, address2, address3, address4, city, state, postalCode, country, gravidaNumber, lmp, sureLMP, warning, riskNote, alternateEdd, useAlternateEdd, doctorConsultDate, dentistConsultDate, mbBook, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, transferOfCare, transferOfCareNote, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyVaginalPain, currentlyVaginalItching, currentlyNone, useIodizedSalt, takingMedication, planToBreastFeed, birthCompanion, practiceFamilyPlanning, practiceFamilyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryHeartProblems, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyHeartProblems, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, questionnaireNote, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerIncome, partnerIncomePeriod, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (NEW.id, NEW.firstname, NEW.lastname, NEW.maidenname, NEW.nickname, NEW.religion, NEW.maritalStatus, NEW.telephone, NEW.work, NEW.education, NEW.clientIncome, NEW.clientIncomePeriod, NEW.address1, NEW.address2, NEW.address3, NEW.address4, NEW.city, NEW.state, NEW.postalCode, NEW.country, NEW.gravidaNumber, NEW.lmp, NEW.sureLMP, NEW.warning, NEW.riskNote, NEW.alternateEdd, NEW.useAlternateEdd, NEW.doctorConsultDate, NEW.dentistConsultDate, NEW.mbBook, NEW.whereDeliver, NEW.fetuses, NEW.monozygotic, NEW.pregnancyEndDate, NEW.pregnancyEndResult, NEW.iugr, NEW.note, NEW.numberRequiredTetanus, NEW.invertedNipples, NEW.hasUS, NEW.wantsUS, NEW.gravida, NEW.stillBirths, NEW.abortions, NEW.living, NEW.para, NEW.term, NEW.preterm, NEW.philHealthMCP, NEW.philHealthNCP, NEW.philHealthID, NEW.philHealthApproved, NEW.transferOfCare, NEW.transferOfCareNote, NEW.currentlyVomiting, NEW.currentlyDizzy, NEW.currentlyFainting, NEW.currentlyBleeding, NEW.currentlyUrinationPain, NEW.currentlyBlurryVision, NEW.currentlySwelling, NEW.currentlyVaginalPain, NEW.currentlyVaginalItching, NEW.currentlyNone, NEW.useIodizedSalt, NEW.takingMedication, NEW.planToBreastFeed, NEW.birthCompanion, NEW.practiceFamilyPlanning, NEW.practiceFamilyPlanningDetails, NEW.familyHistoryTwins, NEW.familyHistoryHighBloodPressure, NEW.familyHistoryDiabetes, NEW.familyHistoryHeartProblems, NEW.familyHistoryTB, NEW.familyHistorySmoking, NEW.familyHistoryNone, NEW.historyFoodAllergy, NEW.historyMedicineAllergy, NEW.historyAsthma, NEW.historyHeartProblems, NEW.historyKidneyProblems, NEW.historyHepatitis, NEW.historyGoiter, NEW.historyHighBloodPressure, NEW.historyHospitalOperation, NEW.historyBloodTransfusion, NEW.historySmoking, NEW.historyDrinking, NEW.historyNone, NEW.questionnaireNote, NEW.partnerFirstname, NEW.partnerLastname, NEW.partnerAge, NEW.partnerWork, NEW.partnerEducation, NEW.partnerIncome, NEW.partnerIncomePeriod, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.patient_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnancy_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancy_after_update;
CREATE TRIGGER pregnancy_after_update AFTER UPDATE ON pregnancy
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyLog
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, clientIncome, clientIncomePeriod, address1, address2, address3, address4, city, state, postalCode, country, gravidaNumber, lmp, sureLMP, warning, riskNote, alternateEdd, useAlternateEdd, doctorConsultDate, dentistConsultDate, mbBook, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, transferOfCare, transferOfCareNote, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyVaginalPain, currentlyVaginalItching, currentlyNone, useIodizedSalt, takingMedication, planToBreastFeed, birthCompanion, practiceFamilyPlanning, practiceFamilyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryHeartProblems, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyHeartProblems, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, questionnaireNote, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerIncome, partnerIncomePeriod, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (NEW.id, NEW.firstname, NEW.lastname, NEW.maidenname, NEW.nickname, NEW.religion, NEW.maritalStatus, NEW.telephone, NEW.work, NEW.education, NEW.clientIncome, NEW.clientIncomePeriod, NEW.address1, NEW.address2, NEW.address3, NEW.address4, NEW.city, NEW.state, NEW.postalCode, NEW.country, NEW.gravidaNumber, NEW.lmp, NEW.sureLMP, NEW.warning, NEW.riskNote, NEW.alternateEdd, NEW.useAlternateEdd, NEW.doctorConsultDate, NEW.dentistConsultDate, NEW.mbBook, NEW.whereDeliver, NEW.fetuses, NEW.monozygotic, NEW.pregnancyEndDate, NEW.pregnancyEndResult, NEW.iugr, NEW.note, NEW.numberRequiredTetanus, NEW.invertedNipples, NEW.hasUS, NEW.wantsUS, NEW.gravida, NEW.stillBirths, NEW.abortions, NEW.living, NEW.para, NEW.term, NEW.preterm, NEW.philHealthMCP, NEW.philHealthNCP, NEW.philHealthID, NEW.philHealthApproved, NEW.transferOfCare, NEW.transferOfCareNote, NEW.currentlyVomiting, NEW.currentlyDizzy, NEW.currentlyFainting, NEW.currentlyBleeding, NEW.currentlyUrinationPain, NEW.currentlyBlurryVision, NEW.currentlySwelling, NEW.currentlyVaginalPain, NEW.currentlyVaginalItching, NEW.currentlyNone, NEW.useIodizedSalt, NEW.takingMedication, NEW.planToBreastFeed, NEW.birthCompanion, NEW.practiceFamilyPlanning, NEW.practiceFamilyPlanningDetails, NEW.familyHistoryTwins, NEW.familyHistoryHighBloodPressure, NEW.familyHistoryDiabetes, NEW.familyHistoryHeartProblems, NEW.familyHistoryTB, NEW.familyHistorySmoking, NEW.familyHistoryNone, NEW.historyFoodAllergy, NEW.historyMedicineAllergy, NEW.historyAsthma, NEW.historyHeartProblems, NEW.historyKidneyProblems, NEW.historyHepatitis, NEW.historyGoiter, NEW.historyHighBloodPressure, NEW.historyHospitalOperation, NEW.historyBloodTransfusion, NEW.historySmoking, NEW.historyDrinking, NEW.historyNone, NEW.questionnaireNote, NEW.partnerFirstname, NEW.partnerLastname, NEW.partnerAge, NEW.partnerWork, NEW.partnerEducation, NEW.partnerIncome, NEW.partnerIncomePeriod, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.patient_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnancy_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancy_after_delete;
CREATE TRIGGER pregnancy_after_delete AFTER DELETE ON pregnancy
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyLog
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, clientIncome, clientIncomePeriod, address1, address2, address3, address4, city, state, postalCode, country, gravidaNumber, lmp, sureLMP, warning, riskNote, alternateEdd, useAlternateEdd, doctorConsultDate, dentistConsultDate, mbBook, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, transferOfCare, transferOfCareNote, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyVaginalPain, currentlyVaginalItching, currentlyNone, useIodizedSalt, takingMedication, planToBreastFeed, birthCompanion, practiceFamilyPlanning, practiceFamilyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryHeartProblems, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyHeartProblems, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, questionnaireNote, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerIncome, partnerIncomePeriod, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (OLD.id, OLD.firstname, OLD.lastname, OLD.maidenname, OLD.nickname, OLD.religion, OLD.maritalStatus, OLD.telephone, OLD.work, OLD.education, OLD.clientIncome, OLD.clientIncomePeriod, OLD.address1, OLD.address2, OLD.address3, OLD.address4, OLD.city, OLD.state, OLD.postalCode, OLD.country, OLD.gravidaNumber, OLD.lmp, OLD.sureLMP, OLD.warning, OLD.riskNote, OLD.alternateEdd, OLD.useAlternateEdd, OLD.doctorConsultDate, OLD.dentistConsultDate, OLD.mbBook, OLD.whereDeliver, OLD.fetuses, OLD.monozygotic, OLD.pregnancyEndDate, OLD.pregnancyEndResult, OLD.iugr, OLD.note, OLD.numberRequiredTetanus, OLD.invertedNipples, OLD.hasUS, OLD.wantsUS, OLD.gravida, OLD.stillBirths, OLD.abortions, OLD.living, OLD.para, OLD.term, OLD.preterm, OLD.philHealthMCP, OLD.philHealthNCP, OLD.philHealthID, OLD.philHealthApproved, OLD.transferOfCare, OLD.transferOfCareNote, OLD.currentlyVomiting, OLD.currentlyDizzy, OLD.currentlyFainting, OLD.currentlyBleeding, OLD.currentlyUrinationPain, OLD.currentlyBlurryVision, OLD.currentlySwelling, OLD.currentlyVaginalPain, OLD.currentlyVaginalItching, OLD.currentlyNone, OLD.useIodizedSalt, OLD.takingMedication, OLD.planToBreastFeed, OLD.birthCompanion, OLD.practiceFamilyPlanning, OLD.practiceFamilyPlanningDetails, OLD.familyHistoryTwins, OLD.familyHistoryHighBloodPressure, OLD.familyHistoryDiabetes, OLD.familyHistoryHeartProblems, OLD.familyHistoryTB, OLD.familyHistorySmoking, OLD.familyHistoryNone, OLD.historyFoodAllergy, OLD.historyMedicineAllergy, OLD.historyAsthma, OLD.historyHeartProblems, OLD.historyKidneyProblems, OLD.historyHepatitis, OLD.historyGoiter, OLD.historyHighBloodPressure, OLD.historyHospitalOperation, OLD.historyBloodTransfusion, OLD.historySmoking, OLD.historyDrinking, OLD.historyNone, OLD.questionnaireNote, OLD.partnerFirstname, OLD.partnerLastname, OLD.partnerAge, OLD.partnerWork, OLD.partnerEducation, OLD.partnerIncome, OLD.partnerIncomePeriod, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.patient_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnote_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnote_after_insert;
CREATE TRIGGER pregnote_after_insert AFTER INSERT ON pregnote
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteLog
  (id, pregnoteType, noteDate, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.pregnoteType, NEW.noteDate, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnote_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnote_after_update;
CREATE TRIGGER pregnote_after_update AFTER UPDATE ON pregnote
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteLog
  (id, pregnoteType, noteDate, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.pregnoteType, NEW.noteDate, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnote_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnote_after_delete;
CREATE TRIGGER pregnote_after_delete AFTER DELETE ON pregnote
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteLog
  (id, pregnoteType, noteDate, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.pregnoteType, OLD.noteDate, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnoteType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnoteType_after_insert;
CREATE TRIGGER pregnoteType_after_insert AFTER INSERT ON pregnoteType
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteTypeLog
  (id, name, description, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnoteType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnoteType_after_update;
CREATE TRIGGER pregnoteType_after_update AFTER UPDATE ON pregnoteType
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteTypeLog
  (id, name, description, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: pregnoteType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnoteType_after_delete;
CREATE TRIGGER pregnoteType_after_delete AFTER DELETE ON pregnoteType
FOR EACH ROW
BEGIN
  INSERT INTO pregnoteTypeLog
  (id, name, description, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: prenatalExam_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS prenatalExam_after_insert;
CREATE TRIGGER prenatalExam_after_insert AFTER INSERT ON prenatalExam
FOR EACH ROW
BEGIN
  INSERT INTO prenatalExamLog
  (id, date, weight, systolic, diastolic, cr, temperature, respiratoryRate, fh, fhNote, fht, fhtNote, pos, mvmt, edema, risk, vitamin, pray, note, returnDate, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.weight, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temperature, NEW.respiratoryRate, NEW.fh, NEW.fhNote, NEW.fht, NEW.fhtNote, NEW.pos, NEW.mvmt, NEW.edema, NEW.risk, NEW.vitamin, NEW.pray, NEW.note, NEW.returnDate, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: prenatalExam_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS prenatalExam_after_update;
CREATE TRIGGER prenatalExam_after_update AFTER UPDATE ON prenatalExam
FOR EACH ROW
BEGIN
  INSERT INTO prenatalExamLog
  (id, date, weight, systolic, diastolic, cr, temperature, respiratoryRate, fh, fhNote, fht, fhtNote, pos, mvmt, edema, risk, vitamin, pray, note, returnDate, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.weight, NEW.systolic, NEW.diastolic, NEW.cr, NEW.temperature, NEW.respiratoryRate, NEW.fh, NEW.fhNote, NEW.fht, NEW.fhtNote, NEW.pos, NEW.mvmt, NEW.edema, NEW.risk, NEW.vitamin, NEW.pray, NEW.note, NEW.returnDate, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: prenatalExam_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS prenatalExam_after_delete;
CREATE TRIGGER prenatalExam_after_delete AFTER DELETE ON prenatalExam
FOR EACH ROW
BEGIN
  INSERT INTO prenatalExamLog
  (id, date, weight, systolic, diastolic, cr, temperature, respiratoryRate, fh, fhNote, fht, fhtNote, pos, mvmt, edema, risk, vitamin, pray, note, returnDate, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.weight, OLD.systolic, OLD.diastolic, OLD.cr, OLD.temperature, OLD.respiratoryRate, OLD.fh, OLD.fhNote, OLD.fht, OLD.fhtNote, OLD.pos, OLD.mvmt, OLD.edema, OLD.risk, OLD.vitamin, OLD.pray, OLD.note, OLD.returnDate, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: referral_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS referral_after_insert;
CREATE TRIGGER referral_after_insert AFTER INSERT ON referral
FOR EACH ROW
BEGIN
  INSERT INTO referralLog
  (id, date, referral, reason, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.referral, NEW.reason, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: referral_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS referral_after_update;
CREATE TRIGGER referral_after_update AFTER UPDATE ON referral
FOR EACH ROW
BEGIN
  INSERT INTO referralLog
  (id, date, referral, reason, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.referral, NEW.reason, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: referral_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS referral_after_delete;
CREATE TRIGGER referral_after_delete AFTER DELETE ON referral
FOR EACH ROW
BEGIN
  INSERT INTO referralLog
  (id, date, referral, reason, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.referral, OLD.reason, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: risk_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS risk_after_insert;
CREATE TRIGGER risk_after_insert AFTER INSERT ON risk
FOR EACH ROW
BEGIN
  INSERT INTO riskLog
  (id, pregnancy_id, riskCode, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.pregnancy_id, NEW.riskCode, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: risk_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS risk_after_update;
CREATE TRIGGER risk_after_update AFTER UPDATE ON risk
FOR EACH ROW
BEGIN
  INSERT INTO riskLog
  (id, pregnancy_id, riskCode, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.pregnancy_id, NEW.riskCode, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: risk_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS risk_after_delete;
CREATE TRIGGER risk_after_delete AFTER DELETE ON risk
FOR EACH ROW
BEGIN
  INSERT INTO riskLog
  (id, pregnancy_id, riskCode, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.pregnancy_id, OLD.riskCode, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: role_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS role_after_insert;
CREATE TRIGGER role_after_insert AFTER INSERT ON role
FOR EACH ROW
BEGIN
  INSERT INTO roleLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: role_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS role_after_update;
CREATE TRIGGER role_after_update AFTER UPDATE ON role
FOR EACH ROW
BEGIN
  INSERT INTO roleLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: role_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS role_after_delete;
CREATE TRIGGER role_after_delete AFTER DELETE ON role
FOR EACH ROW
BEGIN
  INSERT INTO roleLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: schedule_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS schedule_after_insert;
CREATE TRIGGER schedule_after_insert AFTER INSERT ON schedule
FOR EACH ROW
BEGIN
  INSERT INTO scheduleLog
  (id, scheduleType, location, day, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.scheduleType, NEW.location, NEW.day, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: schedule_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS schedule_after_update;
CREATE TRIGGER schedule_after_update AFTER UPDATE ON schedule
FOR EACH ROW
BEGIN
  INSERT INTO scheduleLog
  (id, scheduleType, location, day, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.scheduleType, NEW.location, NEW.day, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: schedule_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS schedule_after_delete;
CREATE TRIGGER schedule_after_delete AFTER DELETE ON schedule
FOR EACH ROW
BEGIN
  INSERT INTO scheduleLog
  (id, scheduleType, location, day, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.scheduleType, OLD.location, OLD.day, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: selectData_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS selectData_after_insert;
CREATE TRIGGER selectData_after_insert AFTER INSERT ON selectData
FOR EACH ROW
BEGIN
  INSERT INTO selectDataLog
  (id, name, selectKey, label, selected, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.selectKey, NEW.label, NEW.selected, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: selectData_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS selectData_after_update;
CREATE TRIGGER selectData_after_update AFTER UPDATE ON selectData
FOR EACH ROW
BEGIN
  INSERT INTO selectDataLog
  (id, name, selectKey, label, selected, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.selectKey, NEW.label, NEW.selected, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: selectData_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS selectData_after_delete;
CREATE TRIGGER selectData_after_delete AFTER DELETE ON selectData
FOR EACH ROW
BEGIN
  INSERT INTO selectDataLog
  (id, name, selectKey, label, selected, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.selectKey, OLD.label, OLD.selected, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: user_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS user_after_insert;
CREATE TRIGGER user_after_insert AFTER INSERT ON user
FOR EACH ROW
BEGIN
  INSERT INTO userLog
  (id, username, firstname, lastname, password, email, lang, shortName, displayName, status, note, isCurrentTeacher, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.username, NEW.firstname, NEW.lastname, NEW.password, NEW.email, NEW.lang, NEW.shortName, NEW.displayName, NEW.status, NEW.note, NEW.isCurrentTeacher, NEW.role_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: user_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS user_after_update;
CREATE TRIGGER user_after_update AFTER UPDATE ON user
FOR EACH ROW
BEGIN
  INSERT INTO userLog
  (id, username, firstname, lastname, password, email, lang, shortName, displayName, status, note, isCurrentTeacher, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.username, NEW.firstname, NEW.lastname, NEW.password, NEW.email, NEW.lang, NEW.shortName, NEW.displayName, NEW.status, NEW.note, NEW.isCurrentTeacher, NEW.role_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: user_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS user_after_delete;
CREATE TRIGGER user_after_delete AFTER DELETE ON user
FOR EACH ROW
BEGIN
  INSERT INTO userLog
  (id, username, firstname, lastname, password, email, lang, shortName, displayName, status, note, isCurrentTeacher, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.username, OLD.firstname, OLD.lastname, OLD.password, OLD.email, OLD.lang, OLD.shortName, OLD.displayName, OLD.status, OLD.note, OLD.isCurrentTeacher, OLD.role_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: vaccination_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccination_after_insert;
CREATE TRIGGER vaccination_after_insert AFTER INSERT ON vaccination
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationLog
  (id, vaccinationType, vacDate, vacMonth, vacYear, administeredInternally, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.vaccinationType, NEW.vacDate, NEW.vacMonth, NEW.vacYear, NEW.administeredInternally, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: vaccination_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccination_after_update;
CREATE TRIGGER vaccination_after_update AFTER UPDATE ON vaccination
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationLog
  (id, vaccinationType, vacDate, vacMonth, vacYear, administeredInternally, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.vaccinationType, NEW.vacDate, NEW.vacMonth, NEW.vacYear, NEW.administeredInternally, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: vaccination_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccination_after_delete;
CREATE TRIGGER vaccination_after_delete AFTER DELETE ON vaccination
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationLog
  (id, vaccinationType, vacDate, vacMonth, vacYear, administeredInternally, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.vaccinationType, OLD.vacDate, OLD.vacMonth, OLD.vacYear, OLD.administeredInternally, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: vaccinationType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccinationType_after_insert;
CREATE TRIGGER vaccinationType_after_insert AFTER INSERT ON vaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: vaccinationType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccinationType_after_update;
CREATE TRIGGER vaccinationType_after_update AFTER UPDATE ON vaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.sortOrder, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ;
 
-- ---------------------------------------------------------------
-- Trigger: vaccinationType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS vaccinationType_after_delete;
CREATE TRIGGER vaccinationType_after_delete AFTER DELETE ON vaccinationType
FOR EACH ROW
BEGIN
  INSERT INTO vaccinationTypeLog
  (id, name, description, sortOrder, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.sortOrder, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ;
