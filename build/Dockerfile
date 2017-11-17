FROM archimg/base:latest

MAINTAINER Luke Skibinski <l.skibinski@elifesciences.org>

# install some basics
RUN pacman -Sy 
RUN pacman -S jre9-openjdk-headless wget git unzip --noconfirm

# clone project
RUN cd /opt && git clone https://github.com/elifesciences/strip-coverletter/
WORKDIR /opt/strip-coverletter

# install cajda
RUN wget --quiet https://github.com/torakiki/sejda/releases/download/v3.2.38/sejda-console-3.2.38-bin.zip
RUN unzip -q sejda-console-3.2.38-bin.zip && ln -s sejda-console-3.2.38 sejda
RUN cd sejda/bin && ln -s sejda-console pdfsam-console
ENV PATH="/opt/strip-coverletter/sejda/bin:${PATH}"

# confirm is working
RUN pdfsam-console

#

RUN git checkout feat-downsample
