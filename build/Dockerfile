FROM ubuntu

MAINTAINER Luke Skibinski <l.skibinski@elifesciences.org>

# install some basics
RUN apt-get update
RUN apt-get install openjdk-8-jre-headless wget git unzip xpdf-utils -y --no-install-recommends

# clone project
RUN cd /opt && git clone https://github.com/elifesciences/strip-coverletter/
WORKDIR /opt/strip-coverletter

# install cajda
RUN wget --quiet https://github.com/torakiki/sejda/releases/download/v3.2.38/sejda-console-3.2.38-bin.zip
RUN unzip -q sejda-console-3.2.38-bin.zip && ln -s sejda-console-3.2.38 sejda
ENV PATH="/opt/strip-coverletter:/opt/strip-coverletter/sejda/bin:${PATH}"

RUN ls -lahR 

# confirm working
RUN sejda-console
RUN ./strip-coverletter.sh

#

RUN git checkout feat-downsample
