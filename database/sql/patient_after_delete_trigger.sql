DELIMITER $$

DROP TRIGGER IF EXISTS patient_after_delete;

CREATE TRIGGER patient_after_delete AFTER DELETE ON patient
FOR EACH ROW
BEGIN
  INSERT INTO patientLog
  (id, dohID, dob, generalInfo, ageOfMenarche, updatedBy, updatedAt, supervisor, op)
  VALUES (
    OLD.id,
    OLD.dohID,
    OLD.dob,
    OLD.generalInfo,
    OLD.ageOfMenarche,
    OLD.updatedBy,
    OLD.updatedAt,
    OLD.supervisor,
    'D'
  );
END;$$

DELIMITER ;

