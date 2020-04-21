CREATE OR REPLACE FUNCTION api.add_image_to_collection(
  IN p_image_id           TEXT,
  IN p_collection_id      TEXT
)
RETURNS JSON
AS $$
DECLARE
  v_user_id            UUID := session_user_id();
  v_image_id           UUID := str_to_uuid(p_image_id);
  v_collection_id      UUID := str_to_uuid(p_collection_id);
BEGIN
  IF NOT check_owns(
    p_user_id           => v_user_id,
    p_obj_id            => v_collection_id
  ) THEN
    RAISE insufficient_privilege;
  ELSIF NOT check_owns(
    p_user_id           => v_user_id,
    p_obj_id            => v_image_id
  ) THEN
    RAISE insufficient_privilege;
  END IF;

  INSERT INTO image_collection_image (
                collection_id,
                image_id
              )
       VALUES (
                v_collection_id,
                v_image_id
              )
  ;
  RETURN json_build_object(
           'created', 1
  );
END;
$$
LANGUAGE plpgsql
;
