#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Enter stack name & template file name to create. - You must set changeset vale (true or false)."
    exit 0
fi

if [ ! -f "cloudformation/$2.yaml" ]; then
    echo "CloudFormation template $2.yaml does not exist"
    exit 0
fi

if [ ! -f "parameters/$1-parameters.properties" ]; then
    echo "CloudFormation parameters $1-parameters.properties does not exist"
    exit 0
fi

if [[ $3 == true ]]; then
    aws cloudformation deploy \
    --stack-name $1 \
    --template-file cloudformation/$2.yaml \
    --parameter-overrides file://parameters/$1-parameters.properties \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-east-1 \
else
    aws cloudformation deploy \
    --stack-name $1 \
    --template-file cloudformation/$2.yaml \
    --parameter-overrides file://parameters/$1-parameters.properties \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-east-1 \
    --no-execute-changeset \
fi