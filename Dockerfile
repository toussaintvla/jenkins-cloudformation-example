# Pull base image.
FROM jenkins/inbound-agent:latest

USER root
# RUN chown -R jenkins:jenkins /var/jenkins_home

# Install packages
RUN apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install python3 python3-pip

# Install AWS CLI
RUN set +x \
  && pip3 install awscli --upgrade

# drop back to the regular jenkins user - good practice
USER jenkins
