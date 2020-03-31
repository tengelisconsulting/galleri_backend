CREATE TABLE IF NOT EXISTS image_tag (
  image_id      UUID       NOT NULL
    REFERENCES image (image_id),
  tag           TEXT       NOT NULL
);
