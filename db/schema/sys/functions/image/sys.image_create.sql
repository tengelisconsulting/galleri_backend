CREATE OR REPLACE FUNCTION sys.image_create(
  IN p_user_id          image.user_id%TYPE,
  IN p_image_id         image.image_id%TYPE
)
RETURNS BOOLEAN
AS $$
BEGIN
  INSERT INTO public.image (
                user_id,
                image_id
              )
       VALUES (
                p_user_id,
                p_image_id
              )
  ;
  RETURN TRUE;
END;
$$
LANGUAGE plpgsql
;
