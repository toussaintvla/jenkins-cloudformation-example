#!/bin/bash

# Please ensure that you have the correct AWS credentials configured.
# Enter the name of the stack you want to delete, then enter the name of the region.

if [ $# -ne 2 ]; then
    echo "Enter stack name to delete & region name."
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