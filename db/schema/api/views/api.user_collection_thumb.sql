CREATE OR REPLACE VIEW api.user_collection_thumb
-- all the user's collections, with a thumbnail (first image in collection)
AS
  SELECT ic.collection_id,
         ic.collection_name,
         im.image_id,
         im.thumb
    FROM image_collection ic
    JOIN image im
      ON im.image_id = ic.images[1]
   WHERE ic.user_id = session_user_id()
;
