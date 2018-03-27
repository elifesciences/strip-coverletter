#!/bin/bash
# runs N instances in parallel

set -e

rm -rf ptests/

pollmem () {
    while true; do
        # memory available as a percentage
        #awk '/MemAvailable/{free=$2} /MemTotal/{total=$2} END{print (100 - (free*100)/total)}' /proc/meminfo

        # memory used as megabytes
        awk '/MemAvailable/{free=$2} /MemTotal/{total=$2} END{print ((total - free)/1024) " MB used"}' /proc/meminfo
        sleep 1
    done
}

pollmem &
pollmem_pid=$!

function finish {
    kill $pollmem_pid
}
trap finish EXIT


scl () {
    infile=$1
    outfile=$2
    echo "starting $infile"
    ./strip-coverletter-docker.sh ./tests/working-fixtures/$infile ptests/$outfile.pdf
    echo "done $infile"
}

# give 10 seconds to establish a baseline
sleep 10

scl 2654_2_merged_1399061544.pdf 1 &
scl 3007_1_merged_1398935138.pdf 2 &
scl 5707_0_merged_1404262610.pdf 3 &
scl 5781_2_merged_pdf_75858_nbs612.pdf 4 &
scl 6605_1_merged_1417429442.pdf 5 &
scl 7538_1_merged_1421145540.pdf 6 &
scl 9001_1_merged_pdf_112167_nk2yfl.pdf 7 &
scl 9257_1_merged_1424838570.pdf 8 &
scl 9943_0_merged_1423237234.pdf 9

echo "--- done ---"

# another 10 to restore baseline 
sleep 10

echo "done"
