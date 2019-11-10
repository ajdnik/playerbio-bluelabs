# PlayerBio

A dummy generator of player profiles written in [Elixir](https://elixir-lang.org/).


## Requirements

- [Docker](https://docs.docker.com/install/)
- [Helm](https://helm.sh/docs/install/#installing-helm) (Optional)
- [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) (Optional)


## Building and Running the Project

#### Local environment

The project contains scripts and configurations to quickly setup a local [Kubernetes](http://kubernetes.io) cluster and deploy the project inside.

To create the local environment:

```bash
./minikube/create.sh
  STEP 1: Create new minikube cluster.
  ...
  SUCCESS: MiniKube environment is set up.
```

This creates a [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) cluster and deploys [Tiller](https://helm.sh/docs/install/#installing-tiller) on it.

To provision the local environment:

```bash
./minikube/provision.sh
  STEP 1: Update helm repository.
  ...
  SUCCESS: Playerbio service deployed to cluster.
  Playerbio:
    Url: http://192.168.64.21:30871
  Grafana:
    Username: admin
    Password: prom-operator
    Url: http://192.168.64.21:32504
  Splunk:
    Username: admin
    Password: helloworld
    Url: http://192.168.64.21:30299
```

This deploys and configures [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) and [Prometheus Operator](https://github.com/coreos/prometheus-operator) on the [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) cluster and deploys the [Elixir](https://elixir-lang.org/) service.

To redeploy the [Elixir](https://elixir-lang.org/) service to the [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) cluster after making changes to the codebase:

```bash
./minikube/deploy.sh
  STEP 1: Setup docker environment.
  ...
  SUCCESS: Service deployed to cluster.
  Playerbio url is http://192.168.64.21:30871.
```

This rebuilds the [Docker](https://docs.docker.com/install/) image while taking advantage of Docker layers and caching to speed up the build and deploys the image to [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) cluster using [Helm](https://helm.sh/docs/install/#installing-helm). The deployment process rolls back changes made in case of failed upgrade.

Read more about how to get started using the local environment by reading the [Documentation](minikube/README.md).

####  Without the local environment

The project can be built running `docker build -t playerbio .`.

By running `docker run -p 8080:8080 playerbio start`, you will start the Docker container and expose the service via the `http://localhost:8080/` url.

#### Deploy to a Kubernetes cluster

The project contains a [Helm Chart](https://helm.sh/docs/developing_charts/) which simplifies deployment of the [Elixir](https://elixir-lang.org/) service to a [Kubernetes](http://kubernetes.io) cluster.

To deploy the project:

```bash
helm install ./helm --name=playerbio
Release "playerbio" has been upgraded.
LAST DEPLOYED: Sun Nov 10 13:41:00 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME       READY  UP-TO-DATE  AVAILABLE  AGE
playerbio  4/5    5           4          5m21s

==> v1/Pod(related)
NAME                        READY  STATUS       RESTARTS  AGE
playerbio-5b446d7dff-2cxrd  1/1    Running      0         9s
playerbio-5b446d7dff-hqrjh  0/1    Running      0         9s
playerbio-5b446d7dff-kmbkk  1/1    Running      0         18s
playerbio-5b446d7dff-lxjbd  1/1    Running      0         18s
playerbio-5b446d7dff-w7rrq  1/1    Running      0         18s

==> v1/Service
NAME                  TYPE       CLUSTER-IP    EXTERNAL-IP  PORT(S)       AGE
playerbio             NodePort   10.96.23.243  <none>       80:30871/TCP  5m21s


NOTES:
Playerbio microservice has been installed. Check its status by running:
  kubectl --namespace default get pods -l "release=playerbio"
```

Read more about how to get started using the [Helm Chart](https://helm.sh/docs/developing_charts/) by reading the [Documentation](helm/README.md).

## Configuration

The service listens on port `8080` by default. This behaviour can be changed in `config/config.exs`.


## API

The service exposes the following two endpoints.

### /ping

Meant to be used as a health check. Returns with a `200` response code and the text `pong!` in the response body
if the service is up and running.

```bash
curl -v http://localhost:8080/ping

*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8080 (#0)
> GET /ping HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.54.0
> Accept: */*
>
< HTTP/1.1 200 OK
< cache-control: max-age=0, private, must-revalidate
< content-length: 5
< content-type: plain/text; charset=utf-8
< date: Wed, 31 Jul 2019 12:57:52 GMT
< server: Cowboy
<
* Connection #0 to host localhost left intact
pong!
```

### /player

Generates the profile of an imaginary sports player.

```bash
curl -v http://localhost:8080/player

*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 8080 (#0)
> GET /player HTTP/1.1
> Host: localhost:8080
> User-Agent: curl/7.54.0
> Accept: */*
>
< HTTP/1.1 200 OK
< cache-control: max-age=0, private, must-revalidate
< content-length: 70
< content-type: application/json; charset=utf-8
< date: Wed, 31 Jul 2019 12:59:52 GMT
< server: Cowboy
<
{
   "sport" : "Tennis",
   "age" : 28,
   "country" : "Spain",
   "name" : "LeBron Williams"
}
```

### /metrics

Returns service-level metrics in a Prometheus-compliant text-based format.

```bash
curl -v http://127.0.0.1:8080/metrics

*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to 127.0.0.1 (127.0.0.1) port 8080 (#0)
> GET /metrics HTTP/1.1
> Host: 127.0.0.1:8080
> User-Agent: curl/7.54.0
> Accept: */*
>
< HTTP/1.1 200 OK
< cache-control: max-age=0, private, must-revalidate
< content-length: 6776
< date: Wed, 31 Jul 2019 13:51:27 GMT
< server: Cowboy
<
# TYPE erlang_vm_memory_atom_bytes_total gauge
# HELP erlang_vm_memory_atom_bytes_total The total amount of memory currently allocated for atoms. This memory is part of the memory presented as system memory.
erlang_vm_memory_atom_bytes_total{usage="used"} 870829
erlang_vm_memory_atom_bytes_total{usage="free"} 21020
# TYPE erlang_vm_memory_bytes_total gauge
# HELP erlang_vm_memory_bytes_total The total amount of memory currently allocated. This is the same as the sum of the memory size for processes and system.
erlang_vm_memory_bytes_total{kind="system"} 40780928
...
```

## License

> Copyright (c) 2019, BlueLabs Software Limited
