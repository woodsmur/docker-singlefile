# docker build -t woodsmur/docker-singlefile .
# currently 10/jessie
FROM node:lts as build

WORKDIR /build
RUN apt update && apt install -y wget git
RUN git clone --recursive https://github.com/gildas-lormeau/SingleFile

# https://antonfisher.com/posts/2018/03/19/reducing-docker-image-size-of-a-node-js-application/
RUN cd SingleFile && npm install --production && cd cli && npm install --production && chmod +x single-file

# does not support root
FROM node:lts as run
RUN  apt-get update \
     # See https://crbug.com/795759
     && apt-get install -yq libgconf-2-4 \
     # Install latest chrome dev package, which installs the necessary libs to
     # make the bundled version of Chromium that Puppeteer installs work.
     && apt-get install -y wget --no-install-recommends \
     && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
     && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
     && apt-get update \
     && apt-get install -y google-chrome-unstable --no-install-recommends \
     && rm -rf /var/lib/apt/lists/*
WORKDIR /singlefile
COPY --from=build /build/ .

RUN groupadd -r appuser && useradd -r -u 1001 -g appuser appuser && chown -R appuser:appuser /singlefile/
RUN mkdir -p /home/appuser && chown -R appuser:appuser /home/appuser
USER appuser

# /singlefile/SingleFile/cli/single-file --browser-executable-path=/usr/bin/google-chrome-unstable [url]
CMD "/singlefile/cli/single-file"
