

-- Load the default user that can be used to administer the system.
-- Note: password hash is for password 'admin'
INSERT INTO `user`
  (username, firstname, lastname, password, note, updatedBy, updatedAt)
VALUES
  ('admin', 'admin', 'admin', '$2a$10$r93uzyhs73Bh88Hco63wTuOyq8rLg2jy2mWnP8g03pu8fkc9mQDb6',
  'This is the default admin account with password of "admin". In production systems, this account should be disabled once another administrator is created.',
  1, NOW())
;

-- Load the roles.
INSERT INTO `role`
  (name, description, updatedBy, updatedAt)
VALUES
  ('administrator', 'Manages users, vaccination and lab types, and the system.', 1, NOW()),
  ('guard', 'Patient check-in and check-out.', 1, NOW()),
  ('clerk', 'No patient care with exception of BP and Wgt. Manages priority list.', 1, NOW()),
  ('student', 'Patient care but always requires a supervisor.', 1, NOW()),
  ('supervisor', 'Patient care.', 1, NOW())
;

-- Assign the admin user to the administrator role.
INSERT INTO `user_role`
  (user_id, role_id, updatedBy, updatedAt)
VALUES
  (1, 1, 1, NOW())
;

-- Create some basic events
INSERT INTO `eventType`
  (name, description)
VALUES
  ('login', 'A user logged in'),
  ('logout', 'A user logged out'),
  ('supervisor', 'A user set a supervisor'),
  ('history', 'A user viewed changes from log tables'),
  ('prenatalCheckin', 'Client checkin for a prenatal exam.'),
  ('prenatalCheckOut', 'Client checkout of a prenatal exam.'),
  ('prenatalChartPulled', 'Chart pulled for a prental exam.')
;

-- Create the data for at least one select option.
INSERT INTO `selectData`
  (name, selectKey, label, selected, updatedBy, updatedAt)
VALUES
  ('maritalStatus', '', 'Unknown', 1, 1, NOW()),
  ('maritalStatus', 'single', 'Single', 0, 1, NOW()),
  ('maritalStatus', 'live-in', 'Live-In', 0, 1, NOW()),
  ('maritalStatus', 'married', 'Married', 0, 1, NOW()),
  ('maritalStatus', 'widowed', 'Widowed', 0, 1, NOW()),
  ('maritalStatus', 'divorced', 'Divorced', 0, 1, NOW()),
  ('maritalStatus', 'separated', 'Separated', 0, 1, NOW()),
  ('religion', '', 'Unknown', 1, 1, NOW()),
  ('religion', 'catholic', 'Roman Catholic', 0, 1, NOW()),
  ('religion', 'protestant', 'Protestant', 0, 1, NOW()),
  ('religion', 'muslim', 'Muslim', 0, 1, NOW()),
  ('religion', 'hindu', 'Hindu', 0, 1, NOW()),
  ('religion', 'other', 'Other', 0, 1, NOW()),
  ('education', '', 'Unknown', 1, 1, NOW()),
  ('education', 'elementary', 'Elementary', 0, 1, NOW()),
  ('education', 'high school', 'High School', 0, 1, NOW()),
  ('education', 'college', 'College', 0, 1, NOW())
;

