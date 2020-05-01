CREATE OR REPLACE VIEW api.obj_op_permitted
AS
  WITH permissions AS (
    SELECT op.obj_id,
           CASE
             WHEN session_user_id() = op.owner_id
             THEN op.permissions->'owner'
             ELSE op.permissions->'public'
           END permission_obj
      FROM obj_permissions op
  )
    SELECT p.obj_id,
           coalesce(p.permission_obj->>'r' = 't', FALSE) read_access,
           coalesce(p.permission_obj->>'w' = 't', FALSE) write_access
      FROM permissions p
;
