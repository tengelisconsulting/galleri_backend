CREATE OR REPLACE FUNCTION api.add_image_to_collection(
  IN p_collection_id      TEXT,
  IN p_image_id           TEXT
)
RETURNS JSON
AS $$
DECLARE
  v_user_id            UUID := session_user_id();
  v_collection_id      UUID := str_to_uuid(p_collection_id);
  v_image_id           UUID := str_to_uuid(p_image_id);
  v_images             UUID[];
  v_updated            INTEGER;
BEGIN
  IF NOT check_owns(
    p_user_id           => v_user_id,
    p_obj_id            => v_collection_id
  ) THEN
    RAISE insufficient_privilege;
  END IF;
  IF NOT check_owns(
    p_user_id           => v_user_id,
    p_obj_id            => v_image_id
  ) THEN
    RAISE insufficient_privilege;
  END IF;

  SELECT images
    INTO v_images
    FROM image_collection
   WHERE collection_id = v_collection_id
  ;
  v_images := v_images || v_image_id;

  SELECT sys.image_collection_update(
           p_collection_id      => v_collection_id,
           p_images             => v_images
         )
    INTO v_updated
  ;

  RETURN json_build_object(
           'updated', v_updated
  );
END;
$$
LANGUAGE plpgsql
;
