# ReadME

<!-- 1. Please ensure you have the correct AWS credentials configured as you have done earlier, then login to AWS ECR repository. Replace the following for the *Repository URI* as necessary which should reflect the correct *AWS Account ID*, *AWS Region*, and the name of the *Image Repository*. Also, it is good practice to tag the latest image to a specific version.

# ECR Login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 012345678910.dkr.ecr.us-east-1.amazonaws.com

# Docker Build
~ REPOSITORY_URI=012345678910.dkr.ecr.us-east-1.amazonaws.com/jenkins-agent
~ docker build -t $REPOSITORY_URI:latest .

# Docker Tag
~ docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:1.0

1. Finally, perform a docker push with the following command.

# Docker Push
~ docker push $REPOSITORY_URI:latest
~ docker push $REPOSITORY_URI:1.0 -->