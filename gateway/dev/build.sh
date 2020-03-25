#!/bin/sh

dev_dir=$(dirname "$(readlink -f "$0")")
base_dir=${dev_dir}/..

docker build -t galleri/gateway:dev $base_dir
