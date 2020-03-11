#!/bin/bash
# Provides the ability to assume an IAM Role and sets credentails as environment variables
set +x

unset AWS_ACCESS_KEY_ID
unset AWS_DEFAULT_REGION
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

the_account=$1
the_region=$2
the_role=$3

date_stamp=$(date +%s)
echo "Date Stamp: ${date_stamp}
Account: ${the_account}
Region: ${the_region}
"

full_temp_file_path="/tmp/aws-temp-creds-${the_account}-${the_region}-${date_stamp}"

aws sts assume-role --role-arn arn:aws:iam::${the_account}:role/${the_role} --role-session-name nipcci${date_stamp} --region ${the_region} > ${full_temp_file_path}

aws_access_key_id=$(cat ${full_temp_file_path} | grep "AccessKeyId" | awk '{print $2}' | cut -d '"' -f 2)
aws_secret_access_key=$(cat ${full_temp_file_path} | grep "SecretAccessKey" | awk '{print $2}' | cut -d '"' -f 2)
aws_session_token=$(cat ${full_temp_file_path} | grep "Token" | awk '{print $2}' | cut -d '"' -f 2)

export AWS_ACCESS_KEY_ID=${aws_access_key_id}
export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
export AWS_SESSION_TOKEN=${aws_session_token}
export AWS_DEFAULT_REGION=${the_region}

rm -f ${full_temp_file_path}
