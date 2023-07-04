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
{{- define "e6data.common.labels" -}}
app: {{ template "e6data.name" . }}
product: e6data
component: workspace
chart: {{ template "e6data.chart" . }}
heritage: {{ .Release.Service }}
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


