#!/bin/sh

base_dir=$(dirname "$(readlink -f "$0")")

psql -h ${PGHOST} -U ${PGUSER} -f ${base_dir}/test_data.sql
