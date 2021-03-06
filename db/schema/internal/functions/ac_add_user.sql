CREATE OR REPLACE FUNCTION ac_add_user(
  IN   p_username      TEXT,
  IN   p_password      TEXT
)
RETURNS UUID
AS $$
DECLARE
  v_user_id     UUID    := uuid_generate_v1mc();
BEGIN
  INSERT INTO ac_user (
                user_id,
                username,
                username_upper,
                password_hash
              )
       VALUES (
                v_user_id,
                p_username,
                upper(p_username),
                crypt(p_password, gen_salt('bf'))
              )
  ;
  RETURN v_user_id;
END;
$$
LANGUAGE plpgsql
;
