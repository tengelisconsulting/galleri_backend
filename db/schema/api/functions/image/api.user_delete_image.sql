CREATE OR REPLACE FUNCTION api.user_image_delete(
  IN p_collection_id           TEXT,
  IN p_image_id                TEXT
)
RETURNS JSON
AS $$
DECLARE
  v_collection_id       UUID     := str_to_uuid(p_collection_id);
  v_image_id            UUID     := str_to_uuid(p_image_id);
  v_user_id             UUID     := session_user_id();
  v_deleted             INTEGER  := 0;
  v_images              UUID[];
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
    FROM public.image_collection
   WHERE collection_id = v_collection_id
  ;
  v_images := array_remove(v_images, v_image_id);
  UPDATE public.image_collection
     SET images = v_images
   WHERE collection_id = v_collection_id
  ;

  RETURN api.user_orphan_image_delete(
           p_image_id   => p_image_id
         );
END;
$$
LANGUAGE plpgsql
;
