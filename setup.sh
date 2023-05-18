#!/bin/bash
# pattern for role name : "[a-zA-Z0-9_\.]{3,64}"
# pattern for service account name:  [a-zA-Z][a-zA-Z\d\-]*[a-zA-Z\d]

REGION=$1 # Region for infra
PROJECT_ID=$2  # GCP project ID
OPERATOR_NAMESPACE=$3 # Namespace for e6data operator
WORKSPACE_NAMESPACE=$4 # Namespace for workspace 
CLUSTER_NAME=$5 # Cluster name for the kubernetes
MAX_INSTANCES_IN_NODEGROUP=$6 # Max VMs to be created in GKE nodegroup
if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" || -z "$5" || -z "$6" ]]; then
  echo "Usage: ./setup.sh <region> <project_id> <operator_namespace> <workspace_namespace> <cluster_name> <max_nodegroup_instances>"
exit 1
fi

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
esac

UUID=""

for i in {1..6}; do
  UUID="${UUID}$(($RANDOM % 10))"
done

COMMON_NAME="e6data-${WORKSPACE_NAMESPACE}-${UUID}"
COMMON_NAME_ROLES="e6data_${WORKSPACE_NAMESPACE}_${UUID}"


gcloud container node-pools \
create e6data-${UUID}-nodepool \
--cluster=${CLUSTER_NAME} \
--region=${REGION} \
--machine-type=c2-standard-30 \
--enable-autoscaling \
--min-nodes=1 \
--max-nodes=${MAX_INSTANCES_IN_NODEGROUP} \
--preemptible \
--workload-metadata=GKE_METADATA


# Create GCS COMMON_NAME
gcloud storage buckets create gs://${COMMON_NAME} --location=${LOCATION} --project=${PROJECT_ID}

# Create write SA
gcloud iam service-accounts create ${COMMON_NAME}-platform --description "e6data service account for platform access" --display-name "${COMMON_NAME}-platform" --project ${PROJECT_ID}

# Create read SA
gcloud iam service-accounts create ${COMMON_NAME}-engine --description "e6data service account for engine access" --display-name "${COMMON_NAME}-engine" --project ${PROJECT_ID}

# Create write YAML file
echo "title: ${COMMON_NAME}-platform-access
description: Custom role with platform access to the ${COMMON_NAME} bucket
stage: GA
includedPermissions:
- storage.objects.create
- storage.objects.delete
- storage.objects.list
- storage.objects.update
- storage.objects.get
- storage.objects.getIamPolicy
- storage.objects.setIamPolicy" > e6data_platform_access.yaml

# Create read YAML file
echo "title: ${COMMON_NAME}-engine-access
description: Custom role with read access to all buckets
stage: GA
includedPermissions:
- storage.objects.get
- storage.objects.list
- storage.objects.getIamPolicy" > e6data_engine_access.yaml




# Create role and binding for writer role
gcloud iam roles create ${COMMON_NAME_ROLES}_platform --project ${PROJECT_ID} --file e6data_platform_access.yaml

# Create role and binding for reader role
gcloud iam roles create ${COMMON_NAME_ROLES}_engine --project ${PROJECT_ID} --file e6data_engine_access.yaml


# Delete the YAML files
rm e6data_platform_access.yaml
rm e6data_engine_access.yaml

PLATFORM_SA_EMAIL="${COMMON_NAME}-platform@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${PLATFORM_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${COMMON_NAME_ROLES}_platform  \
    --condition="title=${COMMON_NAME}-platform-access,description=Access to ${COMMON_NAME} bucket,expression=resource.name.startsWith(\"projects/_/buckets/${COMMON_NAME}/\")"


ENGINE_SA_EMAIL="${COMMON_NAME}-engine@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${ENGINE_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${COMMON_NAME_ROLES}_platform  \
    --condition="title=${COMMON_NAME}-engine-access,description=Access to ${COMMON_NAME} bucket,expression=resource.name.startsWith("projects/_/buckets/${COMMON_NAME}/")"



gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${ENGINE_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${COMMON_NAME_ROLES}_engine \
    --condition=None

# Add workload binding
gcloud iam service-accounts add-iam-policy-binding ${PLATFORM_SA_EMAIL} \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${OPERATOR_NAMESPACE}/e6data-operator]"


gcloud iam service-accounts add-iam-policy-binding ${ENGINE_SA_EMAIL} \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${WORKSPACE_NAMESPACE}/${WORKSPACE_NAMESPACE}]"

#bash setup.sh [REGION] [PROJECT_ID] [OPERATOR_NAMESPACE] [WORKSPACE_NAMESPACE] [CLUSTER_NAME]


echo "------------Outputs required for helm script------------"
echo "GKE_NODEGROUP_NAME=e6data-${UUID}-nodepool"
echo "GKE_NODEGROUP_MAX_INSTANCES=${MAX_INSTANCES_IN_NODEGROUP}"
echo "E6DATA_GCS_BUCKET_NAME=${COMMON_NAME}"
echo "E6DATA_OPERATOR_GSA_EMAIL=${PLATFORM_SA_EMAIL}"
echo "E6DATA_WORKSPACE_GSA_EMAIL=${ENGINE_SA_EMAIL}"
echo "E6DATA_OPERATOR_NAMESPACE=${OPERATOR_NAMESPACE}"
echo "E6DATA_WORKSPACE_NAMESPACE=${WORKSPACE_NAMESPACE}"
echo "--------------------------------------------------------"
