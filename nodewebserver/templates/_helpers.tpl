
{{- define "nodewebserver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nodewebserver.fullname" -}}
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
{{- define "nodewebserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nodewebserver.labels" -}}
helm.sh/chart: {{ include "nodewebserver.chart" . }}
{{ include "nodewebserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: nodewebserver
app.kubernetes.io/part-of: gyeeta
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nodewebserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nodewebserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
gyeeta.io/podtype: nodewebserver
{{- end }}

{{/*
Get the nodewebserver Service Name. Keep as nodewebserver if namespace is non-default
*/}}
{{- define "nodewebserver.servicename" -}}
{{- if eq .Release.Namespace "default" }}
{{- printf "%s" ( include "nodewebserver.fullname" . ) }}
{{- else }}
{{- printf "nodewebserver" }}
{{- end }}
{{- end }}


{{/*
Return the proper nodewebserver image name
*/}}
{{- define "nodewebserver.image" -}}
{{- with .Values.image.registry -}}
    {{- . }}/
{{- end -}}
{{- .Values.image.repository }}:
{{- .Values.image.tag | default .Chart.AppVersion -}}
{{- end -}}


{{/*
Renders a value that contains template.
Usage:
{{ include "nodewebserver.tplvalues" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "nodewebserver.tplvalues" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Return a soft nodeAffinity definition
{{ include "nodewebserver.affinities.nodes.soft" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "nodewebserver.affinities.nodes.soft" -}}
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
{{ include "nodewebserver.affinities.nodes.hard" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "nodewebserver.affinities.nodes.hard" -}}
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
{{ include "nodewebserver.affinities.nodes" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "nodewebserver.affinities.nodes" -}}
  {{- if eq .type "soft" }}
    {{- include "nodewebserver.affinities.nodes.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "nodewebserver.affinities.nodes.hard" . -}}
  {{- end -}}
{{- end -}}

{{/*
Return a soft podAffinity/podAntiAffinity definition
{{ include "nodewebserver.affinities.pods.soft" . -}}
*/}}
{{- define "nodewebserver.affinities.pods.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "nodewebserver.selectorLabels" .context) | nindent 10 }}
      namespaces:
        - {{ .context.Release.Namespace | quote }}
      topologyKey: kubernetes.io/hostname
    weight: 1
{{- end -}}

{{/*
Return a hard podAffinity/podAntiAffinity definition
{{ include "nodewebserver.affinities.pods.hard" . -}}
*/}}
{{- define "nodewebserver.affinities.pods.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels: {{- (include "nodewebserver.selectorLabels" .context) | nindent 10 }}
    namespaces:
      - {{ .context.Release.Namespace | quote }}
    topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
Return a podAffinity/podAntiAffinity definition
{{ include "nodewebserver.affinities.pods" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "nodewebserver.affinities.pods" -}}
  {{- if eq .type "soft" }}
    {{- include "nodewebserver.affinities.pods.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "nodewebserver.affinities.pods.hard" . -}}
  {{- end -}}
{{- end -}}


{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "nodewebserver.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "nodewebserver.validateValues.shyamahosts" .) -}}
{{- $messages := append $messages (include "nodewebserver.validateValues.https" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{- printf "\n\n\nValues Validation failed (Please set the appropriate value using --set option or values.yaml file) :\n%s" $message | fail -}}
{{- end -}}
{{- end -}}


{{/*
Validate values of nodewebserver_config.shyama_hosts and nodewebserver_config.shyama_ports
*/}}
{{- define "nodewebserver.validateValues.shyamahosts" -}}
{{- if or (empty .Values.nodewebserver_config.shyama_hosts) (empty .Values.nodewebserver_config.shyama_ports) }}
nodewebserver: nodewebserver_config.shyama_hosts, nodewebserver_config.shyama_ports
    Missing Shyama Server Host or Port.
    Please provide one or more valid Shyama Server Hosts and ports for nodewebserver hosts.
    Please refer to https://gyeeta.io/docs/installation/nodewebserver_config
{{- else if ne (len .Values.nodewebserver_config.shyama_hosts) (len .Values.nodewebserver_config.shyama_ports) }}
nodewebserver: nodewebserver_config.shyama_hosts, nodewebserver_config.shyama_ports
    Unequal entries seen for Shyama Server Hosts and Ports.
    Please provide equal number of Shyama Server Hosts and ports for nodewebserver hosts.
    Please refer to https://gyeeta.io/docs/installation/nodewebserver_config
{{- else if ne (kindOf (index .Values.nodewebserver_config.shyama_hosts 0)) "string" }}
nodewebserver: nodewebserver_config.shyama_hosts
    Shyama Server Host not of string type.
    Please provide Shyama Server Hosts in string format and Ports in integer format.
    Please refer to https://gyeeta.io/docs/installation/nodewebserver_config
{{- else if eq (kindOf (index .Values.nodewebserver_config.shyama_ports 0)) "string" }}
nodewebserver: nodewebserver_config.shyama_ports
    Shyama Server Port not of integer type.
    Please provide Shyama Server Ports in integer format.
    Please refer to https://gyeeta.io/docs/installation/nodewebserver_config
{{- end -}}
{{- end -}}


{{/*
Validate values of nodewebserver_config.https for certificates
*/}}
{{- define "nodewebserver.validateValues.https" -}}
{{- if and .Values.nodewebserver_config.https.enabled (empty .Values.nodewebserver_config.https.existing_secret_name) (or (empty .Values.nodewebserver_config.https.cert) (empty .Values.nodewebserver_config.https.key)) }}
nodewebserver: nodewebserver_config.https.cert, nodewebserver_config.https.key
    Missing TLS Certificate or Private Key
    Please provide a valid PEM format TLS Certificate and Private Key.
    Please refer to https://gyeeta.io/docs/installation/nodewebserver_config
{{- end -}}
{{- end -}}


{{/*
Return the appropriate apiVersion for ingress.
*/}}
{{- define "nodewebserver.capabilities.ingress.apiVersion" -}}
{{- if semverCompare "<1.14-0" .Capabilities.KubeVersion.Version -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "<1.19-0" .Capabilities.KubeVersion.Version -}}
{{- print "networking.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Generate backend entry that is compatible with all Kubernetes API versions.

Usage:
{{ include "nodewebserver.ingress.backend" (dict "serviceName" "backendName" "servicePort" "backendPort" "context" $) }}

Params:
  - serviceName - String. Name of an existing service backend
  - servicePort - String/Int. Port name (or number) of the service. It will be translated to different yaml depending if it is a string or an integer.
  - context - Dict - Required. The context for the template evaluation.
*/}}
{{- define "nodewebserver.ingress.backend" -}}
{{- $apiVersion := (include "nodewebserver.capabilities.ingress.apiVersion" .context) -}}
{{- if or (eq $apiVersion "extensions/v1beta1") (eq $apiVersion "networking.k8s.io/v1beta1") -}}
serviceName: {{ .serviceName }}
servicePort: {{ .servicePort }}
{{- else -}}
service:
  name: {{ .serviceName }}
  port:
    {{- if typeIs "string" .servicePort }}
    name: {{ .servicePort }}
    {{- else if or (typeIs "int" .servicePort) (typeIs "float64" .servicePort) }}
    number: {{ .servicePort | int }}
    {{- end }}
{{- end -}}
{{- end -}}

{{/*
Print "true" if the API pathType field is supported
Usage:
{{ include "nodewebserver.ingress.supportsPathType" . }}
*/}}
{{- define "nodewebserver.ingress.supportsPathType" -}}
{{- if semverCompare "<1.18-0" .Capabilities.KubeVersion.Version -}}
{{- print "false" -}}
{{- else -}}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/*
Returns true if the ingressClassname field is supported
Usage:
{{ include "nodewebserver.ingress.supportsIngressClassname" . }}
*/}}
{{- define "nodewebserver.ingress.supportsIngressClassname" -}}
{{- if semverCompare "<1.18-0" .Capabilities.KubeVersion.Version -}}
{{- print "false" -}}
{{- else -}}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if cert-manager required annotations for TLS signed
certificates are set in the Ingress annotations
Ref: https://cert-manager.io/docs/usage/ingress/#supported-annotations
Usage:
{{ include "nodewebserver.ingress.certManagerRequest" ( dict "annotations" .Values.path.to.the.ingress.annotations ) }}
*/}}
{{- define "nodewebserver.ingress.certManagerRequest" -}}
{{ if or (hasKey .annotations "cert-manager.io/cluster-issuer") (hasKey .annotations "cert-manager.io/issuer") }}
    {{- true -}}
{{- end -}}
{{- end -}}
