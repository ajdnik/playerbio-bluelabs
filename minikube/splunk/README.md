# Splunk Enterprise

A simple [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) deployment.

## TL;DR;

```console
$ helm install .
```

## Introduction

This chart bootstraps a simple [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

It also installs an application to [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) cluster which sets up indexes that can be used when installing [Splunk Connect for Kubernetes](https://github.com/splunk/splunk-connect-for-kubernetes).

## Prerequisites

- Kubernetes
- Helm

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install --name my-release .
```

The command deploys [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

The following table lists the configurable parameters of the [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) chart and their default values.

| Parameter                         | Description                      | Default         |
| --------------------------------- | -------------------------------- | --------------- |
| `nginx.replicaCount`              | Number of Nginx Pods             | `1`             |
| `nginx.image.name`                | Nginx Docker image name          | `nginx`         |
| `nginx.image.tag`                 | Nginx Docker image tag           | `"1.17"`        |
| `nginx.service.type`              | Nginx Service type               | `ClusterIP`     |
| `nginx.service.port`              | Nginx Service port it listens on | `80`            |
| `password`                        | Splunk web UI admin password     | `helloworld`    |
| `image.name`                      | Splunk Docker image name         | `splunk/splunk` |
| `image.tag`                       | Splunk Docker image tag          | `"7.2"`         |
| `indexer.replicaCount`            | Splunk indexer cluster Pod count | `1`             |
| `indexer.service.type`            | Splunk indexer Service type      | `ClusterIP`     |
| `indexer.service.splunkwebPort`   | Splunk indexer web UI port       | `8000`          |
| `indexer.service.splunkdPort`     | Splunk indexer splunkd port      | `8089`          |
| `indexer.service.hecPort`         | Splunk indexer HEC port          | `8088`          |
| `indexer.service.replicationPort` | Splunk indexer replication port  | `4001`          |
| `indexer.service.s2sPort`         | Splunk indexer forwarder port    | `9997`          |
| `master.replicaCount`             | Splunk master Pod count          | `1`             |
| `master.service.type`             | Splunk master Service type       | `ClusterIP`     |
| `master.service.splunkwebPort`    | Splunk master web UI port        | `8000`          |
| `master.service.splunkdPort`      | Splunk master splunkd port       | `8089`          |
| `search.replicaCount`             | Splunk search head Pod count     | `1`             |
| `search.service.type`             | Splunk search head Service type  | `ClusterIP`     |
| `search.service.splunkwebPort`    | Splunk search head web UI port   | `8000`          |
| `search.service.splunkdPort`      | Splunk search head splunkd port  | `8089`          |
| `search.service.kvPort`           | Splunk indexer kv store port     | `8191`          |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install . \
  --name my-release \
  --set password=foobar
```
The above command installs [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) and sets the web UI password to `foobar`.

Alternatively, a YAML file that specifies the values for the above parameters can be provided while installing the chart. For example,

```console
$ helm install . --name my-release -f values.yaml
```

> **Tip**: You can use the default [values.yaml](values.yaml)

## Default Kubernetes application

The chart installs the [k8s-app](k8s-app) to the master node of the [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) cluster.

To modify the application update the files in the [k8s-app](k8s-app) directory and generate a new application:

```console
$ ./generate.sh
H4sIAHDkx10AA+1YW2/aMBTuc36FpfZhNyD3ABIPbKQba0urwqRODEUmNiMlxJFtevn3OyFZ6YWSIlHY1HwvDofvOAcff8fHlCuTqijhOK7svRpUVXUsC81HOx1V3UzHDEgzLFuzbNNyLKRqhqbre8h6vZAWmAmJOYSCL0kUTJ7nAW00WjFP9jvuxv8E5bv8EzrCs1C+wj54cf5tMOsG5N+0dKfI/zawyP+USkywxJvfAC/Xv2U5tpnk31EL/W8FS/KfFYJyYtjIO2A9bNN8Pv+6oT/Kv6M5xh5SN/L2HLzx/O+jZhyHgY9lwKJSSK9oiGLKp4EQYFD6AwX7PhUCNRCnmKA66qMPaPAJXfNA0vlHTKZBhAYKvYkZl0AUt0LSqaL0rwJ6LSqCShlEv8WyqTLfZdPtemXeBp6e/0FE6A0VZZ9Fq/b7GsjRv6ar5qPz31ENvdD/NtD3px4Ueh74oE9O40PsS8YbeCaZ4rOQnGE5BsEedM+Of3SOvNbnysKhkhDIUBmzKV3JA44c42u6eraUAtzkFJK3MQVm+h2UkpSH14oRvyRAnB8dXhoalMpIppHNH9dYv5SfG11GWx1fRsqJEIeUrxNhys+NMKOtjjAjPR/hrjXwlvG0/secxZus/vn9n2E5i/4PekFVsy1bLer/NvCg/vfOm53u4en5Sbc0ZkKyK8p5QGgjIzwwKs1Wy3MvwMXrtU9c77DtHre6oOkRDgWFqjOZDWmdDS+pL0U9ZgTmb3da7oWbuX3ptU87icP37mnnMT/CUypiDO3iWl6M5Djsern/OSzr/+KZ3GgByL3//e3/Ev1rWqJ/Ry/uf1tBfyxlXK9URBzOookHG8GDzEscRJSDlEgg8DCkBPSjKvObATwtSoYi2Iz7NDvN79klm9AITIamY0p9XNJqtWHJJDW7hIleLTmkWrOrNUi4YRSi3CGe6l9yHIkR49ON1YB8/d/7/89Sk/uf5diF/reB/QXQSSpetL8USn9ZGzBQWm635x25P0HtMAFuQXdf/wYM5dz96l6ANaE33v3qfnyvJL1Fs5fZ6vUDrdB+gQIFCuwIfwA20AHuACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==
```

Override the `k8s-app.tgz` value in the [templates/nginx/k8s-app.yaml](templates/nginx/k8s-app.yaml) file with the newly generated one. Afterwards upgrade your helm installation and update the application in Splunk.
