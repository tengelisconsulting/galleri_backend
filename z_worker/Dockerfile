FROM tengelisconsulting/mg2_py_handler:latest

RUN apk add --update --no-cache \
        zlib-dev \
        jpeg-dev \
        build-base \
        python3-dev

WORKDIR /app
COPY ./requirements.txt ./requirements.txt
RUN python3 -m pip install -r ./requirements.txt \
        && rm ./requirements.txt

RUN apk del \
        build-base \
        python3-dev

COPY ./src .
ENTRYPOINT [ "/app/main.py" ]
