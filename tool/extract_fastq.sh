#!/usr/bin/env bash

set -e

filepath=$(
  cd "$(dirname "${0}")" || exit
  pwd -P
)

if [[ $# == 5 ]]; then
  awk '{print $1}' "$1" \
    >"$1"name.txt
  perl "${filepath}"/delete_fastq.pl \
    -n "$1"name.txt \
    -i "$2" \
    -o "$3" &
  perl "${filepath}"/delete_fastq.pl \
    -n "$1"name.txt \
    -i "$4" \
    -o "$5" &
  wait
  rm "$1"name.txt
elif [[ $# == 3 ]]; then
  awk '{print $1}' "$1" \
    >"$1"name.txt
  perl "${filepath}"/delete_fastq.pl \
    -n "$1"name.txt \
    -i "$2" \
    -o "$3"
  rm "$1"name.txt
else
  echo "Improper Number of Files."
fi
