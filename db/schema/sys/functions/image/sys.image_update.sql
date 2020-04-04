CREATE OR REPLACE FUNCTION sys.image_update(
  IN p_image_id         image.image_id%TYPE,
  IN p_href             image.href%TYPE         DEFAULT NULL,
  IN p_description      image.description%TYPE  DEFAULT NULL
)
RETURNS INTEGER
AS $$
DECLARE
  v_count              INTEGER;
  v_href               image.href%TYPE;
  v_description        image.description%TYPE;
BEGIN
  SELECT COALESCE(p_href, href),
         COALESCE(p_description, description)
    INTO v_href,
         v_description
    FROM image
   WHERE image_id = p_image_id
  ;
  WITH updated AS (
      UPDATE image
         SET href = v_href,
             description = v_description
       WHERE image_id = p_image_id
    RETURNING *
  )
  SELECT count(*)
    FROM updated
    INTO v_count
  ;
  RETURN v_count;
END;
$$
LANGUAGE plpgsql
;
