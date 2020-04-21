FROM tengelisconsulting/mg2_py_handler:latest

WORKDIR /tmp
COPY ./galleri/requirements.txt ./requirements.txt
RUN python3 -m pip install -r ./requirements.txt \
        && rm ./requirements.txt
COPY ./galleri ./galleri
RUN python3 -m pip install ./galleri \
        && rm -rf /tmp/galleri

WORKDIR /app
COPY ./controllers ./controllers
COPY ./init.py ./init.py
COPY ./main.py ./main.py

ENV CONTROLLER_DEF_DIR "/app/controllers"
ENTRYPOINT ["/app/main.py"]
