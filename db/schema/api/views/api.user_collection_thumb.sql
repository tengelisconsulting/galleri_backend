CREATE OR REPLACE VIEW api.user_collection_thumb
AS
  SELECT ic.collection_id,
         ic.collection_name,
         im.image_id,
         encode(im.thumb, 'base64') thumb_b64
    FROM image_collection ic
    JOIN image_collection_image ici
      ON ici.collection_id = ic.collection_id
     AND ici.image_id = (
                         SELECT image_id
                           FROM image_collection_image
                          WHERE collection_id = ic.collection_id
                          LIMIT 1
                        )
    JOIN image im
      ON ici.image_id = im.image_id
   -- WHERE ic.user_id = session_user_id()
;
