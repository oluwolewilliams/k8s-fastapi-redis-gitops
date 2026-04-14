{{- define "python-api-chart.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "python-api-chart.fullname" -}}
{{- .Release.Name -}}
{{- end -}}

{{- define "python-api-chart.labels" -}}
app.kubernetes.io/name: {{ include "python-api-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}