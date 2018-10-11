#!/bin/bash

function nvx_text_wrap {
  local text="${1}"
  local line_length=${2:-80}
  local wrapped_text=$(echo -e "${text}" | fold -sw $line_length)

  while read -r text_line; do
    echo -e "${text_line}"
  done <<< "${wrapped_text}"
}

function nvx_text_pad {
  local line="${1}"
  local line_length=${2:-80}
  local line_padding=$((${line_length} - ${#line}))

  if [ ${line_padding} -gt 0 ]; then
    line=$(printf "${line}%${line_padding}s")
    echo -e "${line}"
  else
    echo -e "${line}"
  fi
}

function nvx_box_top {
  local line_length=74
  local line=$(nvx_text_pad "" $line_length)
  local border_length=78
  local border_color="\033[33m"
  local border_color_reset="\033[39m"
  local border_line_horizontal="━"
  local border_line_vertical="┃"
  local border_line_corner_left="┏"
  local border_line_corner_right="┓"
  local border_line=$(eval printf "${border_line_horizontal}"'%.0s' {1..$border_length})

  # Box top line
  echo -ne "${border_color}${border_line_corner_left}"
  echo -ne "${border_line}"
  echo -e "${border_line_corner_right}${border_color_reset}"

  # Box padding
  echo -ne "${border_color}${border_line_vertical}${border_color_reset}  "
  echo -ne "${line}"
  echo -e "  ${border_color}${border_line_vertical}${border_color_reset}"
}

function nvx_box_bottom {
  local line_length=74
  local line=$(nvx_text_pad "" $line_length)
  local border_length=78
  local border_color="\033[33m"
  local border_color_reset="\033[39m"
  local border_line_horizontal="━"
  local border_line_vertical="┃"
  local border_line_corner_left="┗"
  local border_line_corner_right="┛"
  local border_line=$(eval printf "${border_line_horizontal}"'%.0s' {1..$border_length})

  # Box bottom line
  echo -ne "${border_color}${border_line_corner_left}"
  echo -ne "${border_line}"
  echo -e "${border_line_corner_right}${border_color_reset}"
}

function nvx_box_head {
  local line_length=74
  local text=$(nvx_text_wrap "${1}" $line_length)
  local end_with_new_line="${2}"
  local text_style="\033[1m"
  local text_style_reset="\033[0m"
  local border_color="\033[33m"
  local border_color_reset="\033[39m"
  local border_line_vertical="┃"

  # Head lines
  while read -r line; do
    line=$(nvx_text_pad "${line}" $line_length)
    echo -ne "${border_color}${border_line_vertical}${border_color_reset}  "
    echo -ne "${text_style}${line}${text_style_reset}"
    echo -e "  ${border_color}${border_line_vertical}${border_color_reset}"
  done <<< "${text}"

  if [ -z "${end_with_new_line}" ]; then
    # Head padding
    line=$(nvx_text_pad "" $line_length)
    echo -ne "${border_color}${border_line_vertical}${border_color_reset}  "
    echo -ne "${line}"
    echo -e "  ${border_color}${border_line_vertical}${border_color_reset}"
  fi
}

function nvx_box_text {
  local line_length=74
  local text=$(nvx_text_wrap "${1}" $line_length)
  local end_with_new_line="${2}"
  local border_color="\033[33m"
  local border_color_reset="\033[39m"
  local border_line_horizontal="━"
  local border_line_vertical="┃"
  local border_line_top_left="┏"
  local border_line_top_right="┓"
  local border_line_bottom_left="┗"
  local border_line_bottom_right="┛"

  while read -r line; do
    line=$(nvx_text_pad "${line}" $line_length)
    echo -ne "${border_color}${border_line_vertical}${border_color_reset}  "
    echo -ne "${line}"
    echo -e "  ${border_color}${border_line_vertical}${border_color_reset}"
  done <<< "${text}"

  if [ -z "${end_with_new_line}" ]; then
    # Body padding
    line=$(nvx_text_pad "" $line_length)
    echo -ne "${border_color}${border_line_vertical}${border_color_reset}  "
    echo -ne "${line}"
    echo -e "  ${border_color}${border_line_vertical}${border_color_reset}"
  fi
}
