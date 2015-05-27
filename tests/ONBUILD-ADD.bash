# set -x

export TEST_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${TEST_DIR}/helper.bash"

T_ONBUILD_ADD_singleFile() {
  setup && cd $TMP_DIR

  cat <<-STR > Dockerfile
FROM busybox
ONBUILD ADD a-file /tmp/a-file
STR
  docker_build $ONBUILD_IMG_NAME

  echo 'original' > a-file
  cat <<-STR > Dockerfile
FROM ${ONBUILD_IMG_NAME}
STR
  docker_build $TEST_IMG_NAME
  ORIGINAL_CONTENT=$(docker run --rm docker-replay-tests cat /tmp/a-file)

  echo 'changed' > a-file
  docker_replay $TEST_IMG_NAME &> /dev/null
  NEW_CONTENT=$(docker run --rm docker-replay-tests cat /tmp/a-file)

  if [ "${ORIGINAL_CONTENT}" = "${NEW_CONTENT}" ]; then
    $T_fail "Replay did not execute the specified ONBUILD ADD instruction"
    return 1
  fi
}


T_ONBUILD_ADD_directory() {
  setup && cd $TMP_DIR

  cat <<-STR > Dockerfile
FROM busybox
ONBUILD ADD a-dir/ /tmp/a-dir
STR
  docker_build $ONBUILD_IMG_NAME

  mkdir a-dir
  echo 'original' > a-dir/file
  cat <<-STR > Dockerfile
FROM ${ONBUILD_IMG_NAME}
STR
  docker_build $TEST_IMG_NAME
  ORIGINAL_CONTENT=$(docker run --rm docker-replay-tests cat /tmp/a-dir/file)

  echo 'changed' > a-dir/file
  docker_replay $TEST_IMG_NAME &> /dev/null
  NEW_CONTENT=$(docker run --rm docker-replay-tests cat /tmp/a-dir/file)

  if [ "${ORIGINAL_CONTENT}" = "${NEW_CONTENT}" ]; then
    $T_fail "Replay did not execute the specified ONBUILD ADD instruction"
    return 1
  fi
}

T_ONBUILD_ADD_failure() {
  setup && cd $TMP_DIR

  cat <<-STR > Dockerfile
FROM busybox
ONBUILD ADD file /tmp/file
STR
  docker_build $ONBUILD_IMG_NAME

  touch file
  cat <<-STR > Dockerfile
FROM ${ONBUILD_IMG_NAME}
STR
  docker_build $TEST_IMG_NAME

  rm file
  if docker_replay $TEST_IMG_NAME &> /dev/null; then
    $T_fail 'Returned exit code = 0'
    return 1
  fi
}
