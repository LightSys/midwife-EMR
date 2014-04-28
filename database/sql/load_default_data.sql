

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
  ('attending', 'Patient care but always requires a supervisor.', 1, NOW()),
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
  ('maritalStatus', 'Single', 'Single', 0, 1, NOW()),
  ('maritalStatus', 'Live-In', 'Live-In', 0, 1, NOW()),
  ('maritalStatus', 'Married', 'Married', 0, 1, NOW()),
  ('maritalStatus', 'Other', 'Other', 0, 1, NOW()),
  ('religion', '', 'Unknown', 1, 1, NOW()),
  ('religion', 'Christian', 'Christian', 0, 1, NOW()),
  ('religion', 'Roman Catholic', 'Roman Catholic', 0, 1, NOW()),
  ('religion', 'Muslim/Islam', 'Muslim/Islam', 0, 1, NOW()),
  ('religion', 'SDA', 'SDA', 0, 1, NOW()),
  ('religion', 'INC', 'INC', 0, 1, NOW()),
  ('religion', 'LDS', 'LDS', 0, 1, NOW()),
  ('religion', 'Other', 'Other', 0, 1, NOW()),
  ('education', '', 'Unknown', 1, 1, NOW()),
  ('education', 'Elem level', 'Elem level', 0, 1, NOW()),
  ('education', 'Elem grad', 'Elem grad', 0, 1, NOW()),
  ('education', 'HS level', 'HS level', 0, 1, NOW()),
  ('education', 'HS grad', 'HS grad', 0, 1, NOW()),
  ('education', 'College level', 'College level', 0, 1, NOW()),
  ('education', 'College grad', 'College grad', 0, 1, NOW()),
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
  ('riskLifestyle', 'G6', 'G6', 0, 1, NOW()),
  ('incomePeriod', 'Day', 'Day', 0, 1, NOW()),
  ('incomePeriod', 'Week', 'Week', 0, 1, NOW()),
  ('incomePeriod', 'Two Weeks', 'Two Weeks', 0, 1, NOW()),
  ('incomePeriod', 'Twice Monthly', 'Twice Monthly', 0, 1, NOW()),
  ('incomePeriod', 'Month', 'Month', 1, 1, NOW()),
  ('incomePeriod', 'Quarter', 'Quarter', 0, 1, NOW()),
  ('incomePeriod', 'Year', 'Year', 0, 1, NOW()),
  ('yesNoUnanswered', '', '', 1, 1, NOW()),
  ('yesNoUnanswered', 'Y', 'Yes', 0, 1, NOW()),
  ('yesNoUnanswered', 'N', 'No', 0, 1, NOW()),
  ('yesNoUnknown', '', '', 1, 1, NOW()),
  ('yesNoUnknown', 'Y', 'Yes', 0, 1, NOW()),
  ('yesNoUnknown', 'N', 'No', 0, 1, NOW()),
  ('yesNoUnknown', '?', 'Unknown', 0, 1, NOW()),
  ('attendant', 'Midwife', 'Midwife', 1, 1, NOW()),
  ('attendant', 'Doctor', 'Doctor', 0, 1, NOW()),
  ('attendant', 'Hilot', 'Hilot', 0, 1, NOW()),
  ('attendant', 'Other', 'Other', 0, 1, NOW()),
  ('wksMthsYrs', '', '', 1, 1, NOW()),
  ('wksMthsYrs', 'Weeks', 'Weeks', 0, 1, NOW()),
  ('wksMthsYrs', 'Months', 'Months', 0, 1, NOW()),
  ('wksMthsYrs', 'Years', 'Years', 0, 1, NOW()),
  ('wksMths', '', '', 1, 1, NOW()),
  ('wksMths', 'Weeks', 'Weeks', 0, 1, NOW()),
  ('wksMths', 'Months', 'Months', 0, 1, NOW()),
  ('maleFemale', '', '', 1, 1, NOW()),
  ('maleFemale', 'F', 'Female', 0, 1, NOW()),
  ('maleFemale', 'M', 'Male', 0, 1, NOW())
;

