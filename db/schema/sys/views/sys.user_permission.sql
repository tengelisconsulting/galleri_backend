CREATE OR REPLACE VIEW sys.user_permission
AS
  SELECT u.user_id,
         u.username_upper,
         p.permission_id,
         p.permission_code
    FROM ac_user u
    JOIN ac_user_role ur
      ON u.user_id = ur.user_id
    JOIN ac_role_permission rp
      ON rp.role_id = ur.role_id
    JOIN ac_permission p
      ON p.permission_id = rp.permission_id
;
