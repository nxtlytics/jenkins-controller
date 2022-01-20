FROM jenkins/jenkins:2.319.2-jdk11

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

USER jenkins
