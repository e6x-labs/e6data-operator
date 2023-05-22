REGION=$1 # Region for infra
PROJECT_ID=$2  # GCP project ID
KUBERNETES_OPERATOR_NAMESPACE=$3 #  Kubernetes namespace where e6data operator will be deployed


if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "Usage: ./setup.sh <REGION> <PROJECT_ID> <KUBERNETES_OPERATOR_NAMESPACE>"
  echo "REGION: GCP region kuberentes cluster is running in"
  echo "PROJECT_ID: GCP project ID"
  echo "KUBERNETES_OPERATOR_NAMESPACE: Kubernetes namespace where e6data operator will be deployed"
  
  echo "Example: ./cleanup.sh us-central1 my-project e6data-operator"
exit 0
fi


status_message () {
  OPERATION=$1
  COMMAND_CODE=$2

  if [ ${COMMAND_CODE} -ne 0 ]; then
    echo "${OPERATION}: failed"
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

OPERATOR_NAME="e6data-operator-${KUBERNETES_OPERATOR_NAMESPACE}"
OPERATOR_ROLE_NAME="e6data_operator_${KUBERNETES_OPERATOR_NAMESPACE}"
COMMON_GCP_FLAGS="--project ${PROJECT_ID} --quiet"
OPERATOR_SA_EMAIL="e6data-operator-${KUBERNETES_OPERATOR_NAMESPACE}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Cleanup Started"
echo "\n"
# Remove IAM policy binding for Service account and Kubernetes cluster
gcloud iam service-accounts remove-iam-policy-binding ${OPERATOR_SA_EMAIL} \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${KUBERNETES_OPERATOR_NAMESPACE}/e6data-operator]" \
    --role roles/iam.workloadIdentityUser \
    ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_KUBERNETES_OPERATOR_GSA_KSA_MAPPING_DELETION" ${STATUS_CODE}   

# Remove IAM policy binding for Service account and custom role
gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${OPERATOR_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${OPERATOR_ROLE_NAME} \
    --condition="title=${OPERATOR_NAME}-access,description=Full access to ${OPERATOR_NAME} GCS bucket,expression=resource.name.startsWith(\"projects/_/buckets/${OPERATOR_NAME}/\")" \
    ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_OPERATOR_IAM_POLICY_BINDING_DELETION" ${STATUS_CODE}     

# Remove custom role for GCS bucket read access
gcloud iam roles delete ${OPERATOR_ROLE_NAME} ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_OPERATOR_ROLE_DELETION" ${STATUS_CODE}

# Remove Service account
gcloud iam service-accounts delete ${OPERATOR_SA_EMAIL} ${COMMON_GCP_FLAGS} 
STATUS_CODE=`echo $?`
status_message "E6DATA_KUBERNETES_OPERATOR_GCP_SERVICE_ACCOUNT_DELETION" ${STATUS_CODE}

# Remove GCS bucket
gsutil rm -r gs://${OPERATOR_NAME}
STATUS_CODE=`echo $?`
status_message "E6DATA_OPERATOR_BUCKET_DELETION" ${STATUS_CODE}

echo "Cleanup complete"

