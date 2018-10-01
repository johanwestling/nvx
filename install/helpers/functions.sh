#!/bin/bash

source "output.sh"

function nvx_install {
  local bashrc="${HOME}/.bashrc"
  local nvx_before=$(cat "../bashrc/before.sh")
  local nvx_after=$(cat "../bashrc/after.sh")
  local is_installed=$(grep -E "${nvx_before}" "${bashrc}")

  echo "is_installed: ${is_installed}"
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