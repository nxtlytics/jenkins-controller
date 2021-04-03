#!/usr/bin/env bash
# Enable bash's unofficial strict mode
GITROOT=$(git rev-parse --show-toplevel)
# shellcheck disable=SC1090
. "${GITROOT}/scripts/strict-mode"
strictMode
# shellcheck disable=SC1090
. "${GITROOT}/scripts/utils"

THIS_SCRIPT=$(basename "${0}")
PADDING=$(printf %-${#THIS_SCRIPT}s " ")

usage () {
  echo "Usage:"
  echo "${THIS_SCRIPT} -s <REQUIRED: Secret note location within LastPass>"
  echo
  exit 1
}

function lastpass_login() {
  if ! lpass status -q &> /dev/null; then
    read -rp "LastPass Username: " LPUSER
    if ! lpass login --trust "${LPUSER}" &> /dev/null; then
      msg_error "Unable to authenticate with LastPass!"
      exit 1
    fi
  fi
  msg_info "Starting LastPass sync..."
  if ! lpass sync &> /dev/null; then
    msg_error "Error syncing with LastPass!"
    exit 1
  fi
  msg_info "Sync complete."
}

function install_or_upgrade_jenkins() {
  if helm ls -n "${RELEASE_NAME}" | grep "${RELEASE_NAME}" &> /dev/null; then
    msg_info "${RELEASE_NAME} has already been installed to K8S context: ${CURRENT_K8S_CONTEXT}, I'll upgrade it"
    helm upgrade -f <(kexpand expand -f <(lpass show --note "${SECRETNAME}") "${HELM_VALUES_FILE}") \
      --namespace "${RELEASE_NAME}" --version "${CHART_VERSION}" "${RELEASE_NAME}" jenkins/jenkins
  else
    msg_info "Will try to install release: ${RELEASE_NAME} to K8S context: ${CURRENT_K8S_CONTEXT}"
    helm install -f <(kexpand expand -f <(lpass show --note "${SECRETNAME}") "${HELM_VALUES_FILE}") \
        --create-namespace --namespace "${RELEASE_NAME}" --version "${CHART_VERSION}" "${RELEASE_NAME}" jenkins/jenkins
  fi
}

# Ensure dependencies are present
if [[ ! -x $(command -v kexpand) || ! -x $(command -v lpass) || ! -x $(command -v jq) ]]; then
  msg_fatal "[-] Dependencies unmet. Please verify that the following are installed and in the PATH: kexpand, jq, lpass (LastPass cli)"
  exit 1
fi

while getopts ":s:" opt; do
  case ${opt} in
    s)
      SECRETNAME="${OPTARG}" ;;
    \?)
      usage ;;
    :)
      usage ;;
  esac
done

if [[ -z ${SECRETNAME:-""} ]]; then
  usage
fi

# Constants
CURRENT_K8S_CONTEXT="$(kubectl config current-context)"
HELM_VALUES_FILE="${GITROOT}/kubernetes/helm-values.yaml"
RELEASE_NAME='jankins'
CHART_VERSION='3.3.1'

lastpass_login
if ! lpass show -c "${SECRETNAME}" &> /dev/null; then
  msg_error "Error retrieving values from LastPass.
Please make sure secret is stored at ${SECRETNAME} inside of LastPass."
  exit 1
fi

read -p "Are you sure you want to install/upgrade jenkins to K8S context: ${CURRENT_K8S_CONTEXT} ? " -n 1 -r USER_REPLY
echo
if [[ ${USER_REPLY} =~ ^[Yy]$ ]]; then
  install_or_upgrade_jenkins
fi
