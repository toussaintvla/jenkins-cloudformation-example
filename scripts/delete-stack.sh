#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Enter stack-name to delete & Please specify user profile."
    exit 0
else
    stack_name=$1
    region=$2
fi

aws cloudformation delete-stack \
--stack-name $stack_name \
--region $region

aws cloudformation wait stack-delete-complete \
--stack-name $stack_name \
--region $region