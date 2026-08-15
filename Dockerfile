FROM node:24-bookworm-slim

ARG DSH_VERSION=0.1.0-rc.6

ENV NODE_ENV=production \
    DSH_HOME=/var/lib/dsh \
    HOME=/home/dsh

RUN apt-get update \
 && apt-get install --yes --no-install-recommends \
      bash \
      ca-certificates \
      git \
      ripgrep \
 && rm -rf /var/lib/apt/lists/* \
 && groupadd --gid 10001 dsh \
 && useradd --uid 10001 --gid 10001 --create-home dsh \
 && npm install --global --no-audit --no-fund "@deepseek-ai/dsh@${DSH_VERSION}" \
 && mkdir --parents /var/lib/dsh /workspace /opt/dsh \
 && chown --recursive dsh:dsh /var/lib/dsh /workspace /opt/dsh /home/dsh

COPY --chown=dsh:dsh web.cordis.yml /opt/dsh/web.cordis.yml

USER dsh
WORKDIR /workspace

EXPOSE 3080

ENTRYPOINT ["dsh", "web", "--patch", "/opt/dsh/web.cordis.yml"]
