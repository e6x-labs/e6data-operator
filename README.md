# e6data <!-- omit in toc -->
​
[e6data](https://e6data.io/), is the world's fastest analytics engine. Built from the ground up, it supports open architecture petabyte scale analytics..
​
This chart bootstraps a [e6data](https://e6data.io/) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.
​
- [Install in Google Cloud Platform (GCP)](#install-in-google-cloud-platform-gcp)
  - [Operator Prerequisites](#operator-prerequisites)
  - [Operator Setup](#operator-setup)
  - [Operator Cleanup](#operator-cleanup)
  - [Workspace Prerequisites](#workspace-prerequisites)
  - [Workspace Setup](#workspace-setup)
  - [Workspace Cleanup](#workspace-cleanup)
​
# Install in Google Cloud Platform (GCP)
## Operator Prerequisites
- GKE cluster with auto-scaler and workload identity enabled
- Access to create Kubernetes namespaces
- IAM permissions to create service accounts, roles and role bindings
- IAM permissions to create workload identity
- Domain/Sub-domain name to support _https_ ingress for operator
- SSL certificates to support _https_ ingress domain/sub-domain
- Access to run Helm charts to deploy operator
​
​
## Workspace Prerequisites
- GKE cluster with auto-scaler and workload identity enabled
- Access to create kubernetes namespace
- IAM permissions to create service accounts, roles and role bindings
- IAM permissions to create workload identity pool
- Run helm charts
​
## Workspace Setup
Step 1: Configure the kubernetes context for e6data workspace deployment
​
```console
~$ gcloud config set <GCP_PROJECT_ID>
~$ gcloud container clusters get-credentials <KUBERNETES_CLUSTER_NAME>  --project <GCP_PROJECT_ID> --region <GCP_COMPUTE_REGION> [--zone <GCP_KUBERNETES_CLUSTER_ZONE>]
```
​
Step 2: Run the workspace setup scripts to create service accounts, roles and role bindings
​
```console
~$ git clone https://github.com/e6x-labs/e6data-operator.git
~$ cd e6data-operator/scripts/workspace
~$ ./setup.sh <GCP_COMPUTE_REGION> <GCP_PROJECT_ID> <KUBERNETES_WORKSPACE_NAMESPACE> <OPERATOR_SERVICE_ACCOUNT_EMAIL> <KUBERNETES_CLUSTER_NAME> <MAX_INSTANCES_TO_BE_CREATED_IN_NODEGROUP> [<GCP_COMPUTE_ZONE>]
```
​
```bash
# Kindly mention the GCP_COMPUTE_ZONE only if the kubernetes cluster is zonal
### Example: ./setup.sh asia-southeast1 e6x-labs e6data-workspace e6data-operator-gate@e6x-labs-351604 iam-gke-351604 8 asia-southeast1-a
# This script will create service accounts, roles and role bindings in workspace namespace
# output: WORKSPACE_SERVICE_ACCOUNT_EMAIL will be used in helm chart deployment
```
Step 3: Run the helm charts to deploy workspace
​
```console
~$ helm repo add e6data-workspace https://e6x-labs.github.io/e6data-workspace/
~$ helm repo update
~$ helm install <HELM_WORKSPACE_NAME> -n <KUBERNETES_WORKSPACE_NAMESPACE>  --create-namespace e6data-operator/workspace \
    --set operator.namespace=<KUBERNETES_OPERATOR_NAMESPACE> \
    --set serviceAccounts.server.annotations."iam\.gke\.io\/gcp-service-account"="<WORKSPACE_SERVICE_ACCOUNT_EMAIL>"
```
​
## Workspace Cleanup
 Step 1: Delete the workspace helm charts
​
 ```console
~$ helm un <HELM_WORKSPACE_NAME> -n <KUBERNETES_WORKSPACE_NAMESPACE>
```
​
Step 2: Delete the workspace namespace
​
```console
~$ kubectl delete namespace <KUBERNETES_WORKSPACE_NAMESPACE>
```
​
Step 3: Run the workspace cleanup scripts to delete service accounts, roles and role bindings
​
```console
~$ ./scripts/workspace/cleanup.sh <GCP_COMPUTE_REGION> <GCP_PROJECT_ID> <KUBERNETES_WORKSPACE_NAMESPACE> <OPERATOR_SERVICE_ACCOUNT_EMAIL> <KUBERNETES_CLUSTER_NAME> [<GCP_COMPUTE_ZONE>]
```
