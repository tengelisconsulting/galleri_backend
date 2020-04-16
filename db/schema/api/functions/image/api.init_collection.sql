CREATE OR REPLACE FUNCTION api.init_collection(
  IN p_obj_id                  TEXT,
  IN p_collection_name         TEXT,
  IN p_image_ids               TEXT[]
)
RETURNS JSON
AS $$
DECLARE
  v_user_id            UUID := session_user_id();
  v_obj_id             UUID := str_to_uuid(p_obj_id);
  v_image_id_s         TEXT;
  v_image_id           UUID;
BEGIN
  -- init collection
  PERFORM sys.image_collection_create(
    p_user_id         => v_user_id,
    p_obj_id          => v_obj_id,
    p_collection_name => p_collection_name
  );
  -- add images
  FOREACH v_image_id_s IN ARRAY p_image_ids LOOP
    v_image_id := str_to_uuid(v_image_id_s);
    IF check_owns(
      p_user_id         => v_user_id,
      p_obj_id          => v_image_id
    ) THEN
      PERFORM sys.image_collection_image_create(
        p_image_id         => v_image_id,
        p_collection_id    => v_obj_id
      );
    ELSE
      RAISE insufficient_privilege;
    END IF;
  END LOOP;
  RETURN json_build_object(
    'collection_id', p_obj_id
  );
END;
$$
LANGUAGE plpgsql
;
