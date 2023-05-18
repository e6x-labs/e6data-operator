
Please enable autscaler and workload identity pool for the node pool 

```console
gcloud container node-pools create NODEPOOL_NAME \
    --cluster=CLUSTER_NAME \
    --region=COMPUTE_REGION \
    --machine-type=c2-standard-30 \
    --enable-autoscaling \
    --min-nodes=1 \
    --max-nodes=10 \    
    --preemptible \
    --workload-metadata=GKE_METADATA
    

```


Create a GCS bucket
```console
gcloud storage buckets create [BUCKET] --location=[REGION] --project=[PROJECT ID]

```


Create write SA

```console

gcloud iam service-accounts create [SA-NAME] --description "[DESCRIPTION]" --display-name "[DISPLAY-NAME]" --project [PROJECT-ID]

```

Create read SA

```console

gcloud iam service-accounts create [SA-NAME] --description "[DESCRIPTION]" --display-name "[DISPLAY-NAME]" --project [PROJECT-ID]

```


Create a file (bucket-writer.yaml):
```console
title: [BUCKET-NAME]-Write-Access
description: Custom role with write access to the [BUCKET-NAME] bucket
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
  - serviceAccount:<service-account-email>
  role: roles/custom.role
  condition:
    title: [BUCKET-NAME]-Write-Access
    description: Access to [BUCKET-NAME] bucket
    expression: resource.name.startsWith("projects/_/buckets/[BUCKET-NAME]/")
```

Create a file (bucket-reader.yaml):
```console
title: Bucket-Read-Access
description: Custom role with read access to all buckets
stage: GA
includedPermissions:
- storage.objects.get
- storage.objects.list
- storage.objects.getIamPolicy
- storage.objects.testIamPermissions
bindings:
- members:
  - serviceAccount:<service-account-email>
  role: roles/custom.bucket.reader
```


Create role and binding for writer role:
```console
gcloud iam roles create [ROLE_ID] --project [PROJECT_ID] --file [YAML_OR_JSON_FILE]

```

Create role and binding for reader role:
```console
gcloud iam roles create [ROLE_ID] --project [PROJECT_ID] --file [YAML_OR_JSON_FILE]

```





workload binding

```
gcloud iam service-accounts add-iam-policy-binding GSA_NAME@GSA_PROJECT.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:[PROJECT_ID].svc.id.goog[NAMESPACE/KSA_NAME]"

```

create kubernetes SA // already done
```
kubectl create sa [SERVICE-ACCOUNT]

```


annote:
```
kubectl annotate sa [SERVICE-ACCOUNT] iam.gke.io/gcp-service-account=<sa1-email>

```

