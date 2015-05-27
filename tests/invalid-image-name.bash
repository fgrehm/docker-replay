export TEST_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source "${TEST_DIR}/helper.bash"

T_invalidImageGeneratesMeaningfullErrorMessage() {
  docker_replay WAT 2>&1 | grep -q "The 'WAT' image could not be found!" || \
    $T_fail 'Error message was not displayed'
}

T_invalidImageExitsWithError() {
  errored='1'
  docker_replay RLLY &>/dev/null || errored='0'

  [ "${errored}" -eq '0' ] || $T_fail 'Exit code is zero'
}
