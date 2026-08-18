FROM node:24-bookworm-slim

ARG DSH_VERSION=0.1.0-rc.7
ARG DSH_MARKET_VERSION=1.12.1
ARG PNPM_VERSION=10.34.5

ENV NODE_ENV=production \
    DSH_HOME=/var/lib/dsh \
    HOME=/home/dsh \
    npm_config_python=/usr/bin/python3 \
    DSH_MARKET_VERSION=${DSH_MARKET_VERSION}

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

# The DSH plugin manager delegates profile installs to pnpm. Pin the major
# version because pnpm 10's build-script approval behavior is part of the
# plugin install contract.
RUN npm install --global --no-audit --no-fund "pnpm@${PNPM_VERSION}"

RUN mkdir --parents /var/lib/dsh /workspace /opt/dsh \
 && chown --recursive dsh:dsh /var/lib/dsh /workspace /opt/dsh /home/dsh

COPY --chown=dsh:dsh web.cordis.yml /opt/dsh/web.cordis.yml
COPY --chown=dsh:dsh dsh-entrypoint.sh /opt/dsh/dsh-entrypoint.sh

USER dsh
WORKDIR /workspace

EXPOSE 3080

ENTRYPOINT ["bash", "/opt/dsh/dsh-entrypoint.sh"]
