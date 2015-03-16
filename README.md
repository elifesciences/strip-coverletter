# strip-coverletter.sh

This is a script that detects and removes the leading cover 
sheet from the special article PDF sent to peer reviewers
by EJP.

## installation

This script has two dependencies:

* pdftotext
* pdfsam

## pdftotext

Dumps the textual contents of a pdf file. 

Is part of the `xpdf-utils` package on Ubuntu and `xpdf` on Arch.

## pdfsam

Splits and merges pdf files. 

Is installable as `pdfsam` on Arch but is _not_ part of the official 
repositories on Ubuntu.

Installation instructions for Ubuntu can be found here:  
    http://www.sysads.co.uk/2014/08/install-pdfsam-2-2-4-on-ubuntu-14-04/
    
`pdfsam` is a Java application and comes with a gui but we only want the CLI
called `pdfsam-console`, so don't install any X dependencies if you can avoid it.
