-- Migration: Length measurements in newbornExam to accept decimal
-- Created at: 2018-05-09 08:44:29
-- ====  UP  ====

BEGIN;

ALTER TABLE newbornExam
  MODIFY length DECIMAL(3,1) NULL,
  MODIFY headCir DECIMAL(3,1) NULL,
  MODIFY chestCir DECIMAL(3,1) NULL;

ALTER TABLE newbornExamLog
  MODIFY length DECIMAL(3,1) NULL,
  MODIFY headCir DECIMAL(3,1) NULL,
  MODIFY chestCir DECIMAL(3,1) NULL;

COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE newbornExam
  MODIFY length INT NULL,
  MODIFY headCir INT NULL,
  MODIFY chestCir INT NULL;

ALTER TABLE newbornExamLog
  MODIFY length INT NULL,
  MODIFY headCir INT NULL,
  MODIFY chestCir INT NULL;

COMMIT;
