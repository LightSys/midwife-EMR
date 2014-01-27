DELIMITER $$

DROP TRIGGER IF EXISTS patient_after_update;

CREATE TRIGGER patient_after_update AFTER UPDATE ON patient
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
    'U'
  );
END;$$

DELIMITER ;

