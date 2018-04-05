-- Migration: laborStage3 changes
-- Created at: 2018-03-12 15:04:10
-- ====  UP  ====

BEGIN;

ALTER TABLE laborStage3 DROP COLUMN placentaMembranesComplete;
ALTER TABLE laborStage3 DROP COLUMN placentaOther;
ALTER TABLE laborStage3 ADD COLUMN cotyledons VARCHAR(200) NULL AFTER schultzDuncan;
ALTER TABLE laborStage3 ADD COLUMN membranes VARCHAR(200) NULL AFTER cotyledons;
ALTER TABLE laborStage3Log DROP COLUMN placentaMembranesComplete;
ALTER TABLE laborStage3Log DROP COLUMN placentaOther;
ALTER TABLE laborStage3Log ADD COLUMN cotyledons VARCHAR(200) NULL AFTER schultzDuncan;
ALTER TABLE laborStage3Log ADD COLUMN membranes VARCHAR(200) NULL AFTER cotyledons;

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

COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE laborStage3 DROP COLUMN membranes;
ALTER TABLE laborStage3Log DROP COLUMN membranes;
ALTER TABLE laborStage3 DROP COLUMN cotyledons;
ALTER TABLE laborStage3Log DROP COLUMN cotyledons;
ALTER TABLE laborStage3 ADD COLUMN placentaMembranesComplete BOOLEAN NULL AFTER schultzDuncan;
ALTER TABLE laborStage3Log ADD COLUMN placentaMembranesComplete BOOLEAN NULL AFTER schultzDuncan;
ALTER TABLE laborStage3 ADD COLUMN placentaOther BOOLEAN NULL AFTER placentaMembranesComplete;
ALTER TABLE laborStage3Log ADD COLUMN placentaOther BOOLEAN NULL AFTER placentaMembranesComplete;

-- ---------------------------------------------------------------
-- Trigger: laborStage3_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage3_after_insert;
CREATE TRIGGER laborStage3_after_insert AFTER INSERT ON laborStage3
FOR EACH ROW
BEGIN
  INSERT INTO laborStage3Log
  (id, placentaDatetime, placentaDeliverySpontaneous, placentaDeliveryAMTSL, placentaDeliveryCCT, placentaDeliveryManual, maternalPosition, txBloodLoss1, txBloodLoss2, txBloodLoss3, txBloodLoss4, txBloodLoss5, placentaShape, placentaInsertion, placentaNumVessels, schultzDuncan, placentaMembranesComplete, placentaOther, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.placentaDatetime, NEW.placentaDeliverySpontaneous, NEW.placentaDeliveryAMTSL, NEW.placentaDeliveryCCT, NEW.placentaDeliveryManual, NEW.maternalPosition, NEW.txBloodLoss1, NEW.txBloodLoss2, NEW.txBloodLoss3, NEW.txBloodLoss4, NEW.txBloodLoss5, NEW.placentaShape, NEW.placentaInsertion, NEW.placentaNumVessels, NEW.schultzDuncan, NEW.placentaMembranesComplete, NEW.placentaOther, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
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
  (id, placentaDatetime, placentaDeliverySpontaneous, placentaDeliveryAMTSL, placentaDeliveryCCT, placentaDeliveryManual, maternalPosition, txBloodLoss1, txBloodLoss2, txBloodLoss3, txBloodLoss4, txBloodLoss5, placentaShape, placentaInsertion, placentaNumVessels, schultzDuncan, placentaMembranesComplete, placentaOther, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.placentaDatetime, NEW.placentaDeliverySpontaneous, NEW.placentaDeliveryAMTSL, NEW.placentaDeliveryCCT, NEW.placentaDeliveryManual, NEW.maternalPosition, NEW.txBloodLoss1, NEW.txBloodLoss2, NEW.txBloodLoss3, NEW.txBloodLoss4, NEW.txBloodLoss5, NEW.placentaShape, NEW.placentaInsertion, NEW.placentaNumVessels, NEW.schultzDuncan, NEW.placentaMembranesComplete, NEW.placentaOther, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
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
  (id, placentaDatetime, placentaDeliverySpontaneous, placentaDeliveryAMTSL, placentaDeliveryCCT, placentaDeliveryManual, maternalPosition, txBloodLoss1, txBloodLoss2, txBloodLoss3, txBloodLoss4, txBloodLoss5, placentaShape, placentaInsertion, placentaNumVessels, schultzDuncan, placentaMembranesComplete, placentaOther, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.placentaDatetime, OLD.placentaDeliverySpontaneous, OLD.placentaDeliveryAMTSL, OLD.placentaDeliveryCCT, OLD.placentaDeliveryManual, OLD.maternalPosition, OLD.txBloodLoss1, OLD.txBloodLoss2, OLD.txBloodLoss3, OLD.txBloodLoss4, OLD.txBloodLoss5, OLD.placentaShape, OLD.placentaInsertion, OLD.placentaNumVessels, OLD.schultzDuncan, OLD.placentaMembranesComplete, OLD.placentaOther, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;

COMMIT;
