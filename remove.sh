
BUCKET_NAME=$1
REGION=$2
PROJECT_ID=$3
WRITE_SA_NAME=$4
READ_SA_NAME=$5
WRITE_ROLE_ID=$6
READ_ROLE_ID=$7



gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${WRITE_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=projects/${PROJECT_ID}/roles/${WRITE_ROLE_ID} \
    --condition='title=${BUCKET_NAME}-Write-Access,description=Access to ${BUCKET_NAME} bucket,expression=resource.name.startsWith("projects/_/buckets/${BUCKET_NAME}/")'

gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${READ_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com \
    --role=projects/${PROJECT_ID}/roles/${READ_ROLE_ID} \
    --condition=None



# Delete the custom roles
gcloud iam roles delete ${WRITE_ROLE_ID} --project ${PROJECT_ID}
gcloud iam roles delete ${READ_ROLE_ID} --project ${PROJECT_ID}

# Delete the service accounts
gcloud iam service-accounts delete ${WRITE_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com --project ${PROJECT_ID}
gcloud iam service-accounts delete ${READ_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com --project ${PROJECT_ID}




    
# Delete the YAML files
rm e6data_write_access.yaml
rm e6data_read_access.yaml