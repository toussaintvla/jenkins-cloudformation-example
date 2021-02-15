#!/bin/bash
# Provides the ability to assume an IAM Role and sets credentails as environment variables
set +x

unset AWS_ACCESS_KEY_ID
unset AWS_DEFAULT_REGION
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

if [ $# -ne 2 ]; then
    echo "Enter the ROLE ARN and Region."
    exit 0
fi

ROLE_ARN=$1
REGION=$2

DATE_STAMP=$(date +%s)
echo "Date Stamp: ${DATE_STAMP}
Role: ${ROLE_ARN}
Region: ${REGION}
"

TEMP_PATH="/tmp/aws-temp-creds-${REGION}-${DATE_STAMP}"

aws sts assume-role --role-arn ${ROLE_ARN} --role-session-name jenkins-${DATE_STAMP} --region ${REGION} > ${TEMP_PATH}

ACCESS_KEY_ID=$(cat ${TEMP_PATH} | grep "AccessKeyId" | awk '{print $2}' | cut -d '"' -f 2)
SECRET_ACCESS_KEY=$(cat ${TEMP_PATH} | grep "SecretAccessKey" | awk '{print $2}' | cut -d '"' -f 2)
SESSION_TOKEN=$(cat ${TEMP_PATH} | grep "Token" | awk '{print $2}' | cut -d '"' -f 2)

export AWS_ACCESS_KEY_ID=${ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${SECRET_ACCESS_KEY}
export AWS_SESSION_TOKEN=${SESSION_TOKEN}
export AWS_DEFAULT_REGION=${REGION}

echo "Assumed Role: $(aws sts get-caller-identity)
"
rm -f ${TEMP_PATH}