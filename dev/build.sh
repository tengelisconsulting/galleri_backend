dev_dir=$(dirname "$(readlink -f "$0")")
base_dir=${dev_dir}/..

${base_dir}/mg2/dev/build.sh
${base_dir}/gateway/dev/build.sh
${base_dir}/mg2_handler/dev/build.sh
${base_dir}/z_worker/dev/build.sh
