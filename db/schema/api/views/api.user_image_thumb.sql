CREATE OR REPLACE VIEW api.user_image_thumb
AS
  WITH collection_image AS (
    SELECT ic.collection_id,
           unnest(ic.images) image_id
      FROM image_collection ic
     WHERE ic.user_id = session_user_id()
  )
  SELECT im.image_id,
         im.created,
         im.user_id,
         im.thumb
    FROM image im
    JOIN collection_image ci
      ON im.image_id = ci.image_id
;
