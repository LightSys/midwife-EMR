

-- Load the default user that can be used to administer the system.
-- Note: password hash is for password 'admin'
INSERT INTO `user`
  (username, firstname, lastname, password, comment, updatedBy)
VALUES
  ('admin', 'admin', 'admin', '$2a$10$r93uzyhs73Bh88Hco63wTuOyq8rLg2jy2mWnP8g03pu8fkc9mQDb6',
  'This is the default admin account. In production systems, this account should be disabled once another administrator is created.',
  1)
;

