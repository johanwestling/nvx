#!/bin/bash

source "${PWD}/nvx/helpers/functions.sh"

nvx_reload_session="${1}"

nvx_update_bashrc
nvx_install_bins

bash ${PWD}/nvx/interface/interface.sh

if [ -z "${nvx_reload_session}" ]; then
  exec bash
fi
