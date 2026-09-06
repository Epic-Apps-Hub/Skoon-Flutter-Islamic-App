#!/usr/bin/env bash
set -euo pipefail

if [ ! -f pubspec.yaml ]; then
  echo "لم أجد pubspec.yaml."
  exit 1
fi

deps=$(awk '/^dependencies:/,/^[^ ]/{if($1!~/^dependencies:|^dev_dependencies:|^flutter:|^#/){gsub(/:$/,"\""); sub(/^[ \t]+/,"\""); if(length($0)>0) print $1}}' pubspec.yaml || true)

echo "تحقق احتمال استخدام الحزم:"
for d in $deps; do
  if grep -RIn --exclude-dir=.git -e "package:$d/" . >/dev/null 2>&1; then
    echo "FOUND: $d"
  else
    echo "MAYBE_UNUSED: $d"
  fi
done
