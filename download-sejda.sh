#!/bin/bash
set -e
wget --quiet https://github.com/torakiki/sejda/releases/download/v3.2.38/sejda-console-3.2.38-bin.zip
unzip -q sejda-console-3.2.38-bin.zip 
ln -s sejda-console-3.2.38 sejda-console
rm sejda-console-3.2.38-bin.zip
