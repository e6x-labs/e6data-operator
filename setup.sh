#!/bin/bash
# pattern for role name : "[a-zA-Z0-9_\.]{3,64}"
# pattern for service account name:  [a-zA-Z][a-zA-Z\d\-]*[a-zA-Z\d]

UUID=""
for i in {1..6}; do
  UUID="${UUID}$(($RANDOM % 10))"
done

echo "UUID:${UUID}"

REGION=$1 # Region for infra
PROJECT_ID=$2  # GCP project ID
OPERATOR_NAMESPACE=$3 # Namespace for e6data operator
WORKSPACE_NAMESPACE=$4 # Namespace for workspace 



if [[ -z "$1" || -z "$2" || -z "$3" || -z "$4" ]]; then
  echo "Usage: ./script.sh <region> <project_id> <operator_namespace> <workspace_namespace>"
  exit 1
fi

UUID=""
for i in {1..6}; do
  UUID="${UUID}$(($RANDOM % 10))"
done

echo 


COMMON_NAME="e6data-${WORKSPACE_NAMESPACE}-${UUID}"

COMMON_NAME_ROLES="e6data_${WORKSPACE_NAMESPACE}_${UUID}"


# Create GCS COMMON_NAME
gcloud storage buckets create ${COMMON_NAME} --location=${REGION} --project=${PROJECT_ID}

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
    --condition="title=${COMMON_NAME}-platform-access,description=Access to ${COMMON_NAME} bucket,expression=resource.name.startsWith("projects/_/buckets/${COMMON_NAME}/")"


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
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${OPERATOR_NAMESPACE}/${OPERATOR_NAMESPACE}]"


gcloud iam service-accounts add-iam-policy-binding ${ENGINE_SA_EMAIL} \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${WORKSPACE_NAMESPACE}/${WORKSPACE_NAMESPACE}]"




#bash script.sh [COMMON_NAME] [REGION] [PROJECT_ID] [WRITE_SA_NAME] [READ_SA_NAME] [READ_SA_NAME] [WRITE_ROLE_ID] [READ_ROLE_ID] [GSA_NAME] [GSA_PROJECT] [NAMESPACE] [KSA_NAME]

