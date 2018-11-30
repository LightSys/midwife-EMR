-- Migration: Client Log
-- Created at: 2018-11-20 15:07:48
-- ====  UP  ====

BEGIN;

CREATE TABLE IF NOT EXISTS `clientConsole` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user INT NULL,
  session_id VARCHAR(300) NOT NULL,
  timestamp BIGINT NOT NULL,
  severity ENUM('info', 'warning', 'error', 'debug', 'other') NOT NULL,
  message VARCHAR(500),
  FOREIGN KEY (user) REFERENCES user (id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE EVENT IF NOT EXISTS `e_clientConsole`
  ON SCHEDULE
    EVERY 1 DAY
  COMMENT 'Clears out old clientConsole records.'
  DO
    DELETE FROM clientConsole WHERE FROM_UNIXTIME(timestamp/1000) < DATE_SUB(NOW(), INTERVAL 60 DAY);

SET GLOBAL event_scheduler = ON;

COMMIT;

-- ==== DOWN ====

BEGIN;

DROP EVENT IF EXISTS `e_clientConsole`;
DROP TABLE IF EXISTS `clientConsole`;
SET GLOBAL event_scheduler = OFF;

COMMIT;
