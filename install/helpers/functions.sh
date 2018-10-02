#!/bin/bash

source "${PWD}/install/helpers/output.sh"

function nvx_install_bins {
  local bin_src_path="${PWD}/install/bin"
  local bin_dest_path="${HOME}/.nvx/bin"

  if [ ! -d "${bin_dest_path}" ]; then
    mkdir -p "${bin_dest_path}"
  fi

  for bin_src_file in ${bin_src_path}/*.sh; do
    local bin_dest_file=$(basename "${bin_src_file%\.*}")
    local bin_dest_file="${bin_dest_path}/${bin_dest_file}"

    \cp "${bin_src_file}" "${bin_dest_file}"
    chmod +x "${bin_dest_file}"
  done
}

function nvx_install_bashrc {
  local bashrc="${HOME}/.bashrc"
  local nvx_before="#################### nvx -> ####################"
  local nvx_after="#################### <- nvx ####################"
  local nvx_content=$(cat "${PWD}/install/bashrc/content.sh")
  local nvx_installed=$(grep -E "${nvx_before}" "${bashrc}")

  nvx_uninstall_legacy

  if [ -n "${nvx_installed}" ]; then
    sed -i "/${nvx_before}/,/${nvx_after}/d" "${bashrc}"
  fi

  echo "${nvx_content}" >> "${bashrc}"
}

function nvx_uninstall_legacy {
  local bashrc="${HOME}/.bashrc"
  local legacy_before="# >>>>> nvx >>>>> #"
  local legacy_after="# <<<<< nvx <<<<< #"
  local legacy_installed=$(grep -E "${legacy_before}" "${bashrc}")

  if [ -n "${legacy_installed}" ]; then
    sed -i "/${legacy_before}/,/${legacy_after}/d" "${bashrc}"
  fi
}

function nvx_in_pwd {
  if [ -d "${PWD}/nvx" ] && [ -f "${PWD}/nvx/nvx.sh" ]; then
    echo 'true'
  fi
}

function bin_local_path {
  local bin="${1}"
  local bin_version="${2}"
  local bin_path="${PWD}/nvx/bin/${bin_version}/${bin}"

  if [ -f "${bin_path}" ]; then
    echo "${bin_path}"
  fi
}

function bin_global_path {
  local bin="${1}"
  local bin_path=$(which "${bin}")

  if [ -n "${bin}" ] && [ -n "${bin_path}" ]; then
    dirname "${bin_path}"
  fi
}