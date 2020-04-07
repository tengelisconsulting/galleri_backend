#!/bin/sh


env_sub() {
    val=$(eval "echo \"\$$1\"")
    sed_arg="s/\\\${$1}/${val}/"
    sed -i -e $sed_arg nginx/nginx.conf
}


main() {
    set -e

    cp nginx/nginx.template.conf nginx/nginx.conf
    env_sub OBJ_BUFFER_SIZE
    env_sub OBJ_MAX_SIZE
    env_sub GATEWAY_PORT
    env_sub PUB_PGST_HOST
    env_sub PUB_PGST_PORT
    env_sub LUA_CODE_CACHE
    env_sub OBJ_STORAGE_HOST
    env_sub OBJ_STORAGE_BUCKET

    openresty -p `pwd`/ -c nginx/nginx.conf

    tail -f logs/*.log
    # tail -f logs/access.log -f logs/error.log
}


main
