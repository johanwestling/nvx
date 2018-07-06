source ".nvx/functions.sh"

nvx_flag_install=false

while [ $# -gt 0 ]; do
  case "$1" in
    --install*)
      nvx_flag_install=true
      ;;
  esac
  shift
done

if [ "$nvx_flag_install" = true ]; then
  nvx_install
fi

# NVX node arguments
nvx_node_version=$(nvx_node_version $1)

nvx_output_box_start
nvx_output_box_text "NVX" --style="bright"
nvx_output_box_separator
nvx_output_box_text "Version:            v0.0.1"
nvx_output_box_text "Author:             Johan Westling"
nvx_output_box_separator
nvx_output_box_text "Node version:       ${nvx_node_version}"
nvx_output_box_stop