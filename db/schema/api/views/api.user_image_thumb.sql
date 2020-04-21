CREATE OR REPLACE VIEW api.user_image_thumb
AS
  SELECT im.image_id,
         im.created,
         im.user_id,
         im.href,
         im.description,
         im.thumb
    FROM image im
    JOIN image_collection_image ici
      ON im.image_id = ici.image_id
   WHERE im.user_id = session_user_id()
;
