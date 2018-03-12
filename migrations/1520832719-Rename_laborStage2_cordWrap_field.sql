-- Migration: Rename laborStage2 cordWrap field
-- Created at: 2018-03-12 13:31:59
-- ====  UP  ====

BEGIN;

ALTER TABLE laborStage2 CHANGE cordWrap terminalMec BOOLEAN NULL;
ALTER TABLE laborStage2Log CHANGE cordWrap terminalMec BOOLEAN NULL;

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

COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE laborStage2Log CHANGE terminalMec cordWrap BOOLEAN NULL;
ALTER TABLE laborStage2 CHANGE terminalMec cordWrap BOOLEAN NULL;

-- ---------------------------------------------------------------
-- Trigger: laborStage2_after_insert
-- ---------------------------------------------------------------
DELIMITER $$
DROP TRIGGER IF EXISTS laborStage2_after_insert;
CREATE TRIGGER laborStage2_after_insert AFTER INSERT ON laborStage2
FOR EACH ROW
BEGIN
  INSERT INTO laborStage2Log
  (id, birthDatetime, birthType, birthPosition, durationPushing, birthPresentation, cordWrap, cordWrapType, deliveryType, shoulderDystocia, shoulderDystociaMinutes, laceration, episiotomy, repair, degree, lacerationRepairedBy, birthEBL, meconium, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthDatetime, NEW.birthType, NEW.birthPosition, NEW.durationPushing, NEW.birthPresentation, NEW.cordWrap, NEW.cordWrapType, NEW.deliveryType, NEW.shoulderDystocia, NEW.shoulderDystociaMinutes, NEW.laceration, NEW.episiotomy, NEW.repair, NEW.degree, NEW.lacerationRepairedBy, NEW.birthEBL, NEW.meconium, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "I", NOW());
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
  (id, birthDatetime, birthType, birthPosition, durationPushing, birthPresentation, cordWrap, cordWrapType, deliveryType, shoulderDystocia, shoulderDystociaMinutes, laceration, episiotomy, repair, degree, lacerationRepairedBy, birthEBL, meconium, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (NEW.id, NEW.birthDatetime, NEW.birthType, NEW.birthPosition, NEW.durationPushing, NEW.birthPresentation, NEW.cordWrap, NEW.cordWrapType, NEW.deliveryType, NEW.shoulderDystocia, NEW.shoulderDystociaMinutes, NEW.laceration, NEW.episiotomy, NEW.repair, NEW.degree, NEW.lacerationRepairedBy, NEW.birthEBL, NEW.meconium, NEW.comments, NEW.updatedBy, NEW.updatedAt, NEW.supervisor, NEW.labor_id, "U", NOW());
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
  (id, birthDatetime, birthType, birthPosition, durationPushing, birthPresentation, cordWrap, cordWrapType, deliveryType, shoulderDystocia, shoulderDystociaMinutes, laceration, episiotomy, repair, degree, lacerationRepairedBy, birthEBL, meconium, comments, updatedBy, updatedAt, supervisor, labor_id, op, replacedAt)
  VALUES (OLD.id, OLD.birthDatetime, OLD.birthType, OLD.birthPosition, OLD.durationPushing, OLD.birthPresentation, OLD.cordWrap, OLD.cordWrapType, OLD.deliveryType, OLD.shoulderDystocia, OLD.shoulderDystociaMinutes, OLD.laceration, OLD.episiotomy, OLD.repair, OLD.degree, OLD.lacerationRepairedBy, OLD.birthEBL, OLD.meconium, OLD.comments, OLD.updatedBy, OLD.updatedAt, OLD.supervisor, OLD.labor_id, "D", NOW());
END;$$
DELIMITER ;

COMMIT;
