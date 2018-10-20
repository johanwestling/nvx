#!/bin/bash

source "${PWD}/nvx/helpers/functions.sh"

nvx_install_bashrc
nvx_install_bins

bash ${PWD}/nvx/interface/interface.sh

exec bash