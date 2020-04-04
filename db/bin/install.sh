#!/bin/sh


if [ "${DEF_BASE_DIR}" = "" ]; then
    echo "supply DEF_BASE_DIR"
    exit 1
fi

execute_all_sql_at_root() {
    if [ ! -d "${1}" ]; then
        return
    fi
    for f in $(find "${1}" -name '*.sql'); do
        echo "${f}"
        psql -h ${PGHOST} -U ${PGUSER} -f "${f}"
    done

}

c() {
    psql -h ${PGHOST} -U ${PGUSER} -f "${DEF_BASE_DIR}/${1}"
}


execute_all_sql_at_root ${DEF_BASE_DIR}/internal/extensions
execute_all_sql_at_root ${DEF_BASE_DIR}/internal/schemas
execute_all_sql_at_root ${DEF_BASE_DIR}/internal/tables
execute_all_sql_at_root ${DEF_BASE_DIR}/internal/views
execute_all_sql_at_root ${DEF_BASE_DIR}/internal/functions
execute_all_sql_at_root ${DEF_BASE_DIR}/internal/data

execute_all_sql_at_root ${DEF_BASE_DIR}/api/views
execute_all_sql_at_root ${DEF_BASE_DIR}/api/functions

execute_all_sql_at_root ${DEF_BASE_DIR}/sys/views
execute_all_sql_at_root ${DEF_BASE_DIR}/sys/functions
