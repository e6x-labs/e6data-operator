#!/bin/bash
# pattern for role name : "[a-zA-Z0-9_\.]{3,64}"
# pattern for service account name:  [a-zA-Z][a-zA-Z\d\-]*[a-zA-Z\d]


# name of the bucket for e6data access
BUCKET_NAME=$1
# region for your infra creation
REGION=$2
#  project id for your GCP account
PROJECT_ID=$3
# Service account name which will be used for s3 write access to specific bucket
WRITE_SA_NAME=$4
# Service account name which will be have for s3 read access to all bucket
READ_SA_NAME=$5
# role name which will be used for s3 write access to specific bucket
WRITE_ROLE_ID=$6
# role account name which will be have for s3 read access to all bucket
READ_ROLE_ID=$7


# GSA_NAME=${10}
# GSA_PROJECT=${11}
# NAMESPACE=${12}
# KSA_NAME=${13}

# Create GCS BUCKET_NAME
gcloud storage buckets create ${BUCKET} --location=${REGION} --project=${PROJECT_ID}

# Create write SA
gcloud iam service-accounts create ${WRITE_SA_NAME} --description "e6data service account for write access" --display-name "${WRITE_SA_NAME}" --project ${PROJECT_ID}

# Create read SA
gcloud iam service-accounts create ${READ_SA_NAME} --description "e6data service account for read access" --display-name "${READ_SA_NAME}" --project ${PROJECT_ID}

# Create write YAML file
echo "title: ${BUCKET_NAME}-Write-Access
description: Custom role with write access to the ${BUCKET_NAME} bucket
stage: GA
includedPermissions:
- storage.objects.create
- storage.objects.delete
- storage.objects.list
- storage.objects.update
- storage.objects.get
- storage.objects.getIamPolicy
- storage.objects.setIamPolicy" > e6data_write_access.yaml


# Create role and binding for writer role
gcloud iam roles create ${WRITE_ROLE_ID} --project ${PROJECT_ID} --file e6data_write_access.yaml


gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${WRITE_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=projects/${PROJECT_ID}/roles/${WRITE_ROLE_ID} \
    --condition="title=${BUCKET_NAME}-Write-Access,description=Access to ${BUCKET_NAME} bucket,expression=resource.name.startsWith("projects/_/buckets/${BUCKET_NAME}/")"


# Create read YAML file
echo "title: Bucket-Read-Access
description: Custom role with read access to all buckets
stage: GA
includedPermissions:
- storage.objects.get
- storage.objects.list
- storage.objects.getIamPolicy" > e6data_read_access.yaml


# Create role and binding for reader role
gcloud iam roles create ${READ_ROLE_ID} --project ${PROJECT_ID} --file e6data_read_access.yaml

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${READ_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=projects/${PROJECT_ID}/roles/${READ_ROLE_ID} \
    --condition=None






# Add workload binding
gcloud iam service-accounts add-iam-policy-binding ${GSA_NAME}@${GSA_PROJECT}.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${NAMESPACE}/${KSA_NAME}]"


#bash script.sh [BUCKET_NAME] [REGION] [PROJECT_ID] [WRITE_SA_NAME] [READ_SA_NAME] [READ_SA_NAME] [WRITE_ROLE_ID] [READ_ROLE_ID] [GSA_NAME] [GSA_PROJECT] [NAMESPACE] [KSA_NAME]

