CREATE TABLE IF NOT EXISTS image_collection_image (
  image_id          UUID       NOT NULL
    REFERENCES image (image_id),
  collection_id     UUID       NOT NULL
    REFERENCES image_collection (collection_id),

  PRIMARY KEY (collection_id, image_id)
);
