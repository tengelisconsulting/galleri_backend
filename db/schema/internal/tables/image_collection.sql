CREATE TABLE IF NOT EXISTS image_collection (
  collection_id     UUID                NOT NULL
    DEFAULT uuid_generate_v1mc(),
  created           TIMESTAMPTZ         NOT NULL
    DEFAULT now(),
  user_id           UUID                NOT NULL
    REFERENCES ac_user (user_Id),

  PRIMARY KEY (collection_id)
);
