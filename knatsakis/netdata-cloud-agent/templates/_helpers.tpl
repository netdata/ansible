{{/* vim: set filetype=mustache: */}}

{{- define "labels" -}}
app.kubernetes.io/instance: '{{ .Release.Name }}'
app.kubernetes.io/managed-by: '{{ .Release.Service }}'
app.kubernetes.io/name: '{{ .Chart.Name }}'
helm.sh/chart: '{{ .Chart.Name }}-{{ .Chart.Version }}'
{{- end -}}

{{- define "matchLabels" -}}
app.kubernetes.io/instance: '{{ .Release.Name }}'
app.kubernetes.io/name: '{{ .Chart.Name }}'
{{- end -}}
