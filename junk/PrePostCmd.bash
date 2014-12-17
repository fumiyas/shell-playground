#!/bin/bash
##
## Copyright (c) 2014 SATOH Fumiyasu @ OSS Technology Corp., Japan
##
## License: GNU General Public License version 3
##
## Inspired by:
##   * preexec.bash -- Bash support for ZSH-like 'preexec' and 'precmd' functions.
##     * http://hints.macworld.com/dlfiles/preexec.bash.txt
##

## FIXME: Work In Progress ... (不完全です!)

prepostcmd_path="$PATH"

function precmd {
  :
}

function postcmd {
  :
}

function prepostcmd_exec {
  local PATH="$prepostcmd_path"
  local ret
  type "$1" >/dev/null 2>&1 || {
    echo "$1: command not found" 1>&2
    return 127
  }

  precmd "$@"
  "$@"
  ret=$?
  postcmd "$ret" "$@"

  return $ret
}

function prepostcmd_install {
  prepostcmd_path="${PATH:-$prepostcmd_path}"
  PATH=/nonexistent
  function command_not_found_handle { prepostcmd_exec "$@"; }
}

