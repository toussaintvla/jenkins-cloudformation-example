#!/bin/bash
echo ${selection}

if [ "${selection}" == "plan" ]; then
  terraform init
  terraform validate
  terraform plan -var-file=sample.tfvars
fi


if [ "${selection}" == "preview apply" ]; then
  terraform init
  terraform validate
  terraform plan -var-file=sample.tfvars
  terraform apply -var-file=sample.tfvars
fi

if [ "${selection}" == "apply" ]; then
  terraform init
  terraform validate
  terraform plan -var-file=sample.tfvars
  terraform apply -var-file=sample.tfvars -auto-approve
fi

if [ "${selection}" == "show" ]; then
  terraform show
fi

if [ "${selection}" == "preview destroy" ]; then
  terraform destroy -var-file=sample.tfvars
fi

if [ "${selection}" == "destroy" ]; then
  terraform destroy -var-file=sample.tfvars -auto-approve
fi