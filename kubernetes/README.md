# Jankins setup on Kubernetes

## Requirements

- [kexpand](https://github.com/kopeio/kexpand)
- [jq](https://github.com/stedolan/jq)
- [lpass](https://github.com/lastpass/lastpass-cli)
  - Note with secrets in yaml structure

## Example of secret in LastPass

```yaml
---
namespace: your-namespace
github-api-token: token-to-use
sonarqube-token: token-to-use
sonarqube-url: sonarqube URL
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
$ ../scripts/main.sh -s 'path/to/secret/in/LastPass'
```

## How to setup Azure AD group based access

Let Azure Active Directory provide the `groups` of an user as part of the id token.

1. In Azure Application settings, click `Authentication` and mark the `ID tokens` checkbox under `Advanced Settings -> Implicit grant`. Save settings.
2. In Azure Application settings, click `Manifest` and modify the `"groupMembershipClaims": "None"` value to `"groupMembershipClaims": "SecurityGroup"`. Save manifest.
3. To setup group based authentication in Jenkins, you should search and take note of the groups `Object Id` and `Name` you want to use for Jenkins authorization.
4. In Jenkins configure `Azure Active Directory` Matrix-based security and add the noted down groups one-by-one in the following notation: `groupName (objectId)`

Source: [here](https://plugins.jenkins.io/azure-ad/#readme)

## How to access jenkins when running in Kubernetes for Docker Desktop

```shell
$ kubectl apply -f ./local-expose.yaml
```

## Related links

- [Synchronizing Kubernetes Secrets with LastPass](https://engineering.upside.com/synchronizing-kubernetes-secrets-with-lastpass-584d564ba176)
- [Configure Azure Active Directory with Jenkins](https://medium.com/@seifeddinemouelhi/configure-azure-active-directory-with-jenkins-e6ea31fb833e)
- [Working With AWS ECR on Kubernetes Running on Docker for mac](https://blog.omerh.me/post/2019/08/27/working-with-ecr-on-docker-desktop/)
- [Jenkins config example: GitHub/hmcts/cnp-jenkins-config](https://github.com/hmcts/cnp-jenkins-config)
