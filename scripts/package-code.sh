#!/bin/bash

DIR="$1"
S3_BUCKET="$2"
S3_KEY="$3"
PREP_CMD="$4"
INSTALL_CMD="$5"
TEST_CMD="$6"

if [[ -z "$DIR" ]] || [[ -z "$S3_BUCKET" ]] || [[ -z "$S3_KEY" ]]; then
    echo "usage: package-code.sh <s3-bucket> <s3-key> <code-dir> [prep-command] [install-command] [test-command]"
    exit 1
fi

NAME="$(basename "$DIR")"

mkdir -p "/tmp/$NAME"
cp -r $DIR/* "/tmp/$NAME/"
cd "/tmp/$NAME"

if [[ -n "$PREP_CMD" ]]; then
    bash -c "$PREP_CMD"
fi

if [[ -n "$INSTALL_CMD" ]]; then
    if ! bash -c "$INSTALL_CMD"; then
        echo "installation command failed - please fix any issues and try again"
        exit 1
    fi
fi

if [[ -n "$TEST_CMD" ]]; then
    if ! bash -c "$TEST_CMD"; then
        echo "some tests failed - please fix any issues and try again"
        exit 1
    fi
fi

if [[ -n "$POST_TEST_CMD" ]]; then
    bash -c "$POST_TEST_CMD"
fi

zip -rq "/tmp/$NAME.zip" .

aws s3api put-object --bucket "$S3_BUCKET" --key "code/$S3_KEY.zip" --body "/tmp/$NAME.zip" >/dev/null

rm -rf "/tmp/$NAME"
rm -rf "/tmp/$NAME.zip"

printf -- "code packaging finished for $NAME\n"
