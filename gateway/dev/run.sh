#!/bin/sh

dev_dir=$(dirname "$(readlink -f "$0")")
base_dir=${dev_dir}/..
dcp_file=${dev_dir}/../../docker-compose.yaml


function cleanup() {
    docker stop backend_gateway_dev
    docker rm backend_gateway_dev
}

trap cleanup SIGINT

LUA_CODE_CACHE="off" docker-compose -f ${dcp_file} run -d --rm \
              -v ${base_dir}/lua:/app/lua \
              --name backend_gateway_dev \
              gateway

docker logs -f backend_gateway_dev
