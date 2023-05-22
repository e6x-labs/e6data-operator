GCP Cloud     
    Operator Prequisites:
    - GKE cluster with autoscaler and workload identity enabled
    - Access to create kubernetes namespace
    - IAM permissions to create service accounts, roles and role bindings
    - IAM permissions to create workload identity
    - Domain/Sub-domain name to support "https" ingress for operator
    - SSL certificates to support "https" ingress domain/sub-domain
    - Access to run helm charts to deploy operator

    Operator setup:

    Step 1: Create a namespace for operator setup in Kubernetes cluster (In case of using already existing namespace, skip this step)
    ~$ gcloud config set <GCP_PROJECT_ID>
    ~$ gcloud container clusters get-credentials <KUBERNETES_CLUSTER_NAME>  --project <GCP_PROJECT_ID> --region <GCP_COMPUTE_REGION> [--zone <GCP_KUBERNETES_CLUSTER_ZONE>]
    ~$ kubectl create namespace <KUBERNETES_OPERATOR_NAMESPACE>

    Step 2: Create a TLS secret in operator namespace for ingress
    ~$ kubectl create secret tls <TLS_SECRET_NAME> --key <TLS_KEY_FILE> --cert <TLS_CERT_FILE> -n <KUBERNETES_OPERATOR_NAMESPACE> 

    Step 3: Run the operator setup scripts to create service accounts, roles and role bindings
    ~$ git clone https://github.com/e6x-labs/e6data-operator.git
    ~$ cd e6data-operator/scripts/operator
    ~$ ./setup.sh <GCP_COMPUTE_REGION> <GCP_PROJECT_ID> <KUBERNETES_OPERATOR_NAMESPACE>
    ### Example: ./setup.sh asia-southeast1 e6x-labs e6data-operator
    # This script will create service accounts, roles and role bindings in operator namespace
    # output: OPERATOR_BUCKET_NAME and OPERATOR_SERVICE_ACCOUNT_EMAIL will be used in helm chart deployment

    Step 4: Run the helm charts to deploy operator
    ~$ helm repo add e6data-operator https://e6x-labs.github.io/e6data-operator/
    ~$ helm repo update
    ~$ helm install <HELM_OPERATOR_NAME> -n <KUBERNETES_OPERATOR_NAMESPACE> e6data-operator/operator \
        --set server.ingress.hosts\[0\]=<INGRESS_DOMAIN_NAME> \
        --set server.ingress.tls\[0\].secretName=<TLS_SECRET_NAME> \
        --set server.ingress.tls\[0\].hosts\[0\]=<INGRESS_DOMAIN_NAME> \
        --set server.bucketName=<OPERATOR_BUCKET_NAME> \
        --set serviceAccounts.server.annotations."iam\.gke\.io\/gcp-service-account"="<OPERATOR_SERVICE_ACCOUNT_EMAIL>" 

    Operator Cleanup:
    Step 1: Delete the operator helm charts
    ~$ helm delete <HELM_OPERATOR_NAME> -n <KUBERNETES_OPERATOR_NAMESPACE>

    Step 2: Delete the operator namespace
    ~$ kubectl delete namespace <KUBERNETES_OPERATOR_NAMESPACE>

    Step 3: Run the operator cleanup scripts to delete service accounts, roles and role bindings
    ~$ ./scripts/operator/cleanup.sh <GCP_COMPUTE_REGION> <GCP_PROJECT_ID> <KUBERNETES_OPERATOR_NAMESPACE>    

    Workspace Prequisites:
    - GKE cluster with autoscaler and workload identity enabled
    - Access to create kubernetes namespace
    - IAM permissions to create service accounts, roles and role bindings
    - IAM permissions to create workload identity pool
    - Run helm charts

    Workspace setup:
    Step 1: Create a namespace for workspace setup in Kubernetes cluster (In case of using already existing namespace, skip this step)
    ~$ gcloud config set <GCP_PROJECT_ID>
    ~$ gcloud container clusters get-credentials <KUBERNETES_CLUSTER_NAME>  --project <GCP_PROJECT_ID> --region <GCP_COMPUTE_REGION> [--zone <GCP_KUBERNETES_CLUSTER_ZONE>]
    ~$ kubectl create namespace <KUBERNETES_WORKSPACE_NAMESPACE>

    Step 2: Run the workspace setup scripts to create service accounts, roles and role bindings
    ~$ git clone https://github.com/e6x-labs/e6data-operator.git
    ~$ cd e6data-operator/scripts/workspace
    ~$ ./setup.sh <GCP_COMPUTE_REGION> <GCP_PROJECT_ID> <KUBERNETES_WORKSPACE_NAMESPACE> <OPERATOR_SERVICE_ACCOUNT_EMAIL> <KUBERNETES_CLUSTER_NAME> <MAX_INSTANCES_TO_BE_CREATED_IN_NODEGROUP> [<GCP_COMPUTE_ZONE>]
    # Kindly mention the GCP_COMPUTE_ZONE only if the kubernetes cluster is zonal
    ### Example: ./setup.sh asia-southeast1 e6x-labs e6data-workspace e6data-operator-gate@e6x-labs-351604 iam-gke-351604 8 asia-southeast1-a
    # This script will create service accounts, roles and role bindings in workspace namespace
    # output: WORKSPACE_SERVICE_ACCOUNT_EMAIL will be used in helm chart deployment

    Step 3: Run the helm charts to deploy workspace
    ~$ helm repo add e6data-operator https://e6x-labs.github.io/e6data-operator/
    ~$ helm repo update
    ~$ helm install <HELM_WORKSPACE_NAME> -n <KUBERNETES_WORKSPACE_NAMESPACE>  e6data-operator/workspace \
        --set operator.namespace=<KUBERNETES_OPERATOR_NAMESPACE> \
        --set serviceAccounts.server.annotations."iam\.gke\.io\/gcp-service-account"="<WORKSPACE_SERVICE_ACCOUNT_EMAIL>"


    Workspace Cleanup:
    Step 1: Delete the workspace helm charts
    ~$ helm delete <HELM_WORKSPACE_NAME> -n <KUBERNETES_WORKSPACE_NAMESPACE>

    Step 2: Delete the workspace namespace
    ~$ kubectl delete namespace <KUBERNETES_WORKSPACE_NAMESPACE>

    Step 3: Run the workspace cleanup scripts to delete service accounts, roles and role bindings
    ~$ ./scripts/workspace/cleanup.sh <GCP_COMPUTE_REGION> <GCP_PROJECT_ID> <KUBERNETES_WORKSPACE_NAMESPACE> <OPERATOR_SERVICE_ACCOUNT_EMAIL> <KUBERNETES_CLUSTER_NAME> [<GCP_COMPUTE_ZONE>]





