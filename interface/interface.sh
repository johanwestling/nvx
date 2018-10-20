#!/bin/bash

source "${PWD}/nvx/helpers/functions.sh"

nvx_command="help"
node_version=$(nvx_node_detect_version)

while [ $# -gt 0 ]; do
	case "$1" in
		--enable=*)
			nvx_command="install"
			node_version="${1#*=}"
			;;
		--enable)
			nvx_command="install"
			;;
		--uninstall)
			nvx_command="uninstall"
			;;
	esac
	shift
done

if [[ "${nvx_command}" == "help" ]]; then
	nvx_box_top
  nvx_box_head "NVX"
  nvx_box_head "Command:                      Description:" false
  nvx_box_text "nvx                           Display this help section."
  nvx_box_text "nvx --enable                  Enable latest version of node." false
  nvx_box_text "nvx --enable=\"8.x\"            Enable latest version of node 8."
  nvx_box_text "See available node versions at: https://nodejs.org/dist/"
	nvx_box_bottom
fi

if [[ "${nvx_command}" == "install" ]]; then
	nvx_node_install "${node_version}"
fi

if [[ "${nvx_command}" == "uninstall" ]]; then
	nvx_update_bashrc "uninstall"
	rm -rf "${HOME}/.nvx"
	exec bash
fi
