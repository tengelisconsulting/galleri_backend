CREATE OR REPLACE VIEW api.logon_names
AS
  SELECT user_id,
         username_upper,
         username
    FROM ac_user
;
