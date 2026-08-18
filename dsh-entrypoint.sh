#!/usr/bin/env bash
set -Eeuo pipefail

profile_dir="${DSH_HOME}/profiles/web"
market_manifest="${profile_dir}/node_modules/dshmarket/package.json"

if [[ ! -f "${market_manifest}" ]]; then
  echo "Installing dsh-market ${DSH_MARKET_VERSION} into the web profile..."
  dsh plugin --profile web add --save-exact "dshmarket@${DSH_MARKET_VERSION}"
fi

if [[ ! -f "${market_manifest}" ]]; then
  echo "dsh-market was not installed into ${profile_dir}" >&2
  exit 1
fi

exec dsh web --patch /opt/dsh/web.cordis.yml "$@"
