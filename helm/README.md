# Playerbio

A dummy generator of player profiles written in [Elixir](https://elixir-lang.org/).

## TL;DR;

```console
$ helm install .
```

## Introduction

This chart bootstraps a Playerbio deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

It also packages the [Prometheus Operator](https://github.com/coreos/prometheus-operator) resources needed to bootstrap microservice metrics and display a custom dashboard in [Grafana](https://grafana.com/).

## Prerequisites

- Kubernetes
- Helm
- Prometheus Operator (Optional)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release .
```

The command deploys Playerbio on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following table lists the configurable parameters of the WordPress chart and their default values.

| Parameter                       | Description                                                                         | Default        |
| ------------------------------- | ----------------------------------------------------------------------------------- | -------------- |
| `httpPort`                      | Microservice port                                                                   | `8080`         |
| `replicaCount`                  | Number of Playerbio Pods to run                                                     | `1`            |
| `image.repository`              | Playerbio image name                                                                | `playerbio`    |
| `image.tag`                     | Playerbio image tag                                                                 | `latest`       |
| `image.pullPolicy`              | Image pull policy                                                                   | `IfNotPresent` |
| `args`                          | Playerbio Pod arguments                                                             | `["start"]`    |
| `env`                           | Playerbio Pod environment variables                                                 | `[]`           |
| `resources`                     | Resource limits for Playerbio Pods                                                  | `{}`           |
| `securityContext.enabled`       | Enable custom security configuration for Playerbio Pods                             | `true`         |
| `securityContext.fsGroup`       | User group ID owner of all files in the Playerbio Pods                              | `1001`         |
| `securityContect.runAsUser`     | User ID of the owner of all processes in the Playerbio Pods                         | `1001`         |
| `securityContext.allowPrivEsc`  | Allow user privilege escalation in Playerbio Pods                                   | `false`        |
| `podAnnotations`                | Playerbio Pod annotations                                                           | `{}`           |
| `podLabels`                     | Playerbio Pod labels                                                                | `{}`           |
| `service.type`                  | Playerbio Service type                                                              | `NodePort`     |
| `service.port`                  | Port for Playerbio Service to listen on                                             | `80`           |
| `probes.enabled`                | Enable liveness and readiness checking in Playerbio Pods                            | `true`         |
| `probes.liveness.path`          | HTTP endpoint to query when executing liveness probe on Playerbio Pods              | `/ping`        |
| `probes.readiness.path`         | HTTP endpoint to query when executing readiness probe on Playerbio Pods             | `/ping`        |
| `prometheus.enabled`            | Create Prometheus Operator resources to monitor Playerbio microservice              | `false`        |
| `prometheus.serviceAccount`     | Service Account name used by Prometheus Service Monitor to access Playerbio metrics | `default`      |
| `prometheus.namespace`          | Namespace where Prometheus Operator is installed                                    | `default`      |
| `prometheus.path`               | Playerbio microservice metrics endpoint                                             | `/metrics`     |
| `prometheus.interval`           | Query interval for metrics endpoint                                                 | `15s`          |
| `prometheus.service.type`       | Prometheus Operator Service type                                                    | `ClusterIP`    |
| `prometheus.service.port`       | Port for Prometheus Operator Service to listen on                                   | `9090`         |
| `prometheus.service.targetPort` | Port for Prometheus Operator Service to redirect to                                 | `9090`         |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install . \
  --name my-release \
  --set replicaCount=5
```
The above command installs Playerbio with 5 instances.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install . --name my-release -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)
