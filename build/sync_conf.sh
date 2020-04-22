#!/bin/sh

dev_dir=$(dirname "$(readlink -f "$0")")
base_dir=${dev_dir}/..

TARGET="${1}"

if [ "${TARGET}" = "" ]; then
    echo "supply target host"
    exit 1
fi

rsync -avzz ${base_dir}/env/ ${TARGET}:/home/liam/galleri_backend/env/
rsync -avzz ${base_dir}/docker-compose.yaml ${TARGET}:/home/liam/galleri_backend/docker-compose.yaml
