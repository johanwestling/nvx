#!/bin/bash

bin_name="node"
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

echo "node"
echo "-> global: ${bin_global_path}"
echo "-> local: ${bin_local_path}"