CREATE OR REPLACE FUNCTION sys.image_collection_image_create(
  p_image_id           image_collection_image.image_id%TYPE,
  p_collection_id      image_collection_image.collection_id%TYPE
)
RETURNS BOOLEAN
AS $$
BEGIN
  INSERT INTO image_collection_image (
                image_id,
                collection_id
              )
       VALUES (
                p_image_id,
                p_collection_id
              )
  ;
  RETURN TRUE;
END;
$$
LANGUAGE plpgsql
;
