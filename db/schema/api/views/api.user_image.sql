CREATE OR REPLACE VIEW api.user_image
-- all the user's images, no thumbs
AS
  WITH collection_image AS (
    SELECT ic.collection_id,
           im.image_id,
           im.ordinal
      FROM image_collection ic,
      unnest(ic.images) WITH ordinality AS im(image_id, ordinal)
     WHERE ic.user_id = session_user_id()
  )
  SELECT im.image_id,
         ci.ordinal,
         ci.collection_id,
         im.created,
         im.user_id,
         im.href,
         im.description
    FROM image im
    JOIN collection_image ci
      ON im.image_id = ci.image_id
;
