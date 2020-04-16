CREATE OR REPLACE FUNCTION sys.image_update(
  IN p_obj_id           TEXT,
  IN p_href             image.href%TYPE         DEFAULT NULL,
  IN p_description      image.description%TYPE  DEFAULT NULL,
  IN p_thumb_b64        TEXT                    DEFAULT NULL
)
RETURNS JSON
AS $$
DECLARE
  v_obj_id             UUID := str_to_uuid(p_obj_id);
  v_count              INTEGER;
  v_href               image.href%TYPE;
  v_description        image.description%TYPE;
  v_thumb              image.thumb%TYPE;
BEGIN
  SELECT COALESCE(p_href, href),
         COALESCE(p_description, description),
         COALESCE(decode(p_thumb_b64, 'base64'), thumb)
    INTO v_href,
         v_description,
         v_thumb
    FROM image
   WHERE image_id = v_obj_id
  ;

  WITH updated AS (
      UPDATE image
         SET href = v_href,
             description = v_description,
             thumb = v_thumb
       WHERE image_id = v_obj_id
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
