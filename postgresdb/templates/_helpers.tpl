
{{/*
Expand the name of the chart.
*/}}
{{- define "postgresdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "postgresdb.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "postgresdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "postgresdb.labels" -}}
helm.sh/chart: {{ include "postgresdb.chart" . }}
{{ include "postgresdb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: database
app.kubernetes.io/part-of: gyeeta
{{- end }}

{{/*
Selector labels
*/}}
{{- define "postgresdb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgresdb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return the proper postgresdb image name
*/}}
{{- define "postgresdb.image" -}}
{{- with .Values.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.image.repository }}:
{{- .Values.image.tag | default .Chart.AppVersion -}}
{{- end -}}


{{/*
Renders a value that contains template.
Usage:
{{ include "postgresdb.tplvalues" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "postgresdb.tplvalues" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return a soft nodeAffinity definition
{{ include "postgresdb.affinities.nodes.soft" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "postgresdb.affinities.nodes.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - preference:
      matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
    weight: 1
{{- end -}}

{{/*
Return a hard nodeAffinity definition
{{ include "postgresdb.affinities.nodes.hard" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "postgresdb.affinities.nodes.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
{{- end -}}

{{/*
Return a nodeAffinity definition
{{ include "postgresdb.affinities.nodes" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "postgresdb.affinities.nodes" -}}
  {{- if eq .type "soft" }}
    {{- include "postgresdb.affinities.nodes.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "postgresdb.affinities.nodes.hard" . -}}
  {{- end -}}
{{- end -}}

{{/*
Return a soft podAffinity/podAntiAffinity definition
{{ include "postgresdb.affinities.pods.soft" . -}}
*/}}
{{- define "postgresdb.affinities.pods.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "postgresdb.selectorLabels" .context) | nindent 10 }}
      namespaces:
        - {{ .context.Release.Namespace | quote }}
      topologyKey: kubernetes.io/hostname
    weight: 1
{{- end -}}

{{/*
Return a hard podAffinity/podAntiAffinity definition
{{ include "postgresdb.affinities.pods.hard" . -}}
*/}}
{{- define "postgresdb.affinities.pods.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels: {{- (include "postgresdb.selectorLabels" .context) | nindent 10 }}
    namespaces:
      - {{ .context.Release.Namespace | quote }}
    topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
Return a podAffinity/podAntiAffinity definition
{{ include "postgresdb.affinities.pods" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "postgresdb.affinities.pods" -}}
  {{- if eq .type "soft" }}
    {{- include "postgresdb.affinities.pods.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "postgresdb.affinities.pods.hard" . -}}
  {{- end -}}
{{- end -}}


{{/*
Return  the proper Storage Class
{{ include "postgresdb.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "postgresdb.storage.class" -}}

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

