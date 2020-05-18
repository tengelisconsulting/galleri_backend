CREATE OR REPLACE VIEW api.image_collection_public
AS
  SELECT ic.collection_id,
         ic.user_id,
         ic.collection_name,
         ic.created,
         ic.images,
         u.username_upper
    FROM image_collection ic
    JOIN ac_user u
      ON u.user_id = ic.user_id
   WHERE ic.permissions->'public'->>'r' = 't'
;
