#!/bin/bash

bin_name="npm"
bin_args=${@:1}
bin_path=""
bin_local="${PWD}/nvx/node/bin/${bin_name}"
bin_local_path=""
bin_global=$(which nodejs)
bin_global_path=""

if [ -f "${bin_local}" ]; then
  bin_local_path="${bin_local}"
fi

if [ -f "${bin_global}" ]; then
  bin_global_path="$(dirname "${bin_global}")/${bin_name}"
fi

if [ -n "${bin_local_path}" ]; then
  bin_path="${bin_local_path}"
else
  bin_path="${bin_global_path}"
fi

if [ -n "${bin_path}" ]; then
  echo -e " \033[33m→\033[39m Running: ${bin_path} ${bin_args}"
  ${bin_path} ${bin_args} --scripts-prepend-node-path
else
  echo -e " \033[31m→\033[39m Unable to find ${bin_name}. Is it installed?"
fi