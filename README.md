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

## Install Chart

Start from Version 16.0, e6data chart required Helm 3.7+ in order to install successfully. Please check your Helm chart version before installation.

```console
helm install [RELEASE_NAME] e6data-operator/e6data

```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Dependencies

By default this chart installs additional, dependent charts:

- Domain in values.yaml



_See [helm dependency](https://helm.sh/docs/helm/helm_dependency/) for command documentation._

## Uninstall Chart

```console
helm uninstall [RELEASE_NAME]
```

This removes all the Kubernetes components associated with the chart and deletes the release.

_See [helm uninstall](https://helm.sh/docs/helm/helm_uninstall/) for command documentation._

## Updating values.schema.json

A [`values.schema.json`](https://helm.sh/docs/topics/charts/#schema-files) file has been added to validate chart values. When `values.yaml` file has a structure change (i.e. add a new field, change value type, etc.), modify `values.schema.json` file manually or run `helm schema-gen values.yaml > values.schema.json` to ensure the schema is aligned with the latest values. Refer to [helm plugin `helm-schema-gen`](https://github.com/karuppiah7890/helm-schema-gen) for plugin installation instructions.

## Upgrading Chart

```console
helm upgrade [RELEASE_NAME] [CHART] --install
```

_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._


### To <version>

Description of version features
