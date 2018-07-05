#!/bin/bash

# Allow bash to expand aliases
shopt -s expand_aliases

# Create aliases
nvx_output_step "Creating temporary aliases..."
nvx_output_separator
while read node_bin_path; do
  # Add node to $PATH.
  PATH="${PATH}:${node_bin_path}"

  # Generate aliases for all node binaries.
  for node_bin_file in ${node_bin_path}/*; do
    alias_key=$(basename ${node_bin_file})
    alias ${alias_key}="${node_bin_file}"
    echo -e "${nvx_output_style_bright}${alias_key}${nvx_output_style_default}"
    echo -e "-→ ${nvx_output_style_dim}${node_bin_file}${nvx_output_style_default}"
  done
done < "${nvx_node_path}/node_bin"
nvx_output_separator

echo -e ""