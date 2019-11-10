#! /usr/bin/env sh

# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail
# error on unset variables
set -u

# script directory
CURR_DIR="$(dirname $0)";

# load helper functions
source "${CURR_DIR}/utils.sh"

# print help when --help flag is supplied
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- 'This script installs all of the dependencies to the cluster for playerbio service.\n';
  printf -- '\nUsage: ./provision.sh\n';
  exit 0;
fi;

# check if commands needed for this script exist
exists 'minikube' 'https://kubernetes.io/docs/tasks/tools/install-minikube/';
exists 'helm' 'https://helm.sh/docs/install/#installing-helm';
exists 'docker' 'https://docs.docker.com/install/';

# execute script steps
info 'STEP 1: Update helm repository.';
helm repo update

info 'STEP 2: Install splunk enterprise.';
helm install "${CURR_DIR}/splunk" \
  --name=splunk \
  --namespace=splunk \
  --values="${CURR_DIR}/splunk.yaml" \
  --wait

info 'STEP 3: Install splunk connector.';
helm install https://github.com/splunk/splunk-connect-for-kubernetes/releases/download/1.2.0/splunk-connect-for-kubernetes-1.2.0.tgz \
  --name connector \
  --namespace splunk \
  --values "${CURR_DIR}/splunk-connector.yaml"

info 'STEP 4: Install prometheus operator.';
helm install stable/prometheus-operator \
  --version=8.1.2 \
  --name=monitor \
  --namespace=monitor \
  --values="${CURR_DIR}/prometheus-operator.yaml"

info 'STEP 5: Setup docker environment.';
minikube docker-env -p playerbio
eval $(minikube docker-env -p playerbio)

info 'STEP 6: Build project Docker image.';
docker build -t playerbio:latest "${CURR_DIR}/../"

info 'STEP 7: Reset Docker environment.';
minikube docker-env -u -p playerbio
eval $(minikube docker-env -u -p playerbio)

info 'STEP 8: Deploy project to cluster.';
helm install "${CURR_DIR}/../helm" --name=playerbio \
  --values="${CURR_DIR}/playerbio.yaml"

info 'STEP 9: Test project deployment.';
helm test playerbio

# datasources are loaded on initialization of grafana pods so, we need to manually add it to grafana
GRAFANA_URL=$(minikube service monitor-grafana -n monitor -p playerbio --url)
info 'STEP 10: Add datasource to grafana.';
curl -v -X POST \
  -H "Authorization: Basic YWRtaW46cHJvbS1vcGVyYXRvcg==" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"name":"playerbio", "type":"prometheus", "access":"proxy", "url":"http://playerbio-prometheus:9090/"}' \
  "${GRAFANA_URL}/api/datasources"

SERVICE_URL=$(minikube service playerbio -p playerbio --url);
SPLUNK_URL=$(minikube service splunk-master -n splunk -p playerbio --url | head -n 1);
ok 'SUCCESS: Playerbio service deployed to cluster.';
ok 'Playerbio:';
ok "  Url: ${SERVICE_URL}";
ok 'Grafana:';
ok '  Username: admin';
ok '  Password: prom-operator';
ok "  Url: ${GRAFANA_URL}";
ok 'Splunk:';
ok '  Username: admin';
ok '  Password: helloworld';
ok "  Url: ${SPLUNK_URL}";
