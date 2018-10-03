#!/bin/bash

bin_name="npx"
bin_args=${@:1}
bin_path=""
bin_local="${PWD}/nvx/node/bin/${bin_name}"
bin_local_path=""
bin_global=$(which nodejs)
bin_global_path=""

if [ -f "${bin_local}" ]; then
  bin_local_path="${bin_local}"
else
  bin_global_path=$(dirname "${bin_global}")
  bin_global_path="${bin_global_path}/${bin_name}"
fi

if [ -n "${bin_local_path}" ]; then
  bin_path="${bin_local_path}"
else
  bin_path="${bin_global_path}"
fi

echo -e "${bin_name} \033[33m→\033[39m ${bin_path} ${bin_args}"
echo -e ""

eval "${bin_path} ${bin_args}"