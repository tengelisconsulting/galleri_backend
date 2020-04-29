CREATE OR REPLACE FUNCTION default_permissions()
RETURNS JSON
AS $$
BEGIN
  RETURN json_build_object(
              'owner', json_build_object(
                         'r', 't',
                         'w', 't'
                       ),
              'public', json_build_object(
                         'r', 't'
                       )
            )
  ;
END;
$$
LANGUAGE plpgsql
;
