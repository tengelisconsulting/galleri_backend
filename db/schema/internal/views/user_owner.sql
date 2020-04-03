CREATE OR REPLACE VIEW user_owner
AS

     SELECT user_id owner_id,
            image_id obj_id
       FROM image

  UNION ALL
     SELECT user_id owner_id,
            collection_id obj_id
       FROM image_collection

;
