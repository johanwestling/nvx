#################### nvx -> ####################
#
#   NVX
#   Node Version Executor
#
#   Url:     https://github.com/johanwestling/nvx
#   Author:  Johan Westling
#
################################################

nvx_global_file="${HOME}/.nvx/global"
nvx_global_bins="${HOME}/.nvx/bin"

if ! [ -f "${nvx_global_file}" ]; then
  touch "${nvx_global_file}"
fi

if ! [[ "${PATH}" == *"${nvx_global_bins}"* ]]; then
  nvx_global_node=$(which nodejs)
  nvx_global_npm=$(which npm)
  nvx_global_npx=$(which npx)

  if [[ "${nvx_global_node}" == "${nvx_global_bins}/"* || "${nvx_global_node}" == "/mnt/"*"/nodejs/"* ]]; then
    nvx_global_node=""
  fi

  if [[ "${nvx_global_npm}" == "${nvx_global_bins}/"* || "${nvx_global_npm}" == "/mnt/"*"/nodejs/"* ]]; then
    nvx_global_npm=""
  fi

  if [[ "${nvx_global_npx}" == "${nvx_global_bins}/"* || "${nvx_global_npx}" == "/mnt/"*"/nodejs/"* ]]; then
    nvx_global_npx=""
  fi

  echo "node=${nvx_global_node}" > "${nvx_global_file}"
  echo "npm=${nvx_global_npm}" >> "${nvx_global_file}"
  echo "npx=${nvx_global_npx}" >> "${nvx_global_file}"

  export PATH="${nvx_global_bins}:${PATH}"
fi

#################### <- nvx ####################
