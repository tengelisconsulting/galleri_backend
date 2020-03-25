#!/bin/sh


env_sub() {
    val=$(eval "echo \"\$$1\"")
    sed_arg="s/\\\${$1}/${val}/"
    sed -i -e $sed_arg nginx/nginx.conf
}


main() {
    set -e

    cp nginx/nginx.template.conf nginx/nginx.conf
    env_sub HTTP_PORT
    env_sub PGST_HOST
    env_sub PGST_PORT
    env_sub LUA_CODE_CACHE

    openresty -p `pwd`/ -c nginx/nginx.conf

    tail -f logs/access.log -f logs/error.log
}


main
