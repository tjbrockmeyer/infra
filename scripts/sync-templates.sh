#!/bin/bash

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$DIR/.."

BUCKET=$(aws ssm get-parameter --name ' /global/bucket-name' --output text --query 'Parameter.Value')
for FILE in templates/*.yml; do
    aws s3api put-object --bucket "$BUCKET" --key "$FILE" --body "$FILE" >/dev/null && printf -- "finished uploading $FILE\n" &
done
