{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "e6data.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create unified labels for e6data components
*/}}
{{- define "e6data.common.matchLabels" -}}
app: {{ template "e6data.name" . }}
release: {{ .Release.Name }}
product: e6data
{{- end -}}

{{- define "e6data.common.metaLabels" -}}
chart: {{ template "e6data.chart" . }}
heritage: {{ .Release.Service }}
product: e6data
{{- end -}}

{{- define "e6data.server.labels" -}}
{{ include "e6data.server.matchLabels" . }}
{{ include "e6data.common.metaLabels" . }}
{{- end -}}

{{- define "e6data.server.matchLabels" -}}
component: {{ .Values.server.name | quote }}
{{ include "e6data.common.matchLabels" . }}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "e6data.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "e6data.server.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Get KubeVersion removing pre-release information.
*/}}
{{- define "e6data.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version (regexFind "v[0-9]+\\.[0-9]+\\.[0-9]+" .Capabilities.KubeVersion.Version) -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "e6data.deployment.apiVersion" -}}
{{- print "apps/v1" -}}
{{- end -}}
{{/*

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "e6data.networkPolicy.apiVersion" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for poddisruptionbudget.
*/}}
{{- define "e6data.podDisruptionBudget.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1" }}
{{- print "policy/v1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}
{{/*
Return the appropriate apiVersion for rbac.
*/}}
{{- define "rbac.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "rbac.authorization.k8s.io/v1" }}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}
{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "ingress.apiVersion" -}}
  {{- if and (.Capabilities.APIVersions.Has "networking.k8s.io/v1") (semverCompare ">= 1.19.x" (include "e6data.kubeVersion" .)) -}}
      {{- print "networking.k8s.io/v1" -}}
  {{- else if .Capabilities.APIVersions.Has "networking.k8s.io/v1beta1" -}}
    {{- print "networking.k8s.io/v1beta1" -}}
  {{- else -}}
    {{- print "extensions/v1beta1" -}}
  {{- end -}}
{{- end -}}

{{/*
Return if ingress is stable.
*/}}
{{- define "ingress.isStable" -}}
  {{- eq (include "ingress.apiVersion" .) "networking.k8s.io/v1" -}}
{{- end -}}

{{/*
Return if ingress supports ingressClassName.
*/}}
{{- define "ingress.supportsIngressClassName" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "e6data.kubeVersion" .))) -}}
{{- end -}}
{{/*
Return if ingress supports pathType.
*/}}
{{- define "ingress.supportsPathType" -}}
  {{- or (eq (include "ingress.isStable" .) "true") (and (eq (include "ingress.apiVersion" .) "networking.k8s.io/v1beta1") (semverCompare ">= 1.18.x" (include "e6data.kubeVersion" .))) -}}
{{- end -}}

{{/*
Create the name of the service account to use for the server component
*/}}
{{- define "e6data.serviceAccountName.server" -}}
{{- if .Values.serviceAccounts.server.create -}}
    {{ default (include "e6data.server.fullname" .) .Values.serviceAccounts.server.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccounts.server.name }}
{{- end -}}
{{- end -}}

{{/*
Define the e6data.namespace template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "e6data.namespace" -}}
{{- if .Values.forceNamespace -}}
{{ printf "namespace: %s" .Values.forceNamespace }}
{{- else -}}
{{ printf "namespace: %s" .Release.Namespace }}
{{- end -}}
{{- end -}}


{{/*
Define the e6data.name template if set with forceNamespace or .Release.Namespace is set
*/}}
{{- define "e6data.name" -}}
{{ .Release.Name }}
{{- end -}}

{{/*
Define the e6data.serviceaccount.oidc_key template accordign to Values.cloud.type
*/}}
{{- define "e6data.serviceaccount.oidc_key" -}}
{{- if eq .Values.cloud.type "AWS" -}}
{{- print "eks.amazonaws.com/role-arn" -}}
{{- else -}}
{{- if eq .Values.cloud.type "GCP" -}}
{{- print "iam.gke.io/gcp-service-account" -}}
{{- else -}}
{{- if eq .Values.cloud.type "AZURE" -}}
{{- print "azure.workload.identity/client-id" -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define the e6data.serviceaccount.labels template according to Values.cloud.type
*/}}
{{- define "e6data.serviceaccount.labels" -}}
{{- if eq .Values.cloud.type "AZURE" -}}
{{- print "azure.workload.identity/use: true" -}}
{{- end -}}
{{- end -}}


{{/*
Define the e6data.serviceaccount.annotations template according to Values.cloud.type
*/}}
{{- define "e6data.serviceaccount.annotations" -}}
{{- if eq .Values.cloud.type "AWS" -}}
{{- print "eks.amazonaws.com/sts-regional-endpoints: true" -}}
{{- end -}}
{{- end -}}


