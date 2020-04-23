CREATE OR REPLACE FUNCTION api.collection_update(
  IN p_collection_id      TEXT,
  IN p_collection_name    TEXT          DEFAULT NULL,
  IN p_images             TEXT[]        DEFAULT NULL
)
RETURNS JSON
AS $$
DECLARE
  v_user_id            UUID := session_user_id();
  v_collection_id      UUID := str_to_uuid(p_collection_id);
  v_image_ids          UUID[];
  v_updated            INTEGER;
BEGIN
  IF NOT check_owns(
    p_user_id           => v_user_id,
    p_obj_id            => v_collection_id
  ) THEN
    RAISE insufficient_privilege;
  END IF;

  FOR i IN array_lower(p_images, 1)..array_upper(p_images, 1) LOOP
    v_image_ids[i] := str_to_uuid(p_images[i]);
    IF NOT check_owns(v_user_id, v_image_ids[i]) THEN
      RAISE insufficient_privilege;
    END IF;
  END LOOP;

  SELECT sys.image_collection_update(
           p_collection_id      => v_collection_id,
           p_collection_name    => p_collection_name,
           p_images             => v_image_ids
         )
    INTO v_updated
  ;

  RETURN json_build_object(
           'created', v_updated
  );
END;
$$
LANGUAGE plpgsql
;
