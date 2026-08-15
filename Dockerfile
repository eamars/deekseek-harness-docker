FROM node:24-bookworm-slim

ARG DSH_VERSION=0.1.0-rc.6

ENV NODE_ENV=production \
    DSH_HOME=/var/lib/dsh \
    HOME=/home/dsh \
    npm_config_python=/usr/bin/python3

RUN apt-get update

RUN apt-get install --yes --no-install-recommends \
      bash \
      build-essential \
      ca-certificates \
      git \
      python3 \
      ripgrep \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 10001 dsh \
 && useradd --uid 10001 --gid 10001 --create-home dsh

# The Harness package includes native dependencies. Keep their reviewed
# install scripts enabled for this global npm install and show their output in
# the build log so native compilation failures remain diagnosable.
RUN npm install --global --no-audit --no-fund --foreground-scripts \
      --allow-scripts=@deepseek-ai/dsh-subprocess-local,koffi,node-pty,@google/genai,protobufjs \
      "@deepseek-ai/dsh@${DSH_VERSION}"

RUN mkdir --parents /var/lib/dsh /workspace /opt/dsh \
 && chown --recursive dsh:dsh /var/lib/dsh /workspace /opt/dsh /home/dsh

COPY --chown=dsh:dsh web.cordis.yml /opt/dsh/web.cordis.yml

USER dsh
WORKDIR /workspace

EXPOSE 3080

ENTRYPOINT ["dsh", "web", "--patch", "/opt/dsh/web.cordis.yml"]
