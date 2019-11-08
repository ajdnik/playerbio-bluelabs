#! /usr/bin/env sh

# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail
# error on unset variables
set -u

# print help when --help flag is supplied
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- 'This script deletes the minikube cluster created for the playerbio service.\n';
  printf -- '\nUsage: ./delete.sh\n';
  exit 0;
fi;

# output helper functions
function warn() {
	local msg="$1"
	printf "\033[33m $msg \033[0m\n";
}

function err() {
	local msg="$1"
	printf "\033[31m $msg \033[0m\n";
}

function ok() {
	local msg="$1"
  printf "\033[32m \033[1m $msg \033[0m\n";
}

function info() {
	local msg="$1"
	printf "\033[0m \033[1m $msg \033[0m\n";
}

# check if minikube is installed
_=$(command -v minikube);
if [ "$?" != "0" ]; then
  warn 'You do not seem to have MiniKube installed.';
  warn 'Get it: https://kubernetes.io/docs/tasks/tools/install-minikube/';
  err 'Exiting with code 127...';
  exit 127;
fi;

info 'STEP 1: Reset Docker environment variables.';
minikube docker-env -u -p playerbio
eval $(minikube docker-env -u -p playerbio)

info 'STEP 2: Delete minikube cluster.';
minikube delete -p playerbio

ok 'SUCCESS: MiniKube environment is destroyed.';
