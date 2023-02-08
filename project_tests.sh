#!/bin/bash
set -eu

# quick test with docker
./example-usage.sh

# more involved tests using strip-coverletter directly
#./download-test-fixtures.sh # see Jenkinsfile
test_fixture_dir="$1"
./test.sh "$test_fixture_dir"
