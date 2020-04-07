FROM tengelisconsulting/mg2_py_handler:latest

WORKDIR /app
COPY ./requirements.txt ./requirements.txt
RUN python3 -m pip install -r ./requirements.txt \
        && rm ./requirements.txt

COPY ./src .
ENTRYPOINT [ "/app/main.py" ]
