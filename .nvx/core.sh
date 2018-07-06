#!/bin/bash

#
#  Core
#

# Paths
nvx_path=".nvx"
nvx_node_path="${nvx_path}/node"
nvx_node_artifact_path="${nvx_node_path}/artifact"
nvx_node_binary_path="${nvx_node_path}/binary"

nvx_log="${nvx_path}/nvx.log"

source ".nvx/output.sh"

#
#  Core - Install
#

nvx_install() {
  local bashrc_file="${HOME}/.bashrc"
  local nvx_content="${nvx_path}/bashrc.sh"
  local nvx_exists=$(grep -E '# >>>>> nvx >>>>> #' "${bashrc_file}")

  if [ -z "${nvx_exists}" ]; then
    # Install nvx to .bashrc
    nvx_output_step "Installing nvx..."
    cat "${nvx_content}" >> "${bashrc_file}"
    nvx_output_step_done "Installed!"
  else
    # Update nvx in .bashrc
    nvx_output_step "Updating nvx..."
    sed -i '/# >>>>> nvx >>>>> #/,/# <<<<< nvx <<<<< #/d' "${bashrc_file}"
    nvx_output_step_done "Updated!"
  fi

  exec bash
}

#
#  Core - Uninstall
#

nvx_uninstall() {
  local bashrc_file="${HOME}/.bashrc"
  local nvx_content="${nvx_path}/bashrc.sh"
  local nvx_exists=$(grep -E '# >>>>> nvx >>>>> #' "${bashrc_file}")

  nvx_output_step "Uninstalling nvx..."

  if [ ! -z "${nvx_exists}" ]; then
    # Uninstall nvx from .bashrc
    sed -i '/# >>>>> nvx >>>>> #/,/# <<<<< nvx <<<<< #/d' "${bashrc_file}"
    nvx_output_step_done "Uninstalled!"
  else
    nvx_output_step_error "Already uninstalled"
  fi
  
  exec bash
}

#
#  Core - Helpers
#

nvx_dir_exists() {
  if [ -d "$1" ]; then
    echo true
  fi
}

nvx_dir_create() {
  mkdir -p "$1" >> $nvx_log 2>&1

  if [ -d "$1" ]; then
    echo true
  fi
}

#
#  Core - Node
#


nvx_node_detect_version() {
  local node_version=$1
  local nvxrc_file="${PWD}/.nvxrc"

  if [ -z "${node_version}" ]; then
    if [ -f "${nvxrc_file}" ]; then
      node_version=$(grep -E 'node_version=[0-9].*' "${nvxrc_file}" | cut -d "=" -f2)
    fi
  fi

  if [ -z "${node_version}" ]; then
    node_version="latest"
  fi

  echo $node_version
}

nvx_node_dist_url() {
  local node_version=${1:-"latest"}

  if [ "${node_version}" = "latest" ]; then
    local node_dist_url="https://nodejs.org/dist/latest"
  else
    local node_dist_url="https://nodejs.org/dist/latest-v${node_version}"
  fi

  echo $node_dist_url
}

nvx_node_download_checksums() {
  local checksums_url=$1
  local checksums_file=$2

  if [ ! -f "${checksums_file}" ]; then
    touch "${checksums_file}" >> $nvx_log 2>&1
  fi

  if [ -f "${checksums_file}" ]; then
    curl "${checksums_url}" -o "${checksums_file}" >> $nvx_log 2>&1

    local checksums_downloaded=$(grep -E '^.{65} ' "${checksums_file}")

    if [ ! -z "${checksums_downloaded}" ]; then
      echo true
    fi
  fi
}

nvx_node_version_checksums() {
  local checksums_file=$1

  if [ -f "${checksums_file}" ]; then
    local checksums=$(grep -E 'node-v.*\.tar\.gz' "${checksums_file}")
    local version=$(echo "${checksums}" | sed 's/^.*-\(v[0-9]*\.[0-9]*\.[0-9]*\).*$/\1/' | head -n 1)

    if [ ! -z "${version}" ]; then
      echo "${version}"
    fi
  fi
}

nvx_node_system_architecture() {
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

nvx_node_download_artifact() {
  local dist_url=$1
  local version_exact=$2
  local system_os=$3
  local system_architecture=$4
  local artifact_file=$5

  if [ ! -f "${artifact_file}" ]; then
    touch "${artifact_file}" >> $nvx_log 2>&1
  fi

  if [ -f "${artifact_file}" ]; then
    curl "${dist_url}/node-${version_exact}-${system_os}-${system_architecture}.tar.gz" -o "${artifact_file}" >> $nvx_log 2>&1

    local artifact_downloaded=$(du -k "${artifact_file}" | cut -f1)

    if [ $artifact_downloaded -ge 10000 ]; then
      echo true
    fi
  fi
}

nvx_node_install() {
  local version=${1:-"latest"}
  local version_exact=""
  local dist_url=$(nvx_node_dist_url $version)
  local checksums_url="${dist_url}/SHASUMS256.txt"
  local checksums_file="${nvx_node_path}/SHASUMS256-node-${version}"
  local system_os=$(command uname -a | cut -d " " -f1 | sed -e 's/\(.*\)/\L\1/')
  local system_architecture=$(nvx_node_system_architecture)
  local node_artifact=""

  echo -n "" > $nvx_log

  # Create node path
  if ! [[ $(nvx_dir_exists "${nvx_node_path}") = true ]]; then
    nvx_output_step "Creating ${nvx_node_path} directory..."

    if [ $(nvx_dir_create "${nvx_node_path}") = true ]; then
      nvx_output_step_done "Done"
    else
      nvx_output_step_error "Failed"
      exit
    fi

    echo ""
  fi

  # Download node checksums
  if [ ! -f "${checksums_file}" ]; then 
    nvx_output_step "Downloading node checksums..."

    if [ $(nvx_node_download_checksums "${checksums_url}" "${checksums_file}") = true ]; then
      nvx_output_step_done "Done"
    else
      nvx_output_step_error "Failed"
      exit
    fi

    echo ""
  fi

  # Detect exact node version
  if [ -f "${checksums_file}" ]; then
    nvx_output_step "Detecting exact node version..."

    version_exact=$(nvx_node_version_checksums "${checksums_file}")

    if [ ! -z "${version_exact}" ]; then
      nvx_output_step_done "Done (${version_exact})"
    else
      nvx_output_step_error "Failed"
      exit
    fi

    echo ""
  fi

  # Detect system os
  nvx_output_step "Detecting system os..."
  if [ ! -z "${system_os}" ]; then
    nvx_output_step_done "Done (${system_os})"
  else
    nvx_output_step_error "Failed"
    exit
  fi

  echo ""

  # Detect system architecture
  nvx_output_step "Detecting system architecture..."
  if [ ! -z "${system_architecture}" ]; then
    nvx_output_step_done "Done (${system_architecture})"
  else
    nvx_output_step_error "Failed"
    exit  
  fi

  echo ""

  # Create node artifact path
  if ! [[ $(nvx_dir_exists "${nvx_node_artifact_path}") = true ]]; then
    nvx_output_step "Creating ${nvx_node_artifact_path} directory..."

    if [ $(nvx_dir_create "${nvx_node_artifact_path}") = true ]; then
      nvx_output_step_done "Done"
    else
      nvx_output_step_error "Failed"
      exit
    fi

    echo ""
  fi

  # Download node artifact
  node_artifact="${nvx_node_artifact_path}/${version_exact}.tar.gz"

  if [ ! -f "${node_artifact}" ]; then 
    nvx_output_step "Downloading node artifact..."

    if [ $(nvx_node_download_artifact "${dist_url}" "${version_exact}" "${system_os}" "${system_architecture}" "${node_artifact}") = true ]; then
      nvx_output_step_done "Done"
    else
      nvx_output_step_error "Failed"
      exit
    fi

    echo ""
  fi
}