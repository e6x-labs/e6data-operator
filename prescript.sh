#!/bin/bash

BUCKET=$1
REGION=$2
PROJECT_ID=$3
WRITE_SA_NAME=$4
WRITE_SA_DESC=$5
WRITE_SA_DISPLAY_NAME=$6
READ_SA_NAME=$7
READ_SA_DESC=$8
READ_SA_DISPLAY_NAME=$9
WRITE_YAML_FILE=${10}
READ_YAML_FILE=${11}
WRITE_ROLE_ID=${12}
READ_ROLE_ID=${13}
GSA_NAME=${14}
GSA_PROJECT=${15}
NAMESPACE=${16}
KSA_NAME=${17}

# Create GCS bucket
gcloud storage buckets create ${BUCKET} --location=${REGION} --project=${PROJECT_ID}

# Create write SA
gcloud iam service-accounts create ${WRITE_SA_NAME} --description "${WRITE_SA_DESC}" --display-name "${WRITE_SA_DISPLAY_NAME}" --project ${PROJECT_ID}

# Create read SA
gcloud iam service-accounts create ${READ_SA_NAME} --description "${READ_SA_DESC}" --display-name "${READ_SA_DISPLAY_NAME}" --project ${PROJECT_ID}

# Create write YAML file
echo "title: ${BUCKET}-Write-Access
description: Custom role with write access to the ${BUCKET} bucket
stage: GA
includedPermissions:
- storage.objects.create
- storage.objects.delete
- storage.objects.list
- storage.objects.update
- storage.objects.get
- storage.objects.getIamPolicy
- storage.objects.setIamPolicy
- storage.objects.testIamPermissions
bindings:
- members:
  - serviceAccount:${WRITE_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
  role: roles/custom.role
  condition:
    title: ${BUCKET}-Write-Access
    description: Access to ${BUCKET} bucket
    expression: resource.name.startsWith(\"projects/_/buckets/${BUCKET}/\")" > ${WRITE_YAML_FILE}

# Create read YAML file
echo "title: Bucket-Read-Access
description: Custom role with read access to all buckets
stage: GA
includedPermissions:
- storage.objects.get
- storage.objects.list
- storage.objects.getIamPolicy
- storage.objects.testIamPermissions
bindings:
- members:
  - serviceAccount:${READ_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com
  role: roles/custom.bucket.reader" > ${READ_YAML_FILE}


# Create role and binding for writer role
gcloud iam roles create ${WRITE_ROLE_ID} --project ${PROJECT_ID} --file ${WRITE_YAML_FILE}

# Create role and binding for reader role
gcloud iam roles create ${READ_ROLE_ID} --project ${PROJECT_ID} --file ${READ_YAML_FILE}

# Add workload binding
gcloud iam service-accounts add-iam-policy-binding ${GSA_NAME}@${GSA_PROJECT}.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${NAMESPACE}/${KSA_NAME}]"


#bash script.sh [BUCKET] [REGION] [PROJECT_ID] [WRITE_SA_NAME] [WRITE_SA_DESC] [WRITE_SA_DISPLAY_NAME] [READ_SA_NAME] [READ_SA_DESC] [READ_SA_DISPLAY_NAME] [WRITE_YAML_FILE] [READ_YAML_FILE] [WRITE_ROLE_ID] [READ_ROLE_ID] [GSA_NAME] [GSA_PROJECT] [NAMESPACE] [KSA_NAME]

