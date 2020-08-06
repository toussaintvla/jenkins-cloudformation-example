#!/bin/bash

if [ "$action" = "plan" ]
then
	terraform init ${module_directory}
    terraform plan -var-file=${tfvars} ${module_directory}
elif [ "$action" == "apply" ]
then
	if [ "$auto_apply" = "true" ]
    then
        echo "Approved? $auto_apply"
    	terraform init ${module_directory}
    	terraform plan -var-file=${tfvars} ${module_directory}
        terraform apply -auto-approve -var-file=${tfvars} ${module_directory}
    else
    	echo "Approved? $auto_apply"
        terraform init ${module_directory}
    	terraform plan -var-file=${tfvars} ${module_directory}
        terraform apply -var-file=${tfvars} ${module_directory}
        echo 'no'
    fi
elif [ "$action" == "destroy" ]
then
	if [ "$auto_destroy" = "true" ]
    then
        echo "Approved? $auto_destroy"
        terraform init ${module_directory}
        terraform destroy -auto-approve -var-file=${tfvars} ${module_directory}
    else
    	echo "Approved? $auto_destroy"
        terraform init ${module_directory}
        terraform destroy -var-file=${tfvars} ${module_directory}
        echo 'no'
    fi
else
	echo "No action applied."
fi
