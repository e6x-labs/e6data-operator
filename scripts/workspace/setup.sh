#!/bin/bash

REGION=$1 # GCP region to run e6data workspace
PROJECT_ID=$2  # GCP project ID
WORKSPACE_NAME=$3 # Name of e6data workspace to be created
CLUSTER_NAME=$4 # Kubernetes cluster name
MAX_INSTANCES_IN_NODEGROUP=$5 # Maximum number of instances in nodegroup
KUBERNETES_NAMESPACE=$6 # Kubernetes namespace
CLUSTER_ZONE=$7 # Kubernetes cluster zone

if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" || -z "$6" ]]; then
  echo "Usage: ./setup.sh <REGION> <PROJECT_ID> <WORKSPACE_NAME> <CLUSTER_NAME> <MAX_INSTANCES_IN_NODEGROUP> <CLUSTER_ZONE>"
  echo "REGION: GCP region to run e6data workspace"
  echo "PROJECT_ID: GCP project ID"
  echo "WORKSPACE_NAME: Name of e6data workspace to be created"
  echo "CLUSTER_NAME: Kubernetes cluster name"
  echo "MAX_INSTANCES_IN_NODEGROUP: Maximum number of instances in nodegroup"
  echo "KUBERNETES_NAMESPACE: Kubernetes namespace to deploy e6data workspace in"
  echo "CLUSTER_ZONE: Kubernetes cluster zone (i.e Only if it is zonal kubernetes cluster)"
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

if [[ -z "$CLUSTER_ZONE" ]]; then
  COMMON_GCP_KUBE_FLAGS="--region ${REGION}"
else
  COMMON_GCP_KUBE_FLAGS="--zone ${CLUSTER_ZONE}"  
fi

WORKSPACE_NAMESPACE="e6data-workspace-${WORKSPACE_NAME}"
WORKSPACE_WRITE_ROLE_NAME="e6data_${WORKSPACE_NAME}_write"
WORKSPACE_READ_ROLE_NAME="e6data_${WORKSPACE_NAME}_read"
COMMON_GCP_FLAGS="--project ${PROJECT_ID} --quiet"
WORKSPACE_SA_EMAIL="${WORKSPACE_NAMESPACE}@${PROJECT_ID}.iam.gserviceaccount.com"
PLATFORM_SA_EMAIL="dev-e6-helm-op-whyezopu@e6data-analytics.iam.gserviceaccount.com"


# # Create GKE nodepool for workspace
 gcloud container node-pools describe ${WORKSPACE_NAMESPACE} \
    --cluster=${CLUSTER_NAME} \
    ${COMMON_GCP_KUBE_FLAGS} \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
if [ ${STATUS_CODE} -ne 0 ]; then
  gcloud container node-pools create ${WORKSPACE_NAMESPACE} \
    --cluster=${CLUSTER_NAME} \
    --machine-type=c2-standard-30 \
    --enable-autoscaling \
    --total-min-nodes=1 \
    --total-max-nodes=${MAX_INSTANCES_IN_NODEGROUP} \
    --spot \
    --workload-metadata=GKE_METADATA \
    --location-policy=ANY \
    ${COMMON_GCP_KUBE_FLAGS} \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
  STATUS_CODE=`echo $?`
  status_message "E6DATA_WORKSPACE_NODEPOOL_CREATION" ${STATUS_CODE}
fi

# # Create GCS bucket for workspace
gcloud storage buckets describe gs://${WORKSPACE_NAMESPACE} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
if [ ${STATUS_CODE} -ne 0 ]; then
  gcloud storage buckets create gs://${WORKSPACE_NAMESPACE} --location=${LOCATION} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
  STATUS_CODE=`echo $?`
  status_message "E6DATA_WORKSPACE_BUCKET_CREATION" ${STATUS_CODE}
fi

# # Create service account for workspace
gcloud iam service-accounts describe ${WORKSPACE_SA_EMAIL} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
if [ ${STATUS_CODE} -ne 0 ]; then
  gcloud iam service-accounts create ${WORKSPACE_NAMESPACE} --description "Service account for e6data workspace access" --display-name "${WORKSPACE_NAMESPACE}" ${COMMON_GCP_FLAGS} >/dev/null 2>&1
  STATUS_CODE=`echo $?`
  status_message "E6DATA_WORKSPACE_GCP_SERVICE_ACCOUNT" ${STATUS_CODE} 
fi

# Replace dummy with workspace namespace in gcp_roles yaml files
find gcp_roles/ -name "*.yaml" -exec sed -i '' "s|dummy|${WORKSPACE_NAMESPACE}|g" {} \;

# # Create IAM role for workspace write access on GCS bucket
gcloud iam roles describe ${WORKSPACE_WRITE_ROLE_NAME} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
if [ ${STATUS_CODE} -ne 0 ]; then
  gcloud iam roles create ${WORKSPACE_WRITE_ROLE_NAME} --file gcp_roles/gcs_write_privileges.yaml ${COMMON_GCP_FLAGS} >/dev/null 2>&1
  STATUS_CODE=`echo $?`
  status_message "E6DATA_WORKSPACE_GCP_CUSTOM_ROLE" ${STATUS_CODE} 
fi

# # Create IAM role for workspace read access on GCS buckets
gcloud iam roles describe ${WORKSPACE_READ_ROLE_NAME} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
if [ ${STATUS_CODE} -ne 0 ]; then
  gcloud iam roles create ${WORKSPACE_READ_ROLE_NAME} --file gcp_roles/gcs_read_privileges.yaml ${COMMON_GCP_FLAGS} >/dev/null 2>&1
  STATUS_CODE=`echo $?`
  status_message "E6DATA_WORKSPACE_GCP_CUSTOM_ROLE" ${STATUS_CODE} 
fi

# Revert the replacement of workspace namespace in gcp_roles yaml files
find gcp_roles/ -name "*.yaml" -exec sed -i '' "s|${WORKSPACE_NAMESPACE}|dummy|g" {} \;

# # Create IAM policy binding for workspace service account and GCS bucket write access
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${WORKSPACE_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${WORKSPACE_WRITE_ROLE_NAME} \
    --condition="title=${WORKSPACE_NAMESPACE}-access,description=Write Access to ${WORKSPACE_NAME} GCS bucket,expression=resource.name.startsWith(\"projects/_/buckets/${WORKSPACE_NAMESPACE}/\")" \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GCS_WRITE_IAM_POLICY_BINDING" ${STATUS_CODE}    

# Create IAM policy binding for workspace service account and GCS bucket read access
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${WORKSPACE_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${WORKSPACE_READ_ROLE_NAME} \
    --condition="None" \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GCS_READ_IAM_POLICY_BINDING" ${STATUS_CODE}    

# Create IAM policy binding for e6data Platform with GCS bucket read and write access
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${PLATFORM_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${WORKSPACE_WRITE_ROLE_NAME} \
    --condition="title=${WORKSPACE_NAMESPACE}-read-access,description=Read Access to ${WORKSPACE_NAME} GCS bucket,expression=resource.name.startsWith(\"projects/_/buckets/${WORKSPACE_NAMESPACE}/\")" \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
status_message "E6DATA_PLATFORM_GCS_READ_IAM_POLICY_BINDING" ${STATUS_CODE}  

# Create IAM policy binding for workspace service account and Kubernetes cluster
gcloud iam service-accounts add-iam-policy-binding ${WORKSPACE_SA_EMAIL} \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${KUBERNETES_NAMESPACE}/${WORKSPACE_NAME}]" \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GSA_KSA_MAPPING" ${STATUS_CODE}   

# Create IAM policy binding for Platform Service and Kubernetes cluster
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --role roles/container.clusterViewer \
    --member "serviceAccount:${PLATFORM_SA_EMAIL}" \
    --condition=None \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GSA_KSA_MAPPING" ${STATUS_CODE}   

echo "------------Outputs required for helm script------------"
echo "GKE_NODEGROUP_NAME=${WORKSPACE_NAMESPACE}"
echo "GKE_NODEGROUP_MAX_INSTANCES=${MAX_INSTANCES_IN_NODEGROUP}"
echo "WORKSPACE_GCS_BUCKET_NAME=${WORKSPACE_NAMESPACE}"
echo "E6DATA_WORKSPACE_GSA_EMAIL=${WORKSPACE_SA_EMAIL}"
echo "E6DATA_WORKSPACE_NAME=${WORKSPACE_NAME}"
echo "KUBERNETES_NAMESPACE=${KUBERNETES_NAMESPACE}"
echo "--------------------------------------------------------"
