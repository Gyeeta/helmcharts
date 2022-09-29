
{{- define "shyama.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "shyama.fullname" -}}
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
{{- define "shyama.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "shyama.labels" -}}
helm.sh/chart: {{ include "shyama.chart" . }}
{{ include "shyama.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: shyama
app.kubernetes.io/part-of: gyeeta
{{- end }}

{{/*
Selector labels
*/}}
{{- define "shyama.selectorLabels" -}}
app.kubernetes.io/name: {{ include "shyama.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return the proper shyama image name
*/}}
{{- define "shyama.image" -}}
{{- with .Values.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.image.repository }}:
{{- .Values.image.tag | default .Chart.AppVersion -}}
{{- end -}}


{{/*
Renders a value that contains template.
Usage:
{{ include "shyama.tplvalues" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "shyama.tplvalues" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return a soft nodeAffinity definition
{{ include "shyama.affinities.nodes.soft" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "shyama.affinities.nodes.soft" -}}
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
{{ include "shyama.affinities.nodes.hard" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "shyama.affinities.nodes.hard" -}}
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
{{ include "shyama.affinities.nodes" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "shyama.affinities.nodes" -}}
  {{- if eq .type "soft" }}
    {{- include "shyama.affinities.nodes.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "shyama.affinities.nodes.hard" . -}}
  {{- end -}}
{{- end -}}

{{/*
Return a soft podAffinity/podAntiAffinity definition
{{ include "shyama.affinities.pods.soft" . -}}
*/}}
{{- define "shyama.affinities.pods.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "shyama.selectorLabels" .context) | nindent 10 }}
      namespaces:
        - {{ .context.Release.Namespace | quote }}
      topologyKey: kubernetes.io/hostname
    weight: 1
{{- end -}}

{{/*
Return a hard podAffinity/podAntiAffinity definition
{{ include "shyama.affinities.pods.hard" . -}}
*/}}
{{- define "shyama.affinities.pods.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels: {{- (include "shyama.selectorLabels" .context) | nindent 10 }}
    namespaces:
      - {{ .context.Release.Namespace | quote }}
    topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
Return a podAffinity/podAntiAffinity definition
{{ include "shyama.affinities.pods" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "shyama.affinities.pods" -}}
  {{- if eq .type "soft" }}
    {{- include "shyama.affinities.pods.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "shyama.affinities.pods.hard" . -}}
  {{- end -}}
{{- end -}}



