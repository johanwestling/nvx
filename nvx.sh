source "nvx/src/core.sh"

nvx_flag_install=""
nvx_flag_uninstall=""
nvx_flag_node_version=""

while [ $# -gt 0 ]; do
  case "$1" in
    --install*)
      # Capture install flag
      nvx_flag_install=true
      ;;
    --uninstall*)
      # Capture uninstall flag
      nvx_flag_uninstall=true
      ;;
    --node=*)
      # Capture node flag with specific version
      nvx_flag_node_version=$(echo "${1}" | cut -d "=" -f2)
      ;;
    --node*)
      # Capture node flag without defined version
      nvx_flag_node_version="latest"
      ;;
  esac
  shift
done

if [ "$nvx_flag_uninstall" = true ]; then
  nvx_uninstall
fi

if [ "$nvx_flag_install" = true ]; then
  nvx_install
fi

nvx_node_version=$(nvx_node_detect_version $nvx_flag_node_version)

echo ""

nvx_output_box_start
nvx_output_box_text "NVX" --style="bright"
nvx_output_box_separator
nvx_output_box_text "Version:            v0.0.3"
nvx_output_box_text "Author:             Johan Westling"
nvx_output_box_separator
nvx_output_box_text "Node version:       ${nvx_node_version}"
nvx_output_box_stop

echo ""

if [ ! -f "${nvx_node_binary_path}/${nvx_node_version}" ]; then
  # Install required node version
  nvx_node_install $nvx_node_version
fi