CREATE OR REPLACE FUNCTION api.image_update(
  IN p_obj_id           TEXT,
  IN p_href             image.href%TYPE         DEFAULT NULL,
  IN p_description      image.description%TYPE  DEFAULT NULL
)
RETURNS INTEGER
AS $$
DECLARE
  v_user_id            UUID := session_user_id();
  v_obj_id             UUID := str_to_uuid(p_obj_id);
  v_user_owns          BOOLEAN := check_owns(
    p_user_id           => v_user_id,
    p_obj_id            => v_obj_id
  );
BEGIN
  IF v_user_owns = FALSE THEN
    RAISE insufficient_privilege;
  END IF;

  RETURN sys.image_update(
    p_obj_id            => p_obj_id,
    p_href              => p_href,
    p_description       => p_description
  );
END;
$$
LANGUAGE plpgsql
;
