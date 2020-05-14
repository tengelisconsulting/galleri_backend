FROM tengelisconsulting/mypy
WORKDIR /app
RUN python3 -m pip install \
        ez_arch_worker==0.2.1
COPY ./py ./py
RUN mypy --ignore-missing-imports ./py

FROM tengelisconsulting/pyzmq:alpine
WORKDIR /app
RUN python3 -m pip install \
        ez_arch_worker==0.2.1
RUN wget https://gist.githubusercontent.com/tengelisconsulting/33120a757336dc3625138002c721e383/raw/fb75bad798f1ce80cdd9f363289ad6365e446f46/ez_worker_main.py
COPY ./py ./py
RUN cp /app/ez_worker_main.py /app/py/main.py \
        && chmod +x /app/py/main.py

ENTRYPOINT [ "tini", "/app/py/main.py" ]
