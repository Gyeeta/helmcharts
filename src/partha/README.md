<!--- app-name: partha -->

# Partha - Gyeeta's Host Monitor Agent Helm Chart

[Partha Host Agents](https://gyeeta.io/docs/architecture#host-monitor-agent-partha) can be installed in [Kubernetes](https://kubernetes.io) Cluster environments using 
[Helm Charts](https://helm.sh).

The Partha Host Agent is installed as a Daemonset as it needs to be installed on each host (node).

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Linux kernel version 4.4+

### Requirement of Kernel Headers

The Partha Agent container requires *Kernel Headers* package to be installed on the base host for eBPF support. 

This requirement is not applicable on Google Container Optimized OS (COS) (used in GKE environments), as the partha container will itself download 
the currently running Kernel's Headers.

The Partha Helm Chart includes a parameter `partha_config.install_kern_headers` which, if enabled, the Partha container itself will try installing
the Kernel Headers package to the base OS. The parameter is disabled by default as on enabling this, the container may make changes to the base OS.

Please refer to [Kernel Headers Installation](https://gyeeta.io/docs/installation/partha_install#kernel-headers) for instructions on installing 
Kernel Headers directly on the base OS.


## Install Instructions

The steps to install the Partha Helm chart are :

- Add Gyeeta Repo to Helm
- Fetch and edit the values.yaml for the Partha chart
- Install the Partha chart with the edited values

```bash

helm repo add gyeeta https://gyeeta.io/helmcharts
helm repo update
helm show values gyeeta/partha > /tmp/partha.yaml

# Thereafter you can edit the /tmp/partha.yaml file if you need to change any option. 
# After editing the /tmp/partha.yaml, install the Partha Helm chart using :

helm install --namespace gyeeta --create-namespace partha1  gyeeta/partha -f /tmp/partha.yaml

```

## Uninstalling the Chart

To uninstall the Partha deployment say `partha1` as per command above :

```bash
helm uninstall partha1
```

## Security Requirements

The Partha container will need to run as a `priviliged` container as it needs Linux Capabilities beyond the standard capabilities
provided by the container runtime.

Also, the Partha pod will need to run with `hostPID` and `hostNetwork` set to true as Partha needs to run in the Host Network and PID
namespaces.

For Kubernetes versions 1.25+, users may need to enable the `priviliged` Partha container by enabling the 
[Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission) for the Partha pod Namespace if
priviliged pods are set to be rejected.


## Partha Chart Parameters

The default Chart config can be obtained using the command :

```bash
helm show values gyeeta/partha > /tmp/partha.yaml
```

Then users can edit the `/tmp/partha.yaml` file. 

### Mandatory parameters to provide

The following are the mandatory parameters which users need to provide while installing the chart either using the `--set` CLI
option or by editing the yaml values in the file saved (for example, the `/tmp/partha.yaml` file in the command above) :

- `partha_config.cluster_name`
- `partha_config.shyama_hosts`
- `partha_config.shyama_ports`

The Helm chart install will fail if these parameters are not provided. Explanation about these parameters are given below.

### Partha Container Related parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `partha_config.cluster_name` | Cluster Name : Tag Name for this Cluster | `String` | `""` |
| `partha_config.shyama_hosts` | Shyama Service Domains : Specify one or more Shyama Service Names (e.g., `[ "shyama1-headless" ]`) | `Array` | `[]` |
| `partha_config.shyama_ports` | Shyama Service Ports : Specify one or more Shyama Service Ports (e.g., `[ 10037 ]`) | `Array` | `[]` |
| `partha_config.cloud_type` | Cloud Operator : Specify as either of `aws`, `gcp`, `azure`. For other clouds or on-prem, leave blank | `String` | `""` |
| `partha_config.region_name` | Region Name : Ignore if `cloud_type` is set. For on-prem or other clouds, specify as the Network region name | `String` | `""` |
| `partha_config.zone_name` | Zone Name : Ignore if `cloud_type` is set. For on-prem or other clouds, specify as the Network Zone name | `String` | `""` |
| `partha_config` `.response_sampling_percent` | Percent of workload to be analyzed for Response and QPS Calculations | `Number` | `100` |
| `partha_config.capture_errcode` | Capture HTTP Error codes | `Boolean` | `true` |
| `partha_config.logtofile` | Process Log sent to file instead of stdout/stderr. If true will use the `emptyDir` mount point for logging | `Boolean` | `true` |
| `partha_config` `.install_kern_headers` | Install Kernel Headers on hosts without Kernel Headers (beta) and valid only for Debian, Ubuntu, and Redhat/Amazon Linux | `Boolean` | `false` |

### Other parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `nameOverride` | Set a new name if you want to override the release name used | `String` | `""` |
| `fullnameOverride` | Set a new name if you want to override the fullname used | `String` | `""` |
| `resources.requests` | Partha Container Resource Requests | `Object` | `{ "memory" : "200Mi" }` |
| `resources.limits` | Partha Container Resource Limits | `Object` | `{ "memory" : "1024Mi" }` |
| `podSecurityPolicy` | Enable PodSecurityPolicy (only for K8s versions < 1.25) | `Boolean` | `true` |
| `affinity` | Affinity constraint for pod scheduling | `Object` | `{}` |
| `mounts.volumes` | List of extra volumes to add to the Partha container | `Array` | `[]` |
| `mounts.volumeMounts` | List of extra volume mounts to add to the Partha container | `Array` | `[]` |
| `extra.env` | Extra environment variables to pass onto Partha container | `Object` | `{}` |
| `extra.args` | Extra Command Line Arguments (CLI) to pass onto Partha container | `Array` | `[]` |


If `partha_config.logtofile` is set to `true`, then the Partha process logs will be sent to `/hostdata/log/partha.log`.
Users can analyze the logs by running the command :

```bash

# Get the Partha pod name and fill in PARTHAPOD env
kubectl exec -it $PARTHAPOD -- more /hostdata/log/partha.log

```

