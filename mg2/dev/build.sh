#!/bin/sh

dev_dir=$(dirname "$(readlink -f "$0")")
base_dir=${dev_dir}/..

docker build -t galleri/mg2:dev ${base_dir}
