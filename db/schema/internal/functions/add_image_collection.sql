CREATE OR REPLACE FUNCTION add_image_collection(
  IN   p_user_id           UUID,
  IN   p_collection_name   TEXT
)
RETURNS UUID
AS $$
DECLARE
  v_collection_id       UUID    := uuid_generate_v1mc();
BEGIN
  INSERT INTO image_collection (
                collection_id,
                user_id,
                collection_name
              )
       VALUES (
                v_collection_id,
                p_user_id,
                p_collection_name
              )
  ;
  RETURN v_collection_id;
END;
$$
LANGUAGE plpgsql
;
