CREATE OR REPLACE FUNCTION sys.image_collection_create(
  IN p_user_id             image_collection.user_id%TYPE,
  IN p_collection_id       image_collection.collection_id%TYPE,
  IN p_collection_name     image_collection.collection_name%TYPE,
  IN p_images              UUID[]
)
RETURNS BOOLEAN
AS $$
DECLARE
  v_image_id            UUID;
  v_image_exists        BOOLEAN;
BEGIN
  IF array_length(p_images, 1) < 1 THEN
    RAISE EXCEPTION 'Empty array of images';
  END IF;
  FOREACH v_image_id IN ARRAY p_images LOOP
    SELECT TRUE
      INTO v_image_exists
      FROM public.image
     WHERE image_id = v_image_id
    ;
    IF v_image_exists IS NULL THEN
      RAISE EXCEPTION 'Nonexistent Image ID --> %', v_image_id;
    END IF;
  END LOOP;
  INSERT INTO public.image_collection (
                user_id,
                collection_id,
                collection_name,
                images
              )
       VALUES (
                p_user_id,
                p_collection_id,
                p_collection_name,
                p_images
              )
  ;
  RETURN TRUE;
END;
$$
LANGUAGE plpgsql
;
