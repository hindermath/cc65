#! /bin/bash

SCRIPT_PATH=$(cd "$(dirname "$0")" && pwd)
TEST_PATH=$(mktemp -d "${TMPDIR:-/tmp}/cc65-noexec.XXXXXX") || exit 1
SOURCE_PATH="$TEST_PATH/path with spaces/source file.c"
SCRIPT_FILE="$TEST_PATH/allowed.sh"
ERROR_FILE="$TEST_PATH/error.log"

cleanup ()
{
    chmod -R u+rwX "$TEST_PATH"
    rm -rf "$TEST_PATH"
}

trap cleanup EXIT

mkdir -p "$(dirname "$SOURCE_PATH")"
echo "int main (void) { return 0; }" > "$SOURCE_PATH"

# Eine normale Quelldatei muss akzeptiert werden.
# A regular source file must be accepted.
if ! "$SCRIPT_PATH/noexec.sh" "$TEST_PATH"; then
    echo "error: noexec rejected a non-executable source file" >&2
    exit 1
fi

# Eine ausfuehrbare Quelldatei muss gemeldet werden.
# An executable source file must be reported.
chmod u+x "$SOURCE_PATH"
if "$SCRIPT_PATH/noexec.sh" "$TEST_PATH" 2> "$ERROR_FILE"; then
    echo "error: noexec accepted an executable source file" >&2
    exit 1
fi
if ! grep -F "$SOURCE_PATH" "$ERROR_FILE" > /dev/null; then
    echo "error: noexec did not report the executable source file" >&2
    exit 1
fi

# Ausfuehrbare Skripte gehoeren nicht zur verbotenen Dateiauswahl.
# Executable scripts aren't part of the prohibited file selection.
chmod u-x "$SOURCE_PATH"
echo "#! /bin/bash" > "$SCRIPT_FILE"
chmod u+x "$SCRIPT_FILE"
if ! "$SCRIPT_PATH/noexec.sh" "$TEST_PATH"; then
    echo "error: noexec rejected an allowed executable script" >&2
    exit 1
fi
