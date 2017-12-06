#!/bin/bash
set -e
mkdir -p bucket
cd bucket
echo "downloading"
aws s3 sync s3://elife-ejp-poa-delivery .
