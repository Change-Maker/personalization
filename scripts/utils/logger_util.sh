readonly BOLD="$(tput bold 2>/dev/null || printf '')"
readonly UNDERLINE="$(tput smul 2>/dev/null || printf '')"

readonly BLACK="$(tput setaf 0 2>/dev/null || printf '')"
readonly RED="$(tput setaf 1 2>/dev/null || printf '')"
readonly GREEN="$(tput setaf 2 2>/dev/null || printf '')"
readonly YELLOW="$(tput setaf 3 2>/dev/null || printf '')"
readonly BLUE="$(tput setaf 4 2>/dev/null || printf '')"
readonly MAGENTA="$(tput setaf 5 2>/dev/null || printf '')"
readonly CYAN="$(tput setaf 6 2>/dev/null || printf '')"
readonly WHITE="$(tput setaf 7 2>/dev/null || printf '')"
readonly NO_COLOR="$(tput sgr0 2>/dev/null || printf '')"

function info() {
  printf '%s\n' "${NO_COLOR}> $*"
}

function warn() {
  printf '%s\n' "${YELLOW}! $*${NO_COLOR}"
}

function error() {
  printf '%s\n' "${RED}x $*${NO_COLOR}" >&2
}

function completed() {
  printf '%s\n' "${GREEN}✓ $*${NO_COLOR}"
}
