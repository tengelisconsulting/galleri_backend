FROM tengelisconsulting/ez_worker_mypy
WORKDIR /app
RUN python3 -m pip install \
        boto3==1.12.41
COPY ./py ./py
RUN mypy --ignore-missing-imports ./py

FROM tengelisconsulting/ez_worker_base
WORKDIR /app
RUN python3 -m pip install \
        boto3==1.12.41
COPY ./py ./py
ENTRYPOINT [ "tini", "/app/py/main.py" ]
