# >>>>> nvx >>>>> #

nvx_bash_output_style_default="\033[0m"
nvx_bash_output_style_bright="\033[1m"
nvx_bash_output_foreground_default="\033[39;49m"
nvx_bash_output_foreground_red="\033[31;49m"

node() {
  local binary_name="node"
  local binary_path=$(nvx_binary_path "${binary_name}")
  local binary_args=${@}

  nvx_binary_execute "${binary_path}" "${binary_name}" ${binary_args}
}

npm() {
  local binary_name="npm"
  local binary_path=$(nvx_binary_path "${binary_name}")
  local binary_args=${@}

  nvx_binary_execute "${binary_path}" "${binary_name}" ${binary_args}
}

npx() {
  local binary_name="npx"
  local binary_path=$(nvx_binary_path "${binary_name}")
  local binary_args=${@}

  nvx_binary_execute "${binary_path}" "${binary_name}" ${binary_args}
}

nvx() {
  local nvx_script="${PWD}/nvx/nvx.sh"
  local nvx_args=${@}

  if [ -f "${nvx_script}" ]; then
    eval "${nvx_script} ${nvx_args}"
  else
    echo -e " ${nvx_bash_output_foreground_red}!${nvx_bash_output_foreground_default} ${nvx_bash_output_style_bright}No nvx in this directory...${nvx_bash_output_style_default}"
    echo -e "   Please cd to the directory that contains the nvx folder (usually project root)."
  fi
}

nvx_binary_path() {
  local binary_name=$1
  local binary_path=""
  local binary_reference="${PWD}/nvx/node/reference"

  if [ -f "${binary_reference}" ]; then
    # Load node binary path from nvx
    binary_path=$(head -n 1 "${binary_reference}")
  fi

  if [ ! -z "${binary_path}" ]; then
    # Local nvx path
    echo "${binary_path}"
  else
    # System default path
    which "${binary_name}"
  fi
}

nvx_binary_execute() {
  local binary_path=$1
  local binary_name=$2
  local binary_args=${@:3}
  local binary="${binary_path}/${binary_name}"

  PATH="${PATH}:${binary_path}"

  echo -e "${nvx_bash_output_foreground_red}−→${nvx_bash_output_foreground_default} ${binary} ${binary_args}"
  eval "${binary} ${binary_args}"
}

# <<<<< nvx <<<<< #
