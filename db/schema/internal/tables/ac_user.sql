CREATE TABLE IF NOT EXISTS ac_user (
  user_id            UUID              NOT NULL
    DEFAULT uuid_generate_v1mc(),
  username           TEXT              NOT NULL
    CHECK (length(username) < 512),
  username_upper     TEXT              NOT NULL
    UNIQUE,
  password_hash      TEXT              NOT NULL
    CHECK (length(password_hash) < 512),
  created            TIMESTAMPTZ       NOT NULL
    DEFAULT now(),
  updated            TIMESTAMPTZ       NOT NULL
    DEFAULT now(),

  PRIMARY KEY (user_id)
);

COMMENT ON TABLE ac_user IS 'An app user';
