FROM jenkins/jenkins:lts

USER root

RUN apt -y autoremove && \
    apt update && \
    apt -y install wget && \
    apt clean all && \
    rm -rf /var/log/apt/* /var/log/alternatives.log /var/log/bootstrap.log /var/log/dpkg.log

EXPOSE 8080/tcp

# Copy list of default plugins
COPY jenkins-plugins.yaml /usr/share/jenkins/ref/plugins/

# Install plugins
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins/jenkins-plugins.yaml

# Tell the CasC plugin to pull files from this directory
ENV CASC_JENKINS_CONFIG /usr/share/jenkins/ref/casc_configs

COPY casc_configs /usr/share/jenkins/ref/casc_configs/

#check-for-existing-jenkinshome.sh is a tiny shell script that detects whether $JENKINS_HOME is an empty dir
#if so, it creates a stub file to prevent the initialAdminPassword bootstrap behavior of the vanilla jenkins image
ADD check-for-existing-jenkinshome.sh /usr/local/bin/check-for-existing-jenkinshome.sh
RUN /bin/bash -c "mv /usr/local/bin/jenkins.sh /usr/local/bin/jenkins.sh.backup && \
    cat /usr/local/bin/check-for-existing-jenkinshome.sh > /usr/local/bin/jenkins.sh && \
    tail -n +2 /usr/local/bin/jenkins.sh.backup >> /usr/local/bin/jenkins.sh && \
    chmod +x /usr/local/bin/jenkins.sh"

RUN rm -rf /var/jenkins_home/*

USER jenkins
