#!/bin/bash

REGION=$1 # GCP region kuberentes cluster is running in
PROJECT_ID=$2  # GCP project ID
WORKSPACE_NAME=$3 # Name of e6data workspace to be created
CLUSTER_NAME=$4 # Kubernetes cluster name
CLUSTER_ZONE=$5 # Kubernetes cluster zone
MAX_INSTANCES_IN_NODEGROUP=$6 # Maximum number of instances in nodegroup
OPERATOR_SA_EMAIL=$7 # Service account email for the e6data kubernetes operator
if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" || -z "$6" || -z "$7" ]]; then
  echo "Usage: ./setup.sh <REGION> <PROJECT_ID> <WORKSPACE_NAME> <CLUSTER_NAME> <CLUSTER_ZONE> <MAX_INSTANCES_IN_NODEGROUP> <OPERATOR_SA_EMAIL>"
  echo "REGION: GCP region kuberentes cluster is running in"
  echo "PROJECT_ID: GCP project ID"
  echo "WORKSPACE_NAME: Name of e6data workspace to be created"
  echo "CLUSTER_NAME: Kubernetes cluster name"
  echo "CLUSTER_ZONE: Kubernetes cluster zone"
  echo "MAX_INSTANCES_IN_NODEGROUP: Maximum number of instances in nodegroup"
  echo "OPERATOR_SA_EMAIL: Service account email for the e6data kubernetes operator"
exit 0
fi

status_message () {
  OPERATION=$1
  COMMAND_CODE=$2

  if [ ${COMMAND_CODE} -ne 0 ]; then
  echo "${OPERATION}: failed"
  exit 1
  fi

  echo "${OPERATION}: Success"
}

case "$REGION" in
  northamerica-northeast1|northamerica-northeast2|southamerica-east1|southamerica-west1|us-central1|us-east1|us-east4|us-east5|us-south1|us-west1|us-west2|us-west3|us-west4)
    LOCATION="us"
    ;;
  europe-central2|europe-north1|europe-southwest1|europe-west1|europe-west12|europe-west2|europe-west3|europe-west4|europe-west6|europe-west8|europe-west9)
    LOCATION="eu"
    ;;
  asia-east1|asia-east2|asia-northeast1|asia-northeast2|asia-northeast3|asia-south1|asia-south2|asia-southeast1|asia-southeast2)
    LOCATION="asia"
    ;;
  *)
    echo "GCP region not supported by e6data. Please contact e6data team for further support"
    exit 0    
esac

WORKSPACE_NAMESPACE="e6data-workspace-${WORKSPACE_NAME}"
WORKSPACE_WRITE_ROLE_NAME="e6data_${WORKSPACE_NAME}_write"
WORKSPACE_READ_ROLE_NAME="e6data_${WORKSPACE_NAME}_read"
COMMON_GCP_FLAGS="--project ${PROJECT_ID} --quiet"
WORKSPACE_SA_EMAIL="${WORKSPACE_NAMESPACE}@${PROJECT_ID}.iam.gserviceaccount.com"


# gcloud container node-pools create ${WORKSPACE_NAMESPACE} \
#   --cluster=${CLUSTER_NAME} \
#   --zone=${CLUSTER_ZONE} \
#   --machine-type=c2-standard-30 \
#   --enable-autoscaling \
#   --total-min-nodes=1 \
#   --total-max-nodes=${MAX_INSTANCES_IN_NODEGROUP} \
#   --spot \
#   --workload-metadata=GKE_METADATA \
#   --location-policy=ANY \
#   ${COMMON_GCP_FLAGS} 
# STATUS_CODE=`echo $?`
# status_message "E6DATA_WORKSPACE_NODEPOOL_CREATION" ${STATUS_CODE}

# Create GCS bucket for workspace
gcloud storage buckets create gs://${WORKSPACE_NAMESPACE} --location=${LOCATION} ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_BUCKET_CREATION" ${STATUS_CODE}

# Create service account for workspace
gcloud iam service-accounts create ${WORKSPACE_NAMESPACE} --description "Service account for e6data workspace access" --display-name "${WORKSPACE_NAMESPACE}" ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GCP_SERVICE_ACCOUNT" ${STATUS_CODE} 

# Replace dummy with workspace namespace in gcp_roles yaml files
find gcp_roles/ -name "*.yaml" -exec sed -i '' "s|dummy|${WORKSPACE_NAMESPACE}|g" {} \;

# Create IAM role for workspace write access on GCS bucket
gcloud iam roles create ${WORKSPACE_WRITE_ROLE_NAME} --file gcp_roles/gcs_write_privileges.yaml ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GCP_CUSTOM_ROLE" ${STATUS_CODE} 

# Create IAM role for workspace read access on GCS buckets
gcloud iam roles create ${WORKSPACE_READ_ROLE_NAME} --file gcp_roles/gcs_read_privileges.yaml ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GCP_CUSTOM_ROLE" ${STATUS_CODE}

# Revert the replacement of workspace namespace in gcp_roles yaml files
find gcp_roles/ -name "*.yaml" -exec sed -i '' "s|${WORKSPACE_NAMESPACE}|dummy|g" {} \;

# Create IAM policy binding for workspace service account and GCS bucket write access
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${WORKSPACE_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${WORKSPACE_WRITE_ROLE_NAME} \
    --condition="title=${WORKSPACE_NAMESPACE}-access,description=Write Access to ${WORKSPACE_NAME} GCS bucket,expression=resource.name.startsWith(\"projects/_/buckets/${WORKSPACE_NAMESPACE}/\")" \
    ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GCS_WRITE_IAM_POLICY_BINDING" ${STATUS_CODE}    

# Create IAM policy binding for workspace service account and GCS bucket read access
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${WORKSPACE_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${WORKSPACE_READ_ROLE_NAME} \
    --condition="None" \
    ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GCS_WRITE_IAM_POLICY_BINDING" ${STATUS_CODE}    

# Create IAM policy binding for operator service account and GCS bucket read access
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${OPERATOR_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${WORKSPACE_READ_ROLE_NAME} \
    --condition="title=${WORKSPACE_NAMESPACE}-read-access,description=Read Access to ${WORKSPACE_NAME} GCS bucket,expression=resource.name.startsWith(\"projects/_/buckets/${WORKSPACE_NAMESPACE}/\")" \
    ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_OPERATOR_GCS_READ_IAM_POLICY_BINDING" ${STATUS_CODE}  

# Create IAM policy binding for workspace service account and Kubernetes cluster
gcloud iam service-accounts add-iam-policy-binding ${WORKSPACE_SA_EMAIL} \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${WORKSPACE_NAME}/${WORKSPACE_NAME}]" \
    ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GSA_KSA_MAPPING" ${STATUS_CODE}     

echo "------------Outputs required for helm script------------"
echo "GKE_NODEGROUP_NAME=${WORKSPACE_NAMESPACE}"
echo "GKE_NODEGROUP_MAX_INSTANCES=${MAX_INSTANCES_IN_NODEGROUP}"
echo "WORKSPACE_GCS_BUCKET_NAME=${WORKSPACE_NAMESPACE}"
echo "E6DATA_WORKSPACE_GSA_EMAIL=${WORKSPACE_SA_EMAIL}"
echo "E6DATA_WORKSPACE_NAME=${WORKSPACE_NAME}"
echo "--------------------------------------------------------"
