
{{- define "madhava.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "madhava.fullname" -}}
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
{{- define "madhava.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "madhava.labels" -}}
helm.sh/chart: {{ include "madhava.chart" . }}
{{ include "madhava.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: madhava
app.kubernetes.io/part-of: gyeeta
{{- end }}

{{/*
Selector labels
*/}}
{{- define "madhava.selectorLabels" -}}
app.kubernetes.io/name: {{ include "madhava.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
gyeeta.io/podtype: madhava
{{- end }}

{{/*
Return the proper madhava image name
*/}}
{{- define "madhava.image" -}}
{{- with .Values.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.image.repository }}:
{{- .Values.image.tag | default .Chart.AppVersion -}}
{{- end -}}


{{/*
Renders a value that contains template.
Usage:
{{ include "madhava.tplvalues" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "madhava.tplvalues" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return a soft nodeAffinity definition
{{ include "madhava.affinities.nodes.soft" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "madhava.affinities.nodes.soft" -}}
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
{{ include "madhava.affinities.nodes.hard" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "madhava.affinities.nodes.hard" -}}
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
{{ include "madhava.affinities.nodes" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "madhava.affinities.nodes" -}}
  {{- if eq .type "soft" }}
    {{- include "madhava.affinities.nodes.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "madhava.affinities.nodes.hard" . -}}
  {{- end -}}
{{- end -}}

{{/*
Return a soft podAffinity/podAntiAffinity definition
{{ include "madhava.affinities.pods.soft" . -}}
*/}}
{{- define "madhava.affinities.pods.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "madhava.selectorLabels" .context) | nindent 10 }}
      namespaces:
        - {{ .context.Release.Namespace | quote }}
      topologyKey: kubernetes.io/hostname
    weight: 1
{{- end -}}

{{/*
Return a hard podAffinity/podAntiAffinity definition
{{ include "madhava.affinities.pods.hard" . -}}
*/}}
{{- define "madhava.affinities.pods.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels: {{- (include "madhava.selectorLabels" .context) | nindent 10 }}
    namespaces:
      - {{ .context.Release.Namespace | quote }}
    topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
Return a podAffinity/podAntiAffinity definition
{{ include "madhava.affinities.pods" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "madhava.affinities.pods" -}}
  {{- if eq .type "soft" }}
    {{- include "madhava.affinities.pods.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "madhava.affinities.pods.hard" . -}}
  {{- end -}}
{{- end -}}


{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "madhava.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "madhava.validateValues.shyamasecret" .) -}}
{{- $messages := append $messages (include "madhava.validateValues.shyamahosts" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{- printf "\n\n\nValues Validation failed (Please set the appropriate value using --set option or values.yaml file) :\n%s" $message | fail -}}
{{- end -}}
{{- end -}}


{{/*
Validate to check if either of shyama_secret or shyama_existing_secretname is set
*/}}
{{- define "madhava.validateValues.shyamasecret" -}}
{{- if and (empty .Values.madhava_config.shyama_secret) (empty .Values.madhava_config.shyama_existing_secretname) }}
madhava: madhava_config.shyama_secret, madhava_config.shyama_existing_secretname
    Missing Shyama Secret. Please set either the madhava_config.shyama_secret field or
    if an existing Shyama secret is already in the same namespace, set the Kubernetes Secret name to
    madhava_config.shyama_existing_secretname field.
    Please refer to https://gyeeta.io/docs/installation/madhava_config
{{- end -}}
{{- end -}}

{{/*
Validate values of madhava_config.shyama_hosts and madhava_config.shyama_ports
*/}}
{{- define "madhava.validateValues.shyamahosts" -}}
{{- if or (empty .Values.madhava_config.shyama_hosts) (empty .Values.madhava_config.shyama_ports) }}
madhava: madhava_config.shyama_hosts, madhava_config.shyama_ports
    Missing Shyama Server Host or Port.
    Please provide one or more valid Shyama Server Hosts and ports for madhava hosts.
    Please refer to https://gyeeta.io/docs/installation/madhava_config
{{- else if ne (len .Values.madhava_config.shyama_hosts) (len .Values.madhava_config.shyama_ports) }}
madhava: madhava_config.shyama_hosts, madhava_config.shyama_ports
    Unequal entries seen for Shyama Server Hosts and Ports.
    Please provide equal number of Shyama Server Hosts and ports for madhava hosts.
    Please refer to https://gyeeta.io/docs/installation/madhava_config
{{- else if ne (kindOf (index .Values.madhava_config.shyama_hosts 0)) "string" }}
madhava: madhava_config.shyama_hosts
    Shyama Server Host not of string type.
    Please provide Shyama Server Hosts in string format and Ports in integer format.
    Please refer to https://gyeeta.io/docs/installation/madhava_config
{{- else if eq (kindOf (index .Values.madhava_config.shyama_ports 0)) "string" }}
madhava: madhava_config.shyama_ports
    Shyama Server Port not of integer type.
    Please provide Shyama Server Ports in integer format.
    Please refer to https://gyeeta.io/docs/installation/madhava_config
{{- end -}}
{{- end -}}


