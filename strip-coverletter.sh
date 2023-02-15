#!/bin/bash

# everything must succeed
set -e

# always start in the script's dir
cd "$(dirname "$0")"

# use the local sejda-console rather than rely on one being installed
PATH="sejda-console/bin:$PATH" 

errcho() { echo "$@" 1>&2; } # write to stderr

infile=$1
outfile=$2

if [ ! -f /usr/bin/pdftotext ]; then
    errcho "'pdftotext' not found."
    errcho "For Ubuntu, install 'xpdf-utils'"
    errcho "For Arch, install 'xpdf'"
    exit 1
fi

if ! type -P sejda-console > /dev/null; then
    errcho "installing sejda-console (locally) ... "
    ./download-sejda.sh
    errcho "- sejda installed to ./sejda-console"
fi

if [[ ! $infile ]] || [[ ! -f $infile ]] || [[ ! $outfile ]]; then
    errcho "Usage: ./strip-coverletter.sh <in-pdf> <out-pdf>"
    errcho "Input: ./strip-coverletter.sh $infile $outfile"
    exit 1;
fi

outdir=$(dirname $(readlink -m $outfile))

# fail early if we can't write to the output directory
touch $outdir/.write-test || {
    echo "cannot write to $outdir, failing"
    exit 1;
}
rm "$outdir/.write-test"

pdf=$(basename $infile);
tempdir=/tmp # TODO: make this a third optional parameter to script
explodeddir=$tempdir/$pdf-exploded

mkdir -p $explodeddir $outdir # create output dir if it doesn't exist

function log {
    msg="$(date -u --rfc-3339='ns'): $1"
    errcho $msg
}

log "exploding pdf to $explodeddir"

# called when this script is done
# when last command fails a dump file is written using the given output filename
function finish {
    retcode=$?
    if [[ $retcode > 0 ]]; then
        # capture the input for debugging later
        cp $infile "$explodeddir/$pdf.orig"

        # move explodeddir out of temp for debugging
        dumpfile="$outdir/$pdf.dump.tar"
        tar -cf $dumpfile $explodeddir
        errcho "wrote $dumpfile"
    fi
    #exit $1 # don't do this, retcode is preserved.
}
trap finish EXIT


log "calling pdfinfo, looking for page count ..."
total_pages="`pdfinfo $infile | grep 'Pages:' | grep -Eo '[0-9]+'`"
output_pdf=$(readlink -m "$outfile")

log "splitting pdf into component pages ..."
sejda-console simplesplit --files $infile --output $explodeddir --existingOutput overwrite --predefinedPages all

log 'looking for non-cover pages...'
ncp=-1 # non-cover page
for i in {2..7}; do # first page is guaranteed to be part of the cover letter...
    log "- converting page $i to text..."
    for j in {1..9}; do
        # looks for lines starting with '1' followed by 0 or 1 chars and then ends
        # examples with more whitespace then ends:
        # bucket-pdf/6117_1_merged_pdf_82383_nd6nzc.pdf
        match="`pdftotext $explodeddir/$i\_$pdf /dev/stdout | grep -Ex "^1.{0,1}$" | head -n 1`"
        if [ "$match" = "" ]; then
            log "- page $i is a cover letter"
            break
        else
            #log "match found for line starting with '$j'"
            ncp=$i
        fi
    done
    if [ "$ncp" -gt -1 ]; then
        log "- article begins at page $ncp!"
        break
    fi
done

if [ ! "$ncp" -gt -1 ]; then
    log "failed to detect end of cover letter!"
    # if pdftotext can't find any text, for example if text has been converted 
    # to paths, then we'll get here and exit.

    # TODO: investigate possibility of splitting by bookmarks
    # some but not all of these files have bookmarks like 'Cover Page', 'Article File'
    # this command on this file creates two files, the first is the covering letter, the second the article
    # sejda-console splitbybookmarks -f bucket-pdf/7142_1_merged_pdf_101005_nhp9w3.pdf -l 1 -o tmp/ -e "Article File"

    exit 2
fi

log "writing pdf ..."
sejda-console extractpages --files $infile --output $output_pdf --existingOutput overwrite --pageSelection "$ncp-" 2>&1
log "- wrote $output_pdf"

log 'removing temporary files+dir ...'
# removes log file. if log file detected in FINISH handler (above), it assumes script failed
rm -f $explodeddir/*
rmdir "$explodeddir"
log "- all done"
