FROM tengelisconsulting/mypy
WORKDIR /app
RUN python3 -m pip install \
        PyJWT==1.7.1 \
        ez_arch_worker==0.2.1
COPY ./py ./py
RUN mypy --ignore-missing-imports ./py

FROM tengelisconsulting/pyzmq:alpine
WORKDIR /app
RUN python3 -m pip install \
        PyJWT==1.7.1 \
        ez_arch_worker==0.2.1
COPY ./py ./py
ENTRYPOINT [ "tini", "/app/py/main.py" ]
