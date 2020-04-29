CREATE OR REPLACE VIEW api.image
AS
  SELECT ic.collection_id,
         im_ic.image_id,
         im_ic.ordinal,
         im.created,
         im.href,
         im.description,
         im.user_id,
         u.username_upper
    FROM image_collection ic,
   unnest(ic.images) WITH ordinality AS im_ic(image_id, ordinal)
    JOIN image im
      ON im.image_id = im_ic.image_id
    JOIN ac_user u
      ON u.user_id = im.user_id
;
