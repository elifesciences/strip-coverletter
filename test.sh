#!/bin/bash
# runs strip-coverletter.sh against known pass and failure cases
# see download-test-fixtures.sh to populate

# short

function testdecap {
    expected_rc=$1
    pdf_dir=$2
    
    for pdffile in `ls $pdf_dir/*.pdf`; do
        rc=$(./strip-coverletter $pdffile tmp.pdf)
        if [ $rc != $expected_rc ]; then
            echo "got $rc testing fixture $pdffile, expected $expected_rc"
        fi
        rm -f tmp.pdf
    done
}

testdecap 0 working-fixtures
testdecap 1 corrupt_fixtures
testdecap 2 no-cover-letter-fixtures
testdecap 3 should-be-working-fixtures
