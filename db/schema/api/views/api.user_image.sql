CREATE OR REPLACE VIEW api.user_image
AS
  SELECT im.image_id,
         ici.collection_id,
         im.created,
         im.user_id,
         im.href,
         -- im.thumb,
         im.description
    FROM image im
    JOIN image_collection_image ici
      ON im.image_id = ici.image_id
   WHERE im.user_id = session_user_id()
;
