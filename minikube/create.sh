#! /usr/bin/env sh

# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail
# error on unset variables
set -u

# print help when --help flag is supplied
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- 'This script creates a new minikube cluster for the playerbio service.\n';
  printf -- 'If you already have a minikube cluster configured with helm you can skip this script.\n';
  printf -- '\nUsage: ./create.sh\n';
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

# check if kubectl is installed
_=$(command -v kubectl);
if [ "$?" != "0" ]; then
  warn 'You do not seem to have Kubectl installed.';
  warn 'Get it: https://kubernetes.io/docs/tasks/tools/install-kubectl/';
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

info 'STEP 1: Create new minikube cluster.';
minikube start -p playerbio \
  --kubernetes-version=v1.14.5 \
  --memory=4096 \
  --extra-config=scheduler.address=0.0.0.0 \
  --extra-config=controller-manager.address=0.0.0.0 \
  --extra-config=apiserver.authorization-mode=RBAC
minikube status -p playerbio

info 'STEP 2: Create service account for tiller.';
kubectl create serviceaccount tiller --namespace kube-system

info 'STEP 3: Set cluster role for tiller service account.'
kubectl create clusterrolebinding tiller-role-binding --clusterrole cluster-admin \
  --serviceaccount=kube-system:tiller

info 'STEP 4: Install Tiller';
helm init --service-account tiller --wait

ok 'SUCCESS: MiniKube environment is set up.';
