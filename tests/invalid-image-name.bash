T_invalidImageGeneratesMeaningfullErrorMessage() {
  ./docker-replay WAT 2>&1 | grep -q "The 'WAT' image could not be found!" || \
    $T_fail 'Error message was not displayed'
}

T_invalidImageExitsWithError() {
  errored='1'
  ./docker-replay RLLY &>/dev/null || errored='0'

  [ "${errored}" -eq '0' ] || $T_fail 'Exit code is zero'
}
