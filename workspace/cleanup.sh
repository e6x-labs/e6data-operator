#!/bin/bash
# pattern for role name : "[a-zA-Z0-9_\.]{3,64}"
# pattern for service account name:  [a-zA-Z][a-zA-Z\d\-]*[a-zA-Z\d]



REGION=$1 # Region for infra
PROJECT_ID=$2  # GCP project ID
WORKSPACE_NAME=$3 # Namespace for workspace 
CLUSTER_NAME=$4 # Cluster name for the kubernetes
MAX_INSTANCES_IN_NODEGROUP=$5 # Max VMs to be created in GKE nodegroup



WORKSPACE_NAME="e6data-workspace-${WORKSPACE_NAME}"
WORKSPACE_WRITE_ROLE_NAME="e6data_${WORKSPACE_NAME}_write"
WORKSPACE_READ_ROLE_NAME="e6data_${WORKSPACE_NAME}_read"
COMMON_GCP_FLAGS="--project ${PROJECT_ID} --quiet"
WORKSPACE_SA_EMAIL="e6data-workspace@${PROJECT_ID}.iam.gserviceaccount.com"



if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" ]]; then
  echo "Usage: ./setup.sh <region> <project_id> <workspace_name> <cluster_name> <max_nodegroup_instances>"
exit 0
fi


if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "Usage: ./setup.sh <region> <project_id> <operator_namespace>"
exit 0
fi



gsutil rm -r gs://${WORKSPACE_NAME}
gcloud iam service-accounts delete ${WORKSPACE_NAME}
gcloud iam roles delete ${WORKSPACE_WRITE_ROLE_NAME} ${COMMON_GCP_FLAGS}
gcloud container node-pools delete ${WORKSPACE_NAME} --cluster=${CLUSTER_NAME} --region=${REGION}

