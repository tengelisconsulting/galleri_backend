CREATE OR REPLACE FUNCTION sys.ac_init_user(
  p_username          TEXT,
  p_password          TEXT,
  p_role_names        TEXT[]
)
RETURNS UUID
AS $$
DECLARE
  v_user_id           UUID;
  v_role_name         TEXT;
BEGIN
  v_user_id := ac_add_user(
                 p_username => p_username,
                 p_password => p_password
               )
  ;
  FOREACH v_role_name IN ARRAY p_role_names
  LOOP
    PERFORM ac_add_user_role(
              p_username  => p_username,
              p_role_name => v_role_name
            )
    ;
  END LOOP;
  RETURN v_user_id;
END;
$$
LANGUAGE plpgsql
;
