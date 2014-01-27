DELIMITER $$

DROP TRIGGER IF EXISTS patient_after_insert;

CREATE TRIGGER patient_after_insert AFTER INSERT ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op)
  VALUES (
    NEW.id,
    NEW.dohID,
    NEW.dob,
    NEW.generalInfo,
    NEW.ageOfMenarche,
    NEW.updatedBy,
    NEW.updatedAt,
    NEW.supervisor,
    'I'
  );
END;$$

DELIMITER ;

