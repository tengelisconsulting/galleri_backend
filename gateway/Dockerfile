FROM openresty/openresty:buster-fat

WORKDIR /app

RUN opm get ledgetech/lua-resty-http

VOLUME /app/logs

COPY ./entrypoint.sh ./entrypoint.sh

COPY ./nginx ./nginx
COPY ./lua ./lua

ENTRYPOINT [ "/app/entrypoint.sh" ]
