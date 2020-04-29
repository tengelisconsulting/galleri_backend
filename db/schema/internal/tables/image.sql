CREATE TABLE IF NOT EXISTS image (
  image_id      UUID                      NOT NULL
    DEFAULT uuid_generate_v1mc(),
  created       TIMESTAMPTZ               NOT NULL
    DEFAULT now(),
  href          TEXT,
  user_id       UUID                      NOT NULL
    REFERENCES ac_user (user_id),
  permissions   JSON                      NOT NULL
    DEFAULT json_build_object(
              'owner', 'rw',
              'other', 'r'
            ),
  description   TEXT,
  thumb         BYTEA,

  PRIMARY KEY (image_id)
);
