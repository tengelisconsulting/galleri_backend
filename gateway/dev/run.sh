#!/bin/sh

dev_dir=$(dirname "$(readlink -f "$0")")
base_dir=${dev_dir}/..
dcp_file=${dev_dir}/../../docker-compose.yaml


# function cleanup() {
#     docker-compose -f ${dcp_file} stop gateway
# }

# trap cleanup SIGINT

LUA_CODE_CACHE="off" docker-compose -f ${dcp_file} run --rm \
              -v ${base_dir}/lua:/app/lua \
              gateway
