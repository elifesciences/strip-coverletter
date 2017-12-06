FROM ubuntu:14.04

MAINTAINER Luke Skibinski <l.skibinski@elifesciences.org>

RUN apt-get install xpdf-utils openjdk-7-jdk git
RUN cd /opt/ && wget http://garr.dl.sourceforge.net/project/pdfsam/pdfsam/2.2.4/pdfsam-2.2.4-out.zip
RUN unzip pdfsam-2.2.4-out.zip -d pdfsam
RUN echo "#!/bin/bash\njava -jar /opt/pdfsam/pdfsam-2.2.4.jar" > /usr/bin/pdfsam-console && chmod +x /usr/bin/pdfsam-console
RUN cd /opt/ && git clone http://github.com/elifesciences/strip-coverletter
