#!/bin/bash

#
#  Output
#

nvx_output_line_length=80

# Style
nvx_output_style_default="\033[0m"
nvx_output_style_bright="\033[1m"
nvx_output_style_dim="\033[2m"
nvx_output_style_underline="\033[4m"

# Colors
nvx_output_color_default="\033[39;49m"

# Colors - Foreground
nvx_output_color_foreground_default="\033[39m"
nvx_output_color_foreground_black="\033[30m"
nvx_output_color_foreground_red="\033[31m"
nvx_output_color_foreground_green="\033[32m"
nvx_output_color_foreground_yellow="\033[33m"
nvx_output_color_foreground_blue="\033[34m"
nvx_output_color_foreground_magenta="\033[35m"
nvx_output_color_foreground_cyan="\033[36m"

# Colors - Background
nvx_output_color_background_default="\033[49m"
nvx_output_color_background_black="\033[40m"
nvx_output_color_background_red="\033[41m"
nvx_output_color_background_green="\033[42m"
nvx_output_color_background_yellow="\033[43m"
nvx_output_color_background_blue="\033[44m"
nvx_output_color_background_magenta="\033[45m"
nvx_output_color_background_cyan="\033[46m"

# Boxes
nvx_output_box_color_foreground="${nvx_output_color_foreground_red}"
nvx_output_box_horizontal="━"
nvx_output_box_vertical="┃"
nvx_output_box_top_left="┏"
nvx_output_box_top_right="┓"
nvx_output_box_bottom_left="┗"
nvx_output_box_bottom_right="┛"
nvx_output_box_separator="╌"

# Steps
nvx_output_step_prefix="−→ "
nvx_output_step_prefix_color_foreground="${nvx_output_color_foreground_red}"
nvx_output_step_done_prefix=" › "
nvx_output_step_error_prefix=" ! "

# Separators
nvx_output_separator="╌"
nvx_output_separator_color_foreground="${nvx_output_color_foreground_red}"

#
#  Output - Boxes
#

nvx_output_box_start() {
  local box_width=$(($nvx_output_line_length - 3))
  local box_border=$(eval printf "${nvx_output_box_horizontal}"'%.0s' {1..$box_width})
  local box_padding=$(printf "%${box_width}s")

  echo -e "${nvx_output_box_color_foreground}${nvx_output_box_top_left}${box_border}${nvx_output_box_top_right}${nvx_output_color_foreground_default}"
  echo -e "${nvx_output_box_color_foreground}${nvx_output_box_vertical}${box_padding}${nvx_output_box_vertical}${nvx_output_color_foreground_default}"
}

nvx_output_box_text() {
  # Defaults
  local box_input="$1"
  local box_justify="left"
  local box_style="default"

  # Overrides
  while [ $# -gt 0 ]; do
    case "$1" in
      --justify=*)
        box_justify="${1#*=}"
        ;;
      --style=*)
        box_style="${1#*=}"
        ;;
    esac
    shift
  done

  local box_input_length=${#box_input}
  local box_line_length=$(($nvx_output_line_length - 9))
  local box_output=$(echo "${box_input}" | fold -sw $box_line_length)
  local box_output_style='$nvx_output_style_'${box_style}
  eval box_output_style=${box_output_style}
  
  # Loop each line of box_output
  while read -r box_line; do
    box_padding=$(($box_line_length - ${#box_line}))

    if [ "$box_justify" = "right" ]; then
      box_line=$(printf "%${box_padding}s$box_line")
    elif [ "$box_justify" = "center" ]; then
      box_padding_left=$(($box_padding / 2))
      box_padding_right=$(($box_padding - $box_padding_left))
      box_line=$(printf "%${box_padding_left}s$box_line%${box_padding_right}s")
    else
      box_line=$(printf "$box_line%${box_padding}s")
    fi

    echo -e "${nvx_output_box_color_foreground}${nvx_output_box_vertical}${nvx_output_color_foreground_default}${box_output_style}   ${box_line}   ${nvx_output_style_default}${nvx_output_box_color_foreground}${nvx_output_box_vertical}${nvx_output_color_foreground_default}"
  done <<< "$box_output"
}

nvx_output_box_separator() {
  local box_width=$(($nvx_output_line_length - 9))
  local box_separator=$(eval printf "${nvx_output_box_separator}"'%.0s' {1..$box_width})

  echo -e "${nvx_output_box_color_foreground}${nvx_output_box_vertical}${nvx_output_style_dim}   ${box_separator}   ${nvx_output_style_default}${nvx_output_box_color_foreground}${nvx_output_box_vertical}${nvx_output_color_foreground_default}"
}

nvx_output_box_stop() {
  local box_width=$(($nvx_output_line_length - 3))
  local box_border=$(eval printf "${nvx_output_box_horizontal}"'%.0s' {1..$box_width})
  local box_padding=$(printf "%${box_width}s")

  echo -e "${nvx_output_box_color_foreground}${nvx_output_box_vertical}${box_padding}${nvx_output_box_vertical}${nvx_output_color_foreground_default}"
  echo -e "${nvx_output_box_color_foreground}${nvx_output_box_bottom_left}${box_border}${nvx_output_box_bottom_right}${nvx_output_color_foreground_default}"
}

#
#  Output - Steps
#

nvx_output_step() {
  local step_width=$(($nvx_output_line_length - ${#nvx_output_step_prefix}))
  local step_output=$(echo "${1}" | fold -sw $step_width)
  local step_output_lines=0
  local step_indent=$(eval printf '%${#nvx_output_step_prefix}s')

  while read -r step_line; do
    if [ $step_output_lines -eq 0 ]; then
      echo -e "${nvx_output_step_prefix_color_foreground}${nvx_output_style_bright}${nvx_output_step_prefix}${nvx_output_style_default}${nvx_output_color_foreground_default}${step_line}${nvx_output_style_default}"
    else
      echo -e "${step_indent}${step_line}${nvx_output_style_default}"
    fi

    step_output_lines=$(($step_output_lines + 1))
  done <<< "$step_output"
}

nvx_output_step_done() {
  local step_width=$(($nvx_output_line_length - ${#nvx_output_step_prefix}))
  local step_output=$(echo "${1}" | fold -sw $step_width)
  local step_output_lines=0
  local step_indent=$(eval printf " "'%.0s' {1..${#nvx_output_step_prefix}})

  while read -r step_line; do
    if [ $step_output_lines -eq 0 ]; then
      echo -e "${nvx_output_step_prefix_color_foreground}${nvx_output_step_done_prefix}${nvx_output_color_foreground_default}${nvx_output_style_bright}${step_line}${nvx_output_style_default}"
    else
      echo -e "${step_indent}${nvx_output_style_bright}${step_line}${nvx_output_style_default}"
    fi

    step_output_lines=$(($step_output_lines + 1))
  done <<< "$step_output"
}

nvx_output_step_error() {
  local step_width=$(($nvx_output_line_length - ${#nvx_output_step_prefix}))
  local step_output=$(echo "${1}" | fold -sw $step_width)
  local step_output_lines=0
  local step_indent=$(eval printf " "'%.0s' {1..${#nvx_output_step_prefix}})

  while read -r step_line; do
    if [ $step_output_lines -eq 0 ]; then
      echo -e "${nvx_output_step_prefix_color_foreground}${nvx_output_step_error_prefix}${nvx_output_color_foreground_default}${nvx_output_style_bright}${step_line}${nvx_output_style_default}"
    else
      echo -e "${step_indent}${nvx_output_style_bright}${step_line}${nvx_output_style_default}"
    fi

    step_output_lines=$(($step_output_lines + 1))
  done <<< "$step_output"
}

#
#  Output - Separators
#

nvx_output_separator() {
  local separator_width=$(($nvx_output_line_length - 1))
  local separator_output=$(eval printf "${nvx_output_separator}"'%.0s' {1..$separator_width})

  echo -e "${nvx_output_separator_color_foreground}${separator_output}${nvx_output_color_foreground_default}"
}