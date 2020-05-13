dev_dir=$(dirname "$(readlink -f "$0")")
base_dir=${dev_dir}/..

${base_dir}/gateway/dev/build.sh
