#!/bin/bash
# pattern for role name : "[a-zA-Z0-9_\.]{3,64}"
# pattern for service account name:  [a-zA-Z][a-zA-Z\d\-]*[a-zA-Z\d]



REGION=$1 # Region for infra
PROJECT_ID=$2  # GCP project ID
WORKSPACE_NAME=$3 # Namespace for workspace 



WORKSPACE_NAME="e6data-workspace-${WORKSPACE_NAME}"
WORKSPACE_WRITE_ROLE_NAME="e6data_${WORKSPACE_NAME}_write"
WORKSPACE_READ_ROLE_NAME="e6data_${WORKSPACE_NAME}_read"
COMMON_GCP_FLAGS="--project ${PROJECT_ID} --quiet"
WORKSPACE_SA_EMAIL="e6data-workspace@${PROJECT_ID}.iam.gserviceaccount.com"



gsutil rm -r gs://${WORKSPACE_NAME} ${COMMON_GCP_FLAGS}
gcloud iam service-accounts delete ${WORKSPACE_NAME} ${COMMON_GCP_FLAGS}
gcloud iam roles delete ${WORKSPACE_WRITE_ROLE_NAME} ${COMMON_GCP_FLAGS}
gcloud iam roles delete ${WORKSPACE_READ_ROLE_NAME} ${COMMON_GCP_FLAGS}
gcloud container node-pools delete ${WORKSPACE_NAME} --cluster=${CLUSTER_NAME} --region=${REGION}

