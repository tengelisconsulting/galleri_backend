#!/bin/sh


docker run -d \
       --rm \
       --net=host \
       -e POSTGREST_USER=${PGUSER} \
       -e POSTGREST_PASSWORD=${PGPASSWORD} \
       -v "/etc/localtime:/etc/localtime:ro" \
       -v "${DB_DIRNAME}:/var/lib/postgresql/data" \
       --name galleri_db \
       postgres:12.2
