
{{/*
Expand the name of the chart.
*/}}
{{- define "partha.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "partha.fullname" -}}
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
{{- define "partha.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "partha.labels" -}}
helm.sh/chart: {{ include "partha.chart" . }}
{{ include "partha.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: agent
app.kubernetes.io/part-of: gyeeta
{{- end }}

{{/*
Selector labels
*/}}
{{- define "partha.selectorLabels" -}}
app.kubernetes.io/name: {{ include "partha.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
gyeeta.io/podtype: partha
{{- end }}

{{/*
Return the proper partha image name
*/}}
{{- define "partha.image" -}}
{{- with .Values.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.image.repository }}:
{{- .Values.image.tag | default .Chart.AppVersion -}}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "partha.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "partha.validateValues.clustername" .) -}}
{{- $messages := append $messages (include "partha.validateValues.shyamahosts" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{- printf "\n\n\nValues Validation failed (Please set the appropriate value using --set option or values.yaml file) :\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Validate values of partha_config.cluster_name
*/}}
{{- define "partha.validateValues.clustername" -}}
{{- if empty .Values.partha_config.cluster_name }}
partha: partha_config.cluster_name
    Missing Cluster Name.
    Please provide a valid Cluster Name for partha hosts.
{{- else if gt (len .Values.partha_config.cluster_name) 63 }}
partha: partha_config.cluster_name
    Invalid Partha Cluster Name as max length of 64 bytes exceeded. Please specify a valid Cluster Name for partha hosts.
{{- end -}}
{{- end -}}

{{/*
Validate values of partha_config.shyama_hosts and partha_config.shyama_ports
*/}}
{{- define "partha.validateValues.shyamahosts" -}}
{{- if or (empty .Values.partha_config.shyama_hosts) (empty .Values.partha_config.shyama_ports) }}
partha: partha_config.shyama_hosts, partha_config.shyama_ports
    Missing Shyama Server Host or Port.
    Please provide one or more valid Shyama Server Hosts and ports for partha hosts.
    Please refer to https://gyeeta.io/docs/installation/partha_config
{{- else if ne (len .Values.partha_config.shyama_hosts) (len .Values.partha_config.shyama_ports) }}
partha: partha_config.shyama_hosts, partha_config.shyama_ports
    Unequal entries seen for Shyama Server Hosts and Ports.
    Please provide equal number of Shyama Server Hosts and ports for partha hosts.
    Please refer to https://gyeeta.io/docs/installation/partha_config
{{- else if ne (kindOf (index .Values.partha_config.shyama_hosts 0)) "string" }}
partha: partha_config.shyama_hosts
    Shyama Server Host not of string type.
    Please provide Shyama Server Hosts in string format and Ports in integer format.
    Please refer to https://gyeeta.io/docs/installation/partha_config
{{- else if eq (kindOf (index .Values.partha_config.shyama_ports 0)) "string" }}
partha: partha_config.shyama_ports
    Shyama Server Port not of integer type.
    Please provide Shyama Server Ports in integer format.
    Please refer to https://gyeeta.io/docs/installation/partha_config
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "partha.tplvalues" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "partha.tplvalues" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

