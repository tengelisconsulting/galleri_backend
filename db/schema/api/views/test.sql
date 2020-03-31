CREATE OR REPLACE VIEW api.test AS
SELECT current_setting('request.header.origin', true)
;
