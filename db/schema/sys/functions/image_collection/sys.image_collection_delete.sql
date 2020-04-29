CREATE OR REPLACE FUNCTION sys.image_collection_delete(
  IN p_obj_id         image_collection.collection_id%TYPE
)
RETURNS INTEGER
AS $$
DECLARE
  v_count       INTEGER;
BEGIN
  WITH deleted AS (
  DELETE FROM public.image_collection
        WHERE collection_id = p_obj_id
    RETURNING *
  )
  SELECT count(*)
    FROM deleted
    INTO v_count
  ;
  RETURN v_count;
END;
$$
LANGUAGE plpgsql
;
