#!/bin/bash

# Please ensure that you have the correct AWS credentials configured.
# Enter the name of the stack, the template name, then changeset condition, and finally the region name.

if [ $# -ne 4 ]; then
    echo "Enter stack name, template file name to create, set changeset vale (true or false), and enter region name. "
    exit 0
else
    STACK_NAME=$1
    TEMPLATE_NAME=$2
    CHANGESET_OPTION=$3
    REGION=$4
fi

if [ ! -f "cloudformation/$TEMPLATE_NAME.yaml" ]; then
    echo "CloudFormation template $TEMPLATE_NAME.yaml does not exist"
    exit 0
fi

if [ ! -f "parameters/$STACK_NAME-parameters.properties" ]; then
    echo "CloudFormation parameters $STACK_NAME-parameters.properties does not exist"
    exit 0
fi

if [[ $CHANGESET_OPTION == true ]]; then
    aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file cloudformation/$TEMPLATE_NAME.yaml \
    --parameter-overrides file://parameters/$STACK_NAME-parameters.properties \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION
else
    aws cloudformation deploy \
    --stack-name $STACK_NAME \
    --template-file cloudformation/$TEMPLATE_NAME.yaml \
    --parameter-overrides file://parameters/$STACK_NAME-parameters.properties \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $REGION \
    --no-execute-changeset
fi