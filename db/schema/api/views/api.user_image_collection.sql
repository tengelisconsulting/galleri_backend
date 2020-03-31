CREATE OR REPLACE VIEW api.user_image_collection
AS
  SELECT ic.collection_id,
         ic.created,
         ic.user_id
    FROM internal.image_collection ic
   WHERE ic.user_id = str_to_uuid(
                        current_setting(
                          'request.header.user-id',
                          true
                        )
                      )