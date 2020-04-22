#!/bin/sh

dev_dir=$(dirname "$(readlink -f "$0")")
base_dir=${dev_dir}/..

git_changes=$(git status -s)
if [ "${git_changes}" != "" ]; then
    echo "working changes, won't proceed"
    exit 1
fi

DATE_TAG=$(date -u +%Y-%m-%d-%H%M)
GIT_TAG=$(git rev-parse --short --verify HEAD)
TAG=${DATE_TAG}--${GIT_TAG}

do_build() {
    image_name="${1}"
    build_dir="${2}"
    full_image_name=galleri/${image_name}:${TAG}
    docker build -t ${full_image_name} ${base_dir}/${build_dir} \
        && docker push ${full_image_name}
}

do_build gateway gateway
do_build mg2 mg2
do_build mg2_handler mg2_handler
