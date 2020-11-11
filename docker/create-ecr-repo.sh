#!/bin/bash

# Please ensure that you have the correct AWS credentials configured.
# Enter the name of the image repository you want to create, then enter the name of the region.

if [ $# -ne 2 ]; then
    echo "Enter repository name & region name."
    exit 0
else
    repository_name=$1
    region=$2
fi

aws ecr create-repository \
--repository-name $repository_name \
--image-scanning-configuration scanOnPush=true \
--region $region

aws ecr set-repository-policy \
--repository-name $repository_name \
--policy-text file://ecr-permission-policy.json \
--region $region
