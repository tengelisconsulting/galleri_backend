CREATE OR REPLACE VIEW api.user_account
AS
  SELECT user_id,
         username,
         created,
         updated
    FROM ac_user
   WHERE user_id = session_user_id()
;
