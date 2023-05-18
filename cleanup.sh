
REGION=$1 # Region for infra
PROJECT_ID=$2 
OPERATOR_NAMESPACE=$3
WORKSPACE_NAMESPACE=$4
UUID=$5
CLUSTER_NAME=$6 


COMMON_NAME="e6data-${WORKSPACE_NAMESPACE}-${UUID}"

COMMON_NAME_ROLES="e6data_${WORKSPACE_NAMESPACE}_${UUID}"


PLATFORM_SA_EMAIL="${COMMON_NAME}-platform@${PROJECT_ID}.iam.gserviceaccount.com"


gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${PLATFORM_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${COMMON_NAME_ROLES}_platform  \
    --condition="title=${COMMON_NAME}-platform-access,description=Access to ${COMMON_NAME} bucket,expression=resource.name.startsWith(\"projects/_/buckets/${COMMON_NAME}/\")"


ENGINE_SA_EMAIL="${COMMON_NAME}-engine@${PROJECT_ID}.iam.gserviceaccount.com"


gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${ENGINE_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${COMMON_NAME_ROLES}_platform  \
    --condition="title=${COMMON_NAME}-engine-access,description=Access to ${COMMON_NAME} bucket,expression=resource.name.startsWith("projects/_/buckets/${COMMON_NAME}/")"



gcloud projects remove-iam-policy-binding ${PROJECT_ID} \
    --member=serviceAccount:${ENGINE_SA_EMAIL} \
    --role=projects/${PROJECT_ID}/roles/${COMMON_NAME_ROLES}_engine \
    --condition="None"


# Delete the custom roles
gcloud iam roles delete ${COMMON_NAME_ROLES}_platform --project ${PROJECT_ID}
gcloud iam roles delete ${COMMON_NAME_ROLES}_engine --project ${PROJECT_ID}

# Delete the service accounts
gcloud iam service-accounts delete ${COMMON_NAME}-platform@${PROJECT_ID}.iam.gserviceaccount.com --project ${PROJECT_ID}
gcloud iam service-accounts delete ${COMMON_NAME}-engine@${PROJECT_ID}.iam.gserviceaccount.com --project ${PROJECT_ID}

# delete the storage bucket
gcloud storage buckets delete ${COMMON_NAME} --project=${PROJECT_ID}

# delete node pool
gcloud container node-pools delete NODEPOOL_NAME --cluster=${CLUSTER_NAME} --region=${REGION}




    
