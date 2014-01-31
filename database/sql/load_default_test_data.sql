-- Load a user for each role for testing.
-- Note: password hash is for each user is the same as the username.
INSERT INTO `user`
  (username, firstname, lastname, password, note, updatedBy, updatedAt)
VALUES
  ('admin', 'admin', 'admin', '$2a$10$r93uzyhs73Bh88Hco63wTuOyq8rLg2jy2mWnP8g03pu8fkc9mQDb6',
  'This is the default admin account with password of "admin". In production systems, this account should be disabled once another administrator is created.',
  1, NOW())
;

INSERT INTO `user`
  (username, firstname, lastname, password, note, updatedBy, updatedAt)
VALUES
  ('guard', 'guard', 'guard', '$2a$10$vNSjSzQjcGyY0XZoJaawFev32JdUjZ6GW0Not6YBzQFLG2w7Mcmqm',
  'This is the default guard account with password of "guard".',
  1, NOW())
;

INSERT INTO `user`
  (username, firstname, lastname, password, note, updatedBy, updatedAt)
VALUES
  ('clerk', 'clerk', 'clerk', '$2a$10$0NNM2m/uylWV03qvvSVpXu2YwKBV0JWTTKjgLg2W2lUukgNRsM4ni',
  'This is the default clerk account with password of "clerk".',
  1, NOW())
;

INSERT INTO `user`
  (username, firstname, lastname, password, note, updatedBy, updatedAt)
VALUES
  ('student', 'student', 'student', '$2a$10$1zobFaHaHxpGcxyyt82pSexQuth7KKiMNh6fUCJHN3A50A2Cs85Ky',
  'This is the default student account with password of "student".',
  1, NOW())
;

INSERT INTO `user`
  (username, firstname, lastname, password, note, updatedBy, updatedAt)
VALUES
  ('supervisor', 'supervisor', 'supervisor', '$2a$10$Q5oHzUPxwPJHzM/0qTWwbuP3Ir7NLZgrdbXKxPwP4eo8A.8yb45s2',
  'This is the default supervisor account with password of "supervisor".',
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
-- TODO: this is very brittle and error prone so fix it.
INSERT INTO `user_role`
  (user_id, role_id, updatedBy, updatedAt)
VALUES
  (1, 1, 1, NOW())
;

INSERT INTO `user_role`
  (user_id, role_id, updatedBy, updatedAt)
VALUES
  (2, 2, 1, NOW())
;

INSERT INTO `user_role`
  (user_id, role_id, updatedBy, updatedAt)
VALUES
  (3, 3, 1, NOW())
;

INSERT INTO `user_role`
  (user_id, role_id, updatedBy, updatedAt)
VALUES
  (4, 4, 1, NOW())
;

INSERT INTO `user_role`
  (user_id, role_id, updatedBy, updatedAt)
VALUES
  (5, 5, 1, NOW())
;

