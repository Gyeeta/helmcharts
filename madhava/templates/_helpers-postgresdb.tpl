
{{- define "madhava.postgresdb.name" -}}
{{- printf "%s-postgresdb" (default .Chart.Name .Values.nameOverride) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "madhava.postgresdb.fullname" -}}
{{- printf "%s-postgresdb" ( include "madhava.fullname" . ) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common postgresdb labels
*/}}
{{- define "madhava.postgresdb.labels" -}}
helm.sh/chart: {{ include "madhava.chart" . }}
{{ include "madhava.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.postgresdb.image.tag | default "12.2.0" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: database
app.kubernetes.io/part-of: gyeeta
{{- end }}

{{/*
Selector labels
*/}}
{{- define "madhava.postgresdb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "madhava.postgresdb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}



{{/*
Return the proper madhava postgresdb image name
*/}}
{{- define "madhava.postgresdb.image" -}}
{{- with .Values.postgresdb.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.postgresdb.image.repository }}:
{{- .Values.postgresdb.image.tag | default "12.2.0" -}}
{{- end -}}

{{/*
Return  the proper Storage Class
{{ include "madhava.postgresdb.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "madhava.postgresdb.storage.class" -}}

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

