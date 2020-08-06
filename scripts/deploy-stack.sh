#!/bin/bash

if [ $# -ne 3 ]; then
    echo "Enter stack name & template file name to create. - You must set changeset."
    exit 0
fi

if [ ! -f "templates/$2.yaml" ]; then
    echo "CloudFormation template $2.yaml does not exist"
    exit 0
fi

if [ ! -f "tags/cfn-tags.properties" ]; then
    echo "CloudFormation tags cfn-tags.properties does not exist"
    exit 0
fi

if [ ! -f "parameters/$1-parameters.properties" ]; then
    echo "CloudFormation parameters $1-parameters.properties does not exist"
    exit 0
fi

if [[ $3 == true ]]; then
    aws cloudformation deploy \
    --stack-name $1 \
    --template-file templates/$2.yaml \
    --tags file://tags/cfn-tags.properties \
    --parameter-overrides file://parameters/$1-parameters.properties \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-east-1 \
    # --profile $3
else
    aws cloudformation deploy \
    --stack-name $1 \
    --template-file templates/$2.yaml \
    --tags file://tags/cfn-tags.properties \
    --parameter-overrides file://parameters/$1-parameters.properties \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-east-1 \
    --no-execute-changeset \
    # --profile $3
fi