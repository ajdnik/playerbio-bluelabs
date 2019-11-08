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

# command check function
function exists() {
  local name="$1"
  local url="$2"
  _=$(command -v $name);
  if [ "$?" != "0" ]; then
    warn "You do not seem to have ${name} installed.";
    warn "Get it: ${url}";
    err 'Exiting with code 127...';
    exit 127;
  fi;
}
