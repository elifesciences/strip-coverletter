#!/bin/bash
# runs strip-coverletter.sh against known pass and failure cases
# see download-test-fixtures.sh to populate

# short

set -e

test_fixture_dir=${1:-"tests"}

function testdecap {
    expected_rc=$1
    pdf_dir="$test_fixture_dir/$2" # /ext/cached-repositories/strip-coverletter-test-fixtures/working-fixtures
    
    for pdffile in "$pdf_dir"/*.pdf; do
        pdffile_bname=${pdffile##*/} # tests/working-fixtures/foo.pdf => foo.pdf
        set +e
        echo "testing $pdffile"
        ./strip-coverletter.sh "$pdffile" tmp.pdf &> /dev/null
        rc=$?
        set -e
        if [ "$rc" -eq "$expected_rc" ]; then
            # assertion succeeded. 
            # remove the dump file (written to same dir as output file), if it exists.
            rm -f "$pdffile_bname.dump.tar"
        else
            # assertion failed.
            echo "got return code '$rc', expected $expected_rc for fixture $pdffile"
        fi
        # whatever the case, remove the output file if it exists
        rm -f tmp.pdf
    done
}

if [ ! -d "$test_fixture_dir" ]; then
    echo "test fixture directory not found: $test_fixture_dir"
    echo "see ./download-test-fixtures.sh"
    exit 1
fi

testdecap 0 working-fixtures
testdecap 1 corrupt-fixtures
testdecap 2 no-cover-letter-fixtures

# should be working but are not. change this to 0 as we implement a fallback splitter
testdecap 2 should-be-working-fixtures
