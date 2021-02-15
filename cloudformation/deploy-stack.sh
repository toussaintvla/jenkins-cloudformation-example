#!/bin/bash

# Please ensure that you have the correct AWS credentials configured.
# Enter the name of the stack, the template name, then changeset condition, and finally the region name.

if [ $# -ne 5 ]; then
    echo "Enter stack name, template file name to create, set changeset value (true or false), role arn, and enter region name. "
    exit 0
else
    STACK_NAME=$1
    TEMPLATE_NAME=$2
    CHANGESET_MODE=$3
    CFN_CREDENTIALS_ID=$4
    REGION=$5
fi

source switch-role.sh ${CFN_CREDENTIALS_ID} ${REGION}

if [ ! -f "cloudformation/$TEMPLATE_NAME.yaml" ]; then
    echo "CloudFormation template $TEMPLATE_NAME.yaml does not exist"
    exit 0
fi

if [ ! -f "parameters/$STACK_NAME-parameters.properties" ]; then
    echo "CloudFormation parameters $STACK_NAME-parameters.properties does not exist"
    exit 0
fi

if [[ $CHANGESET_MODE == true ]]; then
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