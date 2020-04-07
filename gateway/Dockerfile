FROM openresty/openresty:buster-fat

WORKDIR /app

RUN opm get ledgetech/lua-resty-http \
        p0pr0ck5/lua-resty-cookie \
        openresty/lua-resty-redis

VOLUME /app/logs

COPY ./entrypoint.sh ./entrypoint.sh

COPY ./nginx ./nginx
COPY ./lua ./lua

ENTRYPOINT [ "/app/entrypoint.sh" ]
