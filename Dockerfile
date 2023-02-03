FROM ubuntu:20.04

# install some basics
RUN apt-get update
RUN apt-get install openjdk-8-jre-headless poppler-utils unzip wget -y --no-install-recommends

# created by docker if it doesn't exist.
WORKDIR /opt/strip-coverletter

# create a worker to run the script as.
RUN useradd worker --uid 1001 --shell /bin/bash --no-create-home
RUN chown worker .

# drop privileges
USER worker

# install sejda
COPY download-sejda.sh .
RUN ./download-sejda.sh

ENV PATH="/opt/strip-coverletter:/opt/strip-coverletter/sejda/bin:${PATH}"

COPY strip-coverletter.sh /opt/strip-coverletter/
ENTRYPOINT ["/opt/strip-coverletter/strip-coverletter.sh"]
CMD []
