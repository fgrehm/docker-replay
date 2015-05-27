# Unfortunately we need to `cd` into the test tmp folder within tests and
# basht does not like that and things start to break when multiple files
# are run, we need to reach out on the basht repository and figure out what
# is the best way to handle that
default:
	@rm -rf tests/tmp
	@for test in tests/*; do [ "$${test}" = 'tmp/helper.bash' ] || { echo $$test && basht $$test; } done
