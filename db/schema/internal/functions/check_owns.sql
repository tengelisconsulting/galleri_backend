CREATE OR REPLACE FUNCTION check_owns(
  IN p_user_id             UUID,
  IN p_obj_id              UUID,
  IN p_if_no_exists        BOOLEAN      DEFAULT true
)
RETURNS BOOLEAN
AS $$
DECLARE
  v_obj_exists  BOOLEAN := NULL;
  v_is_owner    BOOLEAN := NULL;
BEGIN
    SELECT 1
      INTO v_obj_exists
      FROM obj_permissions
     WHERE obj_id = p_obj_id
  GROUP BY obj_id
  ;
  IF v_obj_exists IS NULL THEN
    RETURN p_if_no_exists;
  END IF;

  SELECT true
    INTO v_is_owner
    FROM obj_permissions
   WHERE owner_id = p_user_id
     AND obj_id = p_obj_id
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
