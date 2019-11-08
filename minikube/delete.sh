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
  printf -- 'This script deletes the minikube cluster created for the playerbio service.\n';
  printf -- '\nUsage: ./delete.sh\n';
  exit 0;
fi;

# check if commands needed for this script exist
exists 'minikube' 'https://kubernetes.io/docs/tasks/tools/install-minikube/';

# execute script steps
info 'STEP 1: Reset Docker environment variables.';
minikube docker-env -u -p playerbio
eval $(minikube docker-env -u -p playerbio)

info 'STEP 2: Delete minikube cluster.';
minikube delete -p playerbio

ok 'SUCCESS: MiniKube environment is destroyed.';
