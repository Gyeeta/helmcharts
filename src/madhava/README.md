<!--- app-name: madhava -->

# Gyeeta's Madhava Intermediate Server Helm Chart

# Madhava Kubernetes Helm Chart

[Madhava Intermediate Servers](https://gyeeta.io/docs/architecture#intermediate-server-madhava) can be installed in [Kubernetes](https://kubernetes.io) Cluster environments using 
[Helm Charts](https://helm.sh).

The Madhava servers are installed as a Statefulset along with an optional Postgres DB as a side container

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Install Instructions

The steps to install the Madhava Helm chart are :

- Add Gyeeta Repo to Helm
- Fetch and edit the values.yaml for the Madhava chart
- Install the Madhava chart with the edited values

```bash

helm repo add gyeeta https://gyeeta.io/helmcharts
helm repo update
helm show values gyeeta/madhava > /tmp/madhava.yaml

# Thereafter you can edit the /tmp/madhava.yaml file if you need to change any option. 
# After editing the /tmp/madhava.yaml, install the Madhava Helm chart using :

helm install --namespace gyeeta --create-namespace madhava1  gyeeta/madhava -f /tmp/madhava.yaml

```

## Uninstalling the Chart

To uninstall the Madhava deployment say `madhava1` as per command above :

```bash
helm uninstall madhava1
```

## Madhava Chart Parameters {#madhava-parameters}

The default Chart config can be obtained using the command :

```bash
helm show values gyeeta/madhava > /tmp/madhava.yaml
```

Then users can edit the `/tmp/madhava.yaml` file. 

### Mandatory parameters to provide

The following are the mandatory parameters which users need to provide while installing the chart either using the `--set` CLI
option or by editing the yaml values in the file saved (for example, the `/tmp/madhava.yaml` file in the command above) :

- `madhava_config.shyama_hosts`
- `madhava_config.shyama_ports`
- `madhava_config.shyama_secret`

The Helm chart install will fail if these parameters are not provided. Explanation about these parameters are given below.

The default Chart values enable a Replica Count of 2. This means, 2 pods of Madhava servers will be started. 

Please refer to [Number of Madhava Servers needed](../install_options#num-madhava) for details on planning the
number of Madhava Replica counts.


### Madhava Container Related parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `madhava_config.madhava_name` | Name of madhava instance : Name must start with keyword `madhava` : If not specified, auto-generated | `String` | `""` |
| `madhava_config.shyama_hosts` | Shyama Service Domains : Specify one or more Shyama Service Names (e.g., `[ "shyama1-headless" ]`) | `Array` | `[]` |
| `madhava_config.shyama_ports` | Shyama Service Ports : Specify one or more Shyama Service Ports (e.g., `[ 10037 ]`) | `Array` | `[]` |
| `madhava_config.shyama_secret` | Password string to be used by remote Madhava servers to authenticate. If not specified, auto-generated | `String` | `""` |
| `madhava_config` `.shyama_existing_secretname` | Name of external K8s Secret containing the `shyama_secret`. Use if `shyama_secret` not specified | `String` | `""` |
| `madhava_config.cloud_type` | Cloud Operator : Specify as either of `aws`, `gcp`, `azure`. For other clouds or on-prem, leave blank | `String` | `""` |
| `madhava_config.region_name` | Region Name : Ignore if `cloud_type` is set. For on-prem or other clouds, specify as the Network region name | `String` | `""` |
| `madhava_config.zone_name` | Zone Name : Ignore if `cloud_type` is set. For on-prem or other clouds, specify as the Network Zone name | `String` | `""` |
| `madhava_config.logtofile` | Process Log sent to file instead of stdout/stderr. If true will use the `emptyDir` mount point for logging | `Boolean` | `true` |
| `madhava_config.db` `.postgres_hostname` | Postgres DB Host to connect to. If `postgres.enabled` is true, then specify as `localhost` | `String` | `localhost` |
| `madhava_config.db` `.postgres_port` | Postgres DB Port to connect to. If `postgres.enabled` is true, then specify as `10040` | `Number` | `10040` |
| `madhava_config.db` `.external_postgres_user` | Postgres Username. Specify only if external postgres DB to be used (`postgresdb.enabled` is false)| `String` | `""` |
| `madhava_config.db` `.external_postgres_password` | Postgres User Password. Specify only if external postgres DB to be used (`postgresdb.enabled` is false)| `String` | `""` |
| `madhava_config.db` `.storage_days` | Number of days of data storage in DB (max 60) | `Number` | `3` |
| `madhava_config.service.type` | Madhava Kubernetes Service type (Specify either ClusterIP or NodePort) | `String` | `ClusterIP` |
| `madhava_config.service.port` | Madhava Kubernetes Service port | `Number` | `10037` |
| `madhava_config.service` `.nodePort` | Madhava Kubernetes Node port. Specify if `type` set to `NodePort`. Choose port between 30000-32767 | `Number` | `""` |
| `madhava_config.service` `.clusterIP` | Static ClusterIP or None for headless services | `String` | `""` |
| `madhava_config.service` `.annotations` | Service Annotations | `Object` | `{}` |
| `madhava_config.service` `.loadBalancerIP` | Load balancer IP if service `type` is `LoadBalancer` | `String` | `""` |
| `madhava_config.service` `.externalTrafficPolicy` | Cluster External Traffic Policy | `String` | `Cluster` |
| `madhava_config.service` `.loadBalancerSourceRanges` | Addresses that are allowed when service is LoadBalancer | `Array` | `[]` |

### Postgres Container Related parameters

The main Postgres Container parameters are mentioned below.

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `postgresdb.enabled` | Enable or Disable Madhava specific DB container. If false, an external Postgres must be specified in the madhava config | `Boolean` | `true` |
| `postgresdb.resources` `.requests` | Postgres Container Resource Requests | `Object` | `{}` |
| `postgresdb.resources` `.limits` | Postgres Container Resource Limits | `Object` | `{}` |
| `postgresdb.mounts` `.volumes` | List of extra volumes to add to the Postgres container | `Array` | `[]` |
| `postgresdb.mounts` `.volumeMounts` | List of extra volume mounts to add to the Postgres container | `Array` | `[]` |
| `postgresdb.extra.env` | Extra environment variables to pass onto Postgres container | `Object` | `{}` |
| `postgresdb.extra.args` | Extra Command Line Arguments (CLI) to pass onto Postgres container | `Array` | `[]` |
| `postgresdb.extra.envinit` | Extra environment variables to pass onto Postgres Init db container | `Object` | `{}` |
| `postgresdb.extra.argsinit` | Extra Command Line Arguments (CLI) to pass onto Postgres Init db container | `Array` | `[]` |
| `postgresdb.postgresdb_config` `.password` | `postgres` user password. If empty, will be auto-generated | `String` | `""` |
| `postgresdb.postgresdb_config` `.service.port` | Port on which the Postgres process will listen on | `Number` | `10040` |
| `postgresdb.persistence.enabled` | Postgres data persistence using PVC. If false, will use emptyDir (data delete on pod termination) | `Boolean` | `true` |
| `postgresdb.persistence` `.existingClaim` | Name of an existing PVC to use : If used, specify only for replicaCount set as 1 | `String` | `""` |
| `postgresdb.persistence` `.storageClass` | PVC Storage Class for Postgres data volume. If empty, the default provisioner is used. | `String` | `""` |
| `postgresdb.persistence` `.accessModes` | PVC Access Mode for Postgres volume | `String` | `ReadWriteOnce` |
| `postgresdb.persistence.size` | PVC Storage Size for Postgres volume | `String` | `20Gi` |
| `postgresdb.persistence` `.annotations` | Annotations for the PVC | `Object` | `{}` |
| `postgresdb.persistence` `.selector` | Selector to match an existing Persistent Volume | `Object` | `{}` |
| `postgresdb.persistence` `.dataSource` | Custom PVC dataSource | `Object` | `{}` |
| `postgresdb.persistence` `.dataSourceRef` | Custom PVC dataSourceRef. If specified `dataSource` will be ignored | `Object` | `{}` |
| `postgresdb.initChownData` `.enabled` | If false, data ownership will not be reset at startup | `Boolean` | `false` |


Once this chart is deployed, it is not possible to change the Postgres DB access credentials, such as username or password, using Helm. 
To change these after deployment, delete any persistent volumes (PVs) used by the chart and re-deploy it, or connect to DB externally and manually set the params.

### Other parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `nameOverride` | Set a new name if you want to override the release name used | `String` | `""` |
| `fullnameOverride` | Set a new name if you want to override the fullname used | `String` | `""` |
| `clusterDomain` | Default Kubernetes cluster domain | `String` | `cluster.local` |
| `resources.requests` | Madhava Container Resource Requests | `Object` | `{}` |
| `resources.limits` | Madhava Container Resource Limits | `Object` | `{}` |
| `hostAliases` | Madhava pod host aliases for `/etc/hosts` | `Array` | `[]` |
| `readinessEnabled` | Enable Readiness Probe | `Boolean` | `true` |
| `podSecurityPolicy` | Enable PodSecurityPolicy (only for K8s versions < 1.25) | `Boolean` | `false` |
| `affinity` | Affinity constraint for pod scheduling | `Object` | `{}` |
| `podAffinityPreset` | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `""` |
| `podAntiAffinityPreset` | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `soft` |
| `nodeAffinityPreset.type` | Node affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `""` |
| `nodeAffinityPreset.key` | Node label key to match. Ignored if `affinity` is set. | `String` | `""` |
| `nodeAffinityPreset.values` | Node label values to match. Ignored if `affinity` is set. | `Array` | `[]` |
| `replicaCount` | Number of madhava replicas. This number needs to be based on max Hosts to be monitored | `Number` | `2` |
| `mounts.volumes` | List of extra volumes to add to the Madhava container | `Array` | `[]` |
| `mounts.volumeMounts` | List of extra volume mounts to add to the Madhava container | `Array` | `[]` |
| `extra.env` | Extra environment variables to pass onto Madhava container | `Object` | `{}` |
| `extra.args` | Extra Command Line Arguments (CLI) to pass onto Madhava container | `Array` | `[]` |
| `networkPolicy.enabled` | If enabled is true, all egress is allowed and ingress is limited to Madhava ports with optional namespaceSelector | `Boolean` | `false` |
| `networkPolicy.namespaceSelector` | Kubernetes LabelSelector to explicitly select namespaces from which traffic could be allowed | `Boolean` | `false` |
| `networkPolicy.enabled` | If enabled is true, all egress is allowed and ingress is limited to Madhava ports with optional namespaceSelector | `Object` | `{}` |
| `serviceAccount.create` | Create ServiceAccount | `Boolean` | `false` |


If `madhava_config.logtofile` is set to `true`, then the Madhava process logs will be sent to `/hostdata/log/madhava.log`.
Users can analyze the logs by running the command :

```bash

# Get the Madhava pod name and fill in MADHAVAPOD env

kubectl exec -it $MADHAVAPOD -- more /hostdata/log/madhava.log

```
