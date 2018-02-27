#!/bin/bash
# runs strip-coverletter.sh against known pass and failure cases
# see download-test-fixtures.sh to populate

# short

set -e
#set -xv

function testdecap {
    expected_rc=$1
    pdf_dir="tests/$2"
    
    for pdffile in $pdf_dir/*.pdf; do
        set +e
        echo "testing $pdffile"
        ./strip-coverletter.sh "$pdffile" tmp.pdf &> /dev/null
        rc=$?
        set -e
        if [ $rc -ne "$expected_rc" ]; then
            echo "got return code '$rc', expected $expected_rc for fixture $pdffile"
        fi
        rm -f tmp.pdf
    done
}

if [ ! -d tests ]; then
    echo "test fixtures directory not found"
    echo "see ./download-test-fixtures.sh"
    exit 1
fi

testdecap 0 working-fixtures
testdecap 1 corrupt-fixtures
testdecap 2 no-cover-letter-fixtures

# should be working but are not. change this to 0 as we implement a fallback splitter
testdecap 2 should-be-working-fixtures
