#!/bin/bash

bin_args=${@:1}
bin_path="${PWD}/nvx/interface/interface.sh"

cat "${HOME}/.nvx/global"

if [ ! -f "${bin_path}" ]; then
  echo -e " \033[31m→\033[39m Unable to find nvx in current directory."
  echo -e "   \033[34m→\033[39m Install it with git clone git@github.com:johanwestling/nvx.git or navigate to a directory that contains nvx."
  exit
fi

bash "${bin_path}" ${bin_args}