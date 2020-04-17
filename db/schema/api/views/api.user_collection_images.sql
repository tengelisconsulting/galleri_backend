CREATE OR REPLACE VIEW api.user_collection_images
AS
  SELECT ic.collection_id,
         ic.collection_name,
         ic.created collection_created,
         im.image_id,
         im.created image_created,
         im.href,
         im.description,
         im.thumb
    FROM image_collection ic
    JOIN image_collection_image ici
      ON ici.collection_id = ic.collection_id
    JOIN image im
      ON im.image_id = ici.image_id
   WHERE ic.user_id = session_user_id()
;
