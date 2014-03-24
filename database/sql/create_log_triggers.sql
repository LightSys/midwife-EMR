 
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
-- Trigger: labResult_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labResult_after_insert;
CREATE TRIGGER labResult_after_insert AFTER INSERT ON labResult
FOR EACH ROW
BEGIN
  INSERT INTO labResultLog
  (id, labTest_id, date, result, warn, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.labTest_id, NEW.date, NEW.result, NEW.warn, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: labResult_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labResult_after_update;
CREATE TRIGGER labResult_after_update AFTER UPDATE ON labResult
FOR EACH ROW
BEGIN
  INSERT INTO labResultLog
  (id, labTest_id, date, result, warn, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.labTest_id, NEW.date, NEW.result, NEW.warn, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: labResult_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS labResult_after_delete;
CREATE TRIGGER labResult_after_delete AFTER DELETE ON labResult
FOR EACH ROW
BEGIN
  INSERT INTO labResultLog
  (id, labTest_id, date, result, warn, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.labTest_id, OLD.date, OLD.result, OLD.warn, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
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
  (id, name, description, resultFormat, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.resultFormat, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
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
  (id, name, description, resultFormat, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.resultFormat, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
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
  (id, name, description, resultFormat, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.resultFormat, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
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
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
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
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
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
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
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
-- Trigger: pregnancyHistory_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS pregnancyHistory_after_insert;
CREATE TRIGGER pregnancyHistory_after_insert AFTER INSERT ON pregnancyHistory
FOR EACH ROW
BEGIN
  INSERT INTO pregnancyHistoryLog
  (id, month, year, weeksGA, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.month, NEW.year, NEW.weeksGA, NEW.sexOfBaby, NEW.placeOfBirth, NEW.attendant, NEW.typeOfDelivery, NEW.lengthOfLabor, NEW.birthWeight, NEW.episTear, NEW.repaired, NEW.howLongBFed, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
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
  (id, month, year, weeksGA, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.month, NEW.year, NEW.weeksGA, NEW.sexOfBaby, NEW.placeOfBirth, NEW.attendant, NEW.typeOfDelivery, NEW.lengthOfLabor, NEW.birthWeight, NEW.episTear, NEW.repaired, NEW.howLongBFed, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
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
  (id, month, year, weeksGA, sexOfBaby, placeOfBirth, attendant, typeOfDelivery, lengthOfLabor, birthWeight, episTear, repaired, howLongBFed, note, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.month, OLD.year, OLD.weeksGA, OLD.sexOfBaby, OLD.placeOfBirth, OLD.attendant, OLD.typeOfDelivery, OLD.lengthOfLabor, OLD.birthWeight, OLD.episTear, OLD.repaired, OLD.howLongBFed, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
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
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, monthlyIncome, address, barangay, city, postalCode, gravidaNumber, lmp, warning, edd, additionalEdd, useAdditionalEdd, doctorConsultDate, dentistConsultDate, mbBook, iodizedSalt, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyBirthCanalPain, currentlyNone, useIodizedSalt, canDrinkMedicine, planToBreastFeed, birthCompanion, practiceFamilyPlanning, familyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryChestPains, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyChestPains, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerMonthlyIncome, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (NEW.id, NEW.firstname, NEW.lastname, NEW.maidenname, NEW.nickname, NEW.religion, NEW.maritalStatus, NEW.telephone, NEW.work, NEW.education, NEW.monthlyIncome, NEW.address, NEW.barangay, NEW.city, NEW.postalCode, NEW.gravidaNumber, NEW.lmp, NEW.warning, NEW.edd, NEW.additionalEdd, NEW.useAdditionalEdd, NEW.doctorConsultDate, NEW.dentistConsultDate, NEW.mbBook, NEW.iodizedSalt, NEW.whereDeliver, NEW.fetuses, NEW.monozygotic, NEW.pregnancyEndDate, NEW.pregnancyEndResult, NEW.iugr, NEW.note, NEW.numberRequiredTetanus, NEW.invertedNipples, NEW.hasUS, NEW.wantsUS, NEW.gravida, NEW.stillBirths, NEW.abortions, NEW.living, NEW.para, NEW.term, NEW.preterm, NEW.philHealthMCP, NEW.philHealthNCP, NEW.philHealthID, NEW.philHealthApproved, NEW.currentlyVomiting, NEW.currentlyDizzy, NEW.currentlyFainting, NEW.currentlyBleeding, NEW.currentlyUrinationPain, NEW.currentlyBlurryVision, NEW.currentlySwelling, NEW.currentlyBirthCanalPain, NEW.currentlyNone, NEW.useIodizedSalt, NEW.canDrinkMedicine, NEW.planToBreastFeed, NEW.birthCompanion, NEW.practiceFamilyPlanning, NEW.familyPlanningDetails, NEW.familyHistoryTwins, NEW.familyHistoryHighBloodPressure, NEW.familyHistoryDiabetes, NEW.familyHistoryChestPains, NEW.familyHistoryTB, NEW.familyHistorySmoking, NEW.familyHistoryNone, NEW.historyFoodAllergy, NEW.historyMedicineAllergy, NEW.historyAsthma, NEW.historyChestPains, NEW.historyKidneyProblems, NEW.historyHepatitis, NEW.historyGoiter, NEW.historyHighBloodPressure, NEW.historyHospitalOperation, NEW.historyBloodTransfusion, NEW.historySmoking, NEW.historyDrinking, NEW.historyNone, NEW.partnerFirstname, NEW.partnerLastname, NEW.partnerAge, NEW.partnerWork, NEW.partnerEducation, NEW.partnerMonthlyIncome, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.patient_id, "I", NOW());
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
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, monthlyIncome, address, barangay, city, postalCode, gravidaNumber, lmp, warning, edd, additionalEdd, useAdditionalEdd, doctorConsultDate, dentistConsultDate, mbBook, iodizedSalt, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyBirthCanalPain, currentlyNone, useIodizedSalt, canDrinkMedicine, planToBreastFeed, birthCompanion, practiceFamilyPlanning, familyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryChestPains, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyChestPains, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerMonthlyIncome, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (NEW.id, NEW.firstname, NEW.lastname, NEW.maidenname, NEW.nickname, NEW.religion, NEW.maritalStatus, NEW.telephone, NEW.work, NEW.education, NEW.monthlyIncome, NEW.address, NEW.barangay, NEW.city, NEW.postalCode, NEW.gravidaNumber, NEW.lmp, NEW.warning, NEW.edd, NEW.additionalEdd, NEW.useAdditionalEdd, NEW.doctorConsultDate, NEW.dentistConsultDate, NEW.mbBook, NEW.iodizedSalt, NEW.whereDeliver, NEW.fetuses, NEW.monozygotic, NEW.pregnancyEndDate, NEW.pregnancyEndResult, NEW.iugr, NEW.note, NEW.numberRequiredTetanus, NEW.invertedNipples, NEW.hasUS, NEW.wantsUS, NEW.gravida, NEW.stillBirths, NEW.abortions, NEW.living, NEW.para, NEW.term, NEW.preterm, NEW.philHealthMCP, NEW.philHealthNCP, NEW.philHealthID, NEW.philHealthApproved, NEW.currentlyVomiting, NEW.currentlyDizzy, NEW.currentlyFainting, NEW.currentlyBleeding, NEW.currentlyUrinationPain, NEW.currentlyBlurryVision, NEW.currentlySwelling, NEW.currentlyBirthCanalPain, NEW.currentlyNone, NEW.useIodizedSalt, NEW.canDrinkMedicine, NEW.planToBreastFeed, NEW.birthCompanion, NEW.practiceFamilyPlanning, NEW.familyPlanningDetails, NEW.familyHistoryTwins, NEW.familyHistoryHighBloodPressure, NEW.familyHistoryDiabetes, NEW.familyHistoryChestPains, NEW.familyHistoryTB, NEW.familyHistorySmoking, NEW.familyHistoryNone, NEW.historyFoodAllergy, NEW.historyMedicineAllergy, NEW.historyAsthma, NEW.historyChestPains, NEW.historyKidneyProblems, NEW.historyHepatitis, NEW.historyGoiter, NEW.historyHighBloodPressure, NEW.historyHospitalOperation, NEW.historyBloodTransfusion, NEW.historySmoking, NEW.historyDrinking, NEW.historyNone, NEW.partnerFirstname, NEW.partnerLastname, NEW.partnerAge, NEW.partnerWork, NEW.partnerEducation, NEW.partnerMonthlyIncome, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.patient_id, "U", NOW());
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
  (id, firstname, lastname, maidenname, nickname, religion, maritalStatus, telephone, work, education, monthlyIncome, address, barangay, city, postalCode, gravidaNumber, lmp, warning, edd, additionalEdd, useAdditionalEdd, doctorConsultDate, dentistConsultDate, mbBook, iodizedSalt, whereDeliver, fetuses, monozygotic, pregnancyEndDate, pregnancyEndResult, iugr, note, numberRequiredTetanus, invertedNipples, hasUS, wantsUS, gravida, stillBirths, abortions, living, para, term, preterm, philHealthMCP, philHealthNCP, philHealthID, philHealthApproved, currentlyVomiting, currentlyDizzy, currentlyFainting, currentlyBleeding, currentlyUrinationPain, currentlyBlurryVision, currentlySwelling, currentlyBirthCanalPain, currentlyNone, useIodizedSalt, canDrinkMedicine, planToBreastFeed, birthCompanion, practiceFamilyPlanning, familyPlanningDetails, familyHistoryTwins, familyHistoryHighBloodPressure, familyHistoryDiabetes, familyHistoryChestPains, familyHistoryTB, familyHistorySmoking, familyHistoryNone, historyFoodAllergy, historyMedicineAllergy, historyAsthma, historyChestPains, historyKidneyProblems, historyHepatitis, historyGoiter, historyHighBloodPressure, historyHospitalOperation, historyBloodTransfusion, historySmoking, historyDrinking, historyNone, partnerFirstname, partnerLastname, partnerAge, partnerWork, partnerEducation, partnerMonthlyIncome, updatedBy, updatedAt, supervisor, patient_id, op, replacedAt)
  VALUES (OLD.id, OLD.firstname, OLD.lastname, OLD.maidenname, OLD.nickname, OLD.religion, OLD.maritalStatus, OLD.telephone, OLD.work, OLD.education, OLD.monthlyIncome, OLD.address, OLD.barangay, OLD.city, OLD.postalCode, OLD.gravidaNumber, OLD.lmp, OLD.warning, OLD.edd, OLD.additionalEdd, OLD.useAdditionalEdd, OLD.doctorConsultDate, OLD.dentistConsultDate, OLD.mbBook, OLD.iodizedSalt, OLD.whereDeliver, OLD.fetuses, OLD.monozygotic, OLD.pregnancyEndDate, OLD.pregnancyEndResult, OLD.iugr, OLD.note, OLD.numberRequiredTetanus, OLD.invertedNipples, OLD.hasUS, OLD.wantsUS, OLD.gravida, OLD.stillBirths, OLD.abortions, OLD.living, OLD.para, OLD.term, OLD.preterm, OLD.philHealthMCP, OLD.philHealthNCP, OLD.philHealthID, OLD.philHealthApproved, OLD.currentlyVomiting, OLD.currentlyDizzy, OLD.currentlyFainting, OLD.currentlyBleeding, OLD.currentlyUrinationPain, OLD.currentlyBlurryVision, OLD.currentlySwelling, OLD.currentlyBirthCanalPain, OLD.currentlyNone, OLD.useIodizedSalt, OLD.canDrinkMedicine, OLD.planToBreastFeed, OLD.birthCompanion, OLD.practiceFamilyPlanning, OLD.familyPlanningDetails, OLD.familyHistoryTwins, OLD.familyHistoryHighBloodPressure, OLD.familyHistoryDiabetes, OLD.familyHistoryChestPains, OLD.familyHistoryTB, OLD.familyHistorySmoking, OLD.familyHistoryNone, OLD.historyFoodAllergy, OLD.historyMedicineAllergy, OLD.historyAsthma, OLD.historyChestPains, OLD.historyKidneyProblems, OLD.historyHepatitis, OLD.historyGoiter, OLD.historyHighBloodPressure, OLD.historyHospitalOperation, OLD.historyBloodTransfusion, OLD.historySmoking, OLD.historyDrinking, OLD.historyNone, OLD.partnerFirstname, OLD.partnerLastname, OLD.partnerAge, OLD.partnerWork, OLD.partnerEducation, OLD.partnerMonthlyIncome, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.patient_id, "D", NOW());
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
  (id, date, weight, systolic, diastolic, cr, fh, fht, fhtNote, pos, mvmt, edma, risk, vitamin, pray, note, returnDate, checkin, checkout, chartPulled, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.weight, NEW.systolic, NEW.diastolic, NEW.cr, NEW.fh, NEW.fht, NEW.fhtNote, NEW.pos, NEW.mvmt, NEW.edma, NEW.risk, NEW.vitamin, NEW.pray, NEW.note, NEW.returnDate, NEW.checkin, NEW.checkout, NEW.chartPulled, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "I", NOW());
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
  (id, date, weight, systolic, diastolic, cr, fh, fht, fhtNote, pos, mvmt, edma, risk, vitamin, pray, note, returnDate, checkin, checkout, chartPulled, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (NEW.id, NEW.date, NEW.weight, NEW.systolic, NEW.diastolic, NEW.cr, NEW.fh, NEW.fht, NEW.fhtNote, NEW.pos, NEW.mvmt, NEW.edma, NEW.risk, NEW.vitamin, NEW.pray, NEW.note, NEW.returnDate, NEW.checkin, NEW.checkout, NEW.chartPulled, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.pregnancy_id, "U", NOW());
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
  (id, date, weight, systolic, diastolic, cr, fh, fht, fhtNote, pos, mvmt, edma, risk, vitamin, pray, note, returnDate, checkin, checkout, chartPulled, updatedBy, updatedAt, supervisor, pregnancy_id, op, replacedAt)
  VALUES (OLD.id, OLD.date, OLD.weight, OLD.systolic, OLD.diastolic, OLD.cr, OLD.fh, OLD.fht, OLD.fhtNote, OLD.pos, OLD.mvmt, OLD.edma, OLD.risk, OLD.vitamin, OLD.pray, OLD.note, OLD.returnDate, OLD.checkin, OLD.checkout, OLD.chartPulled, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.pregnancy_id, "D", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: priority_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS priority_after_insert;
CREATE TRIGGER priority_after_insert AFTER INSERT ON priority
FOR EACH ROW
BEGIN
  INSERT INTO priorityLog
  (id, priority, ptype, updatedBy, updatedAt, supervisor, prenatalExam_id, op, replacedAt)
  VALUES (NEW.id, NEW.priority, NEW.ptype, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.prenatalExam_id, "I", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: priority_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS priority_after_update;
CREATE TRIGGER priority_after_update AFTER UPDATE ON priority
FOR EACH ROW
BEGIN
  INSERT INTO priorityLog
  (id, priority, ptype, updatedBy, updatedAt, supervisor, prenatalExam_id, op, replacedAt)
  VALUES (NEW.id, NEW.priority, NEW.ptype, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.prenatalExam_id, "U", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: priority_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS priority_after_delete;
CREATE TRIGGER priority_after_delete AFTER DELETE ON priority
FOR EACH ROW
BEGIN
  INSERT INTO priorityLog
  (id, priority, ptype, updatedBy, updatedAt, supervisor, prenatalExam_id, op, replacedAt)
  VALUES (OLD.id, OLD.priority, OLD.ptype, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.prenatalExam_id, "D", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: priorityType_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS priorityType_after_insert;
CREATE TRIGGER priorityType_after_insert AFTER INSERT ON priorityType
FOR EACH ROW
BEGIN
  INSERT INTO priorityTypeLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: priorityType_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS priorityType_after_update;
CREATE TRIGGER priorityType_after_update AFTER UPDATE ON priorityType
FOR EACH ROW
BEGIN
  INSERT INTO priorityTypeLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: priorityType_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS priorityType_after_delete;
CREATE TRIGGER priorityType_after_delete AFTER DELETE ON priorityType
FOR EACH ROW
BEGIN
  INSERT INTO priorityTypeLog
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
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
  (id, username, firstname, lastname, password, email, lang, status, note, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.username, NEW.firstname, NEW.lastname, NEW.password, NEW.email, NEW.lang, NEW.status, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
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
  (id, username, firstname, lastname, password, email, lang, status, note, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.username, NEW.firstname, NEW.lastname, NEW.password, NEW.email, NEW.lang, NEW.status, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
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
  (id, username, firstname, lastname, password, email, lang, status, note, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.username, OLD.firstname, OLD.lastname, OLD.password, OLD.email, OLD.lang, OLD.status, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: user_role_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS user_role_after_insert;
CREATE TRIGGER user_role_after_insert AFTER INSERT ON user_role
FOR EACH ROW
BEGIN
  INSERT INTO user_roleLog
  (id, user_id, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.user_id, NEW.role_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: user_role_after_update
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS user_role_after_update;
CREATE TRIGGER user_role_after_update AFTER UPDATE ON user_role
FOR EACH ROW
BEGIN
  INSERT INTO user_roleLog
  (id, user_id, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.user_id, NEW.role_id, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
END;$$
DELIMITER ; 
 
-- ---------------------------------------------------------------
-- Trigger: user_role_after_delete
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS user_role_after_delete;
CREATE TRIGGER user_role_after_delete AFTER DELETE ON user_role
FOR EACH ROW
BEGIN
  INSERT INTO user_roleLog
  (id, user_id, role_id, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.user_id, OLD.role_id, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
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
  (id, vaccinationType, vacDate, vacMonth, vacYEAR, administeredInternally, note, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.vaccinationType, NEW.vacDate, NEW.vacMonth, NEW.vacYEAR, NEW.administeredInternally, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
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
  (id, vaccinationType, vacDate, vacMonth, vacYEAR, administeredInternally, note, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.vaccinationType, NEW.vacDate, NEW.vacMonth, NEW.vacYEAR, NEW.administeredInternally, NEW.note, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
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
  (id, vaccinationType, vacDate, vacMonth, vacYEAR, administeredInternally, note, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.vaccinationType, OLD.vacDate, OLD.vacMonth, OLD.vacYEAR, OLD.administeredInternally, OLD.note, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
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
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "I", NOW());
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
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (NEW.id, NEW.name, NEW.description, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, "U", NOW());
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
  (id, name, description, updatedBy, updatedAt, supervisor, op, replacedAt)
  VALUES (OLD.id, OLD.name, OLD.description, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, "D", NOW());
END;$$
DELIMITER ; 
