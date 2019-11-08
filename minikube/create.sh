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
  printf -- 'This script creates a new minikube cluster for the playerbio service.\n';
  printf -- 'If you already have a minikube cluster configured with helm you can skip this script.\n';
  printf -- '\nUsage: ./create.sh\n';
  exit 0;
fi;

# check if commands needed for this script exist
exists 'minikube' 'https://kubernetes.io/docs/tasks/tools/install-minikube/';
exists 'kubectl' 'https://kubernetes.io/docs/tasks/tools/install-kubectl/';
exists 'helm' 'https://helm.sh/docs/install/#installing-helm';

# execute script steps
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
kubectl create clusterrolebinding tiller-role-binding \
  --clusterrole cluster-admin \
  --serviceaccount=kube-system:tiller

info 'STEP 4: Install Tiller';
helm init --service-account tiller --wait

ok 'SUCCESS: MiniKube environment is set up.';
