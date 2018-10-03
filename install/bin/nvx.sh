#!/bin/bash

bin_args=${@:1}
bin_path="${PWD}/nvx/interface/interface.sh"

if [ ! -f "${bin_path}" ]; then
  echo -e "nvx \033[33m→\033[39m No nvx in current directory."
  echo -e "nvx \033[33m→\033[39m Navigate to a directory that contains the nvx folder."
  exit
fi

bash "${bin_path}" ${bin_args}