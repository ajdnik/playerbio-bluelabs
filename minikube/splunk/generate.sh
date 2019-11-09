#! /usr/bin/env sh

# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail
# error on unset variables
set -u

# script directory
CURR_DIR="$(dirname $0)";

# print help when --help flag is supplied
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- 'This script creates a new k8s-app tar archive to be used with the splunk chart.\n';
  printf -- 'It generates a base64 encoded tar archive which can be coppied into the ConfigMap.';
  printf -- '\nUsage: ./generate.sh\n';
  exit 0;
fi;

# generate app archive
cd $CURR_DIR && tar -zcb 1 - ./k8s-app | base64
