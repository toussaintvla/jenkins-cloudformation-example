#!/bin/bash
# Provides the ability to assume an IAM Role and sets credentails as environment variables
set +x

unset AWS_ACCESS_KEY_ID
unset AWS_DEFAULT_REGION
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

date_stamp=$(date +%s)
echo "Date Stamp: ${date_stamp}
Account: ${account_id}
Region: ${region_name}
"

full_temp_file_path="/tmp/aws-temp-creds-${account_id}-${region_name}-${date_stamp}"

aws sts assume-role --role-arn arn:aws:iam::${account_id}:role/${role_name} --role-session-name nipcci${date_stamp} --region ${region_name} > ${full_temp_file_path}

aws_access_key_id=$(cat ${full_temp_file_path} | grep "AccessKeyId" | awk '{print $2}' | cut -d '"' -f 2)
aws_secret_access_key=$(cat ${full_temp_file_path} | grep "SecretAccessKey" | awk '{print $2}' | cut -d '"' -f 2)
aws_session_token=$(cat ${full_temp_file_path} | grep "SessionToken" | awk '{print $2}' | cut -d '"' -f 2)

export AWS_ACCESS_KEY_ID=${aws_access_key_id}
export AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}
export AWS_SESSION_TOKEN=${aws_session_token}
export AWS_DEFAULT_REGION=${region_name}

rm -f ${full_temp_file_path}

aws sts get-caller-identity

aws route53 associate-vpc-with-hosted-zone \
--hosted-zone-id $hosted_zone_id \
--vpc VPCRegion=$region_name,VPCId=$vpc_id