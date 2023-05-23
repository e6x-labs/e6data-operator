# e6data <!-- omit in toc -->
[e6data](https://e6data.io/), is the world's fastest analytics engine. Built from the ground up, it supports open architecture petabyte scale analytics..
This chart bootstraps a [e6data](https://e6data.io/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.
- [Kubernetes Environment Setup](#kubernetes-environment-setup)
  - [Prerequisites](#prerequisites)
    - [Tools](#tools)
    - [Permission to run the script](#permission-to-run-the-script)
    - [Secret](#secret)
    - [Create GKE nodepool WITH C2-STANDARD-30 as machine type](#create-gke-nodepool-with-c2-standard-30-as-machine-type)
  - [Get Repository Info](#get-repository-info)
  - [Install Chart](#install-chart)
  - [Values](#values)
  - [Uninstall Chart](#uninstall-chart)
  - [Upgrading Chart](#upgrading-chart)
- [Google Cloud Plaform (GCP) Setup](#google-cloud-plaform-gcp-setup)
  - [Operator Prerequisites:](#operator-prerequisites)
  - [Operator Setup:](#operator-setup)
  - [Operator Cleanup:](#operator-cleanup)
  - [Workspace Prerequisites:](#workspace-prerequisites)
  - [Workspace Setup:](#workspace-setup)
  - [Workspace Cleanup:](#workspace-cleanup)
# Kubernetes Environment Setup
## Prerequisites
### Tools
- Kubernetes 1.16+
- Helm 3.7+
- google cli
### Permission to run the script
- roles/storage.admin
- roles/iam.serviceAccountAdmin
- roles/iam.roleAdmin
- roles/iam.workloadIdentityUser
### Secret
You need to create a tls secret 
```console
kubectl create secret tls [SECRET_NAME] \
--key ca.key \
--cert ca.crt
```
## Get Repository Info
```console
helm repo add e6data-operator  https://e6x-labs.github.io/e6data-operator/
helm repo update
```
_See [helm repository](https://helm.sh/docs/helm/helm_repo/) for command documentation._
## Install Chart
E6data chart required Helm 3.7+ in order to install successfully. Please check your Helm chart version before installation.
```console
helm install [RELEASE_NAME] e6data-operator/<e6data-chart>
```
custom values.yaml
```console
helm install [RELEASE_NAME] e6data-operator/e6data --values [/path/to/values.yaml]
```
setting values direclty from the installation command:
```console
helm install [RELEASE_NAME] e6data-operator/e6data \
  --set server.ingress.hosts[0]=example.com \
  --set workspace.namespaces[0]=test1 \
  --set workspace.namespaces[1]=test2 \
  --set server.ingress.tls[0].secretName=example-tls-secret \
  --set server.ingress.tls[0].hosts[0]=example.com
```
Alternatively, you can escape the brackets with a backslash, like this if you face error due to noglob:
```console
helm install [RELEASE_NAME] e6data-operator/e6data \
  --set server.ingress.hosts\[0\]=example.com \
  --set workspace.namespaces\[0\]=test1 \
  --set workspace.namespaces\[1\]=test2 \
  --set server.ingress.tls\[0\].secretName=example-tls-secret \
  --set server.ingress.tls\[0\].hosts\[0\]=example.com
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
  --set server.ingress.hosts[0]=example.com \
  --set workspace.namespaces[0]=test1 \
  --set workspace.namespaces[1]=test2 \
  --set server.ingress.tls[0].secretName=example-tls-secret \
  --set server.ingress.tls[0].hosts[0]=example.com
```
Alternatively, you can escape the brackets with a backslash, like this if you face error due to noglob:
```console
helm upgrade [RELEASE_NAME] e6data-operator/e6data \
  --set server.ingress.hosts\[0\]=example.com \
  --set workspace.namespaces\[0\]=test1 \
  --set workspace.namespaces\[1\]=test2 \
  --set server.ingress.tls\[0\].secretName=example-tls-secret \
  --set server.ingress.tls\[0\].hosts\[0\]=example.com
```
_See [helm upgrade](https://helm.sh/docs/helm/helm_upgrade/) for command documentation._
# Google Cloud Plaform (GCP) Setup
## Operator Prerequisites:
- GKE cluster with auto-scaler and workload identity enabled
- Access to create kubernetes namespace
- IAM permissions to create service accounts, roles and role bindings
- IAM permissions to create workload identity
- Domain/Sub-domain name to support "https" ingress for operator
- SSL certificates to support "https" ingress domain/sub-domain
- Access to run helm charts to deploy operator
## Operator Setup:
- Step 1: Create a namespace for operator setup in Kubernetes cluster (In case of using already existing namespace, skip this step)
```console
~$ gcloud config set <GCP_PROJECT_ID>
~$ gcloud container clusters get-credentials <KUBERNETES_CLUSTER_NAME> --project <GCP_PROJECT_ID> --region <GCP_COMPUTE_REGION> [--zone <GCP_KUBERNETES_CLUSTER_ZONE>]
~$ kubectl create namespace <KUBERNETES_OPERATOR_NAMESPACE>
```
- Step 2: Create a TLS secret in operator namespace for ingress
```console
~$ kubectl create secret tls <TLS_SECRET_NAME>
    --key <TLS_KEY_FILE>
    --cert <TLS_CERT_FILE>
    -n <KUBERNETES_OPERATOR_NAMESPACE> 
```
Step 3: Run the operator setup scripts to create service accounts, roles and role bindings.
```console
~$ git clone https://github.com/e6x-labs/e6data-operator.git
~$ cd e6data-operator/scripts/operator
~$ ./setup.sh <GCP_COMPUTE_REGION> <GCP_PROJECT_ID> <KUBERNETES_OPERATOR_NAMESPACE>
```
```bash
## Example: ./setup.sh asia-southeast1 e6x-labs e6data-operator
# This script will create service accounts, roles and role bindings in operator namespace
# output: OPERATOR_BUCKET_NAME and OPERATOR_SERVICE_ACCOUNT_EMAIL will be used in helm chart deployment
```
Step 4: Run the helm charts to deploy operator
```console
~$ helm repo add e6data-operator https://e6x-labs.github.io/e6data-operator/
~$ helm repo update
~$ helm install <HELM_OPERATOR_NAME> -n <KUBERNETES_OPERATOR_NAMESPACE> e6data-operator/operator \
    --set server.ingress.hosts\[0\]=<INGRESS_DOMAIN_NAME> \
    --set server.ingress.tls\[0\].secretName=<TLS_SECRET_NAME> \
    --set server.ingress.tls\[0\].hosts\[0\]=<INGRESS_DOMAIN_NAME> \
    --set server.bucketName=<OPERATOR_BUCKET_NAME> \
    --set serviceAccounts.server.annotations."iam\.gke\.io\/gcp-service-account"="<OPERATOR_SERVICE_ACCOUNT_EMAIL>" 
```
## Operator Cleanup:
Step 1: Delete the operator helm charts
```console
~$ helm delete <HELM_OPERATOR_NAME> -n <KUBERNETES_OPERATOR_NAMESPACE>
```
Step 2: Delete the operator namespace
```console
~$ kubectl delete namespace <KUBERNETES_OPERATOR_NAMESPACE>
```
Step 3: Run the operator cleanup scripts to delete service accounts, roles and role bindings
```console
    ~$ ./scripts/operator/cleanup.sh <GCP_COMPUTE_REGION> <GCP_PROJECT_ID> <KUBERNETES_OPERATOR_NAMESPACE>    
```
## Workspace Prerequisites:
- GKE cluster with auto-scaler and workload identity enabled
- Access to create kubernetes namespace
- IAM permissions to create service accounts, roles and role bindings
- IAM permissions to create workload identity pool
- Run helm charts
## Workspace Setup:
Step 1: Create a namespace for workspace setup in Kubernetes cluster (In case of using already existing namespace, skip this step)
```console
~$ gcloud config set <GCP_PROJECT_ID>
~$ gcloud container clusters get-credentials <KUBERNETES_CLUSTER_NAME>  --project <GCP_PROJECT_ID> --region <GCP_COMPUTE_REGION> [--zone <GCP_KUBERNETES_CLUSTER_ZONE>]
~$ kubectl create namespace <KUBERNETES_WORKSPACE_NAMESPACE>
```
Step 2: Run the workspace setup scripts to create service accounts, roles and role bindings
```console
~$ git clone https://github.com/e6x-labs/e6data-operator.git
~$ cd e6data-operator/scripts/workspace
~$ ./setup.sh <GCP_COMPUTE_REGION> <GCP_PROJECT_ID> <KUBERNETES_WORKSPACE_NAMESPACE> <OPERATOR_SERVICE_ACCOUNT_EMAIL> <KUBERNETES_CLUSTER_NAME> <MAX_INSTANCES_TO_BE_CREATED_IN_NODEGROUP> [<GCP_COMPUTE_ZONE>]
```
```bash
# Kindly mention the GCP_COMPUTE_ZONE only if the kubernetes cluster is zonal
### Example: ./setup.sh asia-southeast1 e6x-labs e6data-workspace e6data-operator-gate@e6x-labs-351604 iam-gke-351604 8 asia-southeast1-a
# This script will create service accounts, roles and role bindings in workspace namespace
# output: WORKSPACE_SERVICE_ACCOUNT_EMAIL will be used in helm chart deployment
```
Step 3: Run the helm charts to deploy workspace
```console
~$ helm repo add e6data-operator https://e6x-labs.github.io/e6data-operator/
~$ helm repo update
~$ helm install <HELM_WORKSPACE_NAME> -n <KUBERNETES_WORKSPACE_NAMESPACE>  e6data-operator/workspace \
    --set operator.namespace=<KUBERNETES_OPERATOR_NAMESPACE> \
    --set serviceAccounts.server.annotations."iam\.gke\.io\/gcp-service-account"="<WORKSPACE_SERVICE_ACCOUNT_EMAIL>"
```
## Workspace Cleanup:
 Step 1: Delete the workspace helm charts
 ```console
~$ helm delete <HELM_WORKSPACE_NAME> -n <KUBERNETES_WORKSPACE_NAMESPACE>
```
Step 2: Delete the workspace namespace
```console
~$ kubectl delete namespace <KUBERNETES_WORKSPACE_NAMESPACE>
```
Step 3: Run the workspace cleanup scripts to delete service accounts, roles and role bindings
```console
~$ ./scripts/workspace/cleanup.sh <GCP_COMPUTE_REGION> <GCP_PROJECT_ID> <KUBERNETES_WORKSPACE_NAMESPACE> <OPERATOR_SERVICE_ACCOUNT_EMAIL> <KUBERNETES_CLUSTER_NAME> [<GCP_COMPUTE_ZONE>]
```