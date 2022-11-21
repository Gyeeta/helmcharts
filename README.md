
# Gyeeta Kubernetes Helm Charts

[Gyeeta](https://gyeeta.io) components can be installed in [Kubernetes](https://kubernetes.io) Cluster environments using [Helm Charts](https://helm.sh).

Gyeeta Helm Charts install the various components in the following way :

1. [Shyama Central Server](https://gyeeta.io/docs/architecture#central-server-shyama) is installed as a Statefulset along with its corresponding Postgres DB as a side container
2. [Madhava Intermediate Server](https://gyeeta.io/docs/architecture#intermediate-server-madhava) is installed as a Statefulset along with its corresponding Postgres DB as a side container
3. [Partha Host Agents](https://gyeeta.io/docs/architecture#host-monitor-agent-partha) are installed as a Daemonset as Partha needs to be installed on each host
4. [Node Webserver](https://gyeeta.io/docs/architecture#node-webserver) is installed as a Deployment
5. [Alert Action Agent](https://gyeeta.io/docs/architecture#alert-action-agent) is installed as a Deployment

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Gyeeta Components Helm Charts

Gyeeta components Helm Chart Description lnks are given below. Readers are advised to install the Helm Charts in the 
sequence as shown below :

1. [Shyama Central Server](./src/shyama/README.md)
2. [Madhava Intermediate Server](./src/madhava/README.md)
3. [Partha Host Agents](./src/partha/README.md)
4. [Node Webserver](./src/nodewebserver/README.md)
5. [Alert Action Agent](./src/alertaction/README.md)

Gyeeta also provides a separate Helm Chart for Postgres DB component though it is recommended not to install a separate Postgres DB.
Instead the Shyama server and Madhava Servers will automatically install a PostgresDB container alongside the server container.

