CREATE OR REPLACE FUNCTION sys.check_session_owns(
  IN p_user_id             TEXT,
  IN p_obj_id              TEXT,
  IN p_if_no_exists        BOOLEAN      DEFAULT true
)
RETURNS BOOLEAN
AS $$
DECLARE
  v_user_id     UUID    := str_to_uuid(p_user_id);
  v_obj_id      UUID    := str_to_uuid(p_obj_id);
BEGIN
  RETURN check_owns(
    p_user_id           => v_user_id,
    p_obj_id            => v_obj_id,
    p_if_no_exists      => p_if_no_exists
  );
END;
$$
LANGUAGE plpgsql
STABLE
;
