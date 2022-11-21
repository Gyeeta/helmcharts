<!--- app-name: alertaction -->

# Gyeeta's Alert Action Agent alertaction Helm Chart

[Alert Action Agent](https://gyeeta.io/docs/architecture#alert-action-agent) can be installed in [Kubernetes](https://kubernetes.io) Cluster environments using 
[Helm Charts](https://helm.sh).

The Alert Agent is installed as a Deployment with a default Replica Count as 1. 

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Install Instructions

The steps to install the Alert Agent Helm chart are :

- Add Gyeeta Repo to Helm
- Fetch and edit the values.yaml for the Alert Agent chart
- Install the Alert Agent chart with the edited values

```bash

helm repo add gyeeta https://gyeeta.io/helmcharts
helm repo update
helm show values gyeeta/alertaction > /tmp/alertaction.yaml

# Thereafter you can edit the /tmp/alertaction.yaml file if you need to change any option. 
# After editing the /tmp/alertaction.yaml, install the Alert Agent Helm chart using :

helm install --namespace gyeeta --create-namespace alertaction1  gyeeta/alertaction -f /tmp/alertaction.yaml

```

## Uninstalling the Chart

To uninstall the Alert Agent deployment say `alertaction1` as per command above :

```bash
helm uninstall alertaction1
```

## Alert Agent Chart Parameters {#alertaction-parameters}

The default Chart config can be obtained using the command :

```bash
helm show values gyeeta/alertaction > /tmp/alertaction.yaml
```

Then users can edit the `/tmp/alertaction.yaml` file. 

### Mandatory parameters to provide

The following are the mandatory parameters which users need to provide while installing the chart either using the `--set` CLI
option or by editing the yaml values in the file saved (for example, the `/tmp/alertaction.yaml` file in the command above) :

- `alertaction_config.shyama_hosts`
- `alertaction_config.shyama_ports`

The Helm chart install will fail if these parameters are not provided. Explanation about these parameters are given below.

### Alert Action Agent Config parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `alertaction_config` `.shyama_hosts` | Shyama Service Domains : Specify one or more Shyama Service Names (e.g., `[ "shyama1-headless" ]`) | `Array` | `[]` |
| `alertaction_config` `.shyama_ports` | Shyama Service Ports : Specify one or more Shyama Service Ports (e.g., `[ 10037 ]`) | `Array` | `[]` |

### Other parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `nameOverride` | Set a new name if you want to override the release name used | `String` | `""` |
| `fullnameOverride` | Set a new name if you want to override the fullname used | `String` | `""` |
| `clusterDomain` | Default Kubernetes cluster domain | `String` | `cluster.local` |
| `resources.requests` | Resource Requests | `Object` | `{}` |
| `resources.limits` | Resource Limits | `Object` | `{}` |
| `hostAliases` | pod host aliases for `/etc/hosts` | `Array` | `[]` |
| `affinity` | Affinity constraint for pod scheduling | `Object` | `{}` |
| `podAffinityPreset` | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `""` |
| `podAntiAffinityPreset` | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `soft` |
| `nodeAffinityPreset.type` | Node affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `""` |
| `nodeAffinityPreset.key` | Node label key to match. Ignored if `affinity` is set. | `String` | `""` |
| `nodeAffinityPreset.values` | Node label values to match. Ignored if `affinity` is set. | `Array` | `[]` |
| `replicaCount` | Number of replicas | `Number` | `1` |
| `serviceAccount.create` | Create ServiceAccount | `Boolean` | `false` |



