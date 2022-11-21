<!--- app-name: postgresdb -->

# Gyeeta's Postgres DB Helm Chart

Gyeeta PostgresDB can be installed in [Kubernetes](https://kubernetes.io) Cluster environments using 
[Helm Charts](https://helm.sh).

The Postgres DB is installed as a Statefulset.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Install Instructions

The steps to install the Postgres Helm chart are :

- Add Gyeeta Repo to Helm
- Fetch and edit the values.yaml for the Postgres chart
- Install the Postgres chart with the edited values

```bash

helm repo add gyeeta https://gyeeta.io/helmcharts
helm repo update
helm show values gyeeta/postgersdb > /tmp/postgersdb.yaml

# Thereafter you can edit the /tmp/postgersdb.yaml file if you need to change any option. 
# After editing the /tmp/postgersdb.yaml, install the Helm chart using :

helm install --namespace gyeeta --create-namespace postgres1  gyeeta/postgersdb -f /tmp/postgersdb.yaml

```

## Uninstalling the Chart

To uninstall the Postgres deployment say `postgres1` as per command above :

```bash
helm uninstall postgres1
```

## Postgres Chart Parameters {#postgres-parameters}

The default Chart config can be obtained using the command :

```bash
helm show values gyeeta/postgres > /tmp/postgres.yaml
```

Then users can edit the `/tmp/postgres.yaml` file, if needed.

No parameter is mandatory and users can skip setting any values (use the default values) while installing the Postgres chart.

### Postgres Config parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `postgresdb_config.password` | `postgres` user password. If empty, will be auto-generated | `String` | `""` |
| `postgresdb_config.service.type` | Kubernetes Service type (Specify either ClusterIP or NodePort) | `String` | `ClusterIP` |
| `postgresdb_config.service.port` | Kubernetes Service port | `Number` | `10040` |
| `postgresdb_config.service` `.nodePort` | Node port. Specify if `type` set to `NodePort`. Choose port between 30000-32767 | `Number` | `""` |
| `postgresdb_config.service` `.clusterIP` | Static ClusterIP or None for headless services | `String` | `""` |
| `postgresdb_config.service` `.annotations` | Service Annotations | `Object` | `{}` |
| `postgresdb_config.service` `.loadBalancerIP` | Load balancer IP if service `type` is `LoadBalancer` | `String` | `""` |
| `postgresdb_config.service` `.externalTrafficPolicy` | Cluster External Traffic Policy | `String` | `Cluster` |
| `postgresdb_config.service` `.loadBalancerSourceRanges` | Addresses that are allowed when service is LoadBalancer | `Array` | `[]` |

### PVC Persistence Related parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `persistence.enabled` | Postgres data persistence using PVC. If false, will use emptyDir (data delete on pod termination) | `Boolean` | `true` |
| `persistence` `.existingClaim` | Name of an existing PVC to use | `String` | `""` |
| `persistence` `.storageClass` | PVC Storage Class for Postgres data volume. If empty, the default provisioner is used. | `String` | `""` |
| `persistence` `.accessModes` | PVC Access Mode for Postgres volume | `String` | `ReadWriteOnce` |
| `persistence.size` | PVC Storage Size for Postgres volume | `String` | `10Gi` |
| `persistence` `.annotations` | Annotations for the PVC | `Object` | `{}` |
| `persistence` `.selector` | Selector to match an existing Persistent Volume | `Object` | `{}` |
| `persistence` `.dataSource` | Custom PVC dataSource | `Object` | `{}` |
| `persistence` `.dataSourceRef` | Custom PVC dataSourceRef. If specified `dataSource` will be ignored | `Object` | `{}` |


:::info

Once this chart is deployed, it is not possible to change the Postgres DB access credentials, such as username or password, using Helm. 
To change these after deployment, delete any persistent volumes (PVs) used by the chart and re-deploy it, or connect to DB externally and manually set the params.

:::

### Other parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `nameOverride` | Set a new name if you want to override the release name used | `String` | `""` |
| `fullnameOverride` | Set a new name if you want to override the fullname used | `String` | `""` |
| `clusterDomain` | Default Kubernetes cluster domain | `String` | `cluster.local` |
| `resources.requests` | Resource Requests | `Object` | `{}` |
| `resources.limits` | Resource Limits | `Object` | `{}` |
| `hostAliases` | pod host aliases for `/etc/hosts` | `Array` | `[]` |
| `readinessEnabled` | Enable Readiness Probe | `Boolean` | `true` |
| `mounts.volumes` | List of extra volumes to add | `Array` | `[]` |
| `mounts.volumeMounts` | List of extra volume mounts | `Array` | `[]` |
| `extra.env` | Extra environment variables to pass onto Postgres container | `Object` | `{}` |
| `extra.args` | Extra Command Line Arguments (CLI) to pass onto Postgres container | `Array` | `[]` |
| `extra.envinit` | Extra environment variables to pass onto Postgres Init db container | `Object` | `{}` |
| `extra.argsinit` | Extra Command Line Arguments (CLI) to pass onto Postgres Init db container | `Array` | `[]` |
| `podSecurityPolicy` | Enable PodSecurityPolicy (only for K8s versions < 1.25) | `Boolean` | `false` |
| `affinity` | Affinity constraint for pod scheduling | `Object` | `{}` |
| `podAffinityPreset` | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `""` |
| `podAntiAffinityPreset` | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `soft` |
| `nodeAffinityPreset.type` | Node affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `""` |
| `nodeAffinityPreset.key` | Node label key to match. Ignored if `affinity` is set. | `String` | `""` |
| `nodeAffinityPreset.values` | Node label values to match. Ignored if `affinity` is set. | `Array` | `[]` |
| `initChownData.enabled` | If false, data ownership will not be reset at startup | `Boolean` | `false` |
| `podSecurityPolicy` | Enable PodSecurityPolicy (only for K8s versions < 1.25) | `Boolean` | `false` |


