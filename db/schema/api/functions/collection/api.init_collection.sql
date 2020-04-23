CREATE OR REPLACE FUNCTION api.init_collection(
  IN p_collection_id           TEXT,
  IN p_collection_name         TEXT,
  IN p_image_ids               TEXT[]
)
RETURNS JSON
AS $$
DECLARE
  v_user_id            UUID := session_user_id();
  v_collection_id      UUID := str_to_uuid(p_collection_id);
  v_image_ids          UUID[];
BEGIN
  FOR i IN array_lower(p_image_ids, 1)..array_upper(p_image_ids, 1) LOOP
    v_image_ids[i] := str_to_uuid(p_image_ids[i]);
    IF NOT check_owns(v_user_id, v_image_ids[i]) THEN
      RAISE insufficient_privilege;
    END IF;
  END LOOP;

  PERFORM sys.image_collection_create(
    p_user_id         => v_user_id,
    p_collection_id   => v_collection_id,
    p_collection_name => p_collection_name,
    p_images          => v_image_ids
  );

  RETURN json_build_object(
    'collection_id', p_collection_id
  );
END;
$$
LANGUAGE plpgsql
;
