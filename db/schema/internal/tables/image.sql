CREATE TABLE IF NOT EXISTS image (
  image_id      UUID                      NOT NULL
    DEFAULT uuid_generate_v1mc(),
  created       TIMESTAMPTZ               NOT NULL
    DEFAULT now(),
  href          TEXT                      NOT NULL,
  user_id       UUID                      NOT NULL
    REFERENCES ac_user (user_id),
  description   TEXT,

  PRIMARY KEY (image_id)
);
