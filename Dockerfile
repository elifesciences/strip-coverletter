FROM ubuntu

MAINTAINER Luke Skibinski <l.skibinski@elifesciences.org>

# install some basics
RUN apt-get update
RUN apt-get install ghostscript openjdk-8-jre-headless wget git unzip xpdf-utils -y --no-install-recommends

# this will be needed to stop font replacement during squish
# echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
# apt-get install ttf-mscorefonts-installer

WORKDIR /opt/strip-coverletter

# install sejda
RUN wget --quiet https://github.com/torakiki/sejda/releases/download/v3.2.38/sejda-console-3.2.38-bin.zip
RUN unzip -q sejda-console-3.2.38-bin.zip && ln -s sejda-console-3.2.38 sejda
ENV PATH="/opt/strip-coverletter:/opt/strip-coverletter/sejda/bin:${PATH}"

COPY *.sh /opt/strip-coverletter/
ENTRYPOINT ["/opt/strip-coverletter/strip-coverletter.sh"]
CMD []
