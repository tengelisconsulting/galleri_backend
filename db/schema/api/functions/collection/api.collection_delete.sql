CREATE OR REPLACE FUNCTION api.collection_delete(
  IN p_collection_id      TEXT
)
RETURNS JSON
AS $$
DECLARE
  v_user_id            UUID := session_user_id();
  v_collection_id      UUID := str_to_uuid(p_collection_id);
  v_deleted            INTEGER := 0;
  v_images             UUID[];
BEGIN
  IF NOT check_owns(
    p_user_id           => v_user_id,
    p_obj_id            => v_collection_id
  ) THEN
    RAISE insufficient_privilege;
  END IF;

  SELECT images
    INTO v_images
    FROM image_collection
   WHERE collection_id = v_collection_id
  ;

  FOR i IN array_lower(v_images, 1)..array_upper(v_images, 1) LOOP
    DELETE FROM image
          WHERE image_id = v_images[i]
    ;
    v_deleted := v_deleted + 1;
  END LOOP;

  DELETE FROM image_collection
        WHERE collection_id = v_collection_id
  ;
  v_deleted := v_deleted + 1;

  RETURN json_build_object(
           'deleted', v_deleted
  );
END;
$$
LANGUAGE plpgsql
;
