# Minikube Environment

Scripts and configurations to setup a local [Kubernetes](http://kubernetes.io) cluster on [Minikube]() and deploy [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html), [Prometheus Operator](https://github.com/coreos/prometheus-operator) and the [Elixir](https://elixir-lang.org/) service to the cluster.

## Requirements

- [Docker](https://docs.docker.com/install/)
- [Helm](https://helm.sh/docs/install/#installing-helm)
- [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Scripts

All scripts support `--help` flag which print out a description of the script and a usage example.

For example:

```bash
./create.sh --help
This script creates a new minikube cluster for the playerbio service.
If you already have a minikube cluster configured with helm you can skip this script.

Usage: ./create.sh
```

#### ./create.sh

Script creates the initial [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) cluster, configures [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) and installs [Tiller](https://helm.sh/docs/install/#installing-tiller).

The [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) cluster created is named `playerbio` which means it can be installed next to other running clusters.

```bash
./create.sh
  STEP 1: Create new minikube cluster.
😄  [playerbio] minikube v1.5.2 on Darwin 10.15.1
✨  Automatically selected the 'hyperkit' driver (alternates: [vmwarefusion])
🔥  Creating hyperkit VM (CPUs=2, Memory=4096MB, Disk=20000MB) ...
🐳  Preparing Kubernetes v1.14.5 on Docker '18.09.9' ...
    ▪ scheduler.address=0.0.0.0
    ▪ controller-manager.address=0.0.0.0
    ▪ apiserver.authorization-mode=RBAC
🚜  Pulling images ...
🚀  Launching Kubernetes ...
⌛  Waiting for: apiserver
🏄  Done! kubectl is now configured to use "playerbio"
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
  STEP 2: Create service account for tiller.
serviceaccount/tiller created
  STEP 3: Set cluster role for tiller service account.
clusterrolebinding.rbac.authorization.k8s.io/tiller-role-binding created
  STEP 4: Install Tiller
$HELM_HOME has been configured at /Users/ajdnik/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
  SUCCESS: MiniKube environment is set up.
```

#### ./provision.sh

Script deploys and configures [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) with [Splunk Connector for Kubernetes](https://github.com/splunk/splunk-connect-for-kubernetes) along with [Prometheus Operator](https://github.com/coreos/prometheus-operator) with [Grafana](https://grafana.com/) and lastly, the [Elixir](https://elixir-lang.org/) service with a custom dashboard for [Grafana]().

To deploy [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) the the cluster the project uses a custom [Helm Chart](https://helm.sh/docs/developing_charts/). To learn more about the chart read it's [Documentation](splunk/README.md).

In the end the script outputs URLs and credentials for the [Elixir](https://elixir-lang.org/) service, [Grafana](https://grafana.com/) and [Splunk Enterprise](https://www.splunk.com/en_us/software/splunk-enterprise.html) web UI.

<details><summary>Long command output:</summary>
<p>
```bash
./provision.sh
  STEP 1: Update helm repository.
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "stable" chart repository
...Successfully got an update from the "jetstack" chart repository
Update Complete.
  STEP 2: Install splunk enterprise.
NAME:   splunk
LAST DEPLOYED: Sun Nov 10 13:29:55 2019
NAMESPACE: splunk
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME             DATA  AGE
splunk-k8s-app   0     100s
splunk-nginx     1     100s
splunk-www-data  2     100s

==> v1/Deployment
NAME             READY  UP-TO-DATE  AVAILABLE  AGE
splunk-defaults  1/1    1           1          100s

==> v1/Pod(related)
NAME                             READY  STATUS   RESTARTS  AGE
splunk-defaults-5d4768b4c-g4qrx  1/1    Running  0         100s
splunk-indexer-0                 1/1    Running  0         100s
splunk-master-7d4fb59bd-chz7w    1/1    Running  0         100s
splunk-search-b9fc78c78-449dg    1/1    Running  0         100s

==> v1/Service
NAME             TYPE       CLUSTER-IP     EXTERNAL-IP  PORT(S)                                       AGE
splunk-defaults  ClusterIP  None           <none>       80/TCP                                        100s
splunk-indexer   ClusterIP  None           <none>       8000/TCP,8089/TCP,8088/TCP,4001/TCP,9997/TCP  100s
splunk-master    NodePort   10.109.138.18  <none>       8000:30299/TCP,8089:31629/TCP                 100s
splunk-search    ClusterIP  None           <none>       8000/TCP,8089/TCP,8191/TCP                    100s

==> v1beta1/Deployment
NAME           READY  UP-TO-DATE  AVAILABLE  AGE
splunk-master  1/1    1           1          100s
splunk-search  1/1    1           1          100s

==> v1beta1/StatefulSet
NAME            READY  AGE
splunk-indexer  1/1    100s


NOTES:
Splunk Enterprise has been installed. Check its status by running:
  kubectl --namespace splunk get pods -l "release=splunk"

  STEP 3: Install splunk connector.
NAME:   connector
LAST DEPLOYED: Sun Nov 10 13:31:38 2019
NAMESPACE: splunk
STATUS: DEPLOYED

RESOURCES:
==> v1/ClusterRole
NAME                                 AGE
connector-splunk-kubernetes-objects  1s
kube-api-aggregator                  1s
kubelet-summary-api-read             1s

==> v1/ClusterRoleBinding
NAME                                            AGE
connector-splunk-kubernetes-metrics             1s
connector-splunk-kubernetes-metrics-aggregator  1s
connector-splunk-kubernetes-objects             1s

==> v1/ConfigMap
NAME                                            DATA  AGE
connector-splunk-kubernetes-logging             7     1s
connector-splunk-kubernetes-metrics             1     1s
connector-splunk-kubernetes-metrics-aggregator  1     1s
connector-splunk-kubernetes-objects             1     1s

==> v1/DaemonSet
NAME                                 DESIRED  CURRENT  READY  UP-TO-DATE  AVAILABLE  NODE SELECTOR  AGE
connector-splunk-kubernetes-metrics  1        1        0      1           0          <none>         1s

==> v1/Pod(related)
NAME                                                     READY  STATUS             RESTARTS  AGE
connector-splunk-kubernetes-logging-jmhdw                0/1    Pending            0         1s
connector-splunk-kubernetes-metrics-agg-c66fc5cf4-fx84w  0/1    Pending            0         0s
connector-splunk-kubernetes-metrics-msf9g                0/1    ContainerCreating  0         1s
connector-splunk-kubernetes-objects-596474f6f6-fl5q2     0/1    Pending            0         0s

==> v1/Secret
NAME                       TYPE    DATA  AGE
splunk-kubernetes-logging  Opaque  1     1s
splunk-kubernetes-metrics  Opaque  1     1s
splunk-kubernetes-objects  Opaque  1     1s

==> v1/ServiceAccount
NAME                       SECRETS  AGE
splunk-kubernetes-metrics  1        1s
splunk-kubernetes-objects  1        1s

==> v1beta1/DaemonSet
NAME                                 DESIRED  CURRENT  READY  UP-TO-DATE  AVAILABLE  NODE SELECTOR  AGE
connector-splunk-kubernetes-logging  1        1        0      1           0          <none>         1s

==> v1beta1/Deployment
NAME                                     READY  UP-TO-DATE  AVAILABLE  AGE
connector-splunk-kubernetes-metrics-agg  0/1    1           0          1s
connector-splunk-kubernetes-objects      0/1    1           0          1s


NOTES:


███████╗██████╗ ██╗     ██╗   ██╗███╗   ██╗██╗  ██╗██╗
██╔════╝██╔══██╗██║     ██║   ██║████╗  ██║██║ ██╔╝╚██╗
███████╗██████╔╝██║     ██║   ██║██╔██╗ ██║█████╔╝  ╚██╗
╚════██║██╔═══╝ ██║     ██║   ██║██║╚██╗██║██╔═██╗  ██╔╝
███████║██║     ███████╗╚██████╔╝██║ ╚████║██║  ██╗██╔╝
╚══════╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝

Listen to your data.

Splunk Connect for Kubernetes is spinning up in your cluster.
After a few minutes, you should see data being indexed in your Splunk.

If you get stuck, we're here to help.
Look for answers here: http://docs.splunk.com
  STEP 4: Install prometheus operator.
NAME:   monitor
LAST DEPLOYED: Sun Nov 10 13:31:41 2019
NAMESPACE: monitor
STATUS: DEPLOYED

RESOURCES:
==> v1/Alertmanager
NAME                                     AGE
monitor-prometheus-operato-alertmanager  37s

==> v1/ClusterRole
NAME                                       AGE
monitor-grafana-clusterrole                38s
monitor-prometheus-operato-alertmanager    38s
monitor-prometheus-operato-operator        38s
monitor-prometheus-operato-operator-psp    38s
monitor-prometheus-operato-prometheus      38s
monitor-prometheus-operato-prometheus-psp  38s
psp-monitor-kube-state-metrics             38s
psp-monitor-prometheus-node-exporter       38s

==> v1/ClusterRoleBinding
NAME                                       AGE
monitor-grafana-clusterrolebinding         38s
monitor-prometheus-operato-alertmanager    38s
monitor-prometheus-operato-operator        38s
monitor-prometheus-operato-operator-psp    38s
monitor-prometheus-operato-prometheus      38s
monitor-prometheus-operato-prometheus-psp  38s
psp-monitor-kube-state-metrics             38s
psp-monitor-prometheus-node-exporter       38s

==> v1/ConfigMap
NAME                                                          DATA  AGE
monitor-grafana                                               1     38s
monitor-grafana-config-dashboards                             1     38s
monitor-grafana-test                                          1     38s
monitor-prometheus-operato-apiserver                          1     38s
monitor-prometheus-operato-cluster-total                      1     38s
monitor-prometheus-operato-controller-manager                 1     38s
monitor-prometheus-operato-etcd                               1     38s
monitor-prometheus-operato-grafana-datasource                 1     38s
monitor-prometheus-operato-k8s-coredns                        1     38s
monitor-prometheus-operato-k8s-resources-cluster              1     38s
monitor-prometheus-operato-k8s-resources-namespace            1     38s
monitor-prometheus-operato-k8s-resources-node                 1     38s
monitor-prometheus-operato-k8s-resources-pod                  1     38s
monitor-prometheus-operato-k8s-resources-workload             1     38s
monitor-prometheus-operato-k8s-resources-workloads-namespace  1     38s
monitor-prometheus-operato-kubelet                            1     38s
monitor-prometheus-operato-namespace-by-pod                   1     38s
monitor-prometheus-operato-namespace-by-workload              1     38s
monitor-prometheus-operato-node-cluster-rsrc-use              1     38s
monitor-prometheus-operato-node-rsrc-use                      1     38s
monitor-prometheus-operato-nodes                              1     38s
monitor-prometheus-operato-persistentvolumesusage             1     38s
monitor-prometheus-operato-pod-total                          1     38s
monitor-prometheus-operato-pods                               1     38s
monitor-prometheus-operato-prometheus                         1     38s
monitor-prometheus-operato-proxy                              1     38s
monitor-prometheus-operato-scheduler                          1     38s
monitor-prometheus-operato-statefulset                        1     38s
monitor-prometheus-operato-workload-total                     1     38s

==> v1/DaemonSet
NAME                              DESIRED  CURRENT  READY  UP-TO-DATE  AVAILABLE  NODE SELECTOR  AGE
monitor-prometheus-node-exporter  1        1        1      1           1          <none>         37s

==> v1/Deployment
NAME                                 READY  UP-TO-DATE  AVAILABLE  AGE
monitor-grafana                      0/1    1           0          37s
monitor-kube-state-metrics           0/1    1           0          37s
monitor-prometheus-operato-operator  0/1    1           0          37s

==> v1/Pod(related)
NAME                                                  READY  STATUS             RESTARTS  AGE
monitor-grafana-86b4c65f8-cbbzr                       0/2    PodInitializing    0         37s
monitor-kube-state-metrics-59cd4b5955-pg9m8           0/1    ContainerCreating  0         37s
monitor-prometheus-node-exporter-4qvsk                1/1    Running            0         37s
monitor-prometheus-operato-operator-65dd5455d9-4bnbs  0/2    ContainerCreating  0         37s

==> v1/Prometheus
NAME                                   AGE
monitor-prometheus-operato-prometheus  37s

==> v1/PrometheusRule
NAME                                                             AGE
monitor-prometheus-operato-alertmanager.rules                    36s
monitor-prometheus-operato-etcd                                  36s
monitor-prometheus-operato-general.rules                         36s
monitor-prometheus-operato-k8s.rules                             36s
monitor-prometheus-operato-kube-apiserver.rules                  36s
monitor-prometheus-operato-kube-prometheus-node-recording.rules  36s
monitor-prometheus-operato-kube-scheduler.rules                  36s
monitor-prometheus-operato-kubernetes-absent                     36s
monitor-prometheus-operato-kubernetes-apps                       36s
monitor-prometheus-operato-kubernetes-resources                  36s
monitor-prometheus-operato-kubernetes-storage                    36s
monitor-prometheus-operato-kubernetes-system                     36s
monitor-prometheus-operato-kubernetes-system-apiserver           36s
monitor-prometheus-operato-kubernetes-system-controller-manager  36s
monitor-prometheus-operato-kubernetes-system-kubelet             36s
monitor-prometheus-operato-kubernetes-system-scheduler           36s
monitor-prometheus-operato-node-exporter                         36s
monitor-prometheus-operato-node-exporter.rules                   36s
monitor-prometheus-operato-node-network                          36s
monitor-prometheus-operato-node-time                             36s
monitor-prometheus-operato-node.rules                            36s
monitor-prometheus-operato-prometheus                            36s
monitor-prometheus-operato-prometheus-operator                   36s

==> v1/Role
NAME                  AGE
monitor-grafana-test  38s

==> v1/RoleBinding
NAME                  AGE
monitor-grafana-test  38s

==> v1/Secret
NAME                                                  TYPE    DATA  AGE
alertmanager-monitor-prometheus-operato-alertmanager  Opaque  1     38s
monitor-grafana                                       Opaque  3     38s

==> v1/Service
NAME                                                TYPE       CLUSTER-IP      EXTERNAL-IP  PORT(S)           AGE
monitor-grafana                                     NodePort   10.105.233.203  <none>       80:32504/TCP      37s
monitor-kube-state-metrics                          ClusterIP  10.100.210.2    <none>       8080/TCP          37s
monitor-prometheus-node-exporter                    ClusterIP  10.100.98.169   <none>       9100/TCP          37s
monitor-prometheus-operato-alertmanager             ClusterIP  10.106.1.212    <none>       9093/TCP          37s
monitor-prometheus-operato-coredns                  ClusterIP  None            <none>       9153/TCP          37s
monitor-prometheus-operato-kube-controller-manager  ClusterIP  None            <none>       10252/TCP         37s
monitor-prometheus-operato-kube-etcd                ClusterIP  None            <none>       2379/TCP          37s
monitor-prometheus-operato-kube-proxy               ClusterIP  None            <none>       10249/TCP         37s
monitor-prometheus-operato-kube-scheduler           ClusterIP  None            <none>       10251/TCP         37s
monitor-prometheus-operato-operator                 ClusterIP  10.102.241.167  <none>       8080/TCP,443/TCP  37s
monitor-prometheus-operato-prometheus               ClusterIP  10.105.116.161  <none>       9090/TCP          37s

==> v1/ServiceAccount
NAME                                     SECRETS  AGE
monitor-grafana                          1        38s
monitor-grafana-test                     1        38s
monitor-kube-state-metrics               1        38s
monitor-prometheus-node-exporter         1        38s
monitor-prometheus-operato-alertmanager  1        38s
monitor-prometheus-operato-operator      1        38s
monitor-prometheus-operato-prometheus    1        38s

==> v1/ServiceMonitor
NAME                                                AGE
monitor-prometheus-operato-alertmanager             36s
monitor-prometheus-operato-apiserver                36s
monitor-prometheus-operato-coredns                  36s
monitor-prometheus-operato-grafana                  36s
monitor-prometheus-operato-kube-controller-manager  36s
monitor-prometheus-operato-kube-etcd                36s
monitor-prometheus-operato-kube-proxy               36s
monitor-prometheus-operato-kube-scheduler           36s
monitor-prometheus-operato-kube-state-metrics       36s
monitor-prometheus-operato-kubelet                  36s
monitor-prometheus-operato-node-exporter            36s
monitor-prometheus-operato-operator                 36s
monitor-prometheus-operato-prometheus               36s

==> v1beta1/ClusterRole
NAME                        AGE
monitor-kube-state-metrics  38s

==> v1beta1/ClusterRoleBinding
NAME                        AGE
monitor-kube-state-metrics  38s

==> v1beta1/MutatingWebhookConfiguration
NAME                                  AGE
monitor-prometheus-operato-admission  37s

==> v1beta1/PodSecurityPolicy
NAME                                     PRIV   CAPS      SELINUX           RUNASUSER  FSGROUP    SUPGROUP  READONLYROOTFS  VOLUMES
monitor-grafana                          false  RunAsAny  RunAsAny          RunAsAny   RunAsAny   false     configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim
monitor-grafana-test                     false  RunAsAny  RunAsAny          RunAsAny   RunAsAny   false     configMap,downwardAPI,emptyDir,projected,secret
monitor-kube-state-metrics               false  RunAsAny  MustRunAsNonRoot  MustRunAs  MustRunAs  false     secret
monitor-prometheus-node-exporter         false  RunAsAny  RunAsAny          MustRunAs  MustRunAs  false     configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim,hostPath
monitor-prometheus-operato-alertmanager  false  RunAsAny  RunAsAny          MustRunAs  MustRunAs  false     configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim
monitor-prometheus-operato-operator      false  RunAsAny  RunAsAny          MustRunAs  MustRunAs  false     configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim
monitor-prometheus-operato-prometheus    false  RunAsAny  RunAsAny          MustRunAs  MustRunAs  false     configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim

==> v1beta1/Role
NAME             AGE
monitor-grafana  38s

==> v1beta1/RoleBinding
NAME             AGE
monitor-grafana  38s

==> v1beta1/ValidatingWebhookConfiguration
NAME                                  AGE
monitor-prometheus-operato-admission  36s


NOTES:
The Prometheus Operator has been installed. Check its status by running:
  kubectl --namespace monitor get pods -l "release=monitor"

Visit https://github.com/coreos/prometheus-operator for instructions on how
to create & configure Alertmanager and Prometheus instances using the Operator.
  STEP 5: Setup docker environment.
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.64.21:2376"
export DOCKER_CERT_PATH="/Users/ajdnik/.minikube/certs"
# Run this command to configure your shell:
# eval $(minikube docker-env)
  STEP 6: Build project Docker image.
Sending build context to Docker daemon  413.2kB
Step 1/21 : FROM elixir:1.9-alpine as build
1.9-alpine: Pulling from library/elixir
89d9c30c1d48: Already exists
d04bb5abd636: Pull complete
ab1535942fc2: Pull complete
Digest: sha256:47179f5b8ab47aca5d7263eaceb6f2c41ac274fb2ec57ab42954079363bb82d1
Status: Downloaded newer image for elixir:1.9-alpine
 ---> 226fb00c5fdd
Step 2/21 : RUN apk add --no-cache make &&     mix local.hex --force &&     mix local.rebar --force
 ---> Running in d39eb8f0b5ed
fetch http://dl-cdn.alpinelinux.org/alpine/v3.10/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.10/community/x86_64/APKINDEX.tar.gz
(1/1) Installing make (4.2.1-r2)
Executing busybox-1.30.1-r2.trigger
OK: 15 MiB in 24 packages
* creating root/.mix/archives/hex-0.20.1
* creating root/.mix/rebar
* creating root/.mix/rebar3
Removing intermediate container d39eb8f0b5ed
 ---> a2f7307985db
Step 3/21 : ENV MIX_ENV=prod
 ---> Running in 39ed6df4ce17
Removing intermediate container 39ed6df4ce17
 ---> 9efaf270e5dc
Step 4/21 : WORKDIR /app
 ---> Running in 0f011738f375
Removing intermediate container 0f011738f375
 ---> a24e336e92ff
Step 5/21 : COPY mix.* ./
 ---> 69d6c068eb95
Step 6/21 : COPY Makefile ./
 ---> 47de2aef7ef0
Step 7/21 : RUN make deps
 ---> Running in 648c38e79ecc
mix deps.get
Resolving Hex dependencies...
Dependency resolution completed:
Unchanged:
  cowboy 2.6.3
  cowlib 2.7.3
  jason 1.1.2
  mime 1.3.1
  plug 1.8.3
  plug_cowboy 2.1.0
  plug_crypto 1.0.0
  prometheus 4.4.1
  prometheus_ex 3.0.5
  ranch 1.7.1
* Getting jason (Hex package)
* Getting plug_cowboy (Hex package)
* Getting prometheus_ex (Hex package)
* Getting prometheus (Hex package)
* Getting cowboy (Hex package)
* Getting plug (Hex package)
* Getting mime (Hex package)
* Getting plug_crypto (Hex package)
* Getting cowlib (Hex package)
* Getting ranch (Hex package)
mix deps.compile
===> Compiling ranch
==> jason
Compiling 8 files (.ex)
Generated jason app
==> prometheus
Compiling 28 files (.erl)
Generated prometheus app
==> prometheus_ex
Compiling 19 files (.ex)
Generated prometheus_ex app
===> Compiling cowlib
===> Compiling cowboy
==> mime
Compiling 2 files (.ex)
Generated mime app
==> plug_crypto
Compiling 4 files (.ex)
Generated plug_crypto app
==> plug
Compiling 1 file (.erl)
Compiling 39 files (.ex)
warning: System.stacktrace/0 outside of rescue/catch clauses is deprecated. If you want to support only Elixir v1.7+, you must access __STACKTRACE__ inside a rescue/catch. If you want to support earlier Elixir versions, move System.stacktrace/0 inside a rescue/catch
  lib/plug/conn/wrapper_error.ex:23

Generated plug app
==> plug_cowboy
Compiling 6 files (.ex)
Generated plug_cowboy app
Removing intermediate container 648c38e79ecc
 ---> 064577b159cc
Step 8/21 : COPY . .
 ---> 7ddf4c38a503
Step 9/21 : RUN make compile
 ---> Running in 5ca84a431247
mix compile
Compiling 4 files (.ex)
Generated player_bio app
Removing intermediate container 5ca84a431247
 ---> 8a819bc3def7
Step 10/21 : FROM build as test
 ---> 8a819bc3def7
Step 11/21 : RUN make check && make test
 ---> Running in 8287c418032e
mix format --check-formatted
mix test
.

Finished in 0.05 seconds
1 test, 0 failures

Randomized with seed 212287
Removing intermediate container 8287c418032e
 ---> dff7653b79be
Step 12/21 : FROM build as release
 ---> 8a819bc3def7
Step 13/21 : RUN make release
 ---> Running in 3b4f66a69fe9
mix release
* assembling player_bio-0.1.0 on MIX_ENV=prod
* skipping runtime configuration (config/releases.exs not found)
* skipping elixir.bat for windows (bin/elixir.bat not found in the Elixir installation)
* skipping iex.bat for windows (bin/iex.bat not found in the Elixir installation)

Release created at _build/prod/rel/player_bio!

    # To start your system
    _build/prod/rel/player_bio/bin/player_bio start

Once the release is running:

    # To connect to it remotely
    _build/prod/rel/player_bio/bin/player_bio remote

    # To stop it gracefully (you may also send SIGINT/SIGTERM)
    _build/prod/rel/player_bio/bin/player_bio stop

To list all commands:

    _build/prod/rel/player_bio/bin/player_bio

Removing intermediate container 3b4f66a69fe9
 ---> a2f9bb411c85
Step 14/21 : FROM alpine:3.10
3.10: Pulling from library/alpine
89d9c30c1d48: Already exists
Digest: sha256:c19173c5ada610a5989151111163d28a67368362762534d8a8121ce95cf2bd5a
Status: Downloaded newer image for alpine:3.10
 ---> 965ea09ff2eb
Step 15/21 : RUN apk add --no-cache       ncurses-libs       zlib       openssl       ca-certificates &&     mkdir -p /app &&     adduser -s /bin/sh -u 1001 -G root -h /app -S -D default &&     chown -R 1001:0 /app
 ---> Running in bdb709303024
fetch http://dl-cdn.alpinelinux.org/alpine/v3.10/main/x86_64/APKINDEX.tar.gz
fetch http://dl-cdn.alpinelinux.org/alpine/v3.10/community/x86_64/APKINDEX.tar.gz
(1/5) Installing ca-certificates (20190108-r0)
(2/5) Installing ncurses-terminfo-base (6.1_p20190518-r0)
(3/5) Installing ncurses-terminfo (6.1_p20190518-r0)
(4/5) Installing ncurses-libs (6.1_p20190518-r0)
(5/5) Installing openssl (1.1.1d-r0)
Executing busybox-1.30.1-r2.trigger
Executing ca-certificates-20190108-r0.trigger
OK: 14 MiB in 19 packages
Removing intermediate container bdb709303024
 ---> c0de71285be6
Step 16/21 : COPY --from=release /app/_build/prod/rel/player_bio /app
 ---> 2b2c9640322b
Step 17/21 : RUN chown -R 1001:0 /app
 ---> Running in 74453a5058ab
Removing intermediate container 74453a5058ab
 ---> 551473d8d728
Step 18/21 : WORKDIR /app
 ---> Running in 23f16acf7292
Removing intermediate container 23f16acf7292
 ---> 8bf0567933f6
Step 19/21 : USER default
 ---> Running in f0563b86a447
Removing intermediate container f0563b86a447
 ---> 1d641daa7fcb
Step 20/21 : EXPOSE 8080
 ---> Running in 6e3f14e33597
Removing intermediate container 6e3f14e33597
 ---> d24c705bd0ac
Step 21/21 : ENTRYPOINT ["/app/bin/player_bio"]
 ---> Running in 352a3f50d25d
Removing intermediate container 352a3f50d25d
 ---> 6dc0995a018c
Successfully built 6dc0995a018c
Successfully tagged playerbio:latest
  STEP 7: Reset Docker environment.
unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
# Run this command to configure your shell:
# eval $(minikube docker-env)
  STEP 8: Deploy project to cluster.
NAME:   playerbio
LAST DEPLOYED: Sun Nov 10 13:35:57 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                  DATA  AGE
playerbio-dashboard   1     0s
playerbio-datasource  1     0s

==> v1/Deployment
NAME       READY  UP-TO-DATE  AVAILABLE  AGE
playerbio  0/5    5           0          0s

==> v1/Pod(related)
NAME                        READY  STATUS             RESTARTS  AGE
playerbio-58c659586f-4s86g  0/1    ContainerCreating  0         0s
playerbio-58c659586f-lkt4w  0/1    ContainerCreating  0         0s
playerbio-58c659586f-mzbwk  0/1    ContainerCreating  0         0s
playerbio-58c659586f-wsc75  0/1    ContainerCreating  0         0s
playerbio-58c659586f-x7xqw  0/1    ContainerCreating  0         0s

==> v1/Prometheus
NAME       AGE
playerbio  0s

==> v1/Service
NAME                  TYPE       CLUSTER-IP    EXTERNAL-IP  PORT(S)       AGE
playerbio             NodePort   10.96.23.243  <none>       80:30871/TCP  0s
playerbio-prometheus  ClusterIP  10.98.15.218  <none>       9090/TCP      0s

==> v1/ServiceMonitor
NAME       AGE
playerbio  0s


NOTES:
Playerbio microservice has been installed. Check its status by running:
  kubectl --namespace default get pods -l "release=playerbio"

  STEP 9: Test project deployment.
RUNNING: playerbio-player-endpoint-test
PASSED: playerbio-player-endpoint-test
RUNNING: playerbio-ping-endpoint-test
PASSED: playerbio-ping-endpoint-test
RUNNING: playerbio-metrics-endpoint-test
PASSED: playerbio-metrics-endpoint-test
  STEP 10: Add datasource to grafana.
Note: Unnecessary use of -X or --request, POST is already inferred.
*   Trying 192.168.64.21...
* TCP_NODELAY set
* Connected to 192.168.64.21 (192.168.64.21) port 32504 (#0)
> POST /api/datasources HTTP/1.1
> Host: 192.168.64.21:32504
> User-Agent: curl/7.64.1
> Authorization: Basic YWRtaW46cHJvbS1vcGVyYXRvcg==
> Accept: application/json
> Content-Type: application/json
> Content-Length: 102
>
* upload completely sent off: 102 out of 102 bytes
< HTTP/1.1 200 OK
< Cache-Control: no-cache
< Content-Type: application/json
< Expires: -1
< Pragma: no-cache
< X-Frame-Options: deny
< Date: Sun, 10 Nov 2019 12:36:39 GMT
< Content-Length: 408
<
* Connection #0 to host 192.168.64.21 left intact
{"datasource":{"id":2,"orgId":1,"name":"playerbio","type":"prometheus","typeLogoUrl":"","access":"proxy","url":"http://playerbio-prometheus:9090/","password":"","user":"","database":"","basicAuth":false,"basicAuthUser":"","basicAuthPassword":"","withCredentials":false,"isDefault":false,"jsonData":{},"secureJsonFields":{},"version":1,"readOnly":false},"id":2,"message":"Datasource added","name":"playerbio"}* Closing connection 0
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

#### ./deploy.sh

Script redeploys the [Elixir](https://elixir-lang.org/) service to the cluster by upgrading the existing [Helm](https://helm.sh/docs/install/#installing-helm) deployment. The deployment process rolls back changes made in case of failed upgrade.

The script needs to be executed everytime changes have been made to the [Elixir](https://elixir-lang.org/) service codebase so that the changes get pushed to the cluster.

```bash
./deploy.sh
  STEP 1: Setup docker environment.
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.64.21:2376"
export DOCKER_CERT_PATH="/Users/ajdnik/.minikube/certs"
# Run this command to configure your shell:
# eval $(minikube docker-env)
  STEP 2: Build project Docker image.
Sending build context to Docker daemon  413.2kB
Step 1/21 : FROM elixir:1.9-alpine as build
 ---> 226fb00c5fdd
Step 2/21 : RUN apk add --no-cache make &&     mix local.hex --force &&     mix local.rebar --force
 ---> Using cache
 ---> a2f7307985db
Step 3/21 : ENV MIX_ENV=prod
 ---> Using cache
 ---> 9efaf270e5dc
Step 4/21 : WORKDIR /app
 ---> Using cache
 ---> a24e336e92ff
Step 5/21 : COPY mix.* ./
 ---> Using cache
 ---> 69d6c068eb95
Step 6/21 : COPY Makefile ./
 ---> Using cache
 ---> 47de2aef7ef0
Step 7/21 : RUN make deps
 ---> Using cache
 ---> 064577b159cc
Step 8/21 : COPY . .
 ---> Using cache
 ---> 7ddf4c38a503
Step 9/21 : RUN make compile
 ---> Using cache
 ---> 8a819bc3def7
Step 10/21 : FROM build as test
 ---> 8a819bc3def7
Step 11/21 : RUN make check && make test
 ---> Using cache
 ---> dff7653b79be
Step 12/21 : FROM build as release
 ---> 8a819bc3def7
Step 13/21 : RUN make release
 ---> Using cache
 ---> a2f9bb411c85
Step 14/21 : FROM alpine:3.10
 ---> 965ea09ff2eb
Step 15/21 : RUN apk add --no-cache       ncurses-libs       zlib       openssl       ca-certificates &&     mkdir -p /app &&     adduser -s /bin/sh -u 1001 -G root -h /app -S -D default &&     chown -R 1001:0 /app
 ---> Using cache
 ---> c0de71285be6
Step 16/21 : COPY --from=release /app/_build/prod/rel/player_bio /app
 ---> Using cache
 ---> 2b2c9640322b
Step 17/21 : RUN chown -R 1001:0 /app
 ---> Using cache
 ---> 551473d8d728
Step 18/21 : WORKDIR /app
 ---> Using cache
 ---> 8bf0567933f6
Step 19/21 : USER default
 ---> Using cache
 ---> 1d641daa7fcb
Step 20/21 : EXPOSE 8080
 ---> Using cache
 ---> d24c705bd0ac
Step 21/21 : ENTRYPOINT ["/app/bin/player_bio"]
 ---> Using cache
 ---> 6dc0995a018c
Successfully built 6dc0995a018c
Successfully tagged playerbio:1573389647
  STEP 3: Reset Docker environment.
unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
# Run this command to configure your shell:
# eval $(minikube docker-env)
  STEP 4: Deploy service.
Release "playerbio" has been upgraded.
LAST DEPLOYED: Sun Nov 10 13:41:00 2019
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                  DATA  AGE
playerbio-dashboard   1     5m21s
playerbio-datasource  1     5m21s

==> v1/Deployment
NAME       READY  UP-TO-DATE  AVAILABLE  AGE
playerbio  4/5    5           4          5m21s

==> v1/Pod(related)
NAME                        READY  STATUS       RESTARTS  AGE
playerbio-58c659586f-4s86g  1/1    Terminating  0         5m21s
playerbio-58c659586f-mzbwk  0/1    Terminating  0         5m21s
playerbio-58c659586f-wsc75  0/1    Terminating  0         5m21s
playerbio-58c659586f-x7xqw  0/1    Terminating  0         5m21s
playerbio-5b446d7dff-2cxrd  1/1    Running      0         9s
playerbio-5b446d7dff-hqrjh  0/1    Running      0         9s
playerbio-5b446d7dff-kmbkk  1/1    Running      0         18s
playerbio-5b446d7dff-lxjbd  1/1    Running      0         18s
playerbio-5b446d7dff-w7rrq  1/1    Running      0         18s

==> v1/Prometheus
NAME       AGE
playerbio  5m21s

==> v1/Service
NAME                  TYPE       CLUSTER-IP    EXTERNAL-IP  PORT(S)       AGE
playerbio             NodePort   10.96.23.243  <none>       80:30871/TCP  5m21s
playerbio-prometheus  ClusterIP  10.98.15.218  <none>       9090/TCP      5m21s

==> v1/ServiceMonitor
NAME       AGE
playerbio  5m21s


NOTES:
Playerbio microservice has been installed. Check its status by running:
  kubectl --namespace default get pods -l "release=playerbio"

  SUCCESS: Service deployed to cluster.
  Playerbio url is http://192.168.64.21:30871.
```
</p>
</details>

#### ./delete.sh

Script deletes the [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/) cluster and all of the services and [Docker](https://docs.docker.com/install/) images deployed to it.

```bash
./delete.sh
  STEP 1: Reset Docker environment variables.
unset DOCKER_TLS_VERIFY
unset DOCKER_HOST
unset DOCKER_CERT_PATH
# Run this command to configure your shell:
# eval $(minikube docker-env)
  STEP 2: Delete minikube cluster.
🔥  Deleting "playerbio" in hyperkit ...
💔  The "playerbio" cluster has been deleted.
🔥  Successfully deleted profile "playerbio"
  SUCCESS: MiniKube environment is destroyed.
```
