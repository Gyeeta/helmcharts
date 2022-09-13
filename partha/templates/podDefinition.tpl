{{- define "partha.podDefinition" -}}
{{- $parthavol := true -}}
{{- range .Values.mounts.volumeMounts }}
  {{- if eq .mountPath "/hostdata" -}}
    {{- $parthavol := false -}}
  {{- end -}} 
{{- end -}}
metadata:
  name: {{ include "partha.fullname" . }}
  labels:
    {{- include "partha.selectorLabels" . | nindent 4 }}
    {{- with .Values.podLabels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    checksum/config: {{ include (print $.Template.BasePath "/configmap.yaml") . | sha256sum }}
    {{- with .Values.podAnnotations }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  hostPID: true
  hostNetwork: true
  dnsPolicy: ClusterFirstWithHostNet
  restartPolicy: Always
  {{- if .Values.podPriorityClassName }}
  priorityClassName: {{ .Values.podPriorityClassName }}
  {{- end }}
  {{- with .Values.nodeSelector }}
  nodeSelector:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.affinity }}
  affinity:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.tolerations }}
  tolerations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.imagePullSecrets }}
  imagePullSecrets: 
    {{- toYaml . | nindent 4 }}
  {{- end }}
  containers:
    - name: {{ .Chart.Name }}
      image: {{ include "partha.image" . }}
      imagePullPolicy: {{ .Values.image.pullPolicy }}
      resources:
        {{- toYaml .Values.resources | nindent 8 }}
      securityContext:
        runAsNonRoot: false
        privileged: true
        runAsUser: 0
        readOnlyRootFilesystem: true 
      args:
        - start
        - --cfg_json_file
        - /etc/partha/partha_main.json
        {{- if not .Values.logtofile }}
        - --nolog
        {{- end }}
        {{- if .Values.debuglevel }}
        - --debuglevel
        - {{ .Values.debuglevel }}
        {{- end }}
        {{- with .Values.extra.args }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
      env:
      {{- range $key, $value := .Values.extra.env }}
        - name: "{{ $key }}"
          value: "{{ $value }}"
      {{- end }}
      volumeMounts:
        - mountPath: /proc
          name: proc
        - mountPath: /sys
          name: sys
        - mountPath: /etc/partha
          name: config-volume
        {{- if $parthavol }}
        - mountPath: /hostdata
          name: parthavol
        {{- end }}  
        {{- with .Values.mounts.volumeMounts }}
          {{- toYaml . | nindent 8 }}
        {{- end }}
  volumes:
    {{- if $parthavol }}
    - name: parthavol
      emptyDir: {}
    {{- end }}  
    - name: proc
      hostPath:
        path: /proc
    - name: sys
      hostPath:
        path: /sys
    - name: config-volume
      configMap:
        name: {{ include "partha.fullname" . }}
    {{- with .Values.mounts.volumes }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
{{- end -}}

