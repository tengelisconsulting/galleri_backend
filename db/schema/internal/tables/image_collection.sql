CREATE TABLE IF NOT EXISTS image_collection (
  collection_id     UUID                NOT NULL
    DEFAULT uuid_generate_v1mc(),
  created           TIMESTAMPTZ         NOT NULL
    DEFAULT now(),
  user_id           UUID                NOT NULL
    REFERENCES ac_user (user_Id),
  collection_name   TEXT                NOT NULL,

  UNIQUE (user_id, collection_name),
  PRIMARY KEY (collection_id)
);
