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

info 'STEP 2: Install prometheus operator.';
helm install stable/prometheus-operator \
  --version=8.1.2 \
  --name=monitor \
  --namespace=monitor \
  --values="${CURR_DIR}/prometheus-operator.yaml"

info 'STEP 3: Setup docker environment.';
minikube docker-env -p playerbio
eval $(minikube docker-env -p playerbio)

info 'STEP 4: Build project Docker image.';
docker build -t playerbio:latest "${CURR_DIR}/../"

info 'STEP 5: Reset Docker environment.';
minikube docker-env -u -p playerbio
eval $(minikube docker-env -u -p playerbio)

info 'STEP 6: Deploy project to cluster.';
helm install "${CURR_DIR}/../helm" --name=playerbio \
  --values="${CURR_DIR}/playerbio.yaml"

# datasources are loaded on initialization of grafana pods so, 
# we need to manually add it to grafana
GRAFANA_URL=$(minikube service monitor-grafana -n monitor -p playerbio --url)
info 'STEP 7: Add datasource to grafana.';
curl -v -X POST \
  -H "Authorization: Basic YWRtaW46cHJvbS1vcGVyYXRvcg==" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"name":"playerbio", "type":"prometheus", "access":"proxy", "url":"http://playerbio-prometheus:9090/"}' \
  "${GRAFANA_URL}/api/datasources"

SERVICE_URL=$(minikube service playerbio -p playerbio --url);
ok 'SUCCESS: Playerbio service deployed to cluster.';
ok 'Playerbio:';
ok "  Url: ${SERVICE_URL}";
ok 'Grafana:';
ok '  Username: admin';
ok '  Password: prom-operator';
ok "  Url: ${GRAFANA_URL}";
