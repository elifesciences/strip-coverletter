# Installation on Ubuntu

Tested on Ubuntu 12.04

The below worked for me:

    sudo su
    cd /opt/
    git clone https://github.com/elifesciences/strip-coverletter
    apt-get install xpdf-utils openjdk-7-jre-headless
    wget http://garr.dl.sourceforge.net/project/pdfsam/pdfsam/2.2.4/pdfsam-2.2.4-out.zip
    unzip pdfsam-2.2.4-out.zip -d pdfsam
    rm pdfsam-2.2.4-out.zip
    echo -e '#!/bin/bash\ncd /opt/pdfsam/bin/\nsh run-console.sh "$@"' > /usr/bin/pdfsam-console
    chmod +x /usr/bin/pdfsam-console


