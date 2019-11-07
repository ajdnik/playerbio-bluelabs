#! /usr/bin/env sh

# exit immediately when a command fails
set -e
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail
# error on unset variables
set -u

# print help when --help flag is supplied
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- 'This script deletes the minikube cluster created for the playerbio service.\n';
  printf -- 'If you want to suppress subcommand outputs you can use the --silent flag.\n';
  printf -- 'Usage: ./delete.sh --silent\n';
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

info 'STEP 1: Reset Docker environment variables.';
printf '\n';
minikube docker-env -u -p playerbio
eval $(minikube docker-env -u -p playerbio)

info 'STEP 2: Delete minikube cluster.';
printf '\n';
minikube delete -p playerbio

ok 'SUCCESS: MiniKube environment is destroyed.';