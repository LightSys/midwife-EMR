

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
  ('administrator', 'Manages users, vaccination and lab types, and the system.', 1, NOW())
;
INSERT INTO `role`
  (name, description, updatedBy, updatedAt)
VALUES
  ('guard', 'Patient check-in and check-out.', 1, NOW())
;
INSERT INTO `role`
  (name, description, updatedBy, updatedAt)
VALUES
  ('clerk', 'No patient care with exception of BP and Wgt. Manages priority list.', 1, NOW())
;
INSERT INTO `role`
  (name, description, updatedBy, updatedAt)
VALUES
  ('student', 'Patient care but always requires a supervisor.', 1, NOW())
;
INSERT INTO `role`
  (name, description, updatedBy, updatedAt)
VALUES
  ('supervisor', 'Patient care.', 1, NOW())
;

-- Assign the admin user to the administrator role.
INSERT INTO `user_role`
  (user_id, role_id, updatedBy, updatedAt)
VALUES
  (1, 1, 1, NOW())
;


