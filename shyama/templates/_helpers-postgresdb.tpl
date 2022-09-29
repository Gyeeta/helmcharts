
{{- define "shyama.postgresdb.name" -}}
{{- printf "%s-postgresdb" (default .Chart.Name .Values.nameOverride) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "shyama.postgresdb.fullname" -}}
{{- printf "%s-postgresdb" ( {{ include "shyama.fullname" }} ) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common postgresdb labels
*/}}
{{- define "shyama.postgresdb.labels" -}}
helm.sh/chart: {{ include "shyama.chart" . }}
{{ include "shyama.postgresdb.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.postgresdb.image.tag | default "12.2.0" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: database
app.kubernetes.io/part-of: gyeeta
{{- end }}

{{/*
Selector labels
*/}}
{{- define "shyama.selectorLabels" -}}
app.kubernetes.io/name: {{ include "shyama.postgresdb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}



{{/*
Return the proper shyama postgresdb image name
*/}}
{{- define "shyama.postgresdb.image" -}}
{{- with .Values.postgresdb.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.postgresdb.image.repository }}:
{{- .Values.postgresdb.image.tag | default "12.2.0" -}}
{{- end -}}

{{/*
Return  the proper Storage Class
{{ include "shyama.postgresdb.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "shyama.postgresdb.storage.class" -}}

{{- $storageClass := .persistence.storageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.storageClass -}}
    {{- end -}}
{{- end -}}

{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}

{{- end -}}

