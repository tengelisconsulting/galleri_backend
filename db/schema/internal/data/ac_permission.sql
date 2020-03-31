DO $$
BEGIN
  DELETE FROM ac_permission;
  INSERT INTO ac_permission (
                permission_code
              )
       VALUES ( 'app_owner' ),
              ( 'test_permission' )
  ;
END
$$;
