#!/bin/bash
set -e

# quick test with docker
./example-usage.sh

# more involved tests using strip-coverletter directly
./download-test-fixtures.sh
./test.sh
