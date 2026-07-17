#! /bin/bash

SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
CHECK_PATH=${1:-.}
FOUND=0

cd "$SCRIPT_PATH/../../" || exit 1

if [ ! -d "$CHECK_PATH" ]; then
    echo "error: check path does not exist: $CHECK_PATH" >&2
    exit 1
fi

# NUL-Trennung erhaelt Leerzeichen in Dateinamen.
# NUL separation preserves whitespace in file names.
while IFS= read -r -d '' FILE; do
    if [ "$FOUND" -eq 0 ]; then
        echo "error: executable flag is set for the following files:" >&2
    fi
    echo "$FILE" >&2
    FOUND=1
done < <(
    find "$CHECK_PATH" -type f \
        \( -name '*.inc' -o -name Makefile -o -name '*.cfg' \
        -o -name '*.[chs]' -o -name '*.mac' -o -name '*.asm' \
        -o -name '*.sgml' \) \
        -exec test -x {} \; -print0
)

exit "$FOUND"
