-- Migration: Labor Stage 3
-- Created at: 2017-11-21 18:20:37
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `laborStage3` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  placentaDatetime DATETIME NULL,
  placentaDeliverySpontaneous BOOLEAN NULL,
  placentaDeliveryAMTSL BOOLEAN NULL,
  placentaDeliveryCCT BOOLEAN NULL,
  placentaDeliveryManual BOOLEAN NULL,
  maternalPosition VARCHAR(50) NULL,
  txBloodLoss1 VARCHAR(50) NULL,
  txBloodLoss2 VARCHAR(50) NULL,
  txBloodLoss3 VARCHAR(50) NULL,
  txBloodLoss4 VARCHAR(50) NULL,
  txBloodLoss5 VARCHAR(50) NULL,
  placentaShape VARCHAR(50) NULL,
  placentaInsertion VARCHAR(50) NULL,
  placentaNumVessels INT NULL,
  schultzDuncan ENUM('Schultz', 'Duncan') NULL,
  placentaMembranesComplete BOOLEAN NULL,
  placentaOther VARCHAR(100) NULL,
  comments VARCHAR(500) NULL,
  updatedBy INT NOT NULL,
  updatedAt DATETIME NOT NULL,
  supervisor INT NULL,
  labor_id INT NOT NULL,
  UNIQUE(labor_id),
  FOREIGN KEY (labor_id) REFERENCES labor (id) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (updatedBy) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

SELECT 'laborStage3Log' AS Creating FROM DUAL;
CREATE TABLE laborStage3Log LIKE laborStage3;
ALTER TABLE laborStage3Log ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE laborStage3Log ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE laborStage3Log MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE laborStage3Log DROP PRIMARY KEY;
ALTER TABLE laborStage3Log ADD PRIMARY KEY (id, replacedAt);
ALTER TABLE laborStage3Log DROP KEY labor_id;

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

INSERT INTO `selectData`
  (name, selectKey, label, selected, updatedBy, updatedAt)
VALUES
  ('stage3TxBloodLoss', 'Oxytocin', 'Oxytocin', 0, 1, NOW()),
  ('stage3TxBloodLoss', 'IV', 'IV', 0, 1, NOW()),
  ('stage3TxBloodLoss', 'Bi-Manual Compression External/Internal', 'Bi-Manual Compression External/Internal', 0, 1, NOW())
;

COMMIT;

-- ==== DOWN ====

BEGIN;

DELETE FROM selectData WHERE name = 'stage3TxBloodLoss';
DROP TABLE laborStage3Log;
DROP TABLE laborStage3;

COMMIT;
