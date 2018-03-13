-- Migration: Baby Lab changes
-- Created at: 2018-03-13 13:19:01
-- ====  UP  ====

BEGIN;

UPDATE babyLabType
  SET name = 'NBS',
  fld3Name = 'Comment',
  fld3Type = 'String'
  WHERE name = 'Newborn Screening'
  LIMIT 1;

INSERT INTO babyLabType
  (name, description, fld1Name, fld1Type, fld2Name, fld2Type, fld3Name,
   fld3Type, active, updatedBy, updatedAt)
  VALUES ('ENBS', 'Extended Newborn Screening', 'Filter Card #',
  'Integer', 'Result', 'String', 'Comment', 'String', 1, 1, NOW()
  );

COMMIT;

-- ==== DOWN ====

BEGIN;

UPDATE babyLabType
  SET name = 'Newborn Screening',
  fld3Name = '',
  fld3Type = ''
  WHERE name = 'NBS'
  LIMIT 1;

DELETE FROM babyLab
  WHERE babyLabType IN (SELECT id FROM babyLabType WHERE name = 'ENBS')
  ;

DELETE FROM babyLabType
  WHERE name = 'ENBS';

COMMIT;
