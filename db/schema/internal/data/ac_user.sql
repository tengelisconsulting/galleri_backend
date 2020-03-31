DO $$
BEGIN
  BEGIN
    PERFORM ac_add_user(
      p_username  => 'test_user',
      p_password  => 'a1s2d3f4g5'
    );
    EXCEPTION
      WHEN unique_violation THEN
        NULL;
  END;
  BEGIN
    PERFORM ac_add_user_role(
      p_username  => 'test_user',
      p_role_name  => 'BASE_USER'
    );
    EXCEPTION
      WHEN unique_violation THEN
        NULL;
  END;
END
$$;
