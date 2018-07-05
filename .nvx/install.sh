#!/bin/bash

nvx_node_url="https://nodejs.org/dist/latest-v${nvx_node_version}"
if [ "${nvx_node_version}" = "latest" ]; then
  nvx_node_url="https://nodejs.org/dist/latest"
fi

# Create node path
if [ ! -d "${nvx_node_path}" ]; then
  nvx_output_step "Creating node path... (${nvx_node_path})"
  mkdir -p "${nvx_node_path}"

  if [ ! -d "${nvx_node_path}" ]; then
    nvx_output_step_error "Failed to create node path..."
  fi
fi

# Download node checksums
nvx_node_checksums_url="${nvx_node_url}/SHASUMS256.txt"
nvx_node_checksums_file="${nvx_node_path}/SHASUMS256-node-${nvx_node_version}"

if [ ! -f "${nvx_node_checksums_file}" ]; then
  nvx_output_step "Downloading node checksums... (${nvx_node_checksums_url})"
  
  nvx_output_separator
  touch "${nvx_node_checksums_file}"
  curl "${nvx_node_checksums_url}" -o "${nvx_node_checksums_file}"
  nvx_output_separator
  
  if [ ! -f "${nvx_node_checksums_file}" ]; then
    nvx_output_step_error "Failed to download node checksums..."
  fi
fi

# Detect exact version
nvx_node_checksums=$(grep -E 'node-v.*\.tar\.gz' "${nvx_node_checksums_file}")
nvx_node_version_exact=$(echo "${nvx_node_checksums}" | sed 's/^.*-\(v[0-9]*\.[0-9]*\.[0-9]*\).*$/\1/' | head -n 1)

if [ ! -z "${nvx_node_version_exact}" ]; then
  nvx_output_step "Detected exact node ${nvx_node_version_exact}"
else
  nvx_output_step_error "Failed to detect exact node version..."
fi

# Detect architecture
nvx_node_system_os=$(command uname -a | cut -d " " -f1 | sed -e 's/\(.*\)/\L\1/')
case $(command uname -m) in
  x86_64 | amd64)
    nvx_node_system_architecture="x64"
    ;;
  i*86)
    nvx_node_system_architecture="x86"
    ;;
  aarch64)
    nvx_node_system_architecture="arm64"
    ;;
esac

if [ ! -z "${nvx_node_system_architecture}" ]; then
  nvx_output_step "Detected node system arcitecture (${nvx_node_system_os}-${nvx_node_system_architecture})"
else
  nvx_output_step_error "Failed to detect node system arcitecture..."
fi

# Create node artifact path
if [ ! -d "${nvx_node_artifact_path}" ]; then
  nvx_output_step "Creating node artifact path... (${nvx_node_artifact_path})"
  mkdir -p "${nvx_node_artifact_path}"

  if [ ! -d "${nvx_node_artifact_path}" ]; then
    nvx_output_step_error "Failed to create node artifact path..."
  fi
fi

# Download node artifact
nvx_node_artifact_url="${nvx_node_url}/node-${nvx_node_version_exact}-${nvx_node_system_os}-${nvx_node_system_architecture}.tar.gz"
nvx_node_artifact_name="node-${nvx_node_version_exact}-${nvx_node_system_os}-${nvx_node_system_architecture}"
nvx_node_artifact_file="${nvx_node_artifact_path}/${nvx_node_artifact_name}.tar.gz"

if [ ! -f "${nvx_node_artifact_file}" ]; then
  nvx_output_step "Downloading node artifact... (${nvx_node_artifact_url})"
  
  nvx_output_separator
  touch "${nvx_node_artifact_file}"
  curl "${nvx_node_artifact_url}" -o "${nvx_node_artifact_file}"
  nvx_output_separator
  
  if [ ! -f "${nvx_node_artifact_file}" ]; then
    nvx_output_step_error "Failed to download node artifact..."
  fi
fi

# Create node binary path
if [ ! -d "${nvx_node_binary_path}" ]; then
  nvx_output_step "Creating node binary path... (${nvx_node_binary_path})"
  mkdir -p "${nvx_node_binary_path}"

  if [ ! -d "${nvx_node_binary_path}" ]; then
    nvx_output_step_error "Failed to create node binary path..."
  fi
fi

# Extract node artifact to binary path
nvx_node_binary_location="${nvx_node_binary_path}/${nvx_node_artifact_name}"

if [ ! -d "${nvx_node_binary_location}" ]; then
  nvx_output_step "Extracting node artifact to binary path... (${nvx_node_binary_path})"
  
  nvx_output_separator
  tar -xvf "${nvx_node_artifact_file}" -C "${nvx_node_binary_path}" | cut -b1-$(tput cols) | sed -u 'i\\o033[2K' | stdbuf -o0 tr '\n' '\r'; echo
  nvx_output_separator
fi

# Create node binary file
nvx_node_binary_file="${nvx_node_path}/node_bin"

if [ ! -f "${nvx_node_binary_file}" ]; then
  nvx_output_step "Creating node binary file... (${nvx_node_binary_file})"
  touch "${nvx_node_binary_file}"

  if [ ! -f "${nvx_node_binary_file}" ]; then
    nvx_output_step_error "Failed to create node binary file..."
  fi
fi

# Write node binary reference to node binary file.
if [ -f "${nvx_node_binary_file}" ]; then
  nvx_output_step "Writing binary reference to node binary file... (${nvx_node_binary_file})"
  echo "${nvx_node_binary_location}/bin" > "${nvx_node_binary_file}"
fi