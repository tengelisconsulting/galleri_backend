CREATE OR REPLACE VIEW api.user_image_collection
-- all the user's collections, no thumb
AS
  SELECT ic.collection_id,
         ic.collection_name,
         ic.created,
         ic.user_id
    FROM image_collection ic
   WHERE ic.user_id = session_user_id()
;
