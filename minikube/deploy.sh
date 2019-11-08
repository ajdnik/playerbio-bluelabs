#! /usr/bin/env sh

# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail
# error on unset variables
set -u

# script directory
CURR_DIR="$(dirname $0)";

# print help when --help flag is supplied
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- 'This script deploys the playerbio service to the minikube cluster.\n';
  printf -- '\nUsage: ./deploy.sh\n';
  exit 0;
fi;

# output helper functions
function warn() {
	local msg="$1"
	printf -- "\033[33m $msg \033[0m\n";
}

function err() {
	local msg="$1"
	printf -- "\033[31m $msg \033[0m\n";
}

function ok() {
	local msg="$1"
	printf -- "\033[32m \033[1m $msg \033[0m\n";
}

function info() {
	local msg="$1"
	printf -- "\033[0m \033[1m $msg \033[0m\n";
}

# check if minikube is installed
_=$(command -v minikube);
if [ "$?" != "0" ]; then
  warn 'You do not seem to have MiniKube installed.';
  warn 'Get it: https://kubernetes.io/docs/tasks/tools/install-minikube/';
  err 'Exiting with code 127...';
  exit 127;
fi;

# check if helm is installed
_=$(command -v helm);
if [ "$?" != "0" ]; then
  warn 'You do not seem to have Helm installed.';
  warn 'Get it: https://helm.sh/docs/install/#installing-helm';
  err 'Exiting with code 127...';
  exit 127;
fi;

# check if docker is installed
_=$(command -v docker);
if [ "$?" != "0" ]; then
  warn 'You do not seem to have Docker installed.';
  warn 'Get it: https://docs.docker.com/install/';
  err 'Exiting with code 127...';
  exit 127;
fi;

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
