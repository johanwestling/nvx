#!/bin/bash

source "${PWD}/nvx/helpers/output.sh"

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

function nvx_resource_download {
  local url="${1}"
  local file="${2}"

  if [ -n "${url}" ]; then
    if [ -n "${file}" ]; then
      curl -s -L -w '%{http_code}' "${url}" -o "${file}"
    else
      curl -s -L "${url}"
    fi
  fi
}

function nvx_resource_extract {
  local resource_file="${1}"
  local resource_directory="${2}"
  local resource_clean="${3}"

  if [ -d "${resource_directory}" ] && [ -n "${resource_clean}" ]; then
    echo -e "    \033[33m→\033[39m Cleaning ${resource_directory}"
    rm -rf "${resource_directory}"
    if [ ! -d "${resource_directory}" ] || [ $(ls -afq "${directory}" | wc -l) -lt 4 ]; then
      echo -e "       \033[32m●\033[39m Done"
    else
      echo -e "       \033[31m●\033[39m Fail"
    fi
  fi

  if [ ! -d "${resource_directory}" ]; then
    echo -e "    \033[33m→\033[39m Creating ${resource_directory}"
    mkdir -p "${resource_directory}"
    if [ -d "${resource_directory}" ]; then
      echo -e "       \033[32m●\033[39m Done"
    else
      echo -e "       \033[31m●\033[39m Fail"
    fi
  fi

  if [ -d "${resource_directory}" ]; then
    echo -e "    \033[33m→\033[39m Extracting ${resource_file}"
    if tar -xvf "${resource_file}" -C "${resource_directory}" > /dev/null 2>&1; then
      echo -e "       \033[32m●\033[39m Done"
    else
      echo -e "       \033[31m●\033[39m Fail"
    fi
  fi
}

function nvx_resource_copy {
  local resource_source="${1}"
  local resource_destination="${2}"
  local resource_clean="${3}"

  if [ -d "${resource_destination}" ] && [ -n "${resource_clean}" ]; then
    echo -e "    \033[33m→\033[39m Cleaning ${resource_destination}"
    rm -rf "${resource_destination}"
    if [ ! -d "${resource_destination}" ] || [ $(ls -afq "${directory}" | wc -l) -lt 4 ]; then
      echo -e "       \033[32m●\033[39m Done"
    else
      echo -e "       \033[31m●\033[39m Fail"
    fi
  fi

  if [ ! -d "${resource_destination}" ]; then
    echo -e "    \033[33m→\033[39m Creating ${resource_destination}"
    mkdir -p "${resource_destination}"
    if [ -d "${resource_destination}" ]; then
      echo -e "       \033[32m●\033[39m Done"
    else
      echo -e "       \033[31m●\033[39m Fail"
    fi
  fi

  if [ -d "${resource_destination}" ]; then
    echo -e "    \033[33m→\033[39m Copying ${resource_source}"
    if \cp -a "${resource_source}/." "${resource_destination}" > /dev/null 2>&1; then
      echo -e "       \033[32m●\033[39m Done"
    else
      echo -e "       \033[31m●\033[39m Fail"
    fi
  fi
}

function nvx_node_detect_version {
  local node_version="${1}"
  local nvxrc_file="${PWD}/.nvxrc"

  # Detect node version from .nvxrc file.
  if [ -z "${node_version}" ] && [ -f "${nvxrc_file}" ]; then
    node_version=$(grep -E 'node_version=[0-9].*' "${nvxrc_file}" | cut -d "=" -f2)
  fi

  # No node version detected, fallback to latest.
  if [ -z "${node_version}" ]; then
    node_version="latest"
  fi

  echo "${node_version}"
}

function nvx_node_detect_version_exact {
  local node_shasum="${1}"
  local node_version=$(grep -E 'node-v.*\.tar\.gz' "${node_shasum}" | sed 's/^.*-v\([0-9]*\.[0-9]*\.[0-9]*\).*$/\1/' | head -n 1)

  if [ ! -z "${node_version}" ]; then
    echo "${node_version}"
  fi
}

function nvx_node_detect_platform {
  echo $(command uname -a | cut -d " " -f1 | sed -e 's/\(.*\)/\L\1/')
}

function nvx_node_detect_architecture {
  case $(command uname -m) in
    x86_64 | amd64)
      echo "x64"
      ;;
    i*86)
      echo "x86"
      ;;
    aarch64)
      echo "arm64"
      ;;
  esac
}

function nvx_node_install {
  local node_version="${1:-latest}"
  local node_version_exact=""
  local node_url="https://nodejs.org/dist/latest"
  local node_path="${PWD}/nvx/node"
  local node_cache_path="${PWD}/nvx/cache"
  local node_cache_shasum="${node_cache_path}/SHASUMS256-${node_version}.txt"
  local node_platform=$(nvx_node_detect_platform)
  local node_architecture=$(nvx_node_detect_architecture)
  local node_archive=""
  local node_archive_url=""
  local node_archive_file=""
  local node_archive_extract="${node_cache_path}/extract"

  echo -e "nvx \033[33m→\033[39m Installing node (${node_version})"

  if [[ "${node_version}" != "latest" ]]; then
    node_url="${node_url}-v${node_version}"
  fi

  echo -e "    \033[33m→\033[39m Downloading ${node_url}/SHASUMS256.txt"
  if [[ $(nvx_resource_download "${node_url}/SHASUMS256.txt" "${node_cache_shasum}") = 200 ]]; then
    node_version_exact=$(nvx_node_detect_version_exact "${node_cache_shasum}")
    echo -e "       \033[32m●\033[39m Done"
  else
    echo -e "       \033[31m●\033[39m Fail"
  fi

  echo -e "    \033[33m→\033[39m Detecting exact node version"
  if [ -n "${node_version_exact}" ] && [ -n "${node_platform}" ] && [ -n "${node_architecture}" ]; then
    echo -e "       \033[32m●\033[39m Done (${node_version_exact})"
    node_archive="node-v${node_version_exact}-${node_platform}-${node_architecture}"
    node_archive_url="${node_url}/${node_archive}.tar.gz"
    node_archive_file="${node_cache_path}/${node_archive}.tar.gz"
  else
    echo -e "       \033[31m●\033[39m Fail"
  fi

  if [ -n "${node_archive_url}" ] && [ -n "${node_archive_file}" ]; then
    echo -e "    \033[33m→\033[39m Downloading ${node_archive_url}"
    if [[ $(nvx_resource_download "${node_archive_url}" "${node_archive_file}") = 200 ]]; then
      echo -e "       \033[32m●\033[39m Done"
    else
      echo -e "       \033[31m●\033[39m Fail"
    fi
  fi

  if [ -n "${node_archive}" ] && [ -f "${node_archive_file}" ]; then
    nvx_resource_extract "${node_archive_file}" "${node_archive_extract}" true
    nvx_resource_copy "${node_archive_extract}/${node_archive}" "${node_path}" true
  fi
}