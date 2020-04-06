#!/bin/sh

dev_dir=$(dirname "$(readlink -f "$0")")
controller_dir=${dev_dir}/../controllers


MG_HOST=${HTTP_ZMQ_HOST} \
       MG_WORK_PORT=${HTTP_ZMQ_WORK_PORT} \
       MG_RESP_PORT=${HTTP_ZMQ_RESP_PORT} \
       CONTROLLER_DEF_DIR=${controller_dir} \
       LOG_LEVEL="DEBUG" \
       HANDLER_TYPE="UPLOAD" \
       python ${dev_dir}/../main.py
