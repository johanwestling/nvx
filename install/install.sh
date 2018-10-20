#!/bin/bash

source "${PWD}/nvx/helpers/functions.sh"

nvx_update_bashrc
nvx_install_bins

bash ${PWD}/nvx/interface/interface.sh

exec bash