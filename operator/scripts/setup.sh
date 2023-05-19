#!/bin/bash
# pattern for role name : "[a-zA-Z0-9_\.]{3,64}"
# pattern for service account name:  [a-zA-Z][a-zA-Z\d\-]*[a-zA-Z\d]

REGION=$1 # Region for infra
PROJECT_ID=$2  # GCP project ID
KUBERNETES_OPERATOR_NAMESPACE=$3 # Namespace for e6data operator

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "Usage: ./setup.sh <region> <project_id> <operator_namespace>"
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

OPERATOR_NAME="e6data-operator-${KUBERNETES_OPERATOR_NAMESPACE}"
OPERATOR_ROLE_NAME="e6data_operator_${KUBERNETES_OPERATOR_NAMESPACE}"
COMMON_GCP_FLAGS="--project ${PROJECT_ID} --quiet"
OPERATOR_SA_EMAIL="e6data-operator-${KUBERNETES_OPERATOR_NAMESPACE}@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud storage buckets create gs://${OPERATOR_NAME} --location=${LOCATION} ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_OPERATOR_BUCKET_CREATION" ${STATUS_CODE} 

gcloud iam service-accounts create ${OPERATOR_NAME} --description "Service account for e6data kubernetes operator access" --display-name "${OPERATOR_NAME}" ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_KUBERNETES_OPERATOR_GCP_SERVICE_ACCOUNT" ${STATUS_CODE} 

# Create role and binding for writer role
gcloud iam roles create ${OPERATOR_ROLE_NAME} --file gcp_roles/gcs_privileges.yaml ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_KUBERNETES_OPERATOR_GCP_CUSTOM_ROLE" ${STATUS_CODE} 

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${OPERATOR_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${OPERATOR_ROLE_NAME} \
    --condition="title=${OPERATOR_NAME}-access,description=Full access to ${OPERATOR_NAME} GCS bucket,expression=resource.name.startsWith(\"projects/_/buckets/${OPERATOR_NAME}/\")" \
    ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_OPERATOR_IAM_POLICY_BINDING" ${STATUS_CODE}     

# Add workload binding
gcloud iam service-accounts add-iam-policy-binding ${OPERATOR_SA_EMAIL} \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${KUBERNETES_OPERATOR_NAMESPACE}/e6data-operator]" \
    --role roles/iam.workloadIdentityUser \
    ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_KUBERNETES_OPERATOR_GSA_KSA_MAPPING" ${STATUS_CODE}   

#bash setup.sh [REGION] [PROJECT_ID] [OPERATOR_NAMESPACE]


echo "------------Outputs required for helm script------------"
echo "E6DATA_OPERATOR_BUCKET_NAME=${OPERATOR_NAME}"
echo "E6DATA_OPERATOR_GSA_EMAIL=${OPERATOR_SA_EMAIL}"
echo "--------------------------------------------------------"
