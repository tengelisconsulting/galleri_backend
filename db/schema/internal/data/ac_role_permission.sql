DO $$
BEGIN
  DELETE FROM ac_role_permission;
  PERFORM ac_add_role_permission('ADMIN', 'app_owner');
END
$$;
