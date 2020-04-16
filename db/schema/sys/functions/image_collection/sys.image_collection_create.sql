CREATE OR REPLACE FUNCTION sys.image_collection_create(
  IN p_user_id             image_collection.user_id%TYPE,
  IN p_obj_id              image_collection.collection_id%TYPE,
  IN p_collection_name     image_collection.collection_name%TYPE
)
RETURNS BOOLEAN
AS $$
BEGIN
  INSERT INTO image_collection (
                user_id,
                collection_id,
                collection_name
              )
       VALUES (
                p_user_id,
                p_obj_id,
                p_collection_name
              )
  ;
  RETURN TRUE;
END;
$$
LANGUAGE plpgsql
;
