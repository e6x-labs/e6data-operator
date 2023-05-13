# e6data

[e6data](https://e6data.io/), is the world's fastest analytics engine. Built from the ground up, it supports open architecture petabyte scale analytics..

This chart bootstraps a [e6data](https://e6data.io/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.16+
- Helm 3.7+

## Get Repository Info

```console
helm repo add e6data-operator  https://e6x-labs.github.io/e6data-operator/
helm repo update
```

_See [helm repository](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Secret

You need to create a secret for accessing the image for the e6data-operator

```console
kubectl create secret tls [SECRET_NAME] \
--key ca.key \
--cert ca.crt
```


## Install Chart

Start from Version 16.0, e6data chart required Helm 3.7+ in order to install successfully. Please check your Helm chart version before installation.

```console
helm install [RELEASE_NAME] e6data-operator/e6data 

```

custom values.yaml

```console

helm install [RELEASE_NAME] e6data-operator/e6data --values [/path/to/values.yaml]

```

setting values direclty from the installation command:

```console
helm install [RELEASE_NAME] e6data-operator/e6data \
  --set ingress.hosts[0]=example.com \
  --set workspace.namespaces[+1]=test3 \
  --set ingress.tls[0].secretName=example-tls-secret \
  --set ingress.tls[0].hosts[0]=example.com

```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._


## Values

Update these blocks in values.yaml:

host:
```console
    hosts:
      - <valid domain>
```

TLS:

```console

    tls:
      - secretName: plat-tls-secret
        hosts:
          - <valid domain>
```

Workspace namespaces:
```console

workspace:
  namespaces:
    - namespace1
    - namespace2

```




_See [helm dependency](https://helm.sh/docs/helm/helm_dependency/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Upgrading Chart

updating the helm chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

updating the helm chart with custom values.yaml

```console

helm install [RELEASE_NAME] e6data-operator/e6data --values [/path/to/values.yaml]

```

updating the helm chart by setting values direclty from command:

```console
helm upgrade [RELEASE_NAME] e6data-operator/e6data \
  --set ingress.hosts[0]=example.com \
  --set workspace.namespaces[+1]=test3 \
  --set ingress.tls[0].secretName=example-tls-secret \
  --set ingress.tls[0].hosts[0]=example.com
```


_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._


### To <version>

Description of version features
