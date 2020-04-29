CREATE OR REPLACE FUNCTION api.user_image_create(
  IN p_image_id         TEXT,
  IN p_href             TEXT,
  IN p_thumb_b64        TEXT
)
RETURNS JSON
AS $$
DECLARE
  v_obj_id              UUID     := str_to_uuid(p_image_id);
  v_user_id             UUID     := session_user_id();
  v_thumb               BYTEA    := decode(p_thumb_b64, 'base64');
BEGIN
  INSERT INTO public.image (
                user_id,
                image_id,
                href,
                thumb
              )
       VALUES (
                v_user_id,
                v_obj_id,
                p_href,
                v_thumb
              )
  ;
  RETURN json_build_object(
    'inserted', 1
  );
END;
$$
LANGUAGE plpgsql
;
