#! /usr/bin/env sh

# exit immediately when a command fails
set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail
# error on unset variables
set -u

# script directory
CURR_DIR="$(dirname $0)";

# print help when --help flag is supplied
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- 'This script installs all of the dependencies to the cluster for playerbio service.\n';
  printf -- 'If you want to suppress subcommand outputs you can use the --silent flag.\n';
  printf -- 'Usage: ./provision.sh --silent\n';
  exit 0;
fi;

# silent output if --silent flag is provided
error_handle() {
  stty echo;
	reset;
}
if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
  stty -echo;
  trap error_handle INT;
  trap error_handle TERM;
  trap error_handle KILL;
  trap error_handle EXIT;
fi;

# output helper functions
function warn() {
	local msg="$1"
	if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
		stty +echo && printf -- "\033[33m $msg \033[0m\n" && stty -echo;
	else
		printf -- "\033[33m $msg \033[0m\n";
	fi;
}

function err() {
	local msg="$1"
	if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
		stty +echo && printf -- "\033[31m $msg \033[0m\n" && stty -echo;
	else
		printf -- "\033[31m $msg \033[0m\n";
	fi;
}

function ok() {
	local msg="$1"
	if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
		stty +echo && printf -- "\033[32m \033[1m $msg \033[0m\n" && stty -echo;
	else
		printf -- "\033[32m \033[1m $msg \033[0m\n";
	fi;
}

function info() {
	local msg="$1"
	if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
		stty +echo && printf -- "\033[0m \033[1m $msg \033[0m\n" && stty -echo;
	else
		printf -- "\033[0m \033[1m $msg \033[0m\n";
	fi;

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

info 'STEP 1: Update helm repository.';
printf '\n';
helm repo update

info 'STEP 2: Install prometheus operator.';
printf '\n';
helm install stable/prometheus-operator --version=8.1.2 \
  --name=monitor \
  --namespace=monitor \
  --values="${CURR_DIR}/prometheus-operator.yaml"

info 'STEP 3: Setup docker environment.';
printf '\n';
minikube docker-env -p playerbio
eval $(minikube docker-env -p playerbio)

info 'STEP 4: Build project Docker image.';
printf '\n';
docker build -t playerbio:latest "${CURR_DIR}/../"

info 'STEP 5: Reset Docker environment.';
printf '\n';
minikube docker-env -u -p playerbio
eval $(minikube docker-env -u -p playerbio)

info 'STEP 6: Deploy project to cluster.';
printf '\n';
helm install "${CURR_DIR}/../helm" --name=playerbio \
  --values="${CURR_DIR}/playerbio.yaml"

printf '\nPlayerbio service URL: ';
minikube service playerbio -p playerbio --url

ok 'SUCCESS: Playerbio service deployed to cluster.';
