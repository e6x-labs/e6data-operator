#!/bin/bash
# pattern for role name : "[a-zA-Z0-9_\.]{3,64}"
# pattern for service account name:  [a-zA-Z][a-zA-Z\d\-]*[a-zA-Z\d]

REGION=$1 # Region for infra
PROJECT_ID=$2  # GCP project ID
WORKSPACE_NAME=$3 # Namespace for workspace 
CLUSTER_NAME=$4 # Cluster name for the kubernetes
CLUSTER_ZONE=$5 # Zone for the cluster
MAX_INSTANCES_IN_NODEGROUP=$6 # Max VMs to be created in GKE nodegroup
OPERATOR_SA_EMAIL=$7 # Service account email for the operator
if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" || -z "$6" || -z "$7" ]]; then
  echo "Usage: ./setup.sh <region> <project_id> <workspace_name> <cluster_name> <cluster_zone> <max_nodegroup_instances> <operator_sa_email>"
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
# --cluster=${CLUSTER_NAME} \
# --zone=${CLUSTER_ZONE} \
# --machine-type=c2-standard-30 \
# --enable-autoscaling \
# --total-min-nodes=1 \
# --total-max-nodes=${MAX_INSTANCES_IN_NODEGROUP} \
# --spot \
# --workload-metadata=GKE_METADATA \
# --location-policy=ANY \
# ${COMMON_GCP_FLAGS} 
# STATUS_CODE=`echo $?`
# status_message "E6DATA_WORKSPACE_NODEPOOL_CREATION" ${STATUS_CODE}

# gcloud storage buckets create gs://${WORKSPACE_NAMESPACE} --location=${LOCATION} ${COMMON_GCP_FLAGS}
# STATUS_CODE=`echo $?`
# status_message "E6DATA_WORKSPACE_BUCKET_CREATION" ${STATUS_CODE}

# gcloud iam service-accounts create ${WORKSPACE_NAMESPACE} --description "Service account for e6data workspace access" --display-name "${WORKSPACE_NAMESPACE}" ${COMMON_GCP_FLAGS}
# STATUS_CODE=`echo $?`
# status_message "E6DATA_WORKSPACE_GCP_SERVICE_ACCOUNT" ${STATUS_CODE} 

# find gcp_roles/ -name "*.yaml" -exec sed -i '' "s|dummy|${WORKSPACE_NAMESPACE}|g" {} \;

# Create role and binding for writer role
# gcloud iam roles create ${WORKSPACE_WRITE_ROLE_NAME} --file gcp_roles/gcs_write_privileges.yaml ${COMMON_GCP_FLAGS}
# STATUS_CODE=`echo $?`
# status_message "E6DATA_WORKSPACE_GCP_CUSTOM_ROLE" ${STATUS_CODE} 

# # Create role and binding for reader role
# gcloud iam roles create ${WORKSPACE_READ_ROLE_NAME} --file gcp_roles/gcs_read_privileges.yaml ${COMMON_GCP_FLAGS}
# STATUS_CODE=`echo $?`
# status_message "E6DATA_WORKSPACE_GCP_CUSTOM_ROLE" ${STATUS_CODE}

# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#     --member=serviceAccount:${WORKSPACE_SA_EMAIL} \
#     --role=projects/${PROJECT_ID}/roles/${WORKSPACE_WRITE_ROLE_NAME} \
#     --condition="title=${WORKSPACE_NAMESPACE}-access,description=Write Access to ${WORKSPACE_NAME} GCS bucket,expression=resource.name.startsWith(\"projects/_/buckets/${WORKSPACE_NAMESPACE}/\")" \
#     ${COMMON_GCP_FLAGS}
# STATUS_CODE=`echo $?`
# status_message "E6DATA_WORKSPACE_GCS_WRITE_IAM_POLICY_BINDING" ${STATUS_CODE}    

# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#     --member=serviceAccount:${WORKSPACE_SA_EMAIL} \
#     --role=projects/${PROJECT_ID}/roles/${WORKSPACE_READ_ROLE_NAME} \
#     --condition="None" \
#     ${COMMON_GCP_FLAGS}
# STATUS_CODE=`echo $?`
# status_message "E6DATA_WORKSPACE_GCS_WRITE_IAM_POLICY_BINDING" ${STATUS_CODE}    

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${OPERATOR_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${WORKSPACE_READ_ROLE_NAME} \
    --condition="title=${WORKSPACE_NAMESPACE}-read-access,description=Read Access to ${WORKSPACE_NAME} GCS bucket,expression=resource.name.startsWith(\"projects/_/buckets/${WORKSPACE_NAMESPACE}/\")" \
    ${COMMON_GCP_FLAGS}
STATUS_CODE=`echo $?`
status_message "E6DATA_OPERATOR_GCS_READ_IAM_POLICY_BINDING" ${STATUS_CODE}  

# gcloud iam service-accounts add-iam-policy-binding ${WORKSPACE_SA_EMAIL} \
#     --role roles/iam.workloadIdentityUser \
#     --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${WORKSPACE_NAME}/${WORKSPACE_NAME}]" \
#     ${COMMON_GCP_FLAGS}
# STATUS_CODE=`echo $?`
# status_message "E6DATA_WORKSPACE_GSA_KSA_MAPPING" ${STATUS_CODE}     

#bash setup.sh [REGION] [PROJECT_ID] [WORKSPACE_NAME] [CLUSTER_NAME]


echo "------------Outputs required for helm script------------"
echo "GKE_NODEGROUP_NAME=e6data-${WORKSPACE_NAME}"
echo "GKE_NODEGROUP_MAX_INSTANCES=${MAX_INSTANCES_IN_NODEGROUP}"
echo "WORKSPACE_GCS_BUCKET_NAME=${WORKSPACE_NAME}"
echo "E6DATA_WORKSPACE_GSA_EMAIL=${WORKSPACE_SA_EMAIL}"
echo "E6DATA_WORKSPACE_NAME=${WORKSPACE_NAME}"
echo "--------------------------------------------------------"
