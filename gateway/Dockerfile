FROM openresty/openresty:buster-fat

ENV TINI_VERSION v0.19.0
WORKDIR /app

RUN apt update \
        && apt install --assume-yes \
        build-essential \
        unzip \
        wget \
        libzmq3-dev

        # luarocks
RUN wget http://luarocks.org/releases/luarocks-2.0.13.tar.gz \
        && tar -xzvf luarocks-2.0.13.tar.gz \
        && cd luarocks-2.0.13/ \
        && ./configure --prefix=/usr/local/openresty/luajit \
        --with-lua=/usr/local/openresty/luajit/ \
        --lua-suffix=jit \
        --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1
RUN cd luarocks-2.0.13 \
        && make \
        && make install
RUN /usr/local/openresty/luajit/bin/luarocks install lzmq

        # opm
RUN opm get ledgetech/lua-resty-http \
        p0pr0ck5/lua-resty-cookie \
        openresty/lua-resty-redis \
        fffonion/lua-resty-openssl

RUN curl -L https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini -o /tini \
        && chmod +x /tini

RUN apt remove --assume-yes \
        build-essential \
        wget \
        unzip \
        && apt clean \
        && rm -rf /var/lib/apt/lists/*

        # ad hoc
COPY ./ez_client.lua ./ez_client.lua

VOLUME /app/logs

COPY ./entrypoint.sh ./entrypoint.sh

COPY ./nginx ./nginx
COPY ./lua ./lua



ENTRYPOINT [ "/tini", "/app/entrypoint.sh" ]
