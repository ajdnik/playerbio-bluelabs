#! /usr/bin/env sh

# exit immediately when a command fails
set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail
# error on unset variables
set -u

# print help when --help flag is supplied
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- 'This script creates a new minikube cluster for the playerbio service.\n';
  printf -- 'If you already have a minikube cluster configured with helm you can skip this script.\n';
  printf -- 'If you want to suppress subcommand outputs you can use the --silent flag.\n';
  printf -- 'Usage: ./create.sh --silent\n';
  exit 0;
fi;

# silent output if --silent flag is provided
error_handle() {
  stty echo;
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
		stty +echo && printf "\033[33m $msg \033[0m\n" && stty -echo;
	else
		printf "\033[33m $msg \033[0m\n";
	fi;
}

function err() {
	local msg="$1"
	if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
		stty +echo && printf "\033[31m $msg \033[0m\n" && stty -echo;
	else
		printf "\033[31m $msg \033[0m\n";
	fi;
}

function ok() {
	local msg="$1"
	if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
		stty +echo && printf "\033[32m \033[1m $msg \033[0m\n" && stty -echo;
	else
		printf "\033[32m \033[1m $msg \033[0m\n";
	fi;
}

function info() {
	local msg="$1"
	if [ ${#@} -ne 0 ] && [ "${@#"--silent"}" = "" ]; then
		stty +echo && printf "\033[0m \033[1m $msg \033[0m\n" && stty -echo;
	else
		printf "\033[0m \033[1m $msg \033[0m\n";
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
printf '\n';
minikube start -p playerbio \
  --kubernetes-version=v1.14.5 \
  --memory=4096 \
  --extra-config=scheduler.address=0.0.0.0 \
  --extra-config=controller-manager.address=0.0.0.0 \
  --extra-config=apiserver.authorization-mode=RBAC
minikube status -p playerbio

info 'STEP 2: Create service account for tiller.';
printf '\n';
kubectl create serviceaccount tiller --namespace kube-system

info 'STEP 3: Set cluster role for tiller service account.'
printf '\n';
kubectl create clusterrolebinding tiller-role-binding --clusterrole cluster-admin \
  --serviceaccount=kube-system:tiller

info 'STEP 4: Install Tiller';
printf '\n';
helm init --service-account tiller

ok 'SUCCESS: MiniKube environment is set up.';
