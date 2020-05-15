CREATE OR REPLACE VIEW sys.obj_permissions
AS

     SELECT user_id owner_id,
            image_id obj_id,
            permissions
       FROM image

  UNION ALL
     SELECT user_id owner_id,
            collection_id obj_id,
            permissions
       FROM image_collection
;
