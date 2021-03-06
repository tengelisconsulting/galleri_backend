CREATE OR REPLACE VIEW sys.user_permission_list
AS
    SELECT up.user_id,
           array_agg(up.permission_code) permissions
      FROM sys.user_permission up
  GROUP BY up.user_id
;
