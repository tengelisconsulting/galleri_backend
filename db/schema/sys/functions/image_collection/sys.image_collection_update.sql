CREATE OR REPLACE FUNCTION sys.image_collection_update(
  IN p_collection_id       image_collection.collection_id%TYPE,
  IN p_collection_name     image_collection.collection_name%TYPE  DEFAULT NULL,
  IN p_images              UUID[]                                 DEFAULT NULL
)
RETURNS INTEGER
AS $$
DECLARE
  v_image_id            UUID;
  v_image_exists        BOOLEAN;
  v_updated             INTEGER := 0;
BEGIN
  IF p_collection_name IS NOT NULL THEN
    UPDATE image_collection
       SET collection_name = p_collection_name
     WHERE collection_id = p_collection_id
    ;
    v_updated := 1;
  END IF;

  IF p_images IS NULL THEN
    RETURN v_updated;
  END IF;

  IF array_length(p_images, 1) < 1 THEN
    RAISE EXCEPTION 'Empty array of images';
  END IF;
  FOREACH v_image_id IN ARRAY p_images LOOP
    SELECT TRUE
      INTO v_image_exists
      FROM image
     WHERE image_id = v_image_id
    ;
    IF v_image_exists IS NULL THEN
      RAISE EXCEPTION 'Nonexistent Image ID --> %', v_image_id;
    END IF;
  END LOOP;
  UPDATE image_collection
     SET images = p_images
   WHERE collection_id = p_collection_id
  ;
  RETURN 1;
END;
$$
LANGUAGE plpgsql
;
