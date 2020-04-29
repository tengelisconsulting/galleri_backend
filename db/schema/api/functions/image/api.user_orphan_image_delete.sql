CREATE OR REPLACE FUNCTION api.user_orphan_image_delete(
  IN p_image_id                TEXT
)
RETURNS JSON
AS $$
DECLARE
  v_image_id            UUID     := str_to_uuid(p_image_id);
  v_user_id             UUID     := session_user_id();
  v_deleted             INTEGER  := 0;
  v_images              UUID[];
BEGIN
  IF NOT check_owns(
    p_user_id           => v_user_id,
    p_obj_id            => v_image_id
  ) THEN
    RAISE insufficient_privilege;
  END IF;

  WITH deleted AS (
    DELETE FROM public.image
          WHERE image_id = v_image_id
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
