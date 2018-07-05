#!/bin/bash

# NVX paths
nvx_path=".nvx"
nvx_node_path=".nvx/node"
nvx_node_artifact_path="${nvx_node_path}/artifact"
nvx_node_binary_path="${nvx_node_path}/binary"

source "${nvx_path}/functions.sh"

# NVX node arguments
nvx_node_version=$(nvx_get_requested_version $1)

nvx_output_box_start
nvx_output_box_text "NVX" --style="bright"
nvx_output_box_separator
nvx_output_box_text "Version:            v0.0.1"
nvx_output_box_text "Author:             Johan Westling"
nvx_output_box_separator
nvx_output_box_text "Node version:       ${nvx_node_version}"
nvx_output_box_stop

if ! [ -f "${nvx_node_path}" ]; then
  source "${nvx_path}/install.sh"
  source "${nvx_path}/use.sh"
else
  source "${nvx_path}/use.sh"
fi