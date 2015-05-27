# set -x

export TEST_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${TEST_DIR}/helper.bash"

T_ONBUILD_RUN_singleInstruction() {
  setup && cd $TMP_DIR

  cat <<-STR > Dockerfile
FROM busybox
ONBUILD RUN date > /tmp/built-at
STR
  docker_build $ONBUILD_IMG_NAME

  cat <<-STR > Dockerfile
FROM ${ONBUILD_IMG_NAME}
STR
  docker_build $TEST_IMG_NAME
  ORIGINAL_DATE=$(docker run --rm docker-replay-tests cat /tmp/built-at)

  docker_replay $TEST_IMG_NAME &> /dev/null
  NEW_DATE=$(docker run --rm docker-replay-tests cat /tmp/built-at)

  if [ "${ORIGINAL_DATE}" = "${NEW_DATE}" ]; then
    $T_fail "Replay did not execute the specified ONBUILD RUN instruction"
    return 1
  fi
}


T_ONBUILD_RUN_multipleInstructions() {
  setup && cd $TMP_DIR

  cat <<-STR > Dockerfile
FROM busybox
ONBUILD RUN date > /tmp/date-1
ONBUILD RUN echo -n 'prefix-' > /tmp/date-2 && date >> /tmp/date-2
STR
  docker_build $ONBUILD_IMG_NAME

  cat <<-STR > Dockerfile
FROM ${ONBUILD_IMG_NAME}
STR
  docker_build $TEST_IMG_NAME
  ORIGINAL_DATE_1=$(docker run --rm $TEST_IMG_NAME cat /tmp/date-1)
  ORIGINAL_DATE_2=$(docker run --rm $TEST_IMG_NAME cat /tmp/date-2)

  docker_replay $TEST_IMG_NAME &> /dev/null
  NEW_DATE_1=$(docker run --rm $TEST_IMG_NAME cat /tmp/date-1)
  NEW_DATE_2=$(docker run --rm $TEST_IMG_NAME cat /tmp/date-2)

  if [ "${ORIGINAL_DATE_1}" = "${NEW_DATE_1}" ]; then
    $T_fail "Replay did not execute the first specified ONBUILD RUN instruction"
    return 1
  fi

  if [ "${ORIGINAL_DATE_2}" = "${NEW_DATE_2}" ]; then
    $T_fail "Replay did not execute the last specified ONBUILD RUN instruction"
    return 1
  fi
}

T_ONBUILD_RUN_failure() {
  setup && cd $TMP_DIR

  cat <<-STR > Dockerfile
FROM busybox
ONBUILD RUN [ -f /tmp/a-file ] && exit 1 || touch /tmp/a-file
STR
  docker_build $ONBUILD_IMG_NAME

  cat <<-STR > Dockerfile
FROM ${ONBUILD_IMG_NAME}
STR
  docker_build $TEST_IMG_NAME

  if docker_replay $TEST_IMG_NAME &> /dev/null; then
    $T_fail 'Returned exit code = 0'
    return 1
  fi
}
