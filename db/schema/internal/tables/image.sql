CREATE TABLE IF NOT EXISTS internal.image (
  image_id      UUID                      NOT NULL
    DEFAULT uuid_generate_v1mc(),
  created       TIMESTAMPTZ               NOT NULL
    DEFAULT now(),
  href          TEXT                      NOT NULL,
  user_id       UUID                      NOT NULL
    REFERENCES internal.ac_user (user_id),

  PRIMARY KEY (image_id)
);
