-- Database upgrade instructions for upgrading from 0.2.3x to 0.4.0

-- Add logging capabilities to the progress note tables.

CREATE TABLE pregnoteTypeLog LIKE pregnoteType;
ALTER TABLE pregnoteTypeLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE pregnoteTypeLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE pregnoteTypeLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE pregnoteTypeLog DROP PRIMARY KEY;
ALTER TABLE pregnoteTypeLog ADD PRIMARY KEY (id, replacedAt);

CREATE TABLE pregnoteLog LIKE pregnote;
ALTER TABLE pregnoteLog ADD COLUMN op CHAR(1) DEFAULT '';
ALTER TABLE pregnoteLog ADD COLUMN replacedAt DATETIME NOT NULL;
ALTER TABLE pregnoteLog MODIFY COLUMN id INT DEFAULT 0;
ALTER TABLE pregnoteLog DROP PRIMARY KEY;
ALTER TABLE pregnoteLog ADD PRIMARY KEY (id, replacedAt);

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


-- Since the pregnote and pregnoteType tables existed months in advance
-- of adding logging capabilities, we will add history to the best of
-- our ability after the fact.
INSERT INTO pregnoteTypeLog (id, name, description, op, replacedAt)
SELECT id, name, description, "I", date('2015-03-21') FROM pregnoteType;

INSERT INTO pregnoteLog (id, pregnoteType, noteDate, note, updatedBy,
  updatedAt, supervisor, pregnancy_id, op, replacedAt)
SELECT id, pregnoteType, noteDate, note, updatedBy, updatedAt, supervisor,
  pregnancy_id, "I", updatedAt
FROM pregnote;

