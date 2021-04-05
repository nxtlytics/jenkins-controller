# Jankins setup on Kubernetes

## Requirements

- [kexpand](https://github.com/kopeio/kexpand)
- [jq](https://github.com/stedolan/jq)
- [lpass](https://github.com/lastpass/lastpass-cli)
  - Note with secrets in yaml structure
- Kubernetes should have CRD `monitoring.coreos.com/v1` implemented
- Jenkins helm chart version 3.3.1+
  - We take advantage of creating [additional secrets](https://github.com/jenkinsci/helm-charts/pull/309)

## Example of secret in LastPass

```yaml
---
jenkins-hostname: jenkins.host.com
http-protocol: https
jenkins-email: jenkins@host.com
jenkins-library-version: branch-or-tag
jenkins-library-repo-owner: github-org-name
jenkins-library-repo-name: github-repo-name
github-api-token: token-to-use
sonarqube-token: token-to-use
sonarqube-url: sonarqube URL
slack-team-domain: slack-team-name
slack-url: https://hooks.slack.com/services/***/***/***
slack-token: token-to-use
azure-ad-client-id: id-to-use
azure-ad-client-secret: secret-to-use
azure-ad-tenant-id: secret-to-use
azure-ad-admin-group: Group Name (Object ID)
azure-ad-read-group: Group Name (Object ID)
```

## Install

```shell
$ ./scripts/main.sh -r '<Your Release Name here>' -s 'path/to/secret/in/LastPass' -v '3.3.1'
```

## How to setup Azure AD group based access

Let Azure Active Directory provide the `groups` of an user as part of the id token.

1. In Azure Application settings, click `Authentication` and mark the `ID tokens` checkbox under `Advanced Settings -> Implicit grant`. Save settings.
2. In Azure Application settings, click `Manifest` and modify the `"groupMembershipClaims": "None"` value to `"groupMembershipClaims": "SecurityGroup"`. Save manifest.
3. To setup group based authentication in Jenkins, you should search and take note of the groups `Object Id` and `Name` you want to use for Jenkins authorization.
4. In Jenkins configure `Azure Active Directory` Matrix-based security and add the noted down groups one-by-one in the following notation: `groupName (objectId)`

Source: [here](https://plugins.jenkins.io/azure-ad/#readme)

## How to access jenkins when running in Kubernetes for Docker Desktop

1. Comment out prometheus and ingress in `helm-values.yaml`

```yaml
#  ingress:
#    enabled: true
#    hostName: $((jenkins-hostname))
#  secondaryingress:
#    enabled: false
#  prometheus:
#    enabled: true
```

2. Add `controller.jenkinsUrl: localhost:8080`

**Note**: Azure AD allows adding `localhost` as a valid callback URL

```yaml
  jenkinsUrl: localhost:8080
```

3. Install helm chart in docker desktop's Kubernetes

```shell
$ ./scripts/main.sh -r '<Your Release Name here>' -s 'path/to/secret/in/LastPass' -v '3.3.1'
```

4. Create loadbalancer in docker desktop's Kubernetes

#### Replace `<Your Release Name here>` in `./kubernetes/local-expose.yaml`

```yaml
metadata:
  name: docker-desktop-loadbalancer
  namespace: <Your Release Name here>
```

#### Apply `./kubernetes/local-expose.yaml`

```shell
$ kubectl apply -f ./kubernetes/local-expose.yaml
```

## Related links

- [Synchronizing Kubernetes Secrets with LastPass](https://engineering.upside.com/synchronizing-kubernetes-secrets-with-lastpass-584d564ba176)
- [Configure Azure Active Directory with Jenkins](https://medium.com/@seifeddinemouelhi/configure-azure-active-directory-with-jenkins-e6ea31fb833e)
- [Working With AWS ECR on Kubernetes Running on Docker for mac](https://blog.omerh.me/post/2019/08/27/working-with-ecr-on-docker-desktop/)
- [Jenkins config example: GitHub/hmcts/cnp-jenkins-config](https://github.com/hmcts/cnp-jenkins-config)
