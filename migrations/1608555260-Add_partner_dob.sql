-- Migration: Add_partner_dob
-- Created at: 2020-12-21 07:54:20
-- ====  UP  ====

BEGIN;

  ALTER TABLE pregnancy
    ADD COLUMN partnerDob date AFTER partnerAge;

COMMIT;

-- ==== DOWN ====

BEGIN;

  ALTER TABLE pregnancy
    DROP COLUMN partnerDob;

COMMIT;
