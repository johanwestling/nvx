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
	esac
	shift
done

if [[ "${nvx_command}" = "help" ]]; then
  echo -e "nvx \033[33m→\033[39m Display help text."
fi

if [[ "${nvx_command}" = "install" ]]; then
	nvx_node_install "${node_version}"
fi
