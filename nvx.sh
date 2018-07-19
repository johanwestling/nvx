source "nvx/src/core.sh"

nvx_flag=""
nvx_version="1.0.1"
nvx_version_node=""

while [ $# -gt 0 ]; do
  case "$1" in
    --install*)
      nvx_flag="install"
      ;;
    --uninstall*)
      nvx_flag="uninstall"
      ;;
    --enable=*)
      nvx_flag="enable"
      nvx_version_node=$(echo "${1}" | cut -d "=" -f2)
      ;;
    --enable*)
      nvx_flag="enable"
      ;;
  esac
  shift
done

if [ ! -z "${nvx_version_node}" ] || [ -z "${nvx_flag}" ]; then
  nvx_version_node=$(nvx_node_detect_version $nvx_version_node)
fi

if [ "${nvx_flag}" = "install" ]; then
  nvx_install
elif [ "${nvx_flag}" = "uninstall" ]; then
  nvx_uninstall
elif [ "${nvx_flag}" = "enable" ]; then
  nvx_node_install $nvx_version_node
else
  nvx_help $nvx_version_node
fi