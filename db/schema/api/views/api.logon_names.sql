CREATE OR REPLACE VIEW api.logon_names
AS
  SELECT username_upper
    FROM ac_user
;
