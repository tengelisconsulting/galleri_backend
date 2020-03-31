CREATE OR REPLACE VIEW api.meta_user_permission_list
AS
    SELECT up.user_id,
           array_agg(up.permission_code) permissions
      FROM api.meta_user_permission up
  GROUP BY up.user_id
;
