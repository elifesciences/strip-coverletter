#!/bin/bash
# downloads pdf test fixtures from bucket
# pdf files are pre-decap whose coverletters contain private information

set -e

rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install pip wheel --upgrade
pip install awscli

mkdir -p tests
cd tests
aws s3 sync s3://elife-test-fixtures/strip-coverletter .

deactivate
rm -rf venv
