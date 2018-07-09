#!/bin/bash

#
#  Core
#

nvx_log="${nvx_path}/nvx.log"

# Paths
nvx_path="nvx"
nvx_node_path="${nvx_path}/node"
nvx_node_reference="${nvx_node_path}/reference"

source "nvx/src/output.sh"

#
#  Core - Install
#

nvx_install() {
  local bashrc_file="${HOME}/.bashrc"
  local nvx_content="${nvx_path}/src/bashrc.sh"
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
    cat "${nvx_content}" >> "${bashrc_file}"
    nvx_output_step_done "Updated!"
  fi

  exec bash
}

#
#  Core - Uninstall
#

nvx_uninstall() {
  local bashrc_file="${HOME}/.bashrc"
  local nvx_content="${nvx_path}/src/bashrc.sh"
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
    echo "true"
  else
    echo "false"
  fi
}

nvx_dir_create() {
  local dir=$1

  if ! [[ $(nvx_dir_exists "${dir}") = true ]]; then
    mkdir -p "${dir}" >> $nvx_log 2>&1

    if [ -d "${dir}" ]; then
      echo "true"
    else
      echo "false"
    fi
  else
    echo "already_exists"
  fi
}

nvx_dir_move() {
  local dir=$1
  local target=$2

  if [[ $(nvx_dir_exists "${dir}") = true ]]; then
    mv "${dir}" "${target}" >> $nvx_log 2>&1;

    if [ -d "${target}" ]; then
      echo "true"
    else
      echo "false"
    fi
  else
    echo "already_exists"
  fi
}

nvx_url_download() {
  local url=$1
  local file=$2

  if [ ! -f "${file}" ]; then
    if curl "${url}" -f -o "${file}" >> $nvx_log 2>&1; then
      echo "true"
    else
      echo "false"
    fi
  else
    echo "already_exists"
  fi
}

nvx_extract() {
  local file=$1
  local directory=$2

  if [ $(ls -afq "${directory}" | wc -l) -lt 4 ]; then
    if tar -xvf "${file}" -C "${directory}" >> $nvx_log 2>&1; then
      echo "true"
    else
      echo "false"
    fi
  else
    echo "already_exists"
  fi
}

#
#  Core - Node
#

nvx_node_detect_version() {
  local version=$1
  local file="${PWD}/.nvxrc"

  if [ -z "${version}" ]; then
    if [ -f "${file}" ]; then
      version=$(grep -E 'node_version=[0-9].*' "${file}" | cut -d "=" -f2)
    fi
  fi

  if [ -z "${version}" ]; then
    version="latest"
  fi

  echo "${version}"
}

nvx_node_detect_version_exact() {
  local file=$1

  if [ -f "${file}" ]; then
    local checksums=$(grep -E 'node-v.*\.tar\.gz' "${file}")
    local version=$(echo "${checksums}" | sed 's/^.*-\(v[0-9]*\.[0-9]*\.[0-9]*\).*$/\1/' | head -n 1)

    if [ ! -z "${version}" ]; then
      echo "${version}"
    fi
  fi
}

nvx_node_detect_platform() {
  echo $(command uname -a | cut -d " " -f1 | sed -e 's/\(.*\)/\L\1/')
}

nvx_node_detect_architecture() {
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

nvx_node_download_url() {
  local version=${1:-"latest"}

  if [ "${version}" = "latest" ]; then
    local url="https://nodejs.org/dist/latest"
  else
    local url="https://nodejs.org/dist/latest-v${version}"
  fi

  echo "${url}"
}

nvx_node_reference_store() {
  local reference="${PWD}/${1}"

  if [ ! -f "${nvx_node_reference}" ]; then
    touch "${nvx_node_reference}"
  fi

  echo "${reference}" > "${nvx_node_reference}"

  if grep -q "${reference}" "${nvx_node_reference}"; then
    echo "true"
  else
    echo "false"
  fi
}

nvx_node_install() {
  local version=${1:-"latest"}
  local platform=$(nvx_node_detect_platform)
  local architecture=$(nvx_node_detect_architecture)
  local download_url=$(nvx_node_download_url "${version}")

  # Reset log file
  echo -n "" > $nvx_log

  # Create node path
  nvx_output_step "Creating ${nvx_node_path} directory..."
  local create_node_path=$(nvx_dir_create "${nvx_node_path}")

  if [ "${create_node_path}" = "true" ]; then
    nvx_output_step_done "Done"
  else
    if [ "${create_node_path}" = "already_exists" ]; then
      nvx_output_step_done "Done (already exists)"
    else
      nvx_output_step_error "Failed"
    fi
  fi
  echo ""

  local checksums_url="${download_url}/SHASUMS256.txt"
  local checksums_file="${nvx_node_path}/SHASUMS256-${version}"

  # Download node checksums
  nvx_output_step "Downloading node checksums..."
  local download_node_checksums=$(nvx_url_download "${checksums_url}" "${checksums_file}")

  if [ "${download_node_checksums}" = "true" ]; then
    nvx_output_step_done "Done"
  else
    if [ "${download_node_checksums}" = "already_exists" ]; then
      nvx_output_step_done "Done (already exists)"
    else
      nvx_output_step_error "Failed"
    fi
  fi
  echo ""

  # Detect node version
  nvx_output_step "Detecting node version..."
  local version_exact=$(nvx_node_detect_version_exact "${checksums_file}")

  if [ ! -z "${version_exact}" ]; then
    nvx_output_step_done "Done (${version_exact})"
  else
    nvx_output_step_error "Failed"
  fi
  echo ""

  local artifact_path="${nvx_node_path}/${version_exact}"

  # Create node artifact path
  nvx_output_step "Creating ${artifact_path} directory..."
  local create_node_artifact_path=$(nvx_dir_create "${artifact_path}")

  if [ "${create_node_artifact_path}" = "true" ]; then
    nvx_output_step_done "Done"
  else
    if [ "${create_node_artifact_path}" = "already_exists" ]; then
      nvx_output_step_done "Done (already exists)"
    else
      nvx_output_step_error "Failed"
    fi
  fi
  echo ""

  local artifact_name="node-${version_exact}-${platform}-${architecture}"
  local artifact_file="${artifact_path}/${artifact_name}.tar.gz"
  local artifact_url="${download_url}/${artifact_name}.tar.gz"

  # Download node artifact
  nvx_output_step "Downloading node artifact..."
  local download_node_artifact=$(nvx_url_download "${artifact_url}" "${artifact_file}")

  if [ "${download_node_artifact}" = "true" ]; then
    nvx_output_step_done "Done"
  else
    if [ "${download_node_artifact}" = "already_exists" ]; then
      nvx_output_step_done "Done (already exists)"
    else
      nvx_output_step_error "Failed"
    fi
  fi
  echo ""

  # Extract node artifact
  nvx_output_step "Extacting node artifact..."
  local extract_node_artifact=$(nvx_extract "${artifact_file}" "${artifact_path}")

  if [ "${extract_node_artifact}" = "true" ]; then
    nvx_output_step_done "Done"
  else
    if [ "${extract_node_artifact}" = "already_exists" ]; then
      nvx_output_step_done "Done (already exists)"
    else
      nvx_output_step_error "Failed"
    fi
  fi
  echo ""

  # Move node extract
  nvx_output_step "Moving extracted files..."
  local move_node_extract=$(nvx_dir_move "${artifact_path}/${artifact_name}" "${artifact_path}/node")

  if [ "${move_node_extract}" = "true" ]; then
    nvx_output_step_done "Done"
  else
    if [ "${move_node_extract}" = "already_exists" ]; then
      nvx_output_step_done "Done (already exists)"
    else
      nvx_output_step_error "Failed"
    fi
  fi
  echo ""

  # Activate node
  nvx_output_step "Activating node..."
  local store_node_reference=$(nvx_node_reference_store "${artifact_path}/node/bin")

  if [ "${store_node_reference}" = "true" ]; then
    nvx_output_step_done "Node ${version} is ready to use!"
  else
    nvx_output_step_error "Failed"
  fi
  echo ""
}