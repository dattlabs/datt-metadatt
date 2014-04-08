
run_in_dir() {
  pushd "$1" &>/dev/null
  if [[ "$3" -eq 1 ]]; then
    eval "$2" &
  else
    shift
    eval "$@"
  fi
  popd &>/dev/null
}
export -f run_in_dir

run_in_dir_bkg() {
  run_in_dir "$1" "$2" 1
}
export -f run_in_dir_bkg

find_containers() {
  local script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  echo `find "$script_dir/../containers" -name datt-* -type d`
}
export -f find_containers

map() {
  local func="$1"; shift
  echo $* | xargs -P 100 -n 1 bash -c "$func \$@" _ {}
}
export -f map

map_over_container_dirs() {
  map "$1" `find_containers`
}
export -f map_over_container_dirs

run_cmd_in_container_dirs() {
  local cmd="\"$@\""
  find_containers | xargs -P 100 -n 1 -I % bash -c "run_in_dir % $cmd" _ {}
}
export -f run_cmd_in_container_dirs

is_installed() {
  command -v $1 &>/dev/null && echo 1 || { echo >&2 "[FAIL] Program '$1' required but not installed."; echo 0; }
}
export -f is_installed
