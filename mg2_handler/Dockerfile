FROM tengelisconsulting/mg2_py_handler:latest

WORKDIR /app
COPY ./controllers ./controllers
COPY ./main.py ./main.py

ENV CONTROLLER_DEF_DIR "/app/controllers"
ENTRYPOINT ["/app/main.py"]
