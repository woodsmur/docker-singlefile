FROM node:11-alpine

ENV CHROME_BIN="/usr/bin/chromium-browser" \
    NODE_ENV="production"

WORKDIR cd /home/pptruser

RUN set -x \
    && apk update && apk upgrade \
    && apk add --no-cache \
    dumb-init \
    udev \
    wget \
    git \
    ttf-freefont \
    chromium \
    && npm install puppeteer-core@1.10.0 --silent \
      \
      # Cleanup
      && apk del --no-cache make gcc g++ python binutils-gold gnupg libstdc++ \
      && rm -rf /usr/include \
      && rm -rf /var/cache/apk/* /root/.node-gyp /usr/share/man /tmp/* \
      # && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
      # && chown -R pptruser:pptruser /home/pptruser \
      # && chown -R pptruser:pptruser /node_modules \
      && git clone --recursive https://github.com/gildas-lormeau/SingleFile \
      && cd SingleFile && npm install --production && cd cli && npm install --production && chmod +x single-file \
      && echo

ENTRYPOINT ["dumb-init", "--"]

CMD /home/pptruser/SingleFile/cli/single-file --browser-executable-path=/usr/bin/chromium-browser

# # FROM node:8-slim
# # FROM node:8-alpine
# FROM zenika/alpine-chrome:with-puppeteer

# # It's a good idea to use dumb-init to help prevent zombie chrome processes.
# ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init

# WORKDIR /home/pptruser

# RUN chmod +x /usr/local/bin/dumb-init \
#     && apt-get update && apt-get install -yq libgconf-2-4 \
#     && apt-get update && apt-get install -y wget git --no-install-recommends \
#     && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
#     && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
#     && apt-get update \
#     && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
#       --no-install-recommends \
#     && rm -rf /var/lib/apt/lists/* \
#     && apt-get purge --auto-remove -y curl \
#     && rm -rf /src/*.deb \
#     # Install puppeteer so it's available in the container.
#     && cd / && npm i puppeteer \
#     # Add user so we don't need --no-sandbox.
#     && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
#     && mkdir -p /home/pptruser/Downloads \
#     && chown -R pptruser:pptruser /home/pptruser \
#     && chown -R pptruser:pptruser /node_modules \
#     && cd /home/pptruser && git clone --recursive https://github.com/gildas-lormeau/SingleFile \
#     && cd SingleFile && npm install --production && cd cli && npm install --production && chmod +x single-file

# # Run everything after as non-privileged user.
# USER pptruser

# ENTRYPOINT ["dumb-init", "--"]
# # CMD ["/SingleFile/cli/single-file", "--browser-executable-path", "/usr/bin/google-chrome-unstable"]
# CMD /home/pptruser/SingleFile/cli/single-file --browser-executable-path=/usr/bin/chromium-browser
