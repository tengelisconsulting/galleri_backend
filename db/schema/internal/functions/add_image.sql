CREATE OR REPLACE FUNCTION add_image(
  IN   p_user_id           UUID,
  IN   p_href              TEXT,
  IN   p_description       TEXT         DEFAULT NULL
)
RETURNS UUID
AS $$
DECLARE
  v_image_id            UUID    := uuid_generate_v1mc();
BEGIN
  INSERT INTO image (
                image_id,
                user_id,
                href,
                description
              )
       VALUES (
                v_image_id,
                p_user_id,
                p_href,
                p_description
              )
  ;
  RETURN v_image_id;
END;
$$
LANGUAGE plpgsql
;
