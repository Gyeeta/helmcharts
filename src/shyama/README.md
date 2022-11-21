<!--- app-name: shyama -->

# Gyeeta's Shyama Central Server Helm Chart

[Shyama Central Server](https://gyeeta.io/docs/architecture#central-server-shyama) can be installed in [Kubernetes](https://kubernetes.io) Cluster environments using 
[Helm Charts](https://helm.sh).

The Shyama server is installed as a Statefulset along with an optional Postgres DB as a side container

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Install Instructions

The steps to install the Shyama Helm chart are :

- Add Gyeeta Repo to Helm
- Fetch and edit the values.yaml for the Shyama chart
- Install the Shyama chart with the edited values

```bash

helm repo add gyeeta https://gyeeta.io/helmcharts
helm repo update
helm show values gyeeta/shyama > /tmp/shyama.yaml

# Thereafter you can edit the /tmp/shyama.yaml file if you need to change any option. 
# After editing the /tmp/shyama.yaml, install the Shyama Helm chart using :

helm install --namespace gyeeta --create-namespace shyama1  gyeeta/shyama -f /tmp/shyama.yaml

```

## Uninstalling the Chart

To uninstall the Shyama deployment say `shyama1` as per command above :

```bash
helm uninstall shyama1
```

## Shyama Chart Parameters {#shyama-parameters}

The default Chart config can be obtained using the command :

```bash
helm show values gyeeta/shyama > /tmp/shyama.yaml
```

Then users can edit the `/tmp/shyama.yaml` file, if needed.

No parameter is mandatory and users can skip setting any values (use the default values) while installing the Shyama chart.


### Shyama Container Related parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `shyama_config.shyama_name` | Name of shyama instance : Name must start with keyword `shyama` : If not specified, auto-generated | `String` | `""` |
| `shyama_config.shyama_secret` | Password string to be used by remote Madhava servers to authenticate. If not specified, auto-generated | `String` | `""` |
| `shyama_config.cloud_type` | Cloud Operator : Specify as either of `aws`, `gcp`, `azure`. For other clouds or on-prem, leave blank | `String` | `""` |
| `shyama_config.region_name` | Region Name : Ignore if `cloud_type` is set. For on-prem or other clouds, specify as the Network region name | `String` | `""` |
| `shyama_config.zone_name` | Zone Name : Ignore if `cloud_type` is set. For on-prem or other clouds, specify as the Network Zone name | `String` | `""` |
| `shyama_config.min_madhava` | Minimum number of Madhava servers that should register with Shyama before Shyama accepts any Host Agent partha | `Number` | `1` |
| `shyama_config.webserver_url` | Webserver URL for use in alert payloads. If not specified, auto-generated | `String` | `""` |
| `shyama_config.logtofile` | Process Log sent to file instead of stdout/stderr. If true will use the `emptyDir` mount point for logging | `Boolean` | `true` |
| `shyama_config.db` `.postgres_hostname` | Postgres DB Host to connect to. If `postgres.enabled` is true, then specify as `localhost` | `String` | `localhost` |
| `shyama_config.db` `.postgres_port` | Postgres DB Port to connect to. If `postgres.enabled` is true, then specify as `10040` | `Number` | `10040` |
| `shyama_config.db` `.external_postgres_user` | Postgres Username. Specify only if external postgres DB to be used (`postgresdb.enabled` is false)| `String` | `""` |
| `shyama_config.db` `.external_postgres_password` | Postgres User Password. Specify only if external postgres DB to be used (`postgresdb.enabled` is false)| `String` | `""` |
| `shyama_config.db` `.storage_days` | Number of days of data storage in DB (max 60) | `Number` | `3` |
| `shyama_config.service.type` | Shyama Kubernetes Service type (Specify either ClusterIP or NodePort) | `String` | `ClusterIP` |
| `shyama_config.service.port` | Shyama Kubernetes Service port | `Number` | `10037` |
| `shyama_config.service` `.nodePort` | Shyama Kubernetes Node port. Specify if `type` set to `NodePort`. Choose port between 30000-32767 | `Number` | `""` |
| `shyama_config.service` `.clusterIP` | Static ClusterIP or None for headless services | `String` | `""` |
| `shyama_config.service` `.annotations` | Service Annotations | `Object` | `{}` |
| `shyama_config.service` `.loadBalancerIP` | Load balancer IP if service `type` is `LoadBalancer` | `String` | `""` |
| `shyama_config.service` `.externalTrafficPolicy` | Cluster External Traffic Policy | `String` | `Cluster` |
| `shyama_config.service` `.loadBalancerSourceRanges` | Addresses that are allowed when service is LoadBalancer | `Array` | `[]` |
| `shyama_config.alertactions` | Alert Actions configuration (in JSON format) | `String` | `""` |
| `shyama_config.alertdefs` | Alert Definitions configuration (in JSON format) | `String` | `""` |
| `shyama_config.alertsilences` | Alert Silences configuration (in JSON format) | `String` | `""` |
| `shyama_config.alertinhibits` | Alert Inhibits configuration (in JSON format) | `String` | `""` |

### Postgres Container Related parameters

The main Postgres Container parameters are mentioned below.

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `postgresdb.enabled` | Enable or Disable Shyama specific DB container. If false, an external Postgres must be specified in the shyama config | `Boolean` | `true` |
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
| `postgresdb.persistence` `.existingClaim` | Name of an existing PVC to use | `String` | `""` |
| `postgresdb.persistence` `.storageClass` | PVC Storage Class for Postgres data volume. If empty, the default provisioner is used. | `String` | `""` |
| `postgresdb.persistence` `.accessModes` | PVC Access Mode for Postgres volume | `String` | `ReadWriteOnce` |
| `postgresdb.persistence.size` | PVC Storage Size for Postgres volume | `String` | `10Gi` |
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
| `resources.requests` | Shyama Container Resource Requests | `Object` | `{}` |
| `resources.limits` | Shyama Container Resource Limits | `Object` | `{}` |
| `hostAliases` | Shyama pod host aliases for `/etc/hosts` | `Array` | `[]` |
| `readinessEnabled` | Enable Readiness Probe | `Boolean` | `true` |
| `podSecurityPolicy` | Enable PodSecurityPolicy (only for K8s versions < 1.25) | `Boolean` | `false` |
| `mounts.volumes` | List of extra volumes to add to the Shyama container | `Array` | `[]` |
| `mounts.volumeMounts` | List of extra volume mounts to add to the Shyama container | `Array` | `[]` |
| `extra.env` | Extra environment variables to pass onto Shyama container | `Object` | `{}` |
| `extra.args` | Extra Command Line Arguments (CLI) to pass onto Shyama container | `Array` | `[]` |
| `networkPolicy.enabled` | If enabled is true, all egress is allowed and ingress is limited to Shyama ports with optional namespaceSelector | `Boolean` | `false` |
| `networkPolicy.namespaceSelector` | Kubernetes LabelSelector to explicitly select namespaces from which traffic could be allowed | `Boolean` | `false` |
| `networkPolicy.enabled` | If enabled is true, all egress is allowed and ingress is limited to Shyama ports with optional namespaceSelector | `Object` | `{}` |
| `serviceAccount.create` | Create ServiceAccount | `Boolean` | `false` |


If `shyama_config.logtofile` is set to `true`, then the Shyama process logs will be sent to `/hostdata/log/shyama.log`.
Users can analyze the logs by running the command :

```bash

# Get the Shyama pod name and fill in SHYAMAPOD env

kubectl exec -it $SHYAMAPOD -- more /hostdata/log/shyama.log

```

