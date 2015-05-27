export TMP_DIR="${TEST_DIR}/tmp"
export REPLAY_BIN=$(readlink -f "${TEST_DIR}/../docker-replay")
export ONBUILD_IMG_NAME="docker-replay-onbuild"
export TEST_IMG_NAME="docker-replay-tests"

setup() {
  rm -rf $TMP_DIR
  mkdir -p $TMP_DIR
}

docker_replay() {
  $REPLAY_BIN "${1}"
}

docker_build() {
  docker rmi $(docker images -q "${1}*") &>/dev/null
  docker build -t "${1}" . &>/dev/null
}
