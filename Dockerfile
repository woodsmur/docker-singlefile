FROM node:8-slim

# It's a good idea to use dumb-init to help prevent zombie chrome processes.
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init

RUN chmod +x /usr/local/bin/dumb-init \
    && apt-get update && apt-get install -yq libgconf-2-4 \
    && apt-get update && apt-get install -y wget git --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get purge --auto-remove -y curl \
    && rm -rf /src/*.deb \
    # Install puppeteer so it's available in the container.
    && npm i puppeteer \
    # Add user so we don't need --no-sandbox.
    && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /node_modules

# Run everything after as non-privileged user.
USER pptruser

# install singlefile
WORKDIR /home/pptruser
RUN git clone --recursive https://github.com/gildas-lormeau/SingleFile \
    # https://antonfisher.com/posts/2018/03/19/reducing-docker-image-size-of-a-node-js-application/
    && cd SingleFile && npm install --production && cd cli && npm install --production && chmod +x single-file

ENTRYPOINT ["dumb-init", "--"]
# CMD ["/SingleFile/cli/single-file", "--browser-executable-path", "/usr/bin/google-chrome-unstable"]
CMD /home/pptruser/SingleFile/cli/single-file --browser-executable-path=/usr/bin/google-chrome-unstable

# CMD ["google-chrome-unstable"]


# RUN groupadd -r appuser && useradd -r -u 1001 -g appuser appuser && chown -R appuser:appuser /singlefile/
# RUN mkdir -p /home/appuser && chown -R appuser:appuser /home/appuser
# USER appuser

# TODO: cmd here 
# CMD  --browser-executable-path=/usr/bin/google-chrome-unstable [url]
# CMD "/singlefile/cli/single-file"