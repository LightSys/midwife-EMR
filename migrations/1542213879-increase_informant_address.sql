-- Migration: increase informant address
-- Created at: 2018-11-14 11:44:39
-- ====  UP  ====

BEGIN;

ALTER TABLE birthCertificate MODIFY COLUMN informantAddress VARCHAR(100) NOT NULL;
ALTER TABLE birthCertificateLog MODIFY COLUMN informantAddress VARCHAR(100) NOT NULL;

COMMIT;

-- ==== DOWN ====

BEGIN;

ALTER TABLE birthCertificate MODIFY COLUMN informantAddress VARCHAR(50) NOT NULL;
ALTER TABLE birthCertificateLog MODIFY COLUMN informantAddress VARCHAR(50) NOT NULL;

COMMIT;
