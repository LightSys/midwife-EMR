-- Load a user for each role for testing.
-- Note: password hash is for each user is the same as the username.
INSERT INTO `user`
  (username, firstname, lastname, password, note, updatedBy, updatedAt)
VALUES
  ('admin', 'admin', 'admin', '$2a$10$r93uzyhs73Bh88Hco63wTuOyq8rLg2jy2mWnP8g03pu8fkc9mQDb6',
  'This is the default admin account with password of "admin". In production systems, this account should be disabled once another administrator is created.',
  1, NOW()),
  ('guard', 'guard', 'guard', '$2a$10$vNSjSzQjcGyY0XZoJaawFev32JdUjZ6GW0Not6YBzQFLG2w7Mcmqm',
  'This is the default guard account with password of "guard".',
  1, NOW()),
  ('clerk', 'clerk', 'clerk', '$2a$10$0NNM2m/uylWV03qvvSVpXu2YwKBV0JWTTKjgLg2W2lUukgNRsM4ni',
  'This is the default clerk account with password of "clerk".',
  1, NOW()),
  ('attending', 'attending', 'attending', '$2a$10$B1gNzN65TBK2qIFweq1Q2.5B2oSV2tx/7WrerWapxYUswwzD2WpuK',
  'This is the default attending account with password of "attending".',
  1, NOW()),
  ('supervisor', 'supervisor', 'supervisor', '$2a$10$Q5oHzUPxwPJHzM/0qTWwbuP3Ir7NLZgrdbXKxPwP4eo8A.8yb45s2',
  'This is the default supervisor account with password of "supervisor".',
  1, NOW())
;

-- Load the roles.
INSERT INTO `role`
  (name, description, updatedBy, updatedAt)
VALUES
  ('administrator', 'Manages users, vaccination and lab types, and the system.', 1, NOW()),
  ('guard', 'Patient check-in and check-out.', 1, NOW()),
  ('clerk', 'No patient care with exception of BP and Wgt. Manages priority list.', 1, NOW()),
  ('attending', 'Patient care but always requires a supervisor.', 1, NOW()),
  ('supervisor', 'Patient care.', 1, NOW())
;

-- Assign the admin user to the administrator role.
-- TODO: this is very brittle and error prone so fix it.
INSERT INTO `user_role`
  (user_id, role_id, updatedBy, updatedAt)
VALUES
  (1, 1, 1, NOW()),
  (2, 2, 1, NOW()),
  (3, 3, 1, NOW()),
  (4, 4, 1, NOW()),
  (5, 5, 1, NOW())
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
  ('maritalStatus', 'unknown', 'Not Set', 1, 1, NOW()),
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
  ('education', 'college', 'College', 0, 1, NOW()),
  ('edema', 'none', 'None', 1, 1, NOW()),
  ('edema', '+1', '+1', 0, 1, NOW()),
  ('edema', '+2', '+2', 0, 1, NOW()),
  ('edema', '+3', '+3', 0, 1, NOW()),
  ('edema', '+4', '+4', 0, 1, NOW()),
  ('riskPresent', '', '', 1, 1, NOW()),
  ('riskPresent', 'A1', 'A1', 0, 1, NOW()),
  ('riskPresent', 'A2', 'A2', 0, 1, NOW()),
  ('riskPresent', 'B1', 'B1', 0, 1, NOW()),
  ('riskPresent', 'B2', 'B2', 0, 1, NOW()),
  ('riskPresent', 'B3', 'B3', 0, 1, NOW()),
  ('riskPresent', 'C', 'C', 0, 1, NOW()),
  ('riskPresent', 'F', 'F', 0, 1, NOW()),
  ('riskObHx', '', '', 1, 1, NOW()),
  ('riskObHx', 'D1', 'D1', 0, 1, NOW()),
  ('riskObHx', 'D2', 'D2', 0, 1, NOW()),
  ('riskObHx', 'D3', 'D3', 0, 1, NOW()),
  ('riskObHx', 'D4', 'D4', 0, 1, NOW()),
  ('riskObHx', 'D5', 'D5', 0, 1, NOW()),
  ('riskObHx', 'D6', 'D6', 0, 1, NOW()),
  ('riskObHx', 'D7', 'D7', 0, 1, NOW()),
  ('riskMedHx', '', '', 1, 1, NOW()),
  ('riskMedHx', 'E1', 'E1', 0, 1, NOW()),
  ('riskMedHx', 'E2', 'E2', 0, 1, NOW()),
  ('riskMedHx', 'E3', 'E3', 0, 1, NOW()),
  ('riskMedHx', 'E4', 'E4', 0, 1, NOW()),
  ('riskMedHx', 'E5', 'E5', 0, 1, NOW()),
  ('riskMedHx', 'E6', 'E6', 0, 1, NOW()),
  ('riskMedHx', 'E7', 'E7', 0, 1, NOW()),
  ('riskMedHx', 'E8', 'E8', 0, 1, NOW()),
  ('riskLifestyle', '', '', 1, 1, NOW()),
  ('riskLifestyle', 'G1', 'G1', 0, 1, NOW()),
  ('riskLifestyle', 'G2', 'G2', 0, 1, NOW()),
  ('riskLifestyle', 'G3', 'G3', 0, 1, NOW()),
  ('riskLifestyle', 'G4', 'G4', 0, 1, NOW()),
  ('riskLifestyle', 'G5', 'G5', 0, 1, NOW()),
  ('riskLifestyle', 'G6', 'G6', 0, 1, NOW())
;
