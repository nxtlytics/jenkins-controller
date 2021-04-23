FROM jenkins/jenkins:2.277.3-lts-jdk11

USER root

RUN apt -y autoremove && \
    apt update && \
    apt -y install wget && \
    apt clean all && \
    rm -rf \
      /var/lib/apt/lists/* \
      /var/log/apt/* \
      /var/log/alternatives.log \
      /var/log/bootstrap.log \
      /var/log/dpkg.log \
      /var/tmp/* \
      /tmp/*

# Copy list of default plugins
COPY jenkins-plugins.yaml /usr/share/jenkins/ref/plugins/

# Install plugins
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins/jenkins-plugins.yaml

# check-for-existing-jenkinshome.sh is a tiny shell script that detects whether $JENKINS_HOME is an empty dir
# if so, it creates a stub file to prevent the initialAdminPassword bootstrap behavior of the vanilla jenkins image
# Read-only permissions are set on "${JENKINS_HOME}/plugins" because we do not want people to be able to install
# new plugins from the UI, new plugins and plugin updates should be installed/updated via the creation of a new
# container image
ADD check-for-existing-jenkinshome.sh /usr/local/bin/check-for-existing-jenkinshome.sh
RUN chmod -R 0400 "${JENKINS_HOME}/plugins"; \
    mv /usr/local/bin/jenkins.sh /usr/local/bin/jenkins.sh.backup; \
    cat /usr/local/bin/check-for-existing-jenkinshome.sh > /usr/local/bin/jenkins.sh; \
    tail -n +2 /usr/local/bin/jenkins.sh.backup >> /usr/local/bin/jenkins.sh; \
    chmod +x /usr/local/bin/jenkins.sh; \
    rm -rf /var/jenkins_home/*

USER jenkins
