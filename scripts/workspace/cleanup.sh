#!/bin/bash
REGION=$1 # GCP region kuberentes cluster is running in
PROJECT_ID=$2  # GCP project ID
WORKSPACE_NAME=$3 # Name of e6data workspace to be created
CLUSTER_NAME=$4 # Kubernetes cluster name
KUBERNETES_NAMESPACE=$5 # Kubernetes namespace
CLUSTER_ZONE=$6 # Kubernetes cluster zone
if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" ]]; then
  echo "Usage: ./setup.sh <REGION> <PROJECT_ID> <WORKSPACE_NAME> <CLUSTER_NAME> <KUBERNETES_NAMESPACE> <CLUSTER_ZONE>"
  echo "REGION: GCP region kuberentes cluster is running in"
  echo "PROJECT_ID: GCP project ID"
  echo "WORKSPACE_NAME: Name of e6data workspace to be created"
  echo "CLUSTER_NAME: Kubernetes cluster name"
  echo "KUBERNETES_NAMESPACE: Kubernetes namespace to deploy e6data workspace in"
  echo "CLUSTER_ZONE: Kubernetes cluster zone (i.e Only if it is zonal kubernetes cluster)"
exit 0
fi

status_message () {
  OPERATION=$1
  COMMAND_CODE=$2

  if [ ${COMMAND_CODE} -ne 0 ]; then
    echo "${OPERATION}: Failed"
  else 
    echo "${OPERATION}: Success"
  fi
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

PLATFORM_SA_EMAIL="e6data-platform@${PROJECT_ID}.iam.gserviceaccount.com"
WORKSPACE_NAMESPACE="e6data-workspace-${WORKSPACE_NAME}"
WORKSPACE_WRITE_ROLE_NAME="e6data_${WORKSPACE_NAME}_write"
WORKSPACE_READ_ROLE_NAME="e6data_${WORKSPACE_NAME}_read"
COMMON_GCP_FLAGS="--project ${PROJECT_ID} --quiet"
WORKSPACE_SA_EMAIL="${WORKSPACE_NAMESPACE}@${PROJECT_ID}.iam.gserviceaccount.com"
PLATFORM_SA_EMAIL="dev-e6-helm-op-whyezopu@e6data-analytics.iam.gserviceaccount.com"


echo "Cleanup Started"
echo "\n"
# Remove IAM policy binding for Platform Service account and Kubernetes cluster
gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member "serviceAccount:${PLATFORM_SA_EMAIL}" \
    --role roles/container.clusterViewer \
    --condition=None \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GSA_KSA_MAPPING_DELETION" ${STATUS_CODE} 

# Remove IAM policy binding for Service account and Kubernetes cluster
gcloud iam service-accounts remove-iam-policy-binding ${WORKSPACE_SA_EMAIL} \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${KUBERNETES_NAMESPACE}/${WORKSPACE_NAME}]" \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GSA_KSA_MAPPING_DELETION" ${STATUS_CODE} 

# Remove IAM policy binding for Service account and custom read role for operator SA
gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${PLATFORM_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${WORKSPACE_WRITE_ROLE_NAME} \
    --condition="title=${WORKSPACE_NAMESPACE}-read-access,description=Read Access to ${WORKSPACE_NAME} GCS bucket,expression=resource.name.startsWith(\"projects/_/buckets/${WORKSPACE_NAMESPACE}/\")" \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
status_message "E6DATA_PLATFORM_GCS_READ_IAM_POLICY_BINDING_DELETION" ${STATUS_CODE} 

# Remove IAM policy binding for Service account and custom read role
gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${WORKSPACE_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${WORKSPACE_READ_ROLE_NAME} \
    --condition="None" \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GCS_READ_IAM_POLICY_BINDING_DELETION" ${STATUS_CODE}  

# Remove IAM policy binding for Service account and custom write role
gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${WORKSPACE_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${WORKSPACE_WRITE_ROLE_NAME} \
    --condition="title=${WORKSPACE_NAMESPACE}-access,description=Write Access to ${WORKSPACE_NAME} GCS bucket,expression=resource.name.startsWith(\"projects/_/buckets/${WORKSPACE_NAMESPACE}/\")" \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
status_message "E6DATA_WORKSPACE_GCS_WRITE_IAM_POLICY_BINDING_DELETION" ${STATUS_CODE} 

# Remove IAM Role for custom read role
gcloud iam roles describe ${WORKSPACE_READ_ROLE_NAME} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
if [ ${STATUS_CODE} -eq 0 ]; then
  gcloud iam roles delete ${WORKSPACE_READ_ROLE_NAME} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
  STATUS_CODE=`echo $?`
  status_message "E6DATA_WORKSPACE_GCP_CUSTOM_READ_ROLE_DELETION" ${STATUS_CODE}
fi

# Remove IAM Role for custom write role
gcloud iam roles describe ${WORKSPACE_WRITE_ROLE_NAME} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
if [ ${STATUS_CODE} -eq 0 ]; then
  gcloud iam roles delete ${WORKSPACE_WRITE_ROLE_NAME} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
  STATUS_CODE=`echo $?`
  status_message "E6DATA_WORKSPACE_GCP_CUSTOM_WRITE_ROLE_DELETION" ${STATUS_CODE}
fi

# Remove IAM workspace SA
gcloud iam service-accounts describe ${WORKSPACE_SA_EMAIL} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
if [ ${STATUS_CODE} -eq 0 ]; then
  gcloud iam service-accounts delete ${WORKSPACE_SA_EMAIL} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
  STATUS_CODE=`echo $?`
  status_message "E6DATA_WORKSPACE_GCP_SERVICE_ACCOUNT_DELETION" ${STATUS_CODE} 
fi

# Remove GCS bucket
gcloud storage buckets describe gs://${WORKSPACE_NAMESPACE} ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
if [ ${STATUS_CODE} -eq 0 ]; then
  gsutil rm -r gs://${WORKSPACE_NAMESPACE} >/dev/null 2>&1
  STATUS_CODE=`echo $?`
  status_message "E6DATA_WORKSPACE_BUCKET_DELETION" ${STATUS_CODE}
fi

# Remove Kubernetes nodepool
gcloud container node-pools describe ${WORKSPACE_NAMESPACE} \
    --cluster=${CLUSTER_NAME} \
    ${COMMON_GCP_KUBE_FLAGS} \
    ${COMMON_GCP_FLAGS} >/dev/null 2>&1
STATUS_CODE=`echo $?`
if [ ${STATUS_CODE} -eq 0 ]; then
  gcloud container node-pools delete ${WORKSPACE_NAMESPACE} \
      --cluster=${CLUSTER_NAME} \
      ${COMMON_GCP_KUBE_FLAGS} \
      ${COMMON_GCP_FLAGS} >/dev/null 2>&1
  STATUS_CODE=`echo $?`
  status_message "E6DATA_WORKSPACE_NODEPOOL_DELETION" ${STATUS_CODE}    
fi  

echo "Cleanup complete"