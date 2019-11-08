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
  printf -- 'This script deploys the playerbio service to the minikube cluster.\n';
  printf -- '\nUsage: ./deploy.sh\n';
  exit 0;
fi;

# check if commands needed for this script exist
exists 'minikube' 'https://kubernetes.io/docs/tasks/tools/install-minikube/';
exists 'helm' 'https://helm.sh/docs/install/#installing-helm';
exists 'docker' 'https://docs.docker.com/install/';

# execute script steps
info 'STEP 1: Setup docker environment.';
minikube docker-env -p playerbio
eval $(minikube docker-env -p playerbio)

info 'STEP 2: Build project Docker image.';
TIME=$(date +%s);
docker build -t "playerbio:${TIME}" "${CURR_DIR}/../"

info 'STEP 3: Reset Docker environment.';
minikube docker-env -u -p playerbio
eval $(minikube docker-env -u -p playerbio)

info 'STEP 4: Deploy service.';
helm upgrade playerbio "${CURR_DIR}/../helm" \
  --reuse-values \
  --atomic \
  --set-string image.tag=$TIME \
  --set replicaCount=5

SERVICE_URL=$(minikube service playerbio -p playerbio --url);
ok 'SUCCESS: Service deployed to cluster.';
ok "Playerbio url is ${SERVICE_URL}.";
