CREATE OR REPLACE FUNCTION sys.check_session_owns(
  IN p_user_id             TEXT,
  IN p_obj_id              TEXT,
  IN p_if_no_exists        BOOLEAN      DEFAULT true
)
RETURNS BOOLEAN
AS $$
DECLARE
  v_user_id     UUID    := str_to_uuid(p_user_id);
  v_obj_exists  BOOLEAN := NULL;
  v_obj_id      UUID    := str_to_uuid(p_obj_id);
  v_is_owner    BOOLEAN := NULL;
BEGIN
    SELECT 1
      INTO v_obj_exists
      FROM user_owner
     WHERE obj_id = v_obj_id
  GROUP BY obj_id
  ;
  IF v_obj_exists IS NULL THEN
    RETURN p_if_no_exists;
  END IF;

  SELECT true
    INTO v_is_owner
    FROM user_owner
   WHERE owner_id = v_user_id
     AND obj_id = v_obj_id
  ;
  IF v_is_owner IS NULL THEN
    RETURN false;
  END IF;
  RETURN v_is_owner;
END;
$$
LANGUAGE plpgsql
STABLE
;
