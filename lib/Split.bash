#!/bin/bash
##
## Copyright (c) 2014 SATOH Fumiyasu @ OSS Technology Corp., Japan
##
## License: GNU General Public License version 3
##

SplitFast() {
  local dst="$1"
  local sep="$2"
  local src="${3-:}"

  [[ $dst =~ [_a-zA-Z][_a-zA-Z0-9]* ]] || {
    echo "ERROR: split_fast(): Invalid destination variable name: $dst" 1>&1
    return 1
  }

  local IFS="$sep"
  eval "$dst=(\$src)"

  return 0
}

Split() {
  local dst="$1"
  local src="$2"
  local sep="${3-:}"

  [[ $dst =~ [_a-zA-Z][_a-zA-Z0-9]* ]] || {
    echo "ERROR: Split(): Invalid destination variable name: $dst" 1>&2
    return 1
  }

  case ${#sep} in
  0)
    echo "ERROR: Split(): Splitting into each chars not implemented" 1>&2
    return 1
    ;;
  1)
    sep="\\$sep"
    ;;
  *)
    sep="${sep//\\/\\\\}"
    sep="${sep//!/\\!}"
    sep="${sep//^/\\^}"
    sep="${sep//-/\\-}"
    sep="${sep//\[/\\[}"
    sep="${sep//\]/\\]}"
    ;;
  esac

  local dst_tmp=()
  local src_tmp
  while :; do
    dst_tmp+=("${src%%[$sep]*}")
    src_tmp="${src#*[$sep]}"
    [[ $src_tmp == $src ]] && break
    src="$src_tmp"
  done

  eval "$dst=(\"\${dst_tmp[@]}\")"

  return 0
}

function test_split {
  set -u
  set -e

  function dump_args {
    local v
    local n=1
    echo -n "${#@}"
    for v in "$@"; do
      echo -n " [$v]"
      let n++
    done
    echo
  }

  Split var 'foo:bar:baz'
  dump_args "${var[@]}"

  Split var 'foo:bar:baz' :a
  dump_args "${var[@]}"

  Split var 'f o o:b a r:baz'
  dump_args "${var[@]}"

  Split var 'f o o:b a r:baz' ' :'
  dump_args "${var[@]}"

  Split var ' foo:bar:baz '
  dump_args "${var[@]}"

  Split var ' foo::baz '
  dump_args "${var[@]}"

  Split var 'foo::baz'
  dump_args "${var[@]}"

  Split var 'foo::'
  dump_args "${var[@]}"

  Split var '::foo'
  dump_args "${var[@]}"

  Split var ':'
  dump_args "${var[@]}"

  Split var '::'
  dump_args "${var[@]}"

  Split var '* : /*'
  dump_args "${var[@]}"
}

if [[ ${0##*/} == Split.bash ]]; then
  test_split
fi
 
