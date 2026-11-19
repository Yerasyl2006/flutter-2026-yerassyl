#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."

http_files=$(grep -rl --include='*.dart' 'package:http' lib/ || test "$?" -eq 1)
material_files=$(grep -rl --include='*.dart' 'package:flutter/material' lib/ || test "$?" -eq 1)
violations=$(
  printf '%s\n' "$http_files" | grep -v -e '^$' -e '^lib/core/api/' -e '_repository\.dart$' || true
  printf '%s\n' "$material_files" | grep -e '_model\.dart$' -e '_repository\.dart$' -e '^lib/core/api/' || true
)
if [ -n "$violations" ]; then
  printf '%s\n' "$violations"
  exit 1
fi
