#!/bin/bash

bin_name="npm"
bin_args=()
bin_flags=()
bin_flags_separator="false"
bin_path=""
bin_local="${PWD}/nvx/node/bin/${bin_name}"
bin_local_path=""
bin_global=$(which nodejs)
bin_global_path=""

# Collect arguments & flags.
for bin_arg in ${@:1}; do
  if [[ "${bin_arg}" = "--" ]] || [[ "${bin_flags_separator}" = "true" ]]; then
    bin_flags+=("${bin_arg}")
    bin_flags_separator="true"
  else
    bin_args+=("${bin_arg}")
  fi
done

# Append --scripts-prepend-node-path to prevent bash index issues.
bin_args+=("--scripts-prepend-node-path")

# Check if local binary file exists.
if [ -f "${bin_local}" ]; then
  bin_local_path="${bin_local}"
fi

# Check if global binary file exists.
if [ -f "${bin_global}" ]; then
  bin_global_path="$(dirname "${bin_global}")/${bin_name}"
fi

# Switch between local/global binary reference.
if [ -n "${bin_local_path}" ]; then
  bin_path="${bin_local_path}"
else
  bin_path="${bin_global_path}"
fi

# Check if binary reference is correct.
if [ -n "${bin_path}" ]; then
  # Run binary.
  echo -e " \033[33m→\033[39m Running: ${bin_path} ${bin_args[@]} ${bin_flags[@]}"
  ${bin_path} ${bin_args[@]} ${bin_flags[@]}
else
  # No binary found.
  echo -e " \033[31m→\033[39m Unable to find ${bin_name}. Is it installed?"
fi