<!--- app-name: nodewebserver -->

# Gyeeta's Node Webserver nodewebserver Helm Chart

[Node Webserver](https://gyeeta.io/docs/architecture#node-webserver) can be installed in [Kubernetes](https://kubernetes.io) Cluster environments using 
[Helm Charts](https://helm.sh).

The Node Webserver is installed as a Deployment with a default Replica Count as 1. 

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Install Instructions

The steps to install the Webserver Helm chart are :

- Add Gyeeta Repo to Helm
- Fetch and edit the values.yaml for the Webserver chart
- Install the Webserver chart with the edited values

```bash

helm repo add gyeeta https://gyeeta.io/helmcharts
helm repo update
helm show values gyeeta/nodewebserver > /tmp/nodewebserver.yaml

# Thereafter you can edit the /tmp/nodewebserver.yaml file if you need to change any option. 
# After editing the /tmp/nodewebserver.yaml, install the Node Webserver Helm chart using :

helm install --namespace gyeeta --create-namespace nodewebserver1  gyeeta/nodewebserver -f /tmp/nodewebserver.yaml

```

## Uninstalling the Chart

To uninstall the Webserver deployment say `nodewebserver1` as per command above :

```bash
helm uninstall nodewebserver1
```

## Node Webserver Chart Parameters {#nodewebserver-parameters}

The default Chart config can be obtained using the command :

```bash
helm show values gyeeta/nodewebserver > /tmp/nodewebserver.yaml
```

Then users can edit the `/tmp/nodewebserver.yaml` file. 

### Mandatory parameters to provide

The following are the mandatory parameters which users need to provide while installing the chart either using the `--set` CLI
option or by editing the yaml values in the file saved (for example, the `/tmp/nodewebserver.yaml` file in the command above) :

- `nodewebserver_config.shyama_hosts`
- `nodewebserver_config.shyama_ports`

The Helm chart install will fail if these parameters are not provided. Explanation about these parameters are given below.

### Node Webserver Config parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `nodewebserver_config` `.shyama_hosts` | Shyama Service Domains : Specify one or more Shyama Service Names (e.g., `[ "shyama1-headless" ]`) | `Array` | `[]` |
| `nodewebserver_config` `.shyama_ports` | Shyama Service Ports : Specify one or more Shyama Service Ports (e.g., `[ 10037 ]`) | `Array` | `[]` |
| `nodewebserver_config` `.admin_password` | Web `admin` user password : Auto-generated if not specified | `String` | `""` |
| `nodewebserver_config` `.userpass_json` | List of Users, Passwords and their roles in JSON Array format | `String` | `""` |
| `nodewebserver_config` `.jwtsecret` | Secret string to be used for JWT Auth Token encoding. Will be auto-generated if not specified | `String` | `""` |
| `nodewebserver_config` `.tokenexpiry` | Authentication Token expiry duration | `String` | `1d` |
| `nodewebserver_config` `.https.enabled` | Enable HTTPS : Default is to use HTTP | `Boolean` | `false` |
| `nodewebserver_config` `.https.cert` | If HTTPS enabled, TLS Certificate in PEM format | `String` | `""` |
| `nodewebserver_config` `.https.key` | If HTTPS enabled, TLS Private Key in PEM format | `String` | `""` |
| `nodewebserver_config` `.https.passphrase` | If TLS Private Key is encrypted using a pass phrase | `String` | `""` |
| `nodewebserver_config` `.https.existing_secret_name` | External TLS Certificate Secret name if already existent : Specify if `https.cert` and `https.key` are empty | `String` | `""` |
| `nodewebserver_config.` `service.type` | Kubernetes Service type | `String` | `ClusterIP` |
| `nodewebserver_config.` `service.port` | Kubernetes Service port | `Number` | `10039` |
| `nodewebserver_config` `.service.nodePort` | Node port. Specify if `type` set to `NodePort`. Choose port between 30000-32767 | `Number` | `""` |
| `nodewebserver_config` `.service.clusterIP` | Static ClusterIP or None for headless services | `String` | `""` |
| `nodewebserver_config` `.service.annotations` | Service Annotations | `Object` | `{}` |
| `nodewebserver_config` `.service.loadBalancerIP` | Load balancer IP if service `type` is `LoadBalancer` | `String` | `""` |
| `nodewebserver_config` `.service.externalTrafficPolicy` | Cluster External Traffic Policy | `String` | `Cluster` |
| `nodewebserver_config` `.service.loadBalancerSourceRanges` | Addresses that are allowed when service is LoadBalancer | `Array` | `[]` |


### Ingress parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `nodewebserver_config` `.ingress.enabled` | Enable Ingress Controller resource | `Boolean` | `false` | 
| `nodewebserver_config` `.ingress.hostname` | Default host for the ingress resource | `String` | `gyeeta.local` | 
| `nodewebserver_config` `.ingress.ingressClassName` | Ingress Class that will be be used to implement the Ingress | `String` | `""` | 
| `nodewebserver_config` `.ingress.annotations` | Additional annotations for the Ingress resource | `Object` | `{}` | 
| `nodewebserver_config` `.ingress.extraHosts` | The list of additional hostnames to be covered with this ingress record | `Array` | `[]` | 
| `nodewebserver_config` `.ingress.extraTls` | The TLS configuration for additional hostnames to be covered with this ingress record | `Array` | `[]` | 
| `nodewebserver_config` `.ingress.secrets` | For your own TLS certificates, use this to add the certificates as secrets | `Array` | `[]` | 
| `nodewebserver_config` `.ingress.extraRules` | Additional rules to be covered with this ingress record | `Array` | `[]` | 
| `nodewebserver_config` `.ingress.tls` | Enable TLS configuration for the hostname defined at `ingress.hostname` parameter | `Boolean` | `false` | 
| `nodewebserver_config` `.ingress.selfSigned` | Create a TLS secret for this ingress record using self-signed certificates generated by Helm | `Boolean` | `false` | 
| `nodewebserver_config` `.ingress.apiVersion` | Force Ingress API version (automatically detected if not set) | `String` | `""` | 
| `nodewebserver_config` `.ingress.path` | Ingress path | `String` | `/` | 
| `nodewebserver_config` `.ingress.pathType` | Ingress path type | `String` | `ImplementationSpecific` | 

### Other parameters

| Name        | Description          | Data Type | Default Value   |
| ----------- | -------------------- | --------- | --------------- |
| `nameOverride` | Set a new name if you want to override the release name used | `String` | `""` |
| `fullnameOverride` | Set a new name if you want to override the fullname used | `String` | `""` |
| `clusterDomain` | Default Kubernetes cluster domain | `String` | `cluster.local` |
| `resources.requests` | Resource Requests | `Object` | `{}` |
| `resources.limits` | Resource Limits | `Object` | `{}` |
| `hostAliases` | pod host aliases for `/etc/hosts` | `Array` | `[]` |
| `podSecurityPolicy` | Enable PodSecurityPolicy (only for K8s versions < 1.25) | `Boolean` | `false` |
| `affinity` | Affinity constraint for pod scheduling | `Object` | `{}` |
| `podAffinityPreset` | Pod affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `""` |
| `podAntiAffinityPreset` | Pod anti-affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `soft` |
| `nodeAffinityPreset.type` | Node affinity preset. Ignored if `affinity` is set. Allowed values: `soft` or `hard` | `String` | `""` |
| `nodeAffinityPreset.key` | Node label key to match. Ignored if `affinity` is set. | `String` | `""` |
| `nodeAffinityPreset.values` | Node label values to match. Ignored if `affinity` is set. | `Array` | `[]` |
| `replicaCount` | Number of replicas | `Number` | `1` |
| `mounts.volumes` | List of extra volumes to add | `Array` | `[]` |
| `mounts.volumeMounts` | List of extra volume mounts | `Array` | `[]` |
| `extra.env` | Extra environment variables | `Object` | `{}` |
| `extra.args` | Extra Command Line Arguments (CLI) | `Array` | `[]` |
| `serviceAccount.create` | Create ServiceAccount | `Boolean` | `false` |



