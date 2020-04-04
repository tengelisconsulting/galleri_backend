CREATE OR REPLACE FUNCTION sys.image_create(
  IN p_user_id          image.user_id%TYPE,
  IN p_image_id         image.image_id%TYPE,
  IN p_href             image.href%TYPE,
  IN p_description      image.description%TYPE
)
RETURNS BOOLEAN
AS $$
BEGIN
  INSERT INTO image (
                user_id,
                image_id,
                href,
                description
              )
       VALUES (
                p_user_id,
                p_image_id,
                p_href,
                p_description
              )
  ;
  RETURN TRUE;
END;
$$
LANGUAGE plpgsql
;
