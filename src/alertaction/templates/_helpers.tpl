
{{- define "alertaction.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "alertaction.fullname" -}}
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
{{- define "alertaction.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "alertaction.labels" -}}
helm.sh/chart: {{ include "alertaction.chart" . }}
{{ include "alertaction.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: alertaction
app.kubernetes.io/part-of: gyeeta
{{- end }}

{{/*
Selector labels
*/}}
{{- define "alertaction.selectorLabels" -}}
app.kubernetes.io/name: {{ include "alertaction.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
gyeeta.io/podtype: alertaction
{{- end }}


{{/*
Return the proper alertaction image name
*/}}
{{- define "alertaction.image" -}}
{{- with .Values.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.image.repository }}:
{{- .Values.image.tag | default .Chart.AppVersion -}}
{{- end -}}


{{/*
Renders a value that contains template.
Usage:
{{ include "alertaction.tplvalues" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "alertaction.tplvalues" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return a soft nodeAffinity definition
{{ include "alertaction.affinities.nodes.soft" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "alertaction.affinities.nodes.soft" -}}
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
{{ include "alertaction.affinities.nodes.hard" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "alertaction.affinities.nodes.hard" -}}
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
{{ include "alertaction.affinities.nodes" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "alertaction.affinities.nodes" -}}
  {{- if eq .type "soft" }}
    {{- include "alertaction.affinities.nodes.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "alertaction.affinities.nodes.hard" . -}}
  {{- end -}}
{{- end -}}

{{/*
Return a soft podAffinity/podAntiAffinity definition
{{ include "alertaction.affinities.pods.soft" . -}}
*/}}
{{- define "alertaction.affinities.pods.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "alertaction.selectorLabels" .context) | nindent 10 }}
      namespaces:
        - {{ .context.Release.Namespace | quote }}
      topologyKey: kubernetes.io/hostname
    weight: 1
{{- end -}}

{{/*
Return a hard podAffinity/podAntiAffinity definition
{{ include "alertaction.affinities.pods.hard" . -}}
*/}}
{{- define "alertaction.affinities.pods.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels: {{- (include "alertaction.selectorLabels" .context) | nindent 10 }}
    namespaces:
      - {{ .context.Release.Namespace | quote }}
    topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
Return a podAffinity/podAntiAffinity definition
{{ include "alertaction.affinities.pods" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "alertaction.affinities.pods" -}}
  {{- if eq .type "soft" }}
    {{- include "alertaction.affinities.pods.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "alertaction.affinities.pods.hard" . -}}
  {{- end -}}
{{- end -}}


{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "alertaction.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "alertaction.validateValues.shyamahosts" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{- printf "\n\n\nValues Validation failed (Please set the appropriate value using --set option or values.yaml file) :\n%s" $message | fail -}}
{{- end -}}
{{- end -}}


{{/*
Validate values of alertaction_config.shyama_hosts and alertaction_config.shyama_ports
*/}}
{{- define "alertaction.validateValues.shyamahosts" -}}
{{- if or (empty .Values.alertaction_config.shyama_hosts) (empty .Values.alertaction_config.shyama_ports) }}
alertaction: alertaction_config.shyama_hosts, alertaction_config.shyama_ports
    Missing Shyama Server Host or Port.
    Please provide one or more valid Shyama Server Hosts and ports for alertaction hosts.
    Please refer to https://gyeeta.io/docs/installation/alertaction_config
{{- else if ne (len .Values.alertaction_config.shyama_hosts) (len .Values.alertaction_config.shyama_ports) }}
alertaction: alertaction_config.shyama_hosts, alertaction_config.shyama_ports
    Unequal entries seen for Shyama Server Hosts and Ports.
    Please provide equal number of Shyama Server Hosts and ports for alertaction hosts.
    Please refer to https://gyeeta.io/docs/installation/alertaction_config
{{- else if ne (kindOf (index .Values.alertaction_config.shyama_hosts 0)) "string" }}
alertaction: alertaction_config.shyama_hosts
    Shyama Server Host not of string type.
    Please provide Shyama Server Hosts in string format and Ports in integer format.
    Please refer to https://gyeeta.io/docs/installation/alertaction_config
{{- else if eq (kindOf (index .Values.alertaction_config.shyama_ports 0)) "string" }}
alertaction: alertaction_config.shyama_ports
    Shyama Server Port not of integer type.
    Please provide Shyama Server Ports in integer format.
    Please refer to https://gyeeta.io/docs/installation/alertaction_config
{{- end -}}
{{- end -}}

