#!/bin/bash

if [ $# -ne 4 ]; then
    echo "Enter stack name & template file name to create. - You must set changeset vale (true or false)."
    exit 0
else
    stack_name=$1
    template_name=$2
    changeset_option=$3
    region=$4
fi

if [ ! -f "cloudformation/$template_name.yaml" ]; then
    echo "CloudFormation template $template_name.yaml does not exist"
    exit 0
fi

if [ ! -f "parameters/$stack_name-parameters.properties" ]; then
    echo "CloudFormation parameters $stack_name-parameters.properties does not exist"
    exit 0
fi

if [[ $changeset_option == true ]]; then
    aws cloudformation deploy \
    --stack-name $stack_name \
    --template-file cloudformation/$template_name.yaml \
    --parameter-overrides file://parameters/$stack_name-parameters.properties \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $region
else
    aws cloudformation deploy \
    --stack-name $stack_name \
    --template-file cloudformation/$template_name.yaml \
    --parameter-overrides file://parameters/$stack_name-parameters.properties \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $region \
    --no-execute-changeset
fi