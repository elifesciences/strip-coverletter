#!/bin/bash
set -e
wget --quiet https://github.com/torakiki/sejda/releases/download/v3.2.85/sejda-console-3.2.85-bin.zip
unzip -q sejda-console-3.2.85-bin.zip
ln -sf sejda-console-3.2.85 sejda-console
rm sejda-console-3.2.85-bin.zip
