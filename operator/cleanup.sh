REGION=$1 # Region for infra
PROJECT_ID=$2  # GCP project ID


if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "Usage: ./setup.sh <region> <project_id> <operator_namespace>"
exit 0
fi


OPERATOR_NAME="e6data-kubernetes-operator"
OPERATOR_ROLE_NAME="e6data_kubernetes_operator"
OPERATOR_SA_EMAIL="e6data-kubernetes-operator@${PROJECT_ID}.iam.gserviceaccount.com"
COMMON_GCP_FLAGS="--project ${PROJECT_ID} --quiet"


gsutil rm -r gs://${OPERATOR_NAME} ${COMMON_GCP_FLAGS}
gcloud iam service-accounts delete ${OPERATOR_SA_EMAIL} ${COMMON_GCP_FLAGS}
gcloud iam roles delete ${OPERATOR_ROLE_NAME} ${COMMON_GCP_FLAGS}
