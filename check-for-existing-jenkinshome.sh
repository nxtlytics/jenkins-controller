#!/usr/bin/env bash
set -e

if [[ ! -e $JENKINS_HOME/jenkins.install.InstallUtil.lastExecVersion ]]; then
    echo "--- NO FILES IN \$JENKINS_HOME ($JENKINS_HOME); adding stub file"
    echo "0.0" > $JENKINS_HOME/jenkins.install.InstallUtil.lastExecVersion
fi

