# jenkins-cloudformation-example

# **Orchestrate Jenkins Workloads using Dynamic Pod Autoscaling with Amazon EKS**

In this blog post, we’ll demonstrate how to leverage [Jenkins](https://www.jenkins.io/) with [Amazon Elastic Kubernetes Service (EKS)](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html) by running a Jenkins Manager within an EKS pod. By doing so, we can run Jenkins workloads by allowing Amazon EKS to spawn dynamic Jenkins Agent(s) to perform application and infrastructure deployment.

In the effort to setup our Amazon EKS cluster with Jenkins, we’ll use the [`eksctl`](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html) simple CLI tool for creating clusters on EKS. Then, we'll build both the Jenkins Manager and Jenkins Agent image. Afterwards, we’ll run a container deployment on our cluster to access the Jenkins application and use the dynamic Jenkins Agent pods to run pipelines & jobs.

## Solution Overview

 The following architecture illustrates the architecture and execution steps.

![Image: img/Jenkins-CloudFormation.png](img/Jenkins-CloudFormation.png)
*Figure 1. Solution Overview Diagram*

To accomplish this deployment workflow we’re going to do the following:

- Centralized Shared Services account
   1. Deploy the Amazon EKS Cluster.
   2. Create Amazon ECR for Jenkins Manager and Jenkins Agent.
   3. Deploy the kubernetes manifest file for the Jenkins Manager.

- Target Account(s) - Establish a set of [AWS Identity and Access Management (IAM)](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_cross-account-with-roles.html) roles with permissions for cross-across access from the Share Services account into the Target account(s).

- Jenkins Plugins - Install and configure the [Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/) and [CloudBees AWS Credentials Plugin](https://plugins.jenkins.io/aws-credentials/) from Manage Plugins.

- Jenkins Pipeline Example - Fetch code from repository by using CloudFormation to deploy an S3 Bucket to the Target account with Jenkins parameterized pipeline.

## Prerequisite

The following below is the minimum requirement in order to ensure this solution will work.

- Shared Services Account: This is where the Amazon EKS Cluster will reside
- Target Account: This is destination of the CI/CD pipeline deployments

## **Setup**

Verify if the AWS CLI was installed by executing this command in your terminal `aws --version`. If you have an existing account, and your machine is configured for programmatic access, then you can proceed to the next step. In this walkthrough, we’ll be using Administrator privileges for our deployment. Amazon ECR requires that users have permission to make calls to the `ecr:GetAuthorizationToken`. These privileges are for demonstration purposes only and not recommended for production.

Before execution please ensure that you've properly configured the AWS credentials for your account. Therefore, please ensure that you have the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html) installed and your AWS credentials are configured with the associated region before you proceed. The following steps show how you can do this.

```bash
# Export access keys
~ export AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
~ export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXX
~ export AWS_SESSION_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
~ export AWS_DEFAULT_REGION=<region-name>

### OR ###

# Export AWS credentials profile
~ export AWS_PROFILE=<profile-name>
```

- Verify if the [Docker CLI](https://docs.docker.com/get-docker/) was installed. Run the docker desktop engine. *Note: The docker engine must be running to build images.*

```bash
# Check docker version
~ docker --version
```

- Install [Kubectl](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html) and [aws-iam-authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html).

```bash
# Check kubectl version
~ kubectl version —client

# Check aws-iam-authenticator version
~ aws-iam-authenticator version
```

## Create EKS Cluster & Deploy Jenkins

Clone the repository and execute the following commands below. Make sure your AWS configuration is pointing to the right region you want EKS deployed.

```bash
# Clone the git repository
~ git clone https://gitlab.aws.dev/toussaiv/jenkins-cloudformation-example
```

```bash
# Create the EKS Cluster
~ eksctl create cluster \
> --name jenkins-app \
> --region us-east-1 \
> --with-oidc \
> --zones "us-east-1a,us-east-1b" \
> --nodegroup-name "test-nodegrp" \
> --nodes-min 2 \
> --nodes-max 4 \
> --enable-ssm \
> --managed \
> --asg-access
```

(Please build custom Jenkins manager & agent)

- Cut & paste the command output into the command terminal. This will set the proper context for your kubernetes cluster.

```bash
# Update kubeconfig and set the context of the cluster
aws eks update-kubeconfig <cluster-name> --region <region-name>
```

- Run the following command to make sure your EKS nodes and pods are ready and running. We have 2 worker nodes and hence the 2/2 output below.

```bash
# Verify that EKS nodes are up running
~ kubectl get nodes

# Verify that jenkins deployment/pods are up running
~ kubectl get pods -n jenkins

# Replace with jenkins manager pod name
kubectl exec -it pod/<jenkins-manager-pod-name> -n jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword

Login Set new password, login again
Check box for default Crumb, then refresh
setup kubernetes cloud, set jenkins url http://jenkins-service.jenkins.svc.cluster.local
check jenkins url resolution
```
## AWS Cross-Account IAM Roles

1. Create one IAM role in each AWS target environment(s). One role should be in the **target** non-production account and called **nonprod_role** and the other in the target **** production account called **prod_role*.*** These two roles must have permission to perform a cloudformation deployment and create the resources associated. We’ve assigned and attached a **PowerUserAccess** Managed Policy to these roles for this example.
2. These two IAM roles **must** have an established **trust relationship** to the account number that Jenkins Manager resides. In this case, Jenkins Manager resides in a Shared Services Account. This will allow the Jenkins Agent the ability to assume role, of the particular target account. See the images below.


[Image: Screen Shot 2020-11-06 at 2.41.01 AM.png]**Figure 2. Solution Overview Diagram**

[Image: Screen Shot 2020-11-06 at 2.41.21 AM.png]**Figure 3. Solution Overview Diagram**

[Image: Screen Shot 2020-11-06 at 2.43.38 AM.png]**Figure 4. Solution Overview Diagram**

[Image: Screen Shot 2020-11-06 at 2.45.17 AM.png]**Figure 5. Solution Overview Diagram**


## Jenkins

### Login Page

AWS will issue a LoadBalancer to access the application.

```
# Fetch the Application URL
~ kubectl get svc -n jenkins
```

The next step is to get the password to login to Jenkins as the **admin** user. Run the following command to get the auto generated Jenkins password. Please update your password after logging in.

```
# Fetch Jenkins Login Password
~ printf $(kubectl get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 —decode);echo
```

Login Jenkins as the **admin** user.
[Image: Screen Shot 2020-09-24 at 9.20.45 AM.png]**Figure 1. Solution Overview Diagram**


### Install Kubernetes Plugin

1. Download the [Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/) from Manage Plugins
2. Download the [CloudBees AWS Credentials Plugin](https://plugins.jenkins.io/aws-credentials/) from Manage Plugins
3. Navigate: Manage Jenkins → Manage Nodes and Clouds → Configure Clouds
4. Click: Add a new cloud → select Kubernetes from the drop menu

[Image: Screen Shot 2020-09-10 at 11.55.29 PM.png]**Figure 1. Solution Overview Diagram**


### Configure Jenkins Kubernetes Cloud


*Note: Before proceeding, please ensure that you have access to your Amazon EKS cluster information, whether it is through Console or CLI.*

1. Enter a name in the **Name** field of the configuration.
2. Enter the **Kubernetes URL**. This can be found via AWS Console by navigating to the Amazon EKS service and locating the API server endpoint of the cluster or run the command **`kubectl cluster-info`***.*
3. Enter the namespace that will be used in the **Kubernetes Namespace** field. This will determine where the dynamic kubernetes pods will spawn. In our case, the name of the namespace is **jenkins***.* However, you may have deployed this in a default namespace which will also suffice.
4. During the initial setup of Jenkins Manager on kubernetes, there is an environment variable `**JENKINS_URL**` which should be set in the kubernetes deployment yaml template before resource creation. This environment variable has a url that will resolve request locally to the cluster IP address. We’re using _option A_. See the two options below.
    1. The format is done as the following: [**_`https://<service-name>.<namespace>.svc.cluster.local`_**](https://(service-name).(namespace).svc.cluster.local/)
    2. If you did not set this via the kubernetes yaml template, then you can enter this in the **`JENKINS_URL`** field below for where the pods will resolve connectivity such as the loadbalancer.

[Image: Screen Shot 2020-11-05 at 2.12.32 PM.png]**Figure 1. Solution Overview Diagram**


### Set AWS Credentials

1. You must have the AWS Credentials Binding Plugin installed for before this step. Enter the unique ID name as shown in the example below. **awsCredentialsNonprod** for the non-production account and **awsCredentialsProd** for the production account.
2. Enter the IAM Role ARN you created earlier for both non-production and production in the field as shown below.

[Image: Screen Shot 2020-11-04 at 12.56.29 PM.png]**Figure 1. Solution Overview Diagram**

[Image: Screen Shot 2020-11-04 at 12.42.18 PM.png]**Figure 1. Solution Overview Diagram**


### Create a pipeline

1. Navigate to the Jenkins main menu and select new item.
2. Create a Pipeline.
3. Select the check box for **This project is parameterized***.* The choice parameters are defined in the Jenkinsfile Pipeline, but you can specify the choices as shown below.

[Image: Screen Shot 2020-09-18 at 10.43.28 AM.png]**Figure 1. Solution Overview Diagram**


1. Add the **GitHub Repository URL** for this project. This will contain all the files for our deployment:  **Jenkinsfile, deploy-stack.sh, delete-stack.sh, k8sPodTemplate.yaml, S3-Bucket.yaml,** and the parameters file **example-stack-parameters.properties**. The repository is public, so there is no need to provide any credentials.

[Image: Screen Shot 2020-11-05 at 1.45.56 PM.png]**Figure 1. Solution Overview Diagram**


### Examine and modify code repository files

1. Setup a Kubernetes YAML template. In this example, we will be using the **k8sPodTemplate.yaml** file stored in the **k8s/** folder.
2. The custom Jenkins Agent image we built earlier uses the Jenkins inbound-agent as the base image with the AWS CLI installed. Specify the container image in the file that will source the image with the associated AWS account and region.
3. You can keep everything else as default, but depending on you specifications you can choose to modify the amount of resources that must be allocated.

```
# Kubernetes YAML file
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-pipeline-pod
spec:
  serviceAccountName: jenkins
  securityContext:
    runAsUser: 0
    fsGroup: 0
    runAsNonRoot: false
  containers:
  - name: custom-image
    image: <REPLACE WITH YOUR AWS ACCOUNT>.dkr.ecr.<REPLACE WITH YOU AWS REGION>.amazonaws.com/jenkins-agent:latest #Enter a custom docker image for the jenkins agent docker image.
    command:
    - cat
    tty: true
    resources:
      requests:
        cpu: 500m
        memory: 512Mi
      limits:
        cpu: "1"
        memory: 1024Mi
```

1. The **deploy-stack.sh** accepts three different parameters. The first parameter being set is the stack name. The stack name should be the same name as the parameters file that will be used. The second parameter is the name of the template on where the parameters should be passed. The third parameter is the condition on whether to execute the deployment right away or create a changeset. The last parameter is the region of the target account where the stack should be deployed. I will show an example of how this is used later.

```
#!/bin/bash

if [ $# -ne 4 ]; then
    echo "Enter stack name & template file name to create. - You must set changeset vale (true or false)."
    exit 0
else
    stack_name=$1
    template_name=$2
    changeset_option=$3
    region=$4
fi
if [ ! -f "cloudformation/$template_name.yaml" ]; then
    echo "CloudFormation template $template_name.yaml does not exist"
    exit 0
fi
if [ ! -f "parameters/$stack_name-parameters.properties" ]; then
    echo "CloudFormation parameters $stack_name-parameters.properties does not exist"
    exit 0
fi
if [[ $changeset_option == true ]]; then
    aws cloudformation deploy \
    --stack-name $stack_name \
    --template-file cloudformation/$template_name.yaml \
    --parameter-overrides file://parameters/$stack_name-parameters.properties \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $region
else
    aws cloudformation deploy \
    --stack-name $stack_name \
    --template-file cloudformation/$template_name.yaml \
    --parameter-overrides file://parameters/$stack_name-parameters.properties \
    --capabilities CAPABILITY_NAMED_IAM \
    --region $region \
    --no-execute-changeset
fi
```

1. The **delete-stack.sh ** **accepts the name and region of the stack that was created to delete the stack. I will show an example of how this is used later.

```
#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Enter stack-name to delete & Please specify user profile."
    exit 0
else
    stack_name=$1
    region=$2
fi
aws cloudformation delete-stack \
--stack-name $stack_name \
--region $region
aws cloudformation wait stack-delete-complete \
--stack-name $stack_name \
--region $region
```

1. In this **Jenkinsfile** pipeline, the **k8sPodTemplate.yaml** is used to specify the kubernetes pod details and the inbound-agent that will be used to run the pipeline.
2. This pipeline stage will consist of the several stages for stack deployment, create changeset, execute changeset, and stack deletion. The deploy-stack.sh will be execute when selected via parameters, and likewise the delete-stack.sh will be executed when selected by the parameters.
3. If you observe closely, there are several variables used within the pipeline stage actions below.

    * ***changeset_mode = True***, this will proceed to deploy a stack or execute changeset.
    * ***changeset_mode** **= False***, this will only create a changeset without executing the changes.
    * ***stack_name = example-stack*,** In this example the name of the stack is called *"example-stack".* The value to this stack name variable **MUST MATCH** the name of the parameters file format as such, **<stack-name>-parameters.properties****.** In our case we are using **example-stack-parameters.properties** under the **parameters/** folder.
    * ***template_name = S3-Bucket***, The name of this variable is equivalent to the format **<template-name>.yaml**. In this example the template name is called **S3-Bucket**, under the **cloudformation/** folder.
    * ***account_env = awsCredentialsNonProd or awsCredentialsProd***. This is the Unique ID that references the IAM Role ARN which is the account we will assume role using the [*AmazonWebServicesCredentialsBinding*](https://www.jenkins.io/doc/pipeline/steps/credentials-binding/) to perform our deployment based on the selected choice parameterized pipeline.
    * ***region = us-east-1,** *Enter the region of the target account.

1. The commands below will utilize the deploy-stack.sh and delete-stack.sh files we showed earlier.

```
# Deploy a Stack or Execute a Changeset
~ scripts/deploy-stack.sh ${stack_name} ${template_name} ${changeset_mode} ${region}

# Delete a CloudFormation Stack
~ scripts/delete-stack.sh ${stack_name} ${region}
```

1. The steps in the pipeline will execute based on the parameter choices you select.

```
pipeline {
  agent {
    kubernetes {
      yamlFile 'k8s/k8sPodTemplate.yaml' // Declarative agents can be defined from YAML.
      // This is a YAML representation of the Pod, to allow setting any values not supported as fields.
    }
  }

  parameters {
    choice(
      choices: [
        'deploy-stack-nonprod', 'create-changeset-nonprod', 'execute-changeset-nonprod', 'delete-stack-nonprod',
        'deploy-stack-prod', 'create-changeset-prod', 'execute-changeset-prod', 'delete-stack-prod'
      ],
      description: 'CloudFormation Actions',
      name: 'action'
    )
  }

  environment {
    stack_name = "example-stack"
    template_name = "S3-Bucket"
    region = "us-east-1"
  }

  stages {

    stage('check version') {
      steps {
        ansiColor('xterm') {
          container("custom-image") {
            sh 'aws --version'
          }
        }
      }
    }

    stage('action') {
      when {
        expression {
          params.action == 'deploy-stack-nonprod' || params.action == 'create-changeset-nonprod' || params.action == 'execute-changeset-nonprod' || params.action == 'delete-stack-nonprod' ||
          params.action == 'deploy-stack-prod' || params.action == 'create-changeset-prod' || params.action == 'execute-changeset-prod' || params.action == 'delete-stack-prod'
        }
      }
      steps {
        ansiColor('xterm') {
          script {
            if ( params.action == 'deploy-stack-prod' || params.action == 'create-changeset-prod' || params.action == 'execute-changeset-prod' || params.action == 'delete-stack-prod' ) {
              env.account_env = 'awsCredentialsProd'
            } else {
              env.account_env = 'awsCredentialsNonProd'
            }
            if ( params.action == 'create-changeset-nonprod' || params.action == 'create-changeset-prod' ) {
              env.changeset_mode = false
            } else {
              env.changeset_mode = true
            }
          }
        }
      }
    }

    stage('stack-execution') {
      when {
        expression { params.action == 'deploy-stack-nonprod' || params.action == 'execute-changeset-nonprod' || params.action == 'deploy-stack-prod' || params.action == 'execute-changeset-prod' }
      }
      steps {
        ansiColor('xterm') {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "${account_env}",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            container("custom-image") {
              sh 'aws sts get-caller-identity'
              sh 'scripts/deploy-stack.sh ${stack_name} ${template_name} ${changeset_mode} ${region}'
            }
          }
        }
      }
    }

    stage('create-changeset') {
      when {
        expression { params.action == 'create-changeset-nonprod' || params.action == 'create-changeset-prod' }
      }
      steps {
        ansiColor('xterm') {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "${account_env}",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            container("custom-image") {
              sh 'aws sts get-caller-identity'
              sh 'scripts/deploy-stack.sh ${stack_name} ${template_name} ${changeset_mode} ${region}'
            }
          }
        }
      }
    }

    stage('delete-stack') {
      when {
        expression { params.action == 'delete-stack-nonprod' || params.action == 'delete-stack-prod' }
      }
      steps {
        ansiColor('xterm') {
          withCredentials([[
            $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "${account_env}",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
            container("custom-image") {
              sh 'aws sts get-caller-identity'
              sh 'scripts/delete-stack.sh ${stack_name} ${region}'
            }
          }
        }
      }
    }
  }
}
```

### Jenkins Pipeline: Execute a pipeline

1. Click **Build with Parameters** then select **deploy-stack-<environment-name>**. As you can see below, the stages perform the execution as followed. You can view more details of the stages below and verify in your AWS account that the CloudFormation stack was executed.

[Image: Screen Shot 2020-09-18 at 10.44.06 AM.png]**Figure 1. Solution Overview Diagram**


1. You can examine the stages a bit further which are executed as you select your choice of execution.

[Image: Screen Shot 2020-09-16 at 2.49.18 PM.png]**Figure 1. Solution Overview Diagram**


1. Final Step is to execute your pipeline and watch the pods spin up dynamically in your terminal. As you can see below the jenkins agent pod spawned then terminated after usage. You can watch this task on your own by executing the following command:

```
# You may not have chose a namespace therefore you can enter the "default" namespace.
~ kubectl get pods -n jenkins -w
```

[Image: Screen Shot 2020-09-18 at 3.14.05 AM.png]**Figure 1. Solution Overview Diagram**


## Code Repository

* [Amazon EKS Jenkins Integration](https://code.amazon.com/packages/Jenkins-cloudformation-example/trees/mainline)

## References

* [Jenkins Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
* [CloudBees AWS Credentials Plugin](https://plugins.jenkins.io/aws-credentials/)

## Conclusion

This post guided you through the process of building out Amazon EKS and integrating Jenkins to Orchestrate Workloads. We demonstrated how you can use this to deploy in multiple accounts with dynamic Jenkins agents and create alignment to your business with similar use cases. To learn more about Amazon EKS, head over to our [documentation](https://aws.amazon.com/eks/getting-started/) pages or explore our [console](https://console.aws.amazon.com/eks/home?region=us-east-1#).
