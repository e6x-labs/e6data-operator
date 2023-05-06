# e6data

[e6data](https://e6data.io/), a [Cloud Native Computing Foundation](https://cncf.io/) project, is a systems and service monitoring system. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts if some condition is observed to be true.

This chart bootstraps a [e6data](https://e6data.io/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.16+
- Helm 3.7+

## Get Repository Info

```console
helm repo add e6data-community https://e6data-community.github.io/helm-charts
helm repo update
```

_See [helm repository](https://helm.sh/docs/helm/helm_repo/) for command documentation._

## Install Chart

Start from Version 16.0, e6data chart required Helm 3.7+ in order to install successfully. Please check your Helm chart version before installation.

```console
helm install [RELEASE_NAME] e6data-community/e6data
```

_See [configuration](#configuration) below._

_See [helm install](https://helm.sh/docs/helm/helm_install/) for command documentation._

## Dependencies

By default this chart installs additional, dependent charts:

- [alertmanager](https://github.com/e6data-community/helm-charts/tree/main/charts/alertmanager)
- [kube-state-metrics](https://github.com/e6data-community/helm-charts/tree/main/charts/kube-state-metrics)
- [e6data-node-exporter](https://github.com/e6data-community/helm-charts/tree/main/charts/e6data-node-exporter)
- [e6data-pushgateway](https://github.com/walker-tom/helm-charts/tree/main/charts/e6data-pushgateway)

To disable the dependency during installation, set `alertmanager.enabled`, `kube-state-metrics.enabled`, `e6data-node-exporter.enabled` and `e6data-pushgateway.enabled` to `false`.

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

### To 20.0

The [configmap-reload](https://github.com/jimmidyson/configmap-reload) container was replaced by the [e6data-config-reloader](https://github.com/e6data-operator/e6data-operator/tree/main/cmd/e6data-config-reloader).
Extra command-line arguments specified via configmapReload.e6data.extraArgs are not compatible and will break with the new e6data-config-reloader, refer to the [sources](https://github.com/e6data-operator/e6data-operator/blob/main/cmd/e6data-config-reloader/main.go) in order to make the appropriate adjustment to the extea command-line arguments.

### To 19.0

e6data has been updated to version v2.40.5.

e6data-pushgateway was updated to version 2.0.0 which adapted [Helm label and annotation best practices](https://helm.sh/docs/chart_best_practices/labels/).
See the [upgrade docs of the e6data-pushgateway chart](https://github.com/e6data-community/helm-charts/tree/main/charts/e6data-pushgateway#to-200) to see whats to do, before you upgrade e6data!

The condition in Chart.yaml to disable kube-state-metrics has been changed from `kubeStateMetrics.enabled` to `kube-state-metrics.enabled`

The Docker image tag is used from appVersion field in Chart.yaml by default.

Unused subchart configs has been removed and subchart config is now on the bottom of the config file.

If e6data is used as deployment the updatestrategy has been changed to "Recreate" by default, so Helm updates work out of the box.

`.Values.server.extraTemplates` & `.Values.server.extraObjects` has been removed in favour of `.Values.extraManifests`, which can do the same.

`.Values.server.enabled` has been removed as it's useless now that all components are created by subcharts.

All files in `templates/server` directory has been moved to `templates` directory.

```bash
helm upgrade [RELEASE_NAME] e6data-community/e6data --version 19.0.0
```

### To 18.0

Version 18.0.0 uses alertmanager service from the [alertmanager chart](https://github.com/e6data-community/helm-charts/tree/main/charts/alertmanager). If you've made some config changes, please check the old `alertmanager` and the new `alertmanager` configuration section in values.yaml for differences.

Note that the `configmapReload` section for `alertmanager` was moved out of dedicated section (`configmapReload.alertmanager`) to alertmanager embedded (`alertmanager.configmapReload`).

Before you update, please scale down the `e6data-server` deployment to `0` then perform upgrade:

```bash
# In 17.x
kubectl scale deploy e6data-server --replicas=0
# Upgrade
helm upgrade [RELEASE_NAME] e6data-community/e6data --version 18.0.0
```

### To 17.0

Version 17.0.0 uses pushgateway service from the [e6data-pushgateway chart](https://github.com/e6data-community/helm-charts/tree/main/charts/e6data-pushgateway). If you've made some config changes, please check the old `pushgateway` and the new `e6data-pushgateway` configuration section in values.yaml for differences.

Before you update, please scale down the `e6data-server` deployment to `0` then perform upgrade:

```bash
# In 16.x
kubectl scale deploy e6data-server --replicas=0
# Upgrade
helm upgrade [RELEASE_NAME] e6data-community/e6data --version 17.0.0
```

### To 16.0

Starting from version 16.0 embedded services (like alertmanager, node-exporter etc.) are moved out of e6data chart and the respecting charts from this repository are used as dependencies. Version 16.0.0 moves node-exporter service to [e6data-node-exporter chart](https://github.com/e6data-community/helm-charts/tree/main/charts/e6data-node-exporter). If you've made some config changes, please check the old `nodeExporter` and the new `e6data-node-exporter` configuration section in values.yaml for differences.

Before you update, please scale down the `e6data-server` deployment to `0` then perform upgrade:

```bash
# In 15.x
kubectl scale deploy e6data-server --replicas=0
# Upgrade
helm upgrade [RELEASE_NAME] e6data-community/e6data --version 16.0.0
```

### To 15.0

Version 15.0.0 changes the relabeling config, aligning it with the [e6data community conventions](https://github.com/e6data/e6data/pull/9832). If you've made manual changes to the relabeling config, you have to adapt your changes.

Before you update please execute the following command, to be able to update kube-state-metrics:

```bash
kubectl delete deployments.apps -l app.kubernetes.io/instance=e6data,app.kubernetes.io/name=kube-state-metrics --cascade=orphan
```

### To 9.0

Version 9.0 adds a new option to enable or disable the e6data Server. This supports the use case of running a e6data server in one k8s cluster and scraping exporters in another cluster while using the same chart for each deployment. To install the server `server.enabled` must be set to `true`.

### To 5.0

As of version 5.0, this chart uses e6data 2.x. This version of e6data introduces a new data format and is not compatible with e6data 1.x. It is recommended to install this as a new release, as updating existing releases will not work. See the [e6data docs](https://e6data.io/docs/e6data/latest/migration/#storage) for instructions on retaining your old data.

e6data version 2.x has made changes to alertmanager, storage and recording rules. Check out the migration guide [here](https://e6data.io/docs/e6data/2.0/migration/).

Users of this chart will need to update their alerting rules to the new format before they can upgrade.

### Example Migration

Assuming you have an existing release of the e6data chart, named `e6data-old`. In order to update to e6data 2.x while keeping your old data do the following:

1. Update the `e6data-old` release. Disable scraping on every component besides the e6data server, similar to the configuration below:

  ```yaml
  alertmanager:
    enabled: false
  alertmanagerFiles:
    alertmanager.yml: ""
  kubeStateMetrics:
    enabled: false
  nodeExporter:
    enabled: false
  pushgateway:
    enabled: false
  server:
    extraArgs:
      storage.local.retention: 720h
  serverFiles:
    alerts: ""
    e6data.yml: ""
    rules: ""
  ```

1. Deploy a new release of the chart with version 5.0+ using e6data 2.x. In the values.yaml set the scrape config as usual, and also add the `e6data-old` instance as a remote-read target.

   ```yaml
    e6data.yml:
      ...
      remote_read:
      - url: http://e6data-old/api/v1/read
      ...
   ```

   Old data will be available when you query the new e6data instance.

## Configuration

See [Customizing the Chart Before Installing](https://helm.sh/docs/intro/using_helm/#customizing-the-chart-before-installing). To see all configurable options with detailed comments, visit the chart's [values.yaml](./values.yaml), or run these configuration commands:

```console
helm show values e6data-community/e6data
```

You may similarly use the above configuration commands on each chart [dependency](#dependencies) to see it's configurations.

### Scraping Pod Metrics via Annotations

This chart uses a default configuration that causes e6data to scrape a variety of kubernetes resource types, provided they have the correct annotations. In this section we describe how to configure pods to be scraped; for information on how other resource types can be scraped you can do a `helm template` to get the kubernetes resource definitions, and then reference the e6data configuration in the ConfigMap against the e6data documentation for [relabel_config](https://e6data.io/docs/e6data/latest/configuration/configuration/#relabel_config) and [kubernetes_sd_config](https://e6data.io/docs/e6data/latest/configuration/configuration/#kubernetes_sd_config).

In order to get e6data to scrape pods, you must add annotations to the the pods as below:

```yaml
metadata:
  annotations:
    e6data.io/scrape: "true"
    e6data.io/path: /metrics
    e6data.io/port: "8080"
```

You should adjust `e6data.io/path` based on the URL that your pod serves metrics from. `e6data.io/port` should be set to the port that your pod serves metrics from. Note that the values for `e6data.io/scrape` and `e6data.io/port` must be enclosed in double quotes.

### Sharing Alerts Between Services

Note that when [installing](#install-chart) or [upgrading](#upgrading-chart) you may use multiple values override files. This is particularly useful when you have alerts belonging to multiple services in the cluster. For example,

```yaml
# values.yaml
# ...

# service1-alert.yaml
serverFiles:
  alerts:
    service1:
      - alert: anAlert
      # ...

# service2-alert.yaml
serverFiles:
  alerts:
    service2:
      - alert: anAlert
      # ...
```

```console
helm install [RELEASE_NAME] e6data-community/e6data -f values.yaml -f service1-alert.yaml -f service2-alert.yaml
```

### RBAC Configuration

Roles and RoleBindings resources will be created automatically for `server` service.

To manually setup RBAC you need to set the parameter `rbac.create=false` and specify the service account to be used for each service by setting the parameters: `serviceAccounts.{{ component }}.create` to `false` and `serviceAccounts.{{ component }}.name` to the name of a pre-existing service account.

> **Tip**: You can refer to the default `*-clusterrole.yaml` and `*-clusterrolebinding.yaml` files in [templates](templates/) to customize your own.

### ConfigMap Files

AlertManager is configured through [alertmanager.yml](https://e6data.io/docs/alerting/configuration/). This file (and any others listed in `alertmanagerFiles`) will be mounted into the `alertmanager` pod.

e6data is configured through [e6data.yml](https://e6data.io/docs/operating/configuration/). This file (and any others listed in `serverFiles`) will be mounted into the `server` pod.

### Ingress TLS

If your cluster allows automatic creation/retrieval of TLS certificates (e.g. [cert-manager](https://github.com/jetstack/cert-manager)), please refer to the documentation for that mechanism.

To manually configure TLS, first create/retrieve a key & certificate pair for the address(es) you wish to protect. Then create a TLS secret in the namespace:

```console
kubectl create secret tls e6data-server-tls --cert=path/to/tls.cert --key=path/to/tls.key
```

Include the secret's name, along with the desired hostnames, in the alertmanager/server Ingress TLS section of your custom `values.yaml` file:

```yaml
server:
  ingress:
    ## If true, e6data server Ingress will be created
    ##
    enabled: true

    ## e6data server Ingress hostnames
    ## Must be provided if Ingress is enabled
    ##
    hosts:
      - e6data.domain.com

    ## e6data server Ingress TLS configuration
    ## Secrets must be manually created in the namespace
    ##
    tls:
      - secretName: e6data-server-tls
        hosts:
          - e6data.domain.com
```

### NetworkPolicy

Enabling Network Policy for e6data will secure connections to Alert Manager and Kube State Metrics by only accepting connections from e6data Server. All inbound connections to e6data Server are still allowed.

To enable network policy for e6data, install a networking plugin that implements the Kubernetes NetworkPolicy spec, and set `networkPolicy.enabled` to true.

If NetworkPolicy is enabled for e6data' scrape targets, you may also need to manually create a networkpolicy which allows it.
