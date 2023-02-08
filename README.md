# strip-coverletter.sh

This script detects and removes the leading cover sheet from the PDF sent to peer reviewers by EJP.

## Dependencies

* java 1.8
* sejda-console
* pdftotext

Optional:

* Docker

## Installation

`java 1.8` and `pdftotext` are typically all available from your distribution's package manager.

`sejda-console` can be installed with the `./download-sejda.sh` script.

## Usage

`./strip-coverletter.sh <in pdf> <out pdf>`

For example:

`./strip-coverletter.sh dummy.pdf decap.pdf`

## Testing

For those with permission, the script `./download-test-fixtures.sh` will 
download a selection of actual pdf files that the `./test.sh` script will run
through.

The entire collection of coverletters can also be downloaded to run the 
strip-coverletter script against with `./download-pdf.sh`. This is a very large
download! Once downloaded, or partially downloaded, use the `./unzip-merged.sh`
script to extract the coverletters from the zip files and then `./test-all.sh` 
to run the test script against all of them. Failures have their log files 
preserved and successful decaps are not tested again until their result is 
deleted.
