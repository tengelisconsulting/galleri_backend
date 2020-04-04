CREATE OR REPLACE VIEW api.user_image
AS
  SELECT im.image_id,
         im.created,
         im.user_id,
         im.href,
         im.description
    FROM image im
   WHERE im.user_id = session_user_id()
;
