CREATE OR REPLACE FUNCTION api.user_image_delete(
  IN p_obj_id           TEXT
)
RETURNS JSON
AS $$
DECLARE
  v_obj_id              UUID     := str_to_uuid(p_obj_id);
  v_user_id             UUID     := session_user_id();
  v_deleted             INTEGER  := 0;
BEGIN
  WITH deleted AS (
    DELETE FROM image
          WHERE image_id = v_obj_id
            AND user_id = v_user_id
      RETURNING image_id
  )
  SELECT count(*)
    INTO v_deleted
    FROM deleted
  ;
  RETURN json_build_object(
    'deleted', v_deleted
  );
END;
$$
LANGUAGE plpgsql
;
