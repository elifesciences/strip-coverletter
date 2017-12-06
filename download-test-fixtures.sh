#!/bin/bash
# downloads pdf test fixtures from bucket
# pdf files are pre-decap whose coverletters contain private information

set -e

mkdir -p tests
cd tests
aws s3 sync s3://elife-test-fixtures/strip-coverletter .
