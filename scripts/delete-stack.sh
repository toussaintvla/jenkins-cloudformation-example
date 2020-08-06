#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Enter stack-name to delete & Please specify user profile."
    exit 0
fi

aws cloudformation delete-stack \
--stack-name $1 \
--region us-east-2
# --profile $2

aws cloudformation wait stack-delete-complete \
--stack-name $1 \
# --profile $2
