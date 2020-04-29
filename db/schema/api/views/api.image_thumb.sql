CREATE OR REPLACE VIEW api.image_thumb
AS
  SELECT im.user_id,
         im.image_id,
         im.thumb
    FROM image im
;
